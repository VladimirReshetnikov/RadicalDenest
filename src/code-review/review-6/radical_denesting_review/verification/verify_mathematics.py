#!/usr/bin/env python3
"""Independent exact checks, NOT an execution or emulation of StradImproved.wl.
Requires Python >=3.10 and SymPy. Writes verification_results.json alongside itself.
"""
from __future__ import annotations
import hashlib
import json
import platform
from pathlib import Path
from time import perf_counter
import sympy as s

HERE = Path(__file__).resolve().parent
checks: list[dict] = []
start = perf_counter()

def check(name: str, condition: object, **details: object) -> None:
    passed = bool(condition)
    checks.append({"name": name, "passed": passed, **details})
    if not passed:
        raise AssertionError(name)

x, t, q = s.symbols("x t q")
check("trace_norm_factorization", s.expand((x**3 - 3*q*x)**2 - 4*q**3 -
      (x**2-q)**2*(x**2-4*q)) == 0)
check("ramanujan_polynomial_certificate", s.rem((1-t+t*t)**3 - 9*(t-1), t**3-2, t) == 0)
check("honsbeek_quartic_certificate", s.expand((-x*x/2 + x*t + t*t)**2 -
      (t**3-x**3)*(1+t) - (x**4 + 4*x**3 + 8*t**3*x - 4*t**3)/4) == 0)

# Direct roots: coefficient identities plus the nonnegative branch.
direct_count = 0
for c in [2, 3, 5, 6, 7, 10]:
    for u in [s.Rational(1,2), s.Integer(1), s.Integer(2), s.Integer(5)]:
        for v in [s.Rational(1,2), s.Integer(1), s.Integer(2)]:
            for sign in [-1, 1]:
                a = u*u + c*v*v; b = sign*2*u*v
                d = abs(u*u-c*v*v)
                U, V = (a+d)/2, (a-d)/2
                assert U >= V >= 0 and s.expand(U+V-a) == 0
                assert s.expand(4*U*V-b*b*c) == 0
                # sqrt(U)+sgn(b)sqrt(V)>=0 since U>=V.
                direct_count += 1
check("direct_quadratic_family", True, cases=direct_count,
      method="Exact coefficient identities, U>=V>=0, signed cross term.")

indirect_count = 0
for c in [2, 3, 5, 6, 7, 10]:
    for u in [s.Rational(1,2), s.Integer(1), s.Integer(2)]:
        for v in [s.Rational(1,3), s.Integer(1), s.Integer(3)]:
            for sign in [-1, 1]:
                a, b = sign*2*c*u*v, c*u*u+v*v
                h = abs(c*u*u-v*v)
                U, V = (b+h)/2, (b-h)/2
                assert U >= V >= 0 and c > 0 and b > 0
                assert s.expand(c*(U+V)**2 - c*b*b) == 0
                assert s.expand(4*c*U*V-a*a) == 0
                assert s.expand(a*a-b*b*c + c*h*h) == 0
                indirect_count += 1
check("indirect_fourth_root_family", True, cases=indirect_count,
      method="Exact squared identity and U>=V>=0 select principal square root.")

cubic_count = 0
for c in [2, 3, 5, 7, 10]:
    for u in [s.Rational(-3,2), s.Rational(1,2), s.Integer(2), s.Integer(4)]:
        for v in [s.Rational(-2,3), s.Rational(1,3), s.Integer(1)]:
            a, b = u**3+3*u*v*v*c, 3*u*u*v+v**3*c
            norm_root, trace = u*u-c*v*v, 2*u
            assert s.expand(a*a-b*b*c-norm_root**3) == 0
            assert s.expand(trace**3-3*norm_root*trace-2*a) == 0
            reconstructed_v = b/(trace*trace-norm_root)
            assert s.cancel(reconstructed_v-v) == 0
            cubic_count += 1
check("cubic_quadratic_family", True, cases=cubic_count)
check("cube_norm_not_sufficient", s.factor(x**3+3*x-2) == x**3+3*x-2 and
      all((x**3+3*x-2).subs(x,k) != 0 for k in [-2,-1,1,2]))

