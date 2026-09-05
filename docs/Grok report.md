# Radical denesting: a research survey and annotated bibliography

**Denesting** means rewriting a nested radical as an equivalent expression of strictly smaller nesting depth. It is not always possible, and even when it is possible the denested form may use roots of a different index, extra roots of unity, or a larger ambient field. The subject sits at the intersection of classical identities (Ramanujan), field theory (Kummer, Galois groups of radical towers), computational complexity, and computer-algebra practice.

A nested radical over a field \(k\) is defined inductively: elements of \(k\) have depth \(0\); field operations do not increase depth; an \(n\)th root of an expression of depth \(d\) has depth \(d+1\). An expression \(\alpha\) **denests over \(k\)** if there is an equivalent expression of smaller depth. One also distinguishes denesting *in a specified field* \(L\) (all subexpressions of the new formula live in \(L\)) from denesting *over \(k\)* (any extra radicals are allowed). Roots of unity are often treated as depth-\(0\) symbols rather than as nested radicals.

---

## 1. Classical identities and elementary theory

### Two nested square roots

The oldest complete theorem is the denesting of \(\sqrt{a\pm\sqrt{c}}\) with \(a,c\in\mathbb{Q}\). It denests into a sum of two square roots of rationals if and only if \(a>0\) and \(a^2-c=d^2\) for some positive rational \(d\):

\[
\sqrt{a+\sqrt{c}}=\sqrt{\frac{a+d}{2}}+\sqrt{\frac{a-d}{2}},\qquad
\sqrt{a-\sqrt{c}}=\sqrt{\frac{a+d}{2}}-\sqrt{\frac{a-d}{2}}.
\]

This is the “direct denesting” of \(\sqrt{a\pm\sqrt{c}}\). When \(a^2-c\) is not a square but \(c(b^2c-a^2)\) is a square for the more general form \(\sqrt{a+b\sqrt{c}}\), one obtains an **indirect denesting** using fourth roots. Over the reals, no roots other than squares and fourths ever help for expressions built only from square roots (Borodin–Fagin–Hopcroft–Tompa, Theorem 3 below).

### Ramanujan

Ramanujan produced the identities that made denesting a research problem rather than a high-school trick. Representative examples:

\[
\sqrt[3]{\sqrt[3]{2}-1}
=\sqrt[3]{\tfrac19}-\sqrt[3]{\tfrac29}+\sqrt[3]{\tfrac49},
\]

\[
\sqrt{\sqrt[3]{28}-\sqrt[3]{27}}
=\tfrac13\bigl(\sqrt[3]{98}-\sqrt[3]{28}-1\bigr),
\]

\[
\sqrt[4]{\frac{3+2\sqrt[4]{5}}{3-2\sqrt[4]{5}}}
=\frac{\sqrt[4]{5}+1}{\sqrt[4]{5}-1}.
\]

Sources: Ramanujan’s *Collected Papers*; Question 298 in *J. Indian Math. Soc.* (1911); Berndt’s *Ramanujan’s Notebooks*, especially Parts II, IV and V. He gave no general theory.

A complete elementary criterion for the Ramanujan shape \(\sqrt{\sqrt[3]{\alpha}+\sqrt[3]{\beta}}\) was later proved by Honsbeek: if \(\alpha/\beta\) is not a cube in \(\mathbb{Q}\), the expression denests over \(\mathbb{Q}\) if and only if there exist integers \(m,n\) with

\[
\frac{\beta}{\alpha}=\frac{(4m+n)n^3}{4(m-2n)m^3}
\]

(equivalently, a related quartic has a rational root). In particular \(\sqrt{\sqrt[3]{3}+\sqrt[3]{2}}\) does *not* denest.

### Linear independence of radicals

These results underwrite uniqueness and “the sum is zero iff each term is zero” arguments used throughout the algorithmic literature.

- **Besicovitch** (1940). The square roots of the distinct square-free products of the first \(n\) primes are linearly independent over \(\mathbb{Q}\).
- **Siegel**, with earlier special cases by Besicovitch and a slight generalization by **Mordell** (1953); **Kneser** (1974) extended the result to certain complex fields. The degree of a real radical extension \(F(\sqrt[r_1]{q_1},\dots,\sqrt[r_k]{q_k})/F\) equals \(\prod r_i\) under natural independence hypotheses, and the obvious monomials form a basis.
- Blömer’s thesis contains a short modern proof of Siegel’s theorem and uses it to characterize denesting elements.

