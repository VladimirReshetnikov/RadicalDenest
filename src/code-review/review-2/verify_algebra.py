#!/usr/bin/env python3
"""Independent algebra checks. Does NOT execute the uploaded Wolfram program."""
from pathlib import Path
import json
import sympy as s
import mpmath as mp

x = s.Symbol('x')
r2, r3, r6 = s.sqrt(2), s.sqrt(3), s.sqrt(6)
checks = {}

def record(name, value):
    checks[name] = str(value)
    print(f'{name}: {value}')

def check_zero(name, value):
    reduced = s.simplify(s.expand(value))
    assert reduced == 0, (name, reduced)
    record(name, 'PASS')

record('sympy_version', s.__version__)
record('mpmath_version', mp.__version__)

A = 5 + 2*r6
P1 = s.minpoly(r2+r3, x)
P2 = s.minpoly(2+r6, x)
G1 = s.Poly(P1,x,extension=r6).gcd(s.Poly(x*x-A,x,extension=r6)).monic().as_expr()
G2 = s.Poly(P2,x,extension=r6).gcd(s.Poly(x*x-2*A,x,extension=r6)).monic().as_expr()
record('worked_example_P1', P1)
record('worked_example_G1', G1)
record('worked_example_P2', P2)
record('worked_example_G2', G2)
record('worked_example_discriminant_P1', s.discriminant(P1,x))
check_zero('worked_example_identity', ((2+r6)/r2)**2-A)

negative = -1-r2
check_zero('negative_input_square', negative**2-(3+2*r2))
record('negative_input_minpoly_of_wrong_branch', s.minpoly(-negative,x))

z = -1+2*s.I*r2
alpha = -5+s.I*r2
check_zero('complex_power_base', (1+s.I*r2)**2-z)
check_zero('complex_power_cube', (1+s.I*r2)**3-alpha)
B = s.expand(alpha**2)
P = s.minpoly(-alpha,x)
G = s.Poly(P,x,extension=s.I*r2).gcd(s.Poly(x*x-B,x,extension=s.I*r2)).monic().as_expr()
record('complex_power_A', B)
record('complex_power_wrong_target_P', P)
record('complex_power_G', G)
mp.mp.dps = 80
zn = -1+2j*mp.sqrt(2)
original = mp.power(zn, mp.mpf(3)/2)
wrong = mp.sqrt(original**2)
assert abs(original - (-5+1j*mp.sqrt(2))) < mp.mpf('1e-75')
assert abs(wrong + original) < mp.mpf('1e-75')
record('complex_power_principal_value_30digits', mp.nstr(original,30))
record('complex_power_reset_value_30digits', mp.nstr(wrong,30))

prod = s.expand((1+s.I*r2)*(1+s.I*r3))
C = s.expand(prod**2)
Pc = s.minpoly(-prod,x)
ext = [s.I*r2, s.I*r3, r6]
Gc = s.Poly(Pc,x,extension=ext).gcd(s.Poly(x*x-C,x,extension=ext)).monic().as_expr()
record('complex_product_original', prod)
record('complex_product_square', C)
record('complex_product_wrong_target_P', Pc)
record('complex_product_G', Gc)
a = mp.sqrt(-1+2j*mp.sqrt(2))*mp.sqrt(-2+2j*mp.sqrt(3))
assert a.real < 0 and a.imag > 0
assert abs(mp.sqrt(a*a)+a) < mp.mpf('1e-75')
record('complex_product_principal_value_30digits', mp.nstr(a,30))
record('complex_product_reset_value_30digits', mp.nstr(mp.sqrt(a*a),30))

# A same-degree multiplier can yield a linear GCD even after a degree-4 baseline.
beta = 1+r2+r3
m = s.simplify(beta**2/A)
Pbeta = s.minpoly(beta,x)
Gbeta = s.Poly(Pbeta,x,extension=[r2,r3]).gcd(s.Poly(x*x-s.expand(beta**2),x,extension=[r2,r3])).monic().as_expr()
record('equal_degree_multiplier', m)
record('equal_degree_P', Pbeta)
record('equal_degree_G', Gbeta)
assert s.degree(Pbeta,x) == s.degree(P1,x) == 4
assert s.degree(G1,x) == 2 and s.degree(Gbeta,x) == 1
record('equal_degree_gate_counterexample', 'PASS')

# Rationalization identity, including nonmonic minimal polynomials.
for name,d in [('quadratic',1+r2),('nonmonic',r2/3),('complex',1+s.I*r2)]:
    p=s.minpoly(d,x)
    q,rem=s.div(p,x-d,extension=True)
    assert s.simplify(rem)==0
    v=s.simplify(-q.subs(x,0)/p.subs(x,0))
    check_zero('rationalization_'+name, d*v-1)
    record('rationalization_'+name+'_result',v)

# Branch-law counterexamples for the factor reconstruction.
assert mp.sqrt((-1)**2) != -1
assert mp.sqrt((-1)*(-1)) != mp.sqrt(-1)*mp.sqrt(-1)
record('unsafe_power_laws', 'PASS: sqrt(z^2)=z and sqrt(uv)=sqrt(u)sqrt(v) fail at z=u=v=-1')

# The comparator uses only the first pair; both directions can be false.
bad_cmp=lambda first,second: first[0] <= first[1]
assert not bad_cmp((2,1),(3,1)) and not bad_cmp((3,1),(2,1))
record('comparator_second_argument_ignored','PASS')

for k in [2,3,5,10,100]:
    n=max(5,int(mp.ceil(mp.log(1000)/mp.log(k))))
    record(f'multiplier_grid_k{k}', {'selected_primes_if_available':n,'divisors_before_drop':k**n,'after_drop':k**n-1})

record('scope','Exact SymPy algebra and mpmath branch checks only; no Wolfram execution.')

out=Path(__file__).with_name('verification_results.json')
out.write_text(json.dumps(checks,indent=2)+'\n')

