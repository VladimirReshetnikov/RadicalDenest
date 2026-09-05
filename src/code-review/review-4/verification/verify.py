#!/usr/bin/env python3
"""Independent exact mathematical checks and limited WL lexical checks.

This is NOT a Wolfram Language interpreter and does NOT execute StradImproved.
Python >= 3.9, SymPy >= 1.12. Run from any directory. Results are written next
 to this script. No network, floating-point identity tests, or external data.
"""
from __future__ import annotations
from fractions import Fraction as F
from math import isqrt, prod
from pathlib import Path
from collections import Counter
import hashlib
import itertools
import json
import platform
import time
import sympy as sp

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
counts: Counter[str] = Counter()
started = time.perf_counter()


def check(condition: bool, group: str, detail: object = "") -> None:
    if not condition:
        raise AssertionError(f"{group}: {detail}")
    counts[group] += 1


def rational_sqrt(x: F) -> F | None:
    if x < 0:
        return None
    a, b = isqrt(x.numerator), isqrt(x.denominator)
    return F(a, b) if a*a == x.numerator and b*b == x.denominator else None


def verify_direct() -> None:
    # Exact coefficient and sign certificate, including negative radicands.
    for i, j, sign in itertools.product(range(1, 16), range(1, 16), (-1, 1)):
        u, v = F(i, 7), F(j, 5)
        a, b, c = u+v, F(2*sign), u*v
        delta = rational_sqrt(a*a-b*b*c)
        assert delta is not None
        U, V = (a+delta)/2, (a-delta)/2
        check(U >= V >= 0 and U+V == a and 4*U*V == b*b*c,
              "direct_quadratic", (a, b, c))
        # sqrt(U)+sign sqrt(V) is nonnegative; its square is the radicand.
        # Multiplying it by i gives the principal square root of its negative.
        check(U >= V >= 0 and (b > 0 or U >= V),
              "negative_radicand_branch", (a, b, c))


def verify_indirect() -> None:
    for c0, i, j, sign in itertools.product((2,3,5,6,7,10), range(1,6), range(1,6), (-1,1)):
        c, r, s = F(c0), F(i,3), F(j,4)
        u, v = r*r, s*s/c
        a, b = F(2*sign)*r*s, u+v
        D = a*a-b*b*c
        e = rational_sqrt(b*b-a*a/c)
        assert e is not None
        U, V = (b+e)/2, (b-e)/2
        check(D < 0 and rational_sqrt(-c*D) is not None and
              U >= V >= 0 and U+V == b and 4*c*U*V == a*a,
              "indirect_quadratic", (a,b,c))
    check(F(4)**2-F(3)**2*2 == -2 and rational_sqrt(F(4)) == 2,
          "indirect_sign_counterexample")


def verify_cubic() -> None:
    for c0, i, j in itertools.product((2,3,5,6,7), range(-4,5), range(-3,4)):
        if j == 0:
            continue
        c, A, B = F(c0), F(i,3), F(j,2)
        a, b = A**3+3*A*c*B*B, 3*A*A*B+c*B**3
        n, T = A*A-c*B*B, 2*A
        denominator = T*T-n
        check(a*a-b*b*c == n**3 and T**3-3*n*T-2*a == 0 and
              denominator > 0 and T/2 == A and b/denominator == B,
              "cubic_trace_norm", (A,B,c))


def verify_honsbeek() -> None:
    s, u = sp.symbols('s u')
    left = (-s*s/2+s*u+u*u)**2-(u**3-s**3)*(1+u)
    right = (s**4+4*s**3+8*u**3*s-4*u**3)/4
    check(sp.expand(left-right) == 0, "honsbeek_symbolic_identity")
    for numerator, denominator in itertools.product(range(-6,7), range(1,7)):
        t = F(numerator, denominator)
        if t in (0, F(1,2), -4):
            continue
        q = t**3*(t+4)/(4*(1-2*t))
        check(t**4+4*t**3+8*q*t-4*q == 0 and q-t**3 != 0,
              "honsbeek_rational_parameters", (t,q))
    check(F(-5,4) == 1**3*(1+4)/(4*(1-2*F(1))) and
          F(-4,5) == (-2)**3*(-2+4)/(4*(1-2*F(-2))),
          "honsbeek_reversal_examples")
    # Real cubic field a^3=2, b^3=5; reduction of the classical identity.
    a,b = sp.symbols('a b')
    basis = sp.groebner([a**3-2, b**3-5], a,b, domain=sp.QQ)
    candidate = (a+a*a*b-b*b)/3
    residual = candidate**2-(b-a*a)
    check(basis.reduce(sp.expand(residual))[1] == 0,
          "ramanujan_square_certificate")