### Infinite nested radicals (related, not denesting)

**Herschfeld** (1935), *Amer. Math. Monthly* 42:419–429: a nested radical of nonnegative real terms \(\sqrt{a_1+\sqrt{a_2+\cdots}}\) converges iff the sequence is bounded. This is about infinite nests (Vieta’s formula for \(\pi\), Ramanujan’s \(\sqrt{1+2\sqrt{1+3\sqrt{1+\cdots}}}=3\), etc.), not finite denesting, but it is the other classical “nested radical” literature. MathWorld’s page is mostly about this side.

---

## 2. Modern theory and algorithms (1976–2000)

This is the core of the subject. The logical line is: unnested radical bases (Caviness–Fateman, Zippel) \(\to\) square-root denesting (Borodin et al.) \(\to\) Galois-theoretic general denesting (Landau) \(\to\) depth-2 / bounded-degree algorithms that avoid splitting fields (Blömer) \(\to\) minimum-depth formulas with roots of unity (Horng–Huang).

### Precursors: unnested radicals

- **Caviness–Fateman**, “Simplification of radical expressions,” SYMSAC 1976. MACSYMA’s `RADCAN`. Canonical forms and bases for *unnested* radical extensions.
- **Fateman**, *Essays in Algebraic Simplification*, MIT PhD 1972.
- **Zippel**, “Radical simplification made easy,” NASA/MACSYMA Users’ Conference 1977; MIT MS thesis *Simplification of Radicals with Applications to Solving Polynomial Equations*.

### Zippel’s denesting theorem

**Richard Zippel**, “Simplification of expressions involving radicals,” *J. Symbolic Computation* 1 (1985), 189–210.

If \(K/k\) contains a primitive \(d\)th root of unity, \(L=K(\sqrt[d]{a})\) has degree \(d\), and there is a Galois extension \(F/k\) with \(L=KF\), then some \(\beta\in k\) makes \(\beta a\) a \(d\)th power in \(K\), and \(F=k(\sqrt[d]{\beta})\). This is a sufficient Kummer-theoretic condition for a nested radical to live in a simple radical extension of lower depth. The paper also constructs linearly independent bases for sets of (possibly nested) radicals.

**Susan Landau**, “A note on ‘Zippel Denesting’,” *J. Symbolic Computation* 13 (1992), 41–45. Fills a gap in Zippel’s proof and shows the condition is also *necessary*. Combined with Landau–Miller factorization, this yields an algorithm.

### Square roots: the complete real theory

**Allan Borodin, Ronald Fagin, John Hopcroft, Martin Tompa**, “Decreasing the nesting depth of expressions involving square roots,” *J. Symbolic Computation* 1 (1985), 169–188. PDF: `http://www.cs.toronto.edu/~bor/Papers/decreasing-nesting-depth-for-expressions.pdf`.

For \(\sqrt{a+b\sqrt{r}}\) over a field \(k\supseteq\mathbb{Q}\) with \(\sqrt{r}\notin k\):

1. The expression denests using only square roots iff \(a^2-b^2 r\) is a square in \(k\) (equivalently, it already lives in \(k(\sqrt{s})\) for some \(s\in k\)).
2. Fourth roots help precisely when a related element \(\sqrt[4]{r(a^2-b^2 r)}\) or similar lies in a single square-root extension.
3. Over a *real* field, no roots other than squares and fourths ever help for expressions built from square roots only.

They give polynomial-time algorithms for this class, including some depth-3 examples and rational linear combinations of square roots (the combination can denest even when individual terms do not). This paper is what SymPy actually implements.

Gkioulekas (2017) rewrote Theorems 1–2 as elementary “direct vs. indirect denesting” suitable for coursework.

### Landau’s general algorithm

**Susan Landau**, “Simplification of nested radicals,” 30th FOCS (1989), 3–12; *SIAM J. Comput.* 21 (1992), 85–110. DOI 10.1137/0221009. MR1148819.

