#!/usr/bin/env python3
"""Exact checks accompanying Radical Denesting: A Unified Research Guide.

Requires Python 3.10+ and SymPy 1.14.0 (other versions may also work).
Run: python verify.py

Polynomial reductions prove the algebraic identities. Sign assertions are
checked separately where an even root is involved; numerical agreement is
never used as the proof. CAS output samples are observations, not claims of
completeness. This script does not implement general radical denesting.
"""
from __future__ import annotations
import platform
import sympy as sp

x, u, v, t, s, q = sp.symbols('x u v t s q')
checks: list[str] = []

def check(name: str, condition: object) -> None:
    if condition is not True and condition != sp.true:
        raise AssertionError(f'{name}: {condition!r}')
    checks.append(name)
    print(f'PASS  {name}')

def zero(name: str, expression: sp.Expr) -> None:
    check(name, sp.expand(expression) == 0)

def remainder_zero(name: str, expression: sp.Expr,
                   relations: list[sp.Expr], variables: tuple[sp.Symbol, ...]) -> None:
    basis = sp.groebner(relations, *variables, domain=sp.QQ)
    check(name, basis.reduce(sp.expand(expression))[1] == 0)

def rational_cuberoot(value: sp.Rational) -> sp.Rational | None:
    """Return the exact rational cube root, or None. No integer factoring."""
    value = sp.Rational(value)
    num, den = value.as_numer_denom()
    rn, en = sp.integer_nthroot(abs(int(num)), 3)
    rd, ed = sp.integer_nthroot(int(den), 3)
    return sp.Rational((-rn if num < 0 else rn), rd) if en and ed else None

def denest_cubic_in_quadratic(a: sp.Rational, b: sp.Rational,
                              p: sp.Rational) -> tuple[sp.Rational, sp.Rational] | None:
    """Decide cbrt(a+b*sqrt(p))=A+B*sqrt(p) for rational a,b,p.

    This deliberately enforces the nondegenerate domain of the report's
    theorem: p>0 nonsquare, b!=0. It is not a general cubic denester.
    """
    a, b, p = map(sp.Rational, (a, b, p))
    if p <= 0 or b == 0 or sp.sqrt(p).is_Rational:
        raise ValueError('Require p>0 nonsquare and b!=0.')
    norm = a*a - b*b*p
    tr_norm = rational_cuberoot(norm)
    if tr_norm is None:
        return None
    roots = sp.polys.polytools.ground_roots(x**3 - 3*tr_norm*x - 2*a, x)
    for root in roots:
        A = root/2
        B = b/(root*root-tr_norm)
        if sp.expand((A+B*sp.sqrt(p))**3-a-b*sp.sqrt(p)) == 0:
            return sp.Rational(A), sp.Rational(B)
    return None

print('Python:', platform.python_version())
print('SymPy:', sp.__version__)
print('All arithmetic below is exact.\n')

# Basic square-root examples: candidates are manifestly positive.
zero('direct example (sqrt(2)+sqrt(3))^2',
     (sp.sqrt(2)+sp.sqrt(3))**2 - (5+2*sp.sqrt(6)))
zero('indirect example [2^(1/4)*(1+sqrt(2))]^2',
     (2**sp.Rational(1,4)*(1+sp.sqrt(2)))**2 - (4+3*sp.sqrt(2)))
# Correct fixture for sqrt(2+sqrt(2)): D=2, -rD=-4; neither rational square.
check('sqrt(2+sqrt(2)): direct norm not a rational square',
      not sp.sqrt(2).is_Rational)
check('sqrt(2+sqrt(2)): indirect norm negative', -sp.Integer(2)*2 < 0)

# Ramanujan cubic-over-cubic identity.
remainder_zero('Ramanujan cubic: (1-t+t^2)^3=9(t-1)',
               (1-t+t*t)**3 - 9*(t-1), [t**3-2], (t,))
# 1-t+t^2=(t-1/2)^2+3/4 >0, and t=cbrt(2)>1.
zero('Ramanujan cubic: positive quadratic decomposition',
     1-t+t*t - ((t-sp.Rational(1,2))**2+sp.Rational(3,4)))

# Square roots of sums/differences of cube roots.
# u=cbrt(2), v=cbrt(7). Candidate=(u*v^2-u^2*v-1)/3.
remainder_zero('sqrt(cbrt(28)-3): square identity',
               (u*v*v-u*u*v-1)**2 - 9*(u*u*v-3),
               [u**3-2, v**3-7], (u, v))