def verify_horner() -> None:
    x = sp.symbols('x')
    # The proof is polynomial: x*inverse(x)-1 is a multiple of p(x).
    for degree in range(1,9):
        for shift in range(1,6):
            coeffs = [sp.Integer(shift)] + [sp.Integer((-1)**k*(k+shift)) for k in range(1, degree+1)]
            p = sum(coeffs[k]*x**k for k in range(degree+1))
            accumulator = coeffs[-1]
            for coefficient in reversed(coeffs[1:-1]):
                accumulator = accumulator*x+coefficient
            inverse = -accumulator/coeffs[0]
            check(sp.rem(sp.expand(x*inverse-1),p,x) == 0,
                  "horner_inverse_polynomials", (degree,shift))


def verify_multiplier_proof() -> list[dict[str, object]]:
    x = sp.symbols('x')
    examples = [
        (2+sp.sqrt(3), sp.Integer(2), 1+sp.sqrt(3), sp.sqrt(3)),
        (5+2*sp.sqrt(6), sp.Integer(2), 2+sp.sqrt(6), sp.sqrt(6))]
    records = []
    for rho,m,t,theta in examples:
        p = sp.minimal_polynomial(t,x)
        gcd = sp.Poly(p,x,extension=theta).gcd(sp.Poly(x*x-m*rho,x,extension=theta)).as_expr()
        z = sp.solve(gcd,x)[0]
        check(sp.expand(t*t-m*rho) == 0 and sp.degree(gcd,x) == 1,
              "multiplier_gcd", str(rho))
        for branch in (-1,1):
            target = branch*t/sp.sqrt(m)
            orbit = (z/sp.sqrt(m), -z/sp.sqrt(m))
            check(any(sp.simplify(candidate-target) == 0 for candidate in orbit),
                  "original_target_orbit", branch)
        records.append({'rho':str(rho),'m':str(m),'minpoly':str(p),'gcd':str(gcd)})
    # Norm-one counterexample and the missing nontrivial rational multiplier.
    y = sp.symbols('y')
    check(sp.expand((2+sp.sqrt(3))*(2-sp.sqrt(3))) == 1 and
          sp.expand((1+sp.sqrt(3))**2-2*(2+sp.sqrt(3))) == 0 and
          rational_sqrt(F(1,2)) is None and rational_sqrt(F(3,2)) is None,
          "norm_only_multiplier_counterexample")
    check(sp.simplify(sp.expand_complex(sp.sqrt(sp.I)*(-1+sp.I)+sp.sqrt(2))) == 0,
          "aggregate_factor_branch_counterexample")
    return records


def old_batch(q: int, cap: int, primes: list[int]) -> list[int]:
    t = 0
    while q**(t+1)-1 <= cap:
        t += 1
    count = min(max(1,t),len(primes))
    selected = primes[:count]
    divisors = {prod(p**e for p,e in zip(selected,exponents))
                for exponents in itertools.product(range(q),repeat=count)}
    return sorted((divisors | set(primes))-{1})