First algorithm that decides denestability in general and produces a minimum-depth formula when one exists.

- If the base field contains all roots of unity: necessary and sufficient conditions, and the algorithm computes a denesting.
- If not: one can compute a denesting within depth one of optimal after adjoining a single root of unity \(\zeta_\ell\), where \(\ell\) is determined by the derived series of the Galois group of the splitting field. \(\zeta_\ell\) is represented symbolically (depth 0), not as a nested radical.
- Runtime is polynomial in the size of the *splitting field* of the minimal polynomial of \(\alpha\) over \(k\), hence exponential in the nesting depth / degree in the worst case.

Structural facts: a minimum-depth nesting exists whose terms live in the splitting field (when roots of unity are in the base field); without them, depth increases by at most 1 after adjoining one root of unity.

**Landau**, “How to Tangle with a Nested Radical,” *Mathematical Intelligencer* 16(2) (1994), 49–55. Best survey of the 1985–94 theory. Freely available PDF: `https://www.cimat.mx/~gil/docencia/2019/algebra_moderna(posgrado)/%5BLandau%5DHow-to-Tangle-with-a-Nested-Radical(1994).pdf`. Frames the three questions — existence, method, complexity — and records that the *general* problem (practical, polynomial-time, no extra roots of unity) remained open.

Related subroutine: **Landau–Miller**, “Solvability by radicals is in polynomial time,” *J. Comput. System Sci.* 30 (1985), 179–208.

### Blömer: depth 2 without Galois theory

**Johannes Blömer**

- FOCS 1991: computing sums of radicals in polynomial time.
- “How to Denest Ramanujan’s Nested Radicals,” 33rd FOCS (1992), 447–456. DOI 10.1109/SFCS.1992.267807. Depth-2 nested radicals; denesting by real radicals or radicals of bounded degree. Describes the structure of denestings and an upper bound on their size. Algorithm that *does not* construct the minimal polynomial or splitting field; runtime at most (and typically much less than) polynomial in the description size of the minpoly. First algorithm of this complexity. Can also detect some denestings of depth \(>2\). Archived PDF often circulated as `DenestRamanujansNestedRadicals.pdf`.
- PhD thesis, *Simplifying Expressions Involving Radicals*, FU Berlin 1993. Full text: `https://cs.nyu.edu/exact/pap/rootBounds/sumOfSqrts/bloemerThesis.pdf`. Chapters 6–7 are the denesting theory: denesting sets, reduction to simple radical extensions, admissible sequences, lattice-reduction reconstruction. Also a short proof of Siegel’s theorem.
- “Denesting by Bounded Degree Radicals,” ESA ’97, LNCS 1284; *Algorithmica* 28 (2000), 2–15. DOI 10.1007/s004530010028. Given a nested radical using only \(d\)th roots, compute an optimal or near-optimal depth denesting that uses only \(D\)th roots for any prescribed multiple \(D\) of \(d\). Runtime polynomial in the description size of the splitting field. Recovers Landau-style denestings as a special case.

### Minimum-depth formulas with roots of unity

**Gwoboa Horng and Ming-Deh Huang**, “Simplifying nested radicals and solving polynomials by radicals in minimum depth,” 31st FOCS (1990), 847–856; Horng’s USC PhD thesis (same title). Follow-up: Horng–Huang, “Solving polynomials by radicals with roots of unity in minimum depth,” *Math. Comp.* 68 (1999), 881–885.

If \(\alpha\) is solvable by radicals, an optimal nested radical *with roots of unity treated as depth 0* can be read off the derived series of \(\mathrm{Gal}(L(\zeta_n)/k(\zeta_n))\), where \(L\) is the splitting field of \(\alpha\) and \(n\) is divisible by the discriminant of the maximal abelian subextension of \(L\) and by the exponent of \(\mathrm{Gal}(L/k)\). They also treat the dual problem: writing the roots of a solvable polynomial as a nested radical of minimum depth.

**Carl Frank Cotner**, *The Nesting Depths of Radical Expressions*, Berkeley PhD 1995 (advisor H. W. Lenstra, Jr.). Nesting depth of an algebraic number is computable; algorithm for a minimum-depth formula. Cited throughout the later literature.

---