# A lower bound for cbrt(98)-cbrt(28)-1, using cbrt(98)>9/2,
# cbrt(28)<31/10. Both comparisons follow by cubing positive rationals.
check('sqrt(cbrt(28)-3): candidate sign by rational bounds',
      sp.Rational(9,2)**3 < 98 and sp.Rational(31,10)**3 > 28
      and sp.Rational(9,2)-sp.Rational(31,10)-1 > 0)

# Here u=cbrt(2), v=cbrt(5); cbrt(20)=u^2*v.
remainder_zero('sqrt(cbrt(5)-cbrt(4)): square identity',
               (u+u*u*v-v*v)**2 - 9*(v-u*u),
               [u**3-2, v**3-5], (u, v))
check('sqrt(cbrt(5)-cbrt(4)): candidate positive by rational bounds',
      sp.Rational(5,4)**3 < 2 and sp.Rational(27,10)**3 < 20
      and sp.Rational(3)**3 > 25
      and sp.Rational(5,4)+sp.Rational(27,10)-3 > 0)

# Honsbeek's quartic condition: the algebraic certificate behind the formula.
zero('Honsbeek quartic identity',
     (-s*s/2+s*u+u*u)**2-(u**3-s**3)*(1+u)
     -(s**4+4*s**3+8*s*u**3-4*u**3)/4)
check('Honsbeek (-4,5) ratio has rational quartic root 1',
      (s**4+4*s**3+8*q*s-4*q).subs({q:sp.Rational(-5,4),s:1}) == 0)
check('Honsbeek swapped (5,-4) ratio has rational quartic root -2',
      (s**4+4*s**3+8*q*s-4*q).subs({q:sp.Rational(-4,5),s:-2}) == 0)

# Fourth-root identity, t=5^(1/4). All denominators and candidates positive:
# 1<t<3/2, since 1<5<(3/2)^4.
remainder_zero('Ramanujan fourth-root identity: cross multiplication',
               (t+1)**4*(3-2*t)-(t-1)**4*(3+2*t), [t**4-5], (t,))
remainder_zero('Ramanujan fourth-root identity: rationalized form',
               2*(t+1)-(3+t+t*t+t**3)*(t-1), [t**4-5], (t,))
check('Ramanujan fourth-root identity: denominator positive',
      1 < 5 < sp.Rational(3,2)**4)

# Sixth-root identity with u=cbrt(5/3), v=cbrt(2/3), so cbrt(20)=3*u*v^2.
remainder_zero('Ramanujan sixth-root identity',
               (u-v)**6-(21*u*v*v-19),
               [u**3-sp.Rational(5,3), v**3-sp.Rational(2,3)], (u, v))
check('Ramanujan sixth-root identity: positive candidate',
      sp.Rational(5,3)>sp.Rational(2,3)>0)

# Fifth-root real-branch example.
zero('real fifth root of 41-29*sqrt(2)',
     (1-sp.sqrt(2))**5-(41-29*sp.sqrt(2)))
check('real fifth-root candidate is negative', sp.sqrt(2)>1)

# Restricted cubic-in-quadratic criterion and its certificate.
zero('trace-norm certificate polynomial',
     (x**3-3*t*x)**2-4*t**3-(x*x-t)**2*(x*x-4*t))
check('restricted cubic denesting 7+5*sqrt(2)',
      denest_cubic_in_quadratic(7,5,2) == (1,1))
check('restricted cubic denesting 85+62*sqrt(7)',
      denest_cubic_in_quadratic(85,62,7) == (1,2))
check('cube norm alone is insufficient (1+sqrt(2))',
      rational_cuberoot(sp.Rational(-1)) == -1
      and denest_cubic_in_quadratic(1,1,2) is None)

# Same minimal polynomial is not a root-selector certificate.
check('minimal polynomial of sqrt(2)+sqrt(3)',
      sp.minpoly(sp.sqrt(2)+sp.sqrt(3), x) == x**4-10*x*x+1)
check('different conjugate has same minimal polynomial',
      sp.minpoly(sp.sqrt(3)-sp.sqrt(2), x) == x**4-10*x*x+1)

print('\nObserved sqrtdenest outputs (not completeness claims):')
for expression in [sp.sqrt(5+2*sp.sqrt(6)), sp.sqrt(4+3*sp.sqrt(2)),
                   sp.sqrt(2+sp.sqrt(2)),
                   sp.sqrt(16-2*sp.sqrt(29)+2*sp.sqrt(55-10*sp.sqrt(29)))]:
    print(' input :', expression)
    print(' output:', sp.sqrtdenest(expression))
print(f'\n{len(checks)} exact checks passed.')
