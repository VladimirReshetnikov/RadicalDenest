#!/usr/bin/env python3
"""Exact checks accompanying Radical Denesting: A Unified Research Report.

Requires Python 3.10+ and SymPy (tested with 1.14.0). No network access.
Run: python verify_examples.py
The assertions check exact algebraic identities, not decimal coincidence.
The negative denesting conclusions in the report rely on stated theorems,
not on the failure of a computer algebra simplifier.
"""
from __future__ import annotations

import json
import platform
from pathlib import Path
from typing import Optional

import sympy as sp
from sympy.simplify.simplify import nthroot
from sympy.simplify.sqrtdenest import sqrtdenest


def rational_nth_root(q: sp.Rational, n: int) -> Optional[sp.Rational]:
    """Return the exact real rational nth root, or None if none exists.

    Floats are rejected to avoid accidental conversion of approximate data
    into exact mathematical inputs. This uses integer root extraction, not
    integer prime factorization.
    """
    q = sp.sympify(q)
    if not isinstance(q, sp.Rational):
        raise TypeError("q must be an exact rational number")
    if not isinstance(n, int) or isinstance(n, bool) or n < 2:
        raise ValueError("n must be an integer at least 2")
    if q < 0 and n % 2 == 0:
        return None
    a, ok_a = sp.integer_nthroot(abs(int(q.p)), n)
    b, ok_b = sp.integer_nthroot(int(q.q), n)
    if not (ok_a and ok_b):
        return None
    return sp.Rational(-a if q < 0 else a, b)


def cubic_in_quadratic(a: sp.Rational, b: sp.Rational,
                      p: sp.Rational) -> Optional[tuple[sp.Rational, sp.Rational]]:
    """Find A,B in Q with (A+B*sqrt(p))**3 == a+b*sqrt(p).

    Scope: a,b,p rational, p>0 nonsquare, b!=0. None means no root
    in the specified quadratic field, not no possible radical denesting.
    """
    a, b, p = map(sp.sympify, (a, b, p))
    if not all(isinstance(v, sp.Rational) for v in (a, b, p)):
        raise TypeError("a, b, p must be exact rationals")
    if p <= 0 or rational_nth_root(p, 2) is not None or b == 0:
        raise ValueError("require p>0 nonsquare and b!=0; preprocess degeneracies")
    norm = a*a - b*b*p
    c = rational_nth_root(norm, 3)
    if c is None:
        return None
    t = sp.Symbol("t")
    roots = sp.Poly(t**3 - 3*c*t - 2*a, t, domain=sp.QQ).ground_roots()
    if not roots:
        return None
    # The discriminant is -108*b**2*p < 0, so there is one real root.
    tr = next(iter(roots))
    A, B = tr/2, b/(tr*tr-c)
    assert sp.expand((A+B*sp.sqrt(p))**3-a-b*sp.sqrt(p)) == 0
    return A, B


def quotient_check(poly: sp.Expr, modulus: sp.Expr, x: sp.Symbol) -> None:
    assert sp.rem(poly, modulus, x) == 0