## 3. Later special-form theory (1999–2025)

### Cubic and Ramanujan-type formulas

- **Mascha Honsbeek**, “Denesting certain nested radicals of depth two,” Univ. Nijmegen report 9916 (1999), `https://repository.ubn.ru.nl/bitstream/handle/2066/18722/18722.pdf`. And the PhD thesis *Radical Extensions and Galois Groups*, Radboud 2005, `https://www.math.ru.nl/~bosma/students/honsbeek/M_Honsbeek_thesis.pdf` (promotor Keune; copromotores Bosma, de Smit; committee includes Beukers, Cohen, Lenstra). Chapter 3 is the Ramanujan cubic criterion above; the rest develops Galois groups of radical extensions *without* assuming roots of unity in the ground field (so Kummer theory does not apply directly).
- **B. Sury**, “Ramanujan’s nested radicals,” lecture notes: `https://www.isibang.ac.in/~sury/ramanujanday.pdf`. Galois criterion: for \(\delta\in\mathbb{Q}(\sqrt[3]{c})\) with \(c\) not a cube, \(\sqrt{\delta}\) denests over \(\mathbb{Q}\) iff the second commutator subgroup of \(\mathrm{Gal}(M/\mathbb{Q})\) is trivial, \(M\) the Galois closure of \(\mathbb{Q}(\sqrt{\delta})\). Recovers the \(m,n\)-criterion.
- **Krepkii–Pimenov** / **Antipov–Pimenov**, “Cube root Ramanujan formulas and elementary Galois theory,” *Vestnik St. Petersburg Univ. Math.* (2015), DOI 10.3103/S106345411504007X; “Ramanujan denesting formulas for cubic radicals,” *Vestnik* 53 (2020), 115–121, DOI 10.1134/S1063454120020028. Answer Zippel’s uniqueness question in the pure-cubic case: Ramanujan-type formulas are unique, have at most three summands, the norm must be a cube, and the associated cyclic cubic is reducible iff the cube root denests.
- **Alberto Cavallo**, “Denesting cubic radicals,” arXiv:2403.04776 (2024; v2 Sep 2024). Complete criterion for \(\sqrt[3]{a+b\sqrt{p}}=A+B\sqrt{p}\) with \(a,b\in\mathbb{Q}\), \(p>0\) not a square: \(N=a^2-b^2p\) is a rational cube *and* \(R(x)=x^3-3Nx-2aN\) is reducible over \(\mathbb{Q}\). Then \(A=r/(2\sqrt[3]{N})\) and \(B=b\sqrt[3]{N^2}/(r^2-N)\) where \(r\) is the unique rational root of \(R\). Connection to Cardano’s formula; a small program is included.

### Higher depth, other indices, Euclid

- **Kaan Dokmeci**, “Theorems on Field Extensions and Radical Denesting,” MIT PRIMES 2017, `https://math.mit.edu/research/highschool/primes/materials/2017/Dokmeci.pdf`. Depth-2 denesting over \(\mathbb{Q}\) and \(\mathbb{Q}(t)\) without Galois theory, using a roots-of-unity filter and degree arguments; an algorithm that makes a radical extension simple; results on sums of radicals; a sufficient condition for *non*-denestability.
- **N. N. Osipov and A. A. Kytmanov**, “Simplification of Nested Real Radicals Revisited,” CASC 2021, LNCS 12865, 293–313. Polynomial-time simplification of at most doubly nested real radicals was known; they treat *triply* nested real radicals over \(\mathbb{Q}\) and give examples that cannot be simplified.
- **Kurt Girstmair**, “Reducing radicals in the spirit of Euclid,” arXiv:2004.06039 (2020); also *J. Symbolic Computation*. For odd \(p\ge 3\), writes \(\sqrt[p]{d+\sqrt{R}}\) (degree \(2p\)) as a polynomial in irrationals of degree \(\le p\). Inspired by Euclid’s Book X; proof uses Zeilberger’s algorithm / hypergeometric summation. Cites Zippel, Horng–Huang, Landau.
- **Joseph Tonien**, “Nested fifth root radical identities from elliptic curves,” *Journal of Computational Algebra* 13–14 (2025), 100032. Ramanujan-style fifth-root identities derived from a family of elliptic curves; SageMath code included.
- **Geoffrey B. Campbell and Aleksander Zujev**, “Variations on Ramanujan’s nested radicals,” arXiv:1511.06865 (2015). New Ramanujan-style identities.

