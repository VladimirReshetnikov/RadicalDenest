#!/usr/bin/env python3
"""Independent checks for the radical-denesting source review.

This script DOES NOT execute or emulate the supplied Wolfram Language package.
It checks algebraic identities, polynomial computations, and elementary counting
arguments used in the article. Requires SymPy and mpmath. Run from any directory;
results are written beside this script. A failed check raises AssertionError.
"""
from __future__ import annotations
import hashlib
import json
import math
import platform
from pathlib import Path
from typing import Any
import sympy as sp
import mpmath as mp

HERE = Path(__file__).resolve().parent
X = sp.Symbol('X')
checks: list[dict[str, Any]] = []

def record(name: str, passed: bool, detail: Any, kind: str = 'exact') -> None:
    if not passed:
        raise AssertionError(f'{name}: {detail}')
    checks.append({'name': name, 'kind': kind, 'passed': True, 'detail': str(detail)})

def zero(expr: sp.Expr) -> bool:
    return sp.simplify(sp.expand(expr)) == 0

def gcd_over_coefficients(p: sp.Expr, q: sp.Expr) -> sp.Expr:
    return sp.gcd(sp.Poly(p, X, extension=True), sp.Poly(q, X, extension=True)).as_expr()

# A direct success: a smaller equation over Q(sqrt(2)).
a = 1 + sp.sqrt(2)
R = 3 + 2*sp.sqrt(2)
p = sp.minpoly(a, X)
g = gcd_over_coefficients(p, X**2 - R)
record('direct square identity', zero(a*a - R), a*a)
record('direct minimal polynomial', p == X**2 - 2*X - 1, p)
record('direct polynomial gcd', zero(g - (X-a)), g)

# A case for which a rational multiplier exposes a linear factor.
R = 5 + 2*sp.sqrt(6)
beta = sp.sqrt(2) + sp.sqrt(3)
p1 = sp.minpoly(beta, X)
g1 = gcd_over_coefficients(p1, X**2 - R)
a2 = 2 + sp.sqrt(6)
p2 = sp.minpoly(a2, X)
g2 = gcd_over_coefficients(p2, X**2 - 2*R)
record('multiplier example square', zero(beta**2-R), beta)
record('unmultiplied degree four', p1 == X**4-10*X**2+1, p1)
record('unmultiplied gcd degree two', zero(g1-(X**2-R)), g1)
record('multiplier two square', zero(a2**2-2*R), a2)
record('multiplied minimal polynomial', p2 == X**2-4*X-2, p2)
record('multiplied gcd linear', zero(g2-(X-a2)), g2)
record('multiplier recovery', zero(a2/sp.sqrt(2)-beta), a2/sp.sqrt(2))
record('unmultiplied discriminant', sp.discriminant(p1, X) == 147456,
       sp.factorint(sp.discriminant(p1, X)))

# Branch-loss counterexamples, with original branch characterized exactly.
negative = -(1+sp.sqrt(2))
positive = 1+sp.sqrt(2)
record('negative target and reconstructed root have equal squares',
       zero(negative**2-positive**2), negative**2)
record('negative target and reconstructed root are different',
       zero(positive-negative-2*(1+sp.sqrt(2))), positive-negative)

u = 1+sp.I*sp.sqrt(2)
v = 1+sp.I*sp.sqrt(3)
beta = sp.expand(u*v)
R = sp.expand((-1+2*sp.I*sp.sqrt(2))*(-2+2*sp.I*sp.sqrt(3)))
gamma = -beta  # Re(gamma)>0, so gamma is the principal square root of R.
record('first principal square-root factor', zero(u**2-(-1+2*sp.I*sp.sqrt(2))), u)
record('second principal square-root factor', zero(v**2-(-2+2*sp.I*sp.sqrt(3))), v)
record('complex product square', zero(beta**2-R), R)
record('complex branch negative real part', sp.re(beta).is_negative is True, sp.re(beta))
record('complex reconstructed branch positive real part', sp.re(gamma).is_positive is True, sp.re(gamma))
pc = sp.minpoly(gamma, X)
gc = gcd_over_coefficients(pc, X**2-R)
record('complex branch minimal polynomial', pc == X**4+4*X**3+4*X**2+48*X+144, pc)
record('complex branch gcd', zero(gc-(X-gamma)), gc)
record('complex branch wrong-target separation', zero(gamma+beta) and not zero(gamma-beta), gamma-beta)

