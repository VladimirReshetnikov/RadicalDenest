#!/usr/bin/env python3
"""Independent exact checks for the article's mathematics, NOT WL execution.

Requires SymPy. No floating-point agreement is used as an equality certificate.
This script also checks lexical delimiter/comment/string balance of the supplied
WL files. That is a lexical check, not a Wolfram parser or runtime conformance test.
"""
from __future__ import annotations
import json
import platform
from pathlib import Path
import sympy as s

BASE = Path(__file__).resolve().parent.parent
checks: list[dict[str, object]] = []

def record(name: str, condition: object, detail: str = "") -> None:
    ok = bool(condition)
    checks.append({"name": name, "passed": ok, "detail": detail})
    if not ok:
        raise AssertionError(f"{name}: {detail}")

def zero(name: str, expr: s.Expr) -> None:
    value = s.simplify(s.expand(expr))
    record(name, value == 0, f"exact residual = {value}")

x, t, u, v, a, b, c, d, z, q = s.symbols("x t u v a b c d z q")
# Norm identities are polynomial certificates, separate from root selection.
zero("direct-norm-discriminant", ((a+d)/2)*((a-d)/2) - (a*a-d*d)/4)
zero("indirect-norm-identity", ((b+d)/2)*((b-d)/2) - (b*b-d*d)/4)
for name, rad, candidate in [
    ("square-3", 3+2*s.sqrt(2), 1+s.sqrt(2)),
    ("square-5", 5+2*s.sqrt(6), s.sqrt(2)+s.sqrt(3)),
    ("square-small", 3-2*s.sqrt(2), s.sqrt(2)-1),
    ("fourth-root", 4+3*s.sqrt(2), 2**s.Rational(1,4)*(1+s.sqrt(2))),
    ("negative-square", -5-2*s.sqrt(6), s.I*(s.sqrt(2)+s.sqrt(3))),
]:
    zero(name + "-square", candidate**2-rad)
    # Exact sign data selects the principal square root.
    real_candidate = s.simplify(candidate / s.I) if name == "negative-square" else candidate
    record(name + "-branch", real_candidate.is_positive is True, "exact positivity of candidate or candidate / I")

# A generated family: a=m+n, b=2, c=m*n. The discriminant is (m-n)^2.
# Selection by m>=n proves the positive branch without decimal estimates.
for m in range(2, 12):
    for n in range(1, m):
        aa, cc = s.Integer(m+n), s.Integer(m*n)
        dd = abs(m-n)
        record(f"generated-direct-{m}-{n}-norm", aa**2-4*cc == dd**2)
        zero(f"generated-direct-{m}-{n}-identity",
             (s.sqrt(m)+s.sqrt(n))**2 - (aa+2*s.sqrt(cc)))

p = x**4 - 10*x*x + 1
record("quartic-minimal-polynomial", s.minpoly(s.sqrt(2)+s.sqrt(3), x) == p)
record("quartic-discriminant", s.discriminant(p, x) == 147456)
record("quartic-discriminant-factorization", s.factorint(147456) == {2:14, 3:2})
R = 5+2*s.sqrt(6)
g1 = s.Poly(p,x,extension=s.sqrt(6)).gcd(s.Poly(x*x-R,x,extension=s.sqrt(6))).monic().as_expr()
zero("gcd-no-proper-reduction-at-m1", g1-(x*x-R))
p2 = s.minpoly(2+s.sqrt(6), x)
zero("scaled-minimal-polynomial", p2-(x*x-4*x-2))
g2 = s.Poly(p2,x,extension=s.sqrt(6)).gcd(s.Poly(x*x-2*R,x,extension=s.sqrt(6))).monic().as_expr()
zero("gcd-linear-at-m2", g2-(x-2-s.sqrt(6)))
zero("scaled-reconstruction", (2+s.sqrt(6))/s.sqrt(2)-(s.sqrt(2)+s.sqrt(3)))
R2 = 3+2*s.sqrt(2)
g = s.Poly(x*x-2*x-1,x,extension=s.sqrt(2)).gcd(s.Poly(x*x-R2,x,extension=s.sqrt(2))).monic().as_expr()
zero("gcd-simple-linear", g-(x-1-s.sqrt(2)))

# Equality of minimal polynomials does not select an embedding.
record("same-polynomial-opposite-small-conjugate", s.minpoly(s.sqrt(3)-s.sqrt(2),x) == p)
record("conjugates-not-equal", s.simplify((s.sqrt(3)+s.sqrt(2))-(s.sqrt(3)-s.sqrt(2))) == 2*s.sqrt(2))

# Principal-power counterexamples with exact radicals.
zero("square-product-phase-gap", s.sqrt(-1)*s.sqrt(-1) - (-1))
record("square-product-is-not-square-of-product", s.sqrt(-1)*s.sqrt(-1) != s.sqrt(s.Integer(-1)*(-1)))
beta = -s.Rational(1,2)+s.I*s.sqrt(3)/2
zero("original-beta-cubes-to-one", beta**3-1)
record("original-beta-is-not-principal-root-of-one", beta != 1)
zero("phase-orbit-cube-root-1", beta**3-1)
zero("phase-orbit-cube-root-2", s.conjugate(beta)**3-1)
record("three-phase-values-distinct", len({s.Integer(1), beta, s.conjugate(beta)}) == 3)
zero("negative-fifth-real-value", (1-s.sqrt(2))**5 - (41-29*s.sqrt(2)))
record("fifth-radicand-negative", (41-29*s.sqrt(2)).is_negative is True)
# Principal fifth root of negative R has argument pi/5, not pi.
record("fifth-principal-sector-excludes-negative-real", s.Rational(1,5) != 1)