A useful “denesting structure theorem” (Bill Dubuque, Math.SE, drawing on Blömer): if a real nested radical denests using only real radicals, then after multiplying the radicand by an element of the base field and a power-product of the inner radicals, the denesting already takes place in the field generated by the radicand. This is the theoretical reason the “subtract \(\sqrt{\mathrm{Norm}}\), divide \(\sqrt{\mathrm{Trace}}\)” heuristic works so often.

---

## 4. Computer-algebra implementations

No major CAS implements Landau’s or Blömer’s general algorithms. Practice is heuristics plus the Borodin–Fagin–Hopcroft–Tompa square-root theory.

| System | What exists | Status |
|---|---|---|
| **SymPy** | `sympy.simplify.sqrtdenest` | Implements BFHT 1985 + Jeffrey–Rich ideas. Handles \(\sqrt{a\pm b\sqrt{c}}\), some deeper square-root towers, and some linear combinations that cancel. Default recursion depth 3. Source: `sympy/simplify/sqrtdenest.py`. Square roots only; misses most Ramanujan cubics. |
| **Maxima** | package `raddenest` (gschintgen) | Direct port of SymPy 1.0 `sqrtdenest`. `RADCAN` handles unnested radicals (Caviness–Fateman lineage). |
| **Mathematica** | `ResourceFunction["RadicalDenest"]` | Heuristic package by Swastik Banerjee (2020–2024), based on Corey Ziegler Hunts, Bill Gosper, and Daniel Lichtblau. `TimeConstraint` (default 5s); may miss a denesting that exists; accepts `Root` objects. `https://resources.wolframcloud.com/FunctionRepository/resources/RadicalDenest`. Built-in `FullSimplify` / `PowerExpand` are incomplete. Gosper’s earlier “Strad” / `DenestRadicals3` notebooks: Wolfram Community thread “Heuristic package to denest radicals.” |
| **Derive** | Jeffrey–Rich algorithms | The practical algorithm in Wester’s book (below). Nesting measure \(N(\cdot)\) as a termination guard; recursive \(\sqrt{X\pm Y}\) via \(X^2-Y^2\). |
| **Maple** | no dedicated `denest` | `simplify` denests some nested sqrts; `radfield` converts radicals to independent `RootOf`s (field-basis problem, not denesting). Users regularly report failures on identities such as \(\sqrt{x+2\sqrt{x-1}}=\sqrt{x-1}+1\). |
| **SageMath** | no high-level `denest` | Relies on Maxima/SymPy backends. `QQbar` / `AA.minpoly()` can decide whether a nested *real* radical is rational (degree-1 minpoly), which is equality testing, not a denested formula. |
| **Magma** | none public | Number-field / radical-extension machinery exists; denesting would be hand-rolled. |
| **rssn** (Rust) | `denest_sqrt` | Pattern-match denesting of \(\sqrt{A\pm B\sqrt{C}}\). |

**David J. Jeffrey and Albert D. Rich**, “Simplifying Square Roots of Square Roots by Denesting,” in M. J. Wester (ed.), *Computer Algebra Systems: A Practical Guide*, Wiley 1999. PDF: `https://cybertester.com/data/denest.pdf`. The paper CAS implementers actually use. Defines a nesting measure \(N(x)\) (numbers have \(N=1\); \(N(\sqrt[n]{y})=1+N(y)\); products take max; sums add), then recursively tries \(\sqrt{X+Y}=\sqrt{(X+\sqrt{X^2-Y^2})/2}+\sqrt{(X-\sqrt{X^2-Y^2})/2}\) and stops when \(N\) does not drop. Argument: full Galois algorithms are too expensive; heuristics win in practice. Designed for Derive.

Gosper’s recurring observation: the Galois-theoretic papers almost never exhibit new pretty denestings; heuristics find the identities people actually want.

---

## 5. Books and surveys

There is no monograph devoted solely to denesting. The subject lives in papers, theses, and chapters.

**Surveys and encyclopedia pages**