# Nontrivial individual examples; exact power identities and sign witnesses.
examples = [
    ("direct_plus", 3+2*s.sqrt(2), 1+s.sqrt(2)),
    ("direct_minus", 3-2*s.sqrt(2), s.sqrt(2)-1),
    ("two_square_roots", 5+2*s.sqrt(6), s.sqrt(2)+s.sqrt(3)),
    ("indirect_plus", 4+3*s.sqrt(2), 2**s.Rational(1,4)*(1+s.sqrt(2))),
    ("indirect_minus", -4+3*s.sqrt(2), 2**s.Rational(1,4)*(s.sqrt(2)-1)),
    ("multiquadratic", 112+70*s.sqrt(2)+(46+34*s.sqrt(2))*s.sqrt(5),
     5+4*s.sqrt(2)+3*s.sqrt(5)+s.sqrt(10)),
    ("partial", 16-2*s.sqrt(29)+2*s.sqrt(55-10*s.sqrt(29)),
     s.sqrt(5)+s.sqrt(11-2*s.sqrt(29)))
]
for name, rad, candidate in examples:
    check(name+"_square", s.simplify(s.expand(candidate**2-rad)) == 0)
    check(name+"_positive", candidate.is_positive is True)
check("imaginary_branch", s.expand((s.I*(1+s.sqrt(2)))**2 + 3+2*s.sqrt(2)) == 0)
check("complex_quadratic", s.expand((2+s.I)**2-(3+4*s.I)) == 0)
check("principal_negative_cube_not_real", s.im((-1)**s.Rational(1,3)).is_positive is True)
# Avoid a numerical 'proof' of the cyclotomic identity: polynomial plus angle sign.
z = s.symbols("z")
check("cyclotomic_eighth_root_certificate", s.rem(
    (z-z**7)**4-4*(z-z**7)**2+2, z**8+1, z) == 0,
    note="Uses z^(-1)=-z^7 and z^8=-1; selection of z=exp(i*pi/8) discussed in article.")

# Genuine field-GCD test of the multiplier architecture on Ramanujan's example.
two_cuberoot = 2**s.Rational(1,3)
u = 1-two_cuberoot+two_cuberoot**2
p = s.minpoly(u, x)
g = s.gcd(s.Poly(p, x, extension=two_cuberoot),
          s.Poly(x**3-9*(two_cuberoot-1), x, extension=two_cuberoot))
check("ramanujan_multiplier_gcd_linear", g.degree() == 1,
      minimal_polynomial=str(p), gcd=str(g.as_expr()))
root = -g.nth(0)/g.nth(1)
check("ramanujan_multiplier_root", s.simplify(s.expand(root-u)) == 0)

# The original generator's arithmetic, isolated from all Wolfram semantics.
def old_prime_batch(primes: list[int], r: int, cap: int) -> list[int]:
    exponent_count = 0
    while r**(exponent_count+1)-1 <= cap:
        exponent_count += 1
    n = min(max(1, exponent_count), len(primes))
    return sorted(set(map(int, s.divisors(s.prod(primes[:n])**(r-1)))) | set(primes))[1:]

primes = [2,3,5,7,11]
for cap, expected in [(0,5),(1,5),(7,9)]:
    batch = old_prime_batch(primes, 2, cap)
    check(f"old_cap_{cap}_counterexample", len(batch) == expected and len(batch) > cap,
          advertised_cap=cap, actual_count=len(batch), multipliers=batch)

# A deliberately small model of the revised insertion invariant.
for cap in range(20):
    queue: list[int] = []; seen: set[int] = set()
    for m in [1,1,2,3,0,2,5,7,11,13,17,19,23,29,31,37,41,43,47,53,59,61]:
        if len(queue) >= cap:
            break
        if m != 0 and m not in seen:
            seen.add(m); queue.append(m)
        assert len(queue) <= cap
check("revised_queue_model_caps", True, caps_tested=list(range(20)),
      note="Python model of insertion invariant, not execution of WL queue.")
check("history_sensitive_gate", not (12 <= 6 or s.gcd(12,6) < 6) and
      (12 <= 5 or s.gcd(12,5) < 5),
      note="Control-flow scenario; no concrete radical realizing the complete history is asserted.")

# Denominator inverse identity in a quotient field.
p = x**3 - 2
inverse_poly = -(s.Poly(p,x).nth(1) + s.Poly(p,x).nth(2)*x + s.Poly(p,x).nth(3)*x*x)/s.Poly(p,x).nth(0)
check("denominator_inverse_certificate", s.rem(x*inverse_poly-1, p, x) == 0)

result = {"scope": "Independent mathematics and finite control-flow models only",
          "native_wolfram_executed": False, "python": platform.python_version(),
          "sympy": s.__version__, "elapsed_seconds": round(perf_counter()-start, 3),
          "checks": checks, "all_passed": all(c["passed"] for c in checks),
          "property_cases": direct_count+indirect_count+cubic_count}
(HERE/"verification_results.json").write_text(json.dumps(result, indent=2), encoding="utf-8")
print(json.dumps({k:v for k,v in result.items() if k != "checks"}, indent=2))