# Invalid formal transformations: these are checks of rules, not WL traces.
record('nested-power counterexample', sp.sqrt((-2)**2) != -2, 'sqrt((-2)^2)=2 != -2')
x = sp.Integer(-2)
record('factored-root counterexample', sp.sqrt(x+x*x) != sp.sqrt(x)*sp.sqrt(1+x),
       f'{sp.sqrt(x+x*x)} != {sp.sqrt(x)*sp.sqrt(1+x)}')

# Denominator rationalization by the polynomial quotient identity.
for d in [1+sp.sqrt(2), 1+sp.I, sp.Rational(2,3), 2+sp.sqrt(3),
          sp.sqrt(2)+sp.sqrt(3)]:
    pd = sp.minpoly(d, X)
    q, rem = sp.div(sp.Poly(pd, X, extension=d),
                    sp.Poly(X-d, X, extension=d))
    inv = -q.as_expr().subs(X, 0)/pd.subs(X, 0)
    record(f'rationalizer remainder for {d}', rem.is_zero, rem.as_expr())
    record(f'rationalizer inverse for {d}', zero(d*inv-1), inv)

# Prime support is not just field ramification: a generator can add an index prime.
record('generator discriminant example',
       sp.discriminant(sp.minpoly(3*sp.sqrt(2), X), X) == 72, 'disc(X^2-18)=72=8*3^2')
record('degree gcd does not determine product degree',
       sp.degree(sp.minpoly(sp.sqrt(2)*sp.real_root(3,3), X), X) == 6,
       sp.minpoly(sp.sqrt(2)*sp.real_root(3,3), X))

# This lambda is the meaning of the erroneous Slot[1] comparator, not an emulator.
bad = lambda first, second: first[0] <= first[1]
record('comparator ignores second pair',
       bad((2,1),(3,1)) == bad((2,1),(101,1)) == False,
       'both comparisons are 2 <= 1, hence False', 'source-semantics model')
record('comparator does not order the primes',
       bad((2,1),(3,1)) == bad((3,1),(2,1)) == False,
       'False in both directions', 'source-semantics model')

counts = []
for r in [2,3,4,5,6,10,100]:
    # Integer calculation avoids floating logarithm ambiguity at exact powers.
    t = 0
    while r**t < 1000:
        t += 1
    t = max(5, t)
    count = r**t-1
    counts.append({'r': r, 'selected_primes_assuming_available': t,
                   'divisor_candidates_excluding_one': count})
    record(f'candidate count r={r}', count >= 1000,
           f't={t}; r^t-1={count}', 'exact counting')

# Numerical sanity checks of the proved root-of-unity recovery identity.
mp.mp.dps = 90
numerical_count = 0
max_error = mp.mpf('0')
for r in range(2,9):
    for m in [mp.mpc(2), mp.mpc(-3), mp.mpc(1,1)]:
        beta_mp = mp.mpc(-2,3)
        alpha_mp = mp.power(m*beta_mp**r, mp.mpf(1)/r)
        mu_mp = mp.power(m, mp.mpf(1)/r)
        values = [alpha_mp/mu_mp*mp.exp(2j*mp.pi*k/r) for k in range(r)]
        err = min(abs(w-beta_mp) for w in values)
        max_error = max(max_error, err)
        numerical_count += 1
record('root-of-unity branch-recovery sanity checks', max_error < mp.mpf('1e-75'),
       f'{numerical_count} cases; maximum nearest-candidate error {mp.nstr(max_error,8)}',
       'high-precision numerical sanity check')

source = HERE/'original.wl'
report = {
    'scope': 'Independent algebra and source-rule checks; no Wolfram package execution',
    'python': platform.python_version(), 'sympy': sp.__version__, 'mpmath': mp.__version__,
    'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest() if source.exists() else None,
    'checks_passed': len(checks), 'checks': checks, 'candidate_counts': counts,
    'wolfram_kernel_executed': False,
}
(HERE/'test_results.json').write_text(json.dumps(report, indent=2)+'\n', encoding='utf-8')
print(f'{len(checks)} independent checks passed. Wolfram package execution: NOT PERFORMED.')
print(json.dumps(counts, indent=2))