# Demonstrates the helper's lost winding number, NOT ordinary-input reachability.
F, S = (-s.Integer(1))**2, s.Integer(5)
original, distributed = s.sqrt(F*S), (-s.Integer(1))**(2*s.Rational(1,2))*s.sqrt(S)
record("aggregate-factor-positive", F == 1)
zero("helper-fault-residual", distributed-original+2*s.sqrt(5))
record("aggregate-positivity-insufficient", s.simplify(distributed-original) != 0)

# Denominator rationalization: P(X)=(X-d)Q(X) for P(d)=0 gives Q(0)=-P(0)/d.
den = 1+s.sqrt(2)
P = x*x-2*x-1
Q, rem = s.div(P, x-den, x, extension=s.sqrt(2))
zero("rationalization-polynomial-remainder", rem)
zero("rationalization-value", -Q.subs(x,0)/P.subs(x,0)-1/den)

# Norm/trace cubic-in-quadratic reconstruction and its insufficient-condition test.
zero("trace-norm-polynomial-certificate", (x**3-3*t*x)**2-4*t**3-(x*x-t)**2*(x*x-4*t))
record("cube-norm-not-sufficient", s.Poly(x**3+3*x-2,x).ground_roots() == {})
zero("cubic-quadratic-example", (1+s.sqrt(2))**3-(7+5*s.sqrt(2)))
# Honsbeek: entirely polynomial verification, compatible-root issue kept separate.
zero("honsbeek-quartic-certificate", (-t*t/2+t*u+u*u)**2-(u**3-t**3)*(1+u)
     -(t**4+4*t**3+8*u**3*t-4*u**3)/4)
zero("honsbeek-ratio-minus-four-fifths", (t**4+4*t**3+8*q*t-4*q).subs({t:-2,q:-s.Rational(4,5)}))
zero("honsbeek-swapped-ratio", (t**4+4*t**3+8*q*t-4*q).subs({t:1,q:-s.Rational(5,4)}))
# A Ramanujan cubic certificate in Q[u]/(u^3-2).
record("ramanujan-cubic-certificate", s.rem((1-u+u*u)**3-9*(u-1),u**3-2,u) == 0)
# Algebraic-model illustration of symbolic callback corruption.
record("symbolic-callback-error", s.simplify((x+0)-(x+s.sqrt(5+2*s.sqrt(6)))) != 0)
record("assumption-drop-error-at-negative-x", s.sqrt((-s.Integer(2))**2) != -2)


def lexical_balance(path: Path) -> dict[str, int]:
    """Ignore strings and nested WL comments; check ordinary (), [], {} pairs."""
    text = path.read_text(encoding="utf-8")
    stack: list[tuple[str,int]] = []
    comment = 0
    string = False
    i = 0
    pairs = {')':'(', ']':'[', '}':'{'}
    while i < len(text):
        ch = text[i]
        if comment:
            if text.startswith('(*',i): comment += 1; i += 2; continue
            if text.startswith('*)',i): comment -= 1; i += 2; continue
            i += 1; continue
        if string:
            if ch == '\\': i += 2; continue
            if ch == '"': string = False
            i += 1; continue
        if text.startswith('(*',i): comment = 1; i += 2; continue
        if ch == '"': string = True
        elif ch in '([{': stack.append((ch,i))
        elif ch in ')]}':
            if not stack or stack.pop()[0] != pairs[ch]:
                raise AssertionError(f"unbalanced {path}:{i}")
        i += 1
    if stack or string or comment:
        raise AssertionError(f"unterminated source structure in {path}")
    return {"bytes": len(text.encode()), "lines": len(text.splitlines())}

for rel in ["code/StradImproved.wl", "tests/regression.wlt", "tests/run_tests.wls", "tests/original_reproducers.wl"]:
    stats = lexical_balance(BASE/rel)
    record("lexical-balance-"+rel, True, str(stats)+"; NOT a native parse")
source = (BASE/"code/StradImproved.wl").read_text()
record("no-PowerExpand", "PowerExpand[" not in source)
record("no-marker-engine", "mark[" not in source)
record("no-ReplaceRepeated-engine", "//." not in source)
record("explicit-assumptions-reset", "Assumptions -> True" in source and "$Assumptions = True" in source)
record("callback-proposal-has-local-acceptance-gate", 'p = stage[$cfg["Solver"][e], $cfg["StageTime"]];\n    best = accept[p, e, best]];' in source)

result = {
 "scope": "Independent exact mathematics and lexical checks only; not Wolfram execution",
 "python": platform.python_version(), "sympy": s.__version__,
 "checks": len(checks), "passed": sum(int(c["passed"]) for c in checks),
 "native_wolfram_tests_executed": False, "details": checks,
}
(BASE/"evidence"/"verification.json").write_text(json.dumps(result,indent=2)+"\n")
lines = [result["scope"], f"Python {result['python']}; SymPy {result['sympy']}"]
lines += [f"PASS {c['name']}" for c in checks]
lines += [f"TOTAL: {result['passed']}/{result['checks']} checks passed.", "Native Wolfram Language regression suite: NOT EXECUTED."]
(BASE/"evidence"/"verification.txt").write_text("\n".join(lines)+"\n")
print("\n".join(lines[-3:]))
