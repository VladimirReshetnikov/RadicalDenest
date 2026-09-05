#!/usr/bin/env python3
"""Independent exact-mathematics checks for the review.

This does NOT execute the supplied Wolfram Language source.  It checks
polynomial identities with SymPy and models two small control/data invariants.
Run: python independent_checks.py
"""
from __future__ import annotations
import hashlib
import json
import platform
from pathlib import Path
import sympy as sp

BASE = Path(__file__).resolve().parent
x = sp.Symbol("x")
results: list[dict[str, object]] = []

def check(name: str, condition: bool, detail: object = "") -> None:
    if not bool(condition):
        raise AssertionError(name)
    results.append({"name": name, "passed": True, "detail": str(detail)})
    print(f"PASS: {name}")

def zero(e: sp.Expr) -> bool:
    return sp.simplify(sp.expand(e)) == 0

rho = 5 + 2 * sp.sqrt(6)
a = sp.sqrt(2) + sp.sqrt(3)
check("classical square-root denesting identity", zero(a**2-rho))
p0 = sp.minimal_polynomial(a, x)
check("classical minimal polynomial", p0 == x**4-10*x**2+1, p0)
check("classical discriminant", sp.discriminant(p0,x)==147456,
      sp.factorint(sp.discriminant(p0,x)))
g0 = sp.gcd(p0,x**2-rho,extension=True)
check("unscaled GCD retains degree two", sp.degree(g0,x)==2, g0)

rows=[]
for m, expected in [(sp.sqrt(6),4),(sp.Integer(2),2),
                     (sp.Integer(3),2),(sp.sqrt(5),8)]:
    p=sp.minimal_polynomial(sp.sqrt(m*rho),x)
    g=sp.gcd(p,x*x-m*rho,extension=True)
    check(f"multiplier {m}: rational minimal-polynomial degree",
          sp.degree(p,x)==expected,p)
    rows.append({"multiplier":str(m),"polynomial":str(p),
                 "degree":int(sp.degree(p,x)),"gcd":str(g)})
check("multiplier two produces linear GCD",
      sp.gcd(x*x-4*x-2,x*x-2*rho,extension=True)==x-2-sp.sqrt(6))
check("negative target and principal reconstruction disagree",
      zero((-a)**2-a**2) and not zero(-a-a))

z=-1+2*sp.I*sp.sqrt(2)
u=1+sp.I*sp.sqrt(2)
alpha=-5+sp.I*sp.sqrt(2)
check("complex base is square of its right-half-plane square root",zero(u*u-z))
check("three-halves power has left-half-plane value",zero(u**3-alpha))
check("three-halves target square",zero(alpha**2-(23-10*sp.I*sp.sqrt(2))))
p=sp.minimal_polynomial(-alpha,x)
check("wrong-branch minimal polynomial",p==x*x-10*x+27,p)
check("wrong-branch polynomial GCD is linear",
      sp.gcd(p,x*x-sp.expand(alpha**2),extension=True)==x-5+sp.I*sp.sqrt(2))

product=sp.expand((1+sp.I*sp.sqrt(2))*(1+sp.I*sp.sqrt(3)))
p=sp.minimal_polynomial(-product,x)
check("merged-product wrong-branch polynomial",p==x**4+4*x**3+4*x**2+48*x+144,p)
check("merged-product wrong-branch GCD is linear",
      zero(sp.gcd(p,x*x-sp.expand(product**2),extension=True)-(x+product)))

# The following is a mathematical substitution counterexample to the
# transformation described in the article, not an execution of Factorc.
check("unrestricted square-root splitting changes a sign",
      sp.sqrt(2) != sp.I*sp.sqrt(-2))
for d in [sp.sqrt(2)+sp.sqrt(3), 1+sp.I*sp.sqrt(2), sp.Rational(2,3)]:
    p=sp.minimal_polynomial(d,x)
    quotient,_=sp.div(p,x-d,x)
    inverse=-quotient.subs(x,0)/p.subs(x,0)
    check(f"minimal-polynomial reciprocal identity for {d}",zero(d*inverse-1),inverse)

bad_compare=lambda first, second: first[0] <= first[1]
check("faulty comparator ignores the second operand",
      bad_compare((2,1),(3,1)) == bad_compare((2,1),(101,1000)) == False)
check("distinct increasing prime records can compare false both ways",
      not bad_compare((2,1),(3,1)) and not bad_compare((3,1),(2,1)))
primes=[2,3,5,7,11,2003]
check("prime gap fixture uses actual primes",all(sp.isprime(p) for p in primes))
pruned=primes.copy()
i=len(pruned)
while i>5 and sp.Rational(pruned[i-1],pruned[i-2])>100:
    pruned[i-1]=0
    i-=1
clean=[p for p in pruned if p!=0]
old_upper=min(max(5,10),len(pruned))
check("trimming upper bound exceeds shortened list",old_upper>len(clean),
      {"before":pruned,"clean":clean,"requested_last_index":old_upper})
counts={q:q**max(5, int(sp.ceiling(sp.log(1000)/sp.log(q))))-1
        for q in [2,3,10,100]}
check("nominal cap is not a cap",all(n>1000 for n in counts.values()),counts)

source=BASE/"source.wl"
report={"scope":"Independent mathematics and small source-invariant models; not Wolfram execution",
        "python":platform.python_version(),"sympy":sp.__version__,
        "source_sha256":hashlib.sha256(source.read_bytes()).hexdigest() if source.exists() else None,
        "passed":len(results),"failed":0,"checks":results,"multiplier_examples":rows}
(BASE/"verification_results.json").write_text(json.dumps(report,indent=2)+"\n",encoding="utf-8")
print(f"\n{len(results)} checks passed. Wolfram source was not executed.")