- Landau 1994 *Mathematical Intelligencer* (above) — still the best narrative survey of the algorithmic theory.
- Wikipedia, *Nested radical*, § Denesting — two-sqrt theorem, Landau stub, Ramanujan list. `https://en.wikipedia.org/wiki/Nested_radical`
- Weisstein, “Nested Radical,” MathWorld. Mostly infinite nests; references Landau/Zippel/Jeffrey–Rich. `https://mathworld.wolfram.com/NestedRadical.html`
- Gkioulekas 2017 — elementary survey of the square-root case.

**Books containing substantial related material**

- Bruce C. Berndt, *Ramanujan’s Notebooks*, Parts II, IV, V, Springer. The identities and (in Berndt’s commentary) proofs.
- Srinivasa Ramanujan, *Collected Papers* (Hardy–Aiyar–Wilson), AMS reprint.
- M. J. Wester (ed.), *Computer Algebra Systems: A Practical Guide*, Wiley 1999 — Jeffrey–Rich chapter.
- J. von zur Gathen and J. Gerhard, *Modern Computer Algebra*, CUP — radical extensions, factorization over number fields; not denesting per se, but the algorithmic substrate.
- K. O. Geddes, S. R. Czapor, G. Labahn, *Algorithms for Computer Algebra*, Kluwer 1992 — same.
- J. M. Borwein and P. B. Borwein, *Pi and the AGM*, Wiley — infinite nested radicals and AGM, not finite denesting.
- Polya–Szegő, *Problems and Theorems in Analysis I* — classical nested-radical exercises.

**Theses** (often the best detailed expositions)

- Zippel, MIT MS 1977.
- Blömer, FU Berlin 1993.
- Horng, USC 1990.
- Cotner, Berkeley 1995 (Lenstra).
- Honsbeek, Radboud 2005.
- Sandra Rahal, “Introduction to nested radicals,” Stockholm University bachelor thesis 2017.

---

## 6. Web pages, blogs, and Q&A that are actually useful

- **BrownMath**, “Denesting Radicals (or Unnesting Radicals),” `https://brownmath.com/alge/nestrad.htm` — best elementary cookbook; works through Gkioulekas’s direct and indirect formulas with numerical checks.
- **Bill Dubuque**, Math.SE answers on denesting (especially the structure theorem and the “subtract \(\sqrt{\mathrm{Norm}}\), divide \(\sqrt{\mathrm{Trace}}\)” heuristic). Starting points: `https://math.stackexchange.com/questions/4680` and `https://math.stackexchange.com/questions/16331`.
- MSE 871639, “Denesting radicals like \(\sqrt[3]{\sqrt[3]{2}-1}\)” — identities, links to the archived Blömer FOCS PDF, discussion of units in cubic fields. `https://math.stackexchange.com/questions/871639`
- MathOverflow 319874, “Relevance of Landau’s Algorithm for Denesting Radicals” — short answer: it solved decidability but is exponential; polynomial-time general denesting is still open. `https://mathoverflow.net/questions/319874`
- MathOverflow 410388, denesting sums of several square roots.
- MathOverflow 344478, deciding whether a nested-radical expression is rational (Sage `AA.minpoly`).
- Wolfram Community: Gosper’s heuristic-package thread; Banerjee’s “Radical Denest: an ancient difficult task in symbolic computation.”
- Gaurav Tiwari, “Introduction to Nested Radicals / Ramanujan’s Nested Radicals” — recreational but carefully written.

---

## 7. Open problems

As of the mid-2020s literature the status is:

1. **Decidability is settled** (Landau 1989/1992). General denesting is decidable, but the algorithm is exponential in nesting depth because it builds a splitting field.
2. **A polynomial-time algorithm for general nested radicals remains open.** This is stated as such by Gkioulekas (2017) and on MathOverflow 319874. Depth-2 real square roots are in P (BFHT); depth-2 Ramanujan-type expressions have practical non-Galois algorithms (Blömer); depth 3 real radicals over \(\mathbb{Q}\) have partial algorithms (Osipov–Kytmanov 2021).
3. **No major CAS implements Landau or Blömer.** Production systems use BFHT-style square-root heuristics and Gosper-style search. Maple and Mathematica still fail on many identities that have been known for a century.
4. **Canonical forms.** Two nested-radical expressions can be equal without either denesting. Equality testing of radical expressions is a related, not fully solved, problem (already stressed by Caviness–Fateman; zero-testing sums of real radicals is better understood than finding a denested *formula*).
5. **Denesting over \(\mathbb{Q}\) without roots of unity**, at minimum depth, is strictly harder than the version that is allowed to adjoin \(\zeta_\ell\) and count it as depth 0 (Landau’s “within one of optimal” theorem).
6. **Higher-index identities** (5th roots, mixed indices) are still produced case-by-case (Tonien 2025 via elliptic curves; Cavallo 2024 for one cubic family) rather than by a uniform algorithm that people run.

---

## 8. Compact annotated bibliography (primary sources)

**Classical and elementary**

- Euclid, *Elements*, Book X — geometric identities later re-read as denestings (see Girstmair 2020).
- S. Ramanujan, Question 298, *J. Indian Math. Soc.* (1911); *Collected Papers*; notebooks (Berndt eds.).
- A. Besicovitch, “On the linear independence of fractional powers of integers,” *J. London Math. Soc.* 15 (1940), 3–6.
- A. Herschfeld, “On infinite radicals,” *Amer. Math. Monthly* 42 (1935), 419–429.
- L. J. Mordell, “On the linear independence of algebraic numbers,” *Pacific J. Math.* 3 (1953), 625–630.
- M. Kneser, “Lineare Abhängigkeit von Wurzeln,” *Acta Arith.* 26 (1974/75).
- J. M. Borwein and G. de Barra, “Nested Radicals,” *Amer. Math. Monthly* 98 (1991), 735–739 — infinite nests.

**Algorithmic core**

- B. F. Caviness and R. J. Fateman, “Simplification of radical expressions,” SYMSAC 1976.
- R. Zippel, “Simplification of expressions involving radicals,” *J. Symbolic Computation* 1 (1985), 189–210.
- A. Borodin, R. Fagin, J. Hopcroft, M. Tompa, “Decreasing the nesting depth of expressions involving square roots,” *J. Symbolic Computation* 1 (1985), 169–188.
- S. Landau and G. Miller, “Solvability by radicals is in polynomial time,” *J. Comput. System Sci.* 30 (1985), 179–208.
- S. Landau, “Simplification of nested radicals,” FOCS 1989 / *SIAM J. Comput.* 21 (1992), 85–110.
- S. Landau, “A note on ‘Zippel Denesting’,” *J. Symbolic Computation* 13 (1992), 41–45.
- S. Landau, “How to Tangle with a Nested Radical,” *Math. Intelligencer* 16(2) (1994), 49–55.
- G. Horng and M.-D. Huang, FOCS 1990; *Math. Comp.* 68 (1999), 881–885.
- J. Blömer, FOCS 1992; PhD FU Berlin 1993; *Algorithmica* 28 (2000), 2–15.
- C. F. Cotner, Berkeley PhD 1995.

**Special forms and later work**

- M. Honsbeek, Nijmegen report 1999; Radboud PhD 2005.
- D. J. Jeffrey and A. D. Rich, in Wester (ed.), Wiley 1999.
- E. Gkioulekas, *Int. J. Math. Educ. Sci. Technol.* 48 (2017), 942–953.
- K. Dokmeci, MIT PRIMES 2017.
- N. N. Osipov and A. A. Kytmanov, CASC 2021, LNCS 12865.
- K. Girstmair, arXiv:2004.06039 (2020).
- Antipov–Pimenov, *Vestnik St. Petersburg Univ. Math.* 53 (2020).
- A. Cavallo, arXiv:2403.04776 (2024).
- J. Tonien, *J. Computational Algebra* 13–14 (2025), 100032.

**Starting points if you read only four items**

1. Landau 1994 *Intelligencer* — orientation and the theorem landscape.  
2. Borodin–Fagin–Hopcroft–Tompa 1985 — the square-root case, completely solved.  
3. Blömer FOCS 1992 + thesis Chapter 6 — how to denest Ramanujan-type depth-2 expressions without building splitting fields.  
4. Jeffrey–Rich 1999 — what a CAS actually does, and why.