def main() -> None:
    s = sp.sqrt
    observations: list[dict[str, str]] = []
    cases = [
        ("direct square roots", s(5+2*s(6)), s(2)+s(3)),
        ("principal-root sign", s(3-2*s(2)), s(2)-1),
        ("fourth roots", s(4+3*s(2)), 2**sp.Rational(1,4)*(s(2)+1)),
        ("depth three to two", s(16-2*s(29)+2*s(55-10*s(29))),
         s(5)+s(11-2*s(29))),
        ("multiquadratic input", s(112+70*s(2)+(46+34*s(2))*s(5)),
         5+4*s(2)+3*s(5)+s(10)),
        ("cancellation across terms", s(1+s(3))+s(3+3*s(3))-s(10+6*s(3)),
         sp.Integer(0)),
    ]
    for name, expr, expected in cases:
        out = sqrtdenest(expr)
        assert sp.simplify(out-expected) == 0, name
        observations.append({"test": name, "function": "sqrtdenest", "output": str(out)})
    expr = s(2+s(2))
    out = sqrtdenest(expr)
    assert out == expr
    observations.append({"test": "unchanged example (not itself a proof)",
                         "function": "sqrtdenest", "output": str(out)})
    for name, a, n, expected in [
        ("cubic quadratic 1", 7+5*s(2), 3, 1+s(2)),
        ("cubic quadratic 2", 90+34*s(7), 3, 3+s(7)),
        ("negative real fifth root", 41-29*s(2), 5, 1-s(2)),
    ]:
        out = nthroot(a, n)
        assert sp.expand(out**n-a) == 0
        assert sp.simplify(out-expected) == 0
        observations.append({"test": name, "function": "nthroot", "output": str(out)})

    assert cubic_in_quadratic(7,5,2) == (1,1)
    assert cubic_in_quadratic(90,34,7) == (3,1)
    assert cubic_in_quadratic(3,1,10) is None  # norm is a cube, but not sufficient
    assert rational_nth_root(sp.Rational(-8,27), 3) == sp.Rational(-2,3)
    assert rational_nth_root(sp.Rational(2), 2) is None
    assert rational_nth_root(sp.Rational(0), 3) == 0

    x,u,v = sp.symbols("x u v")
    # Ramanujan's cube root of a cube root.
    quotient_check((1-u+u*u)**3-9*(u-1), u**3-2, u)
    # Square root of a difference of cube roots.
    G = sp.groebner([u**3-2, v**3-5], u, v, domain=sp.QQ)
    assert G.reduce(sp.expand(((u+u*u*v-v*v)/3)**2-(v-u*u)))[1] == 0
    # Square root of cube root of 28 minus 3.
    quotient_check(((u*u/2-u-1)/3)**2-(u-3), u**3-28, u)
    # A sixth root reducing to cube roots.
    quotient_check((u-2)**6-144*(7*u-19), u**3-20, u)
    # Fourth-root ratio identity, with denominators cleared.
    quotient_check((u+1)**4*(3-2*u)-(u-1)**4*(3+2*u), u**4-5, u)
    # Honsbeek's quartic reconstruction certificate.
    g,t=sp.symbols("g t")
    numerator = -t*t/2+t*u+u*u
    rem = sp.rem(sp.expand(numerator**2-(g-t**3)*(1+u)), u**3-g, u)
    assert sp.expand(rem-(t**4+4*t**3+8*g*t-4*g)/4) == 0
    for gamma, tr in [(sp.Rational(-4,5),-2), (sp.Rational(-27,28),-3),
                      (sp.Rational(-5,4),1)]:
        assert tr**4+4*tr**3+8*gamma*tr-4*gamma == 0
    # Degree-four example: no single quadratic field can contain this number.
    assert sp.minimal_polynomial(s(2)+s(3),x) == x**4-10*x*x+1
    assert sp.Poly(x**4-10*x*x+1,x).is_irreducible
    # A wrong branch passes a squared-identity test: sign must be checked.
    assert sp.expand((1-s(2))**2-(3-2*s(2))) == 0
    assert 1-s(2) < 0
    # Exact rational bounds used for signs of selected radical identities.
    assert sp.Rational(5,4)**3 < 2
    assert sp.Rational(17,10)**3 < 5 < sp.Rational(7,4)**3
    assert sp.Rational(5,4)+sp.Rational(5,4)**2*sp.Rational(17,10)-sp.Rational(7,4)**2 > 0
    assert 3**3 < 28
    assert 1 < 5 < sp.Rational(3,2)**4

    result = {"python": platform.python_version(), "sympy": sp.__version__,
              "status": "all exact assertions passed", "observations": observations}
    text = json.dumps(result, indent=2)
    print(text)
    Path(__file__).with_name("verification_results.json").write_text(text+"\n", encoding="utf-8")


if __name__ == "__main__":
    main()