def verify_caps() -> list[dict[str, object]]:
    violations = []
    for q,cap,primes in [(3,1,[5]),(2,1,[5,13]),(5,2,[2])]:
        batch = old_batch(q,cap,primes)
        check(len(batch)>cap,"old_cap_counterexamples", (q,cap,batch))
        violations.append({'q':q,'cap':cap,'primes':primes,'batch':batch})
    # Independent finite scheduler model, not execution of the WL code.
    for cap,q in itertools.product(range(33),range(2,13)):
        admitted: list[F] = []
        seen: set[F] = set()
        proposed = 0
        def add(m: F) -> bool:
            nonlocal proposed
            if len(admitted)>=cap or proposed>=4*cap:
                return False
            proposed += 1
            if m == 0 or m in seen:
                return False
            seen.add(m); admitted.append(m); return True
        for seed in map(F,[0,1,1,2,3,-1,2,5]):
            add(seed)
        index=0
        while index<len(admitted):
            m=admitted[index]; index+=1
            for prime in [2,3,5]:
                add(m*prime)
            # Only the first 32 vectors are materialized; no q^3 product list.
            for j in range(1,min(q**3,33)):
                number=j; digits=[0,0,0]
                for k in (2,1,0):
                    digits[k]=number%q; number//=q
                add(m*prod(p**e for p,e in zip([2,3,5],digits)))
        check(len(admitted)<=cap and proposed<=4*cap and index<=cap,
              "bounded_scheduler_model", (cap,q))
    return violations


def lexical_balance(text: str) -> None:
    """Check nested WL comments/strings and (), [], {}; not grammar/type checking."""
    i=0; comments=0; quoted=False; stack=[]
    matching={')':'(',']':'[','}':'{'}
    while i<len(text):
        pair=text[i:i+2]
        if comments:
            if pair=='(*': comments+=1; i+=2; continue
            if pair=='*)': comments-=1; i+=2; continue
            i+=1; continue
        if quoted:
            if text[i]=='\\': i+=2; continue
            if text[i]=='"': quoted=False
            i+=1; continue
        if pair=='(*': comments=1; i+=2; continue
        ch=text[i]
        if ch=='"': quoted=True
        elif ch in '([{': stack.append((ch,i))
        elif ch in ')]}':
            if not stack or stack[-1][0]!=matching[ch]:
                raise AssertionError(f'Delimiter mismatch at character {i}')
            stack.pop()
        i+=1
    if comments or quoted or stack:
        raise AssertionError(f'Unclosed lexical construct: {comments}, {quoted}, {stack[-3:]}')


def verify_sources() -> list[dict[str,object]]:
    records=[]
    paths=[ROOT/'StradImproved.wl', *sorted((ROOT/'tests').glob('*.wl*'))]
    for path in paths:
        data=path.read_bytes()
        lexical_balance(data.decode('utf-8'))
        check(True,'wl_lexical_balance',path.name)
        records.append({'file':str(path.relative_to(ROOT)), 'bytes':len(data),
                        'sha256':hashlib.sha256(data).hexdigest()})
    return records


def main() -> None:
    verify_direct(); verify_indirect(); verify_cubic(); verify_honsbeek()
    verify_horner()
    gcds=verify_multiplier_proof(); caps=verify_caps(); sources=verify_sources()
    result={
        'status':'PASS',
        'scope':'Independent exact arithmetic/algebra and limited lexical checks; NOT native Wolfram execution',
        'python':platform.python_version(),'sympy':sp.__version__,
        'assertions':sum(counts.values()),'groups':dict(counts),
        'multiplier_examples':gcds,'baseline_cap_counterexamples':caps,
        'source_files':sources,
        'native_wolfram_tests':{'status':'NOT RUN','reason':'Wolfram connector returned MCP HTTP 404; no local kernel'},
        'elapsed_seconds':round(time.perf_counter()-started,3)}
    (HERE/'results.json').write_text(json.dumps(result,indent=2)+'\n')
    lines=[f"Independent exact checks: {result['status']}",
           f"Python {result['python']}; SymPy {result['sympy']}",
           f"Assertions passed: {result['assertions']}"]
    lines.extend(f"  {group}: {number}" for group,number in counts.items())
    lines += ['Wolfram Language runtime tests: NOT RUN.',
              'Lexical checking is not parsing, evaluation, or native semantic validation.']
    transcript='\n'.join(lines)+'\n'
    (HERE/'transcript.txt').write_text(transcript)
    print(transcript,end='')


if __name__=='__main__':
    main()
