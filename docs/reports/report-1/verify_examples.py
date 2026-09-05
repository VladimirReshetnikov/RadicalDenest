"""Exact checks accompanying Radical Denesting: A Unified Literature Report.

Requires Python 3.10+ and SymPy.  No internet access is needed.
This is a small verification/illustration suite, not a general denester.
"""
from __future__ import annotations

from fractions import Fraction
from typing import Optional
import sympy as sp
from sympy.simplify.simplify import nthroot


def exact_rational_cube_root(value: Fraction) -> Optional[Fraction]:
    """Return the real cube root iff rational, without integer factorization."""
    value = Fraction(value)
    a, a_exact = sp.integer_nthroot(abs(value.numerator), 3)
    b, b_exact = sp.integer_nthroot(value.denominator, 3)
    if not (a_exact and b_exact):
        return None
    return Fraction((-1 if value < 0 else 1) * int(a), int(b))


def quadratic_cuberoot(a: Fraction, b: Fraction, p: Fraction
                       ) -> Optional[tuple[Fraction, Fraction]]:
    """Solve real cbrt(a+b*sqrt(p)) = A+B*sqrt(p), with A,B rational.

    Requires b != 0 and positive nonsquare rational p.  None proves only
    failure in this particular quadratic field, not failure of every
    conceivable unnested radical representation.  Polynomial factorization
    is over QQ; divisors of integer coefficients are not enumerated.
    """
    a, b, p = Fraction(a), Fraction(b), Fraction(p)
    if b == 0 or p <= 0:
        raise ValueError("Require b != 0 and p > 0")
    _, num_square = sp.integer_nthroot(p.numerator, 2)
    _, den_square = sp.integer_nthroot(p.denominator, 2)
    if num_square and den_square:
        raise ValueError("p must not be a rational square")
    q = exact_rational_cube_root(a*a-b*b*p)
    if q is None:
        return None
    X = sp.Symbol('X')
    T = sp.Poly(X**3-3*sp.Rational(q)*X-2*sp.Rational(a), X, domain=sp.QQ)
    for factor, _multiplicity in T.factor_list()[1]:
        if factor.degree() == 1:
            t = Fraction(-factor.nth(0)/factor.nth(1))
            A, B = t/2, b/(t*t-q)
            # Complete exact certificate in the basis 1,sqrt(p).
            assert A**3+3*A*B**2*p == a
            assert 3*A**2*B+B**3*p == b
            return A, B
    return None


def main() -> None:
    print('SymPy version:', sp.__version__)
    X = sp.Symbol('X')
    sq = sp.sqrt
    square_examples = [
        (sq(5+2*sq(6)), sq(2)+sq(3)),
        (sq(5-2*sq(6)), sq(3)-sq(2)),
        (sq(4+3*sq(2)), 2**sp.Rational(1,4)+2**sp.Rational(3,4)),
        (sq(1+sq(2)), sq(1+sq(2))),
        (sq(16-2*sq(29)+2*sq(55-10*sq(29))), sq(5)+sq(11-2*sq(29))),
    ]
    for expr, expected in square_examples:
        result = sp.sqrtdenest(expr)
        # The denester itself is tested here; the identities also have proofs
        # in the report. simplify checks agreement of the selected branches.
        assert sp.simplify(result-expected) == 0
        print('sqrtdenest:', expr, '->', result)
    assert sp.minimal_polynomial(sq(2)+sq(3), X) == X**4-10*X**2+1
    print('minimal polynomial:', sp.minimal_polynomial(sq(2)+sq(3), X))
    for a, b, p, expected in [
        (7,5,2,(1,1)), (85,62,7,(1,2)), (2,1,3,None),
        (-7,-5,2,(-1,-1)),
    ]:
        result = quadratic_cuberoot(Fraction(a), Fraction(b), Fraction(p))
        assert result == expected
        print('quadratic_cuberoot:', (a,b,p), '->', result)
    for radicand,n,expected in [
        (85+62*sq(7),3,1+2*sq(7)),
        (41-29*sq(2),5,1-sq(2)),
    ]:
        result = nthroot(radicand,n)
        assert sp.simplify(result-expected)==0
        assert sp.expand(expected**n-radicand)==0
        print('nthroot:', (radicand,n), '->', result)
    # Ramanujan's pure-cubic identity, proved in Q[t]/(t^3-2).
    t=sp.Symbol('t')
    assert sp.rem((1-t+t*t)**3-9*(t-1), t**3-2,t)==0
    # The fourth-root quotient identity, proved in Q[t]/(t^4-5).
    assert sp.rem((t+1)**4*(3-2*t)-(t-1)**4*(3+2*t),t**4-5,t)==0
    # Additional checks of the quadratic-field criterion against all small
    # constructed solutions (independent rational coefficient certificates).
    count=0
    for p in (2,3,5,6,7):
        for A in range(-3,4):
            for B in range(-3,4):
                if B==0: continue
                a=A**3+3*A*B*B*p
                b=3*A*A*B+B**3*p
                assert quadratic_cuberoot(a,b,p)==(A,B)
                count+=1
    print('constructed quadratic-field examples verified:', count)
    print('All checks passed.')


if __name__ == '__main__':
    main()
