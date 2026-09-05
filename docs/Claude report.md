# Radical Denesting: An Annotated Bibliography

## TL;DR
- Denesting has a well-defined theoretical core: a **complete decision procedure exists** (Landau 1989/1992, based on Galois theory and factorization over number fields — her SIAM abstract states the algorithms "require computing the splitting field of the minimal polynomial of α over k, and have exponential running time," while the 1989 FOCS version bounds runtime as "polynomial in the size of the splitting field"), and the depth‑2 two‑square‑root case is completely and elementarily solved; higher‑depth and higher‑degree cases are only partially solved.
- The literature splits cleanly into four strands: (i) Ramanujan's identities and their number‑theoretic explanation (Berndt–Chan–Zhang; Krepkii–Pimenov; Antipov–Pimenov), (ii) the 1976–2000 algorithmic canon (Caviness–Fateman, Borodin–Fagin–Hopcroft–Tompa, Zippel, Landau, Blömer, Horng–Huang), (iii) modern complexity/identity‑testing work (sum‑of‑square‑roots; Balaji–Nosan–Shirmohammadi–Worrell), and (iv) CAS implementations.
- CAS reality: **only depth‑2 square‑root denesting is robustly implemented** in the mainstream (SymPy `sqrtdenest`, Maxima `raddenest`, Maple `radnormal`/`sqrt`, Wolfram `RootReduce`/`RadicalDenest`); Landau's and Blömer's general algorithms are **not implemented in any mainstream CAS** — the single largest gap in the field.

## Key Findings
- The **depth‑2 two‑square‑root theorem** (√(a+b√c) denests iff a²−b²c is a perfect square of a rational) is classical, elementary, and the basis of essentially every production implementation. Its structure‑theoretic completion (why nothing more complicated than a sum of two surds is ever needed) is a small Galois/Kummer argument, spelled out in the Wikipedia article and in Borodin et al.
- **Landau (1992)** gives the first general decision procedure and proves the deep structural fact that roots of unity may be genuinely required: her abstract states that when the base field lacks all roots of unity, one computes a denesting "within one of optimal over the base field adjoining a single root of unity," representing "a primitive lth root of unity … by its symbol ζ_l, rather than as a nested radical." Her "Note on Zippel denesting" repairs and completes Zippel's (1985) sufficient condition, showing it is also necessary.
- **Blömer (1991, 1992)** is the algorithmically sharpest classical work: a polynomial‑time Monte Carlo zero‑test for sums of radicals, and a depth‑2 denesting algorithm that avoids Galois theory / minimal‑polynomial construction entirely, making it far faster than Landau's in its domain.
- The cube‑root Ramanujan phenomenon (∛(∛2−1) = ∛(1/9)−∛(2/9)+∛(4/9)) is now fully explained by the **Galois theory of cubic fields** (Krepkii–Pimenov 2015; Antipov–Pimenov 2020). Antipov–Pimenov, answering "Zippel's question," prove that in a pure cubic extension "there must be no more than three summands in the right‑hand side and the norm of the irrationality in question must be a cube," and that such "Ramanujan‑type formulas are in some sense unique."
- Modern complexity work has migrated to the closely related **sum‑of‑square‑roots** and **radical identity‑testing** problems. Balaji–Nosan–Shirmohammadi–Worrell (LICS 2022) "place the problem in coNP assuming the Generalised Riemann Hypothesis (GRH), improving on the straightforward PSPACE upper bound obtained by reduction to the existential theory of reals," with 2‑RIT "in coRP assuming GRH and in coNP unconditionally."

---

## 1. Historical & Ramanujan

**S. Ramanujan, Collected Papers / Notebooks / Journal of the Indian Mathematical Society (1911–1919).** The origin of the subject. Question 289 (JIMS, 1911) posed the infinite nested radical √(1+2√(1+3√(1+4…))) = 3; his notebooks contain the celebrated finite identities ∛(∛2−1) = ∛(1/9)−∛(2/9)+∛(4/9) and √(∛5−∛4) = (∛2+∛20−∛25)/3. These are the canonical test cases every later algorithm is measured against. Relevant problems: Question 525 (solution by N. S. Aiyar, JIMS 6, 1914, 191–192), Question 1070 (JIMS 11, 1919), Question 1076 (JIMS 11, 1919).

**B. C. Berndt, H. H. Chan, L.-C. Zhang, "Ramanujan's association with radicals in India," American Mathematical Monthly 104 (10) (1997), 905–911.** DOI 10.1080/00029890.1997.11990738. The definitive historical‑mathematical account of how Ramanujan came to his radical identities, connecting them to class invariants and singular moduli (over 100 class‑invariant values recorded in his notebooks, used for high‑precision π approximations). Berndt's publications page has PostScript copies: https://faculty.math.illinois.edu/~berndt/publications.html.

**B. C. Berndt, H. H. Chan, L.-C. Zhang, "Radicals and units in Ramanujan's work," Acta Arithmetica 87 (2) (1998), 145–158.** Free full text: http://eudml.org/doc/207210. Explains the unit‑theoretic and Chebyshev‑polynomial structure behind Ramanujan's cube‑root and higher denestings; ties the identities to Weber class invariants and singular moduli via hypergeometric functions.

**B. C. Berndt, Ramanujan's Notebooks, Part IV (Springer, 1994) and Part V (Springer, 1998).** The chapters on radicals collect and prove the notebook identities with full rigor; the standard reference for the primary‑source identities.

**D. Shanks, "Incredible identities," Fibonacci Quarterly 12 (1974), 271, 280;** with a correcting **Letter to the Editor by W. G. Spohn, Fibonacci Quarterly 14 (1976), 12** (MR0349623, MR0384744). The classic short expository note that popularized striking denesting identities in the recreational/expository literature; the Spohn letter corrects it. A "Incredible Identities Revisited" appears in Fibonacci Quarterly (Oct 2024).

**T. J. Osler, "Cardan polynomials and the reduction of radicals," Mathematics Magazine 74 (1) (2001), 26–32.** Uses Cardan (Chebyshev‑like) polynomials to reduce/simplify radical expressions; a self‑contained elementary route to some Ramanujan‑style reductions. This "Cardan polynomial" idea reappears in Maxima's `raddenest` cube‑root routine. See also Wituła–Słota, "Cardano's formula, square roots, Chebyshev polynomials and radicals," J. Math. Anal. Appl. 363 (2010), 639–647 (extends Osler's approach to Vieta–Lucas/Vieta–Fibonacci polynomials).

**Historical algebra (Bombelli, Cardano, casus irreducibilis).** The nested‑radical form of the Cardano cubic solution and the *casus irreducibilis* (three real roots forced through cube roots of complex numbers) is the oldest denesting context; well covered in Wikipedia "Nested radical" §"In the solution of the cubic equation," and in Osler's expository "An easy look at the cubic formula" (https://math.ucr.edu/~res/math153-2019/osler-An_easy_look_at_the_cubic_formula.pdf).

---

## 2. Classical Algorithmic Papers, 1976–2000

**B. F. Caviness, R. J. Fateman, "Simplification of radical expressions," Proc. 1976 ACM Symposium on Symbolic and Algebraic Computation (SYMSAC '76), 329–338.** Free PDF: https://people.eecs.berkeley.edu/~fateman/papers/radcan.pdf. Describes the RADCAN algorithm (implemented in MACSYMA by Zippel and Trager) for *unnested* radical canonicalization; the foundational CAS treatment of radical simplification and the starting point everyone cites, though it does not itself denest.

**A. Borodin, R. Fagin, J. E. Hopcroft, M. Tompa, "Decreasing the nesting depth of expressions involving square roots," J. Symbolic Computation 1 (2) (1985), 169–188.** Free PDF: http://www.cs.toronto.edu/~bor/Papers/decreasing-nesting-depth-for-expressions.pdf; IBM copy: https://researcher.watson.ibm.com/researcher/files/us-fagin/symb85.pdf. The sqrt‑of‑sqrt algorithm: given a depth‑2 expression over ℚ involving only square roots, it denests over ℚ when possible, and shows the technique does not generalize past depth 2. **This is the algorithm SymPy's `sqrtdenest` and Maxima's `raddenest` are primarily based on.**

**R. Zippel, "Simplification of expressions involving radicals," J. Symbolic Computation 1 (2) (1985), 189–210.** DOI 10.1016/S0747-7171(85)80014-6; free PDF via ScienceDirect open archive: https://www.sciencedirect.com/science/article/pii/S0747717185800146. Computes a linearly independent basis for a set of (possibly nested) radicals and gives a *structure theorem*: a sufficient condition for a nested radical to be expressible in lower nesting depth. Grew out of Zippel's 1977 MIT thesis.

**S. Landau, "Simplification of nested radicals," 30th FOCS (1989), 314–319** (DOI 10.1109/SFCS.1989.63496); journal version **SIAM J. Computing 21 (1) (1992), 85–110** (DOI 10.1137/0221009). Free PDF: https://www.researchgate.net/publication/2629046. The landmark result: necessary and sufficient conditions for denestability over a field, and the **first algorithm to decide denestability and compute a minimum‑depth denesting**. Based on Galois theory, field theory, and polynomial factorization over algebraic number fields; roots of unity ζ_l are treated as symbols of zero depth. Per the abstract, the algorithms "require computing the splitting field of the minimal polynomial of α over k, and have exponential running time," and when the base field lacks all roots of unity one obtains a denesting "within one of optimal over the base field adjoining a single root of unity" — the precise sense in which roots of unity are sometimes unavoidable.

**S. Landau, "A note on Zippel denesting," J. Symbolic Computation 13 (1) (1992), 41–45.** Fills a lacuna in Zippel's (1985) proof and shows his sufficient condition for denesting is also necessary; connects the problem to Landau–Miller machinery. CiteSeerX: http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.35.5512.

**S. Landau, G. Miller, "Solvability by radicals is in polynomial time," J. Computer and System Sciences 30 (2) (1985), 179–208.** The solvability‑by‑radicals decision procedure whose techniques underpin Landau's denesting work; a companion result shows an optimal nested radical with roots of unity for a root of a solvable polynomial can be effectively constructed from the derived series of the solvable Galois group.

**S. Landau, "How to tangle with a nested radical," The Mathematical Intelligencer 16 (2) (1994), 49–55.** DOI 10.1007/BF03024284; PDF: https://link.springer.com/content/pdf/10.1007/BF03024284.pdf. The accessible exposition of the whole circle of ideas, with the historical Ramanujan framing; the single best entry point before the SIAM paper.

**G. Horng, M.-D. Huang, "Simplifying nested radicals and solving polynomials by radicals in minimum depth," 31st FOCS (1990), 847–854.** A parallel/independent line to Landau: denesting and minimum‑depth radical solving of polynomials, using Galois‑theoretic depth invariants. (ACM thesis record: https://dl.acm.org/doi/abs/10.5555/142931.)

**J. Blömer, "Computing sums of radicals in polynomial time," 32nd FOCS (1991), 670–677.** A polynomial‑time Monte Carlo algorithm to decide whether a sum of radicals lies in a given number field ℚ(α) (in particular whether it is zero/rational). The key complexity result on the sum‑of‑radicals side; the basis of the Wikipedia "Sum of radicals" and "Square‑root sum problem" articles.

**J. Blömer, "How to denest Ramanujan's nested radicals," 33rd FOCS (1992), 447–456.** DOI 10.1109/SFCS.1992.267807; IEEE: https://ieeexplore.ieee.org/document/267807/. A simple condition for depth‑2 denestability using real radicals or radicals of bounded degree, with explicit structure and size bounds, and — crucially — **the first denesting algorithm that avoids Galois theory** (no minimal‑polynomial/splitting‑field construction), so its running time is at most, and usually far below, polynomial in the minimal‑polynomial description size. Can also produce nontrivial denestings for depth > 2.

**J. Blömer, "Denesting by bounded degree radicals," ESA 1997, LNCS 1284, 53–63** (DOI 10.1007/3-540-63397-9_5); journal version **Algorithmica 28 (1) (2000), 2–15** (DOI 10.1007/s004530010028). Given a nested radical involving only d‑th roots, computes an optimal‑or‑near‑optimal‑depth denesting using only D‑th roots (D any multiple of d), in time polynomial in the splitting‑field description size. Generalizes the FOCS '92 special case.

**J. Blömer, "A probabilistic zero‑test for expressions involving roots of rational numbers," ESA 1998, LNCS 1461, 151–162.** Extends the 1991 sum‑of‑radicals zero‑test; the algorithmic ancestor of modern radical identity‑testing.

---

## 3. Galois / Kummer Theory & Modern Research Papers (2000–2026)

**M. Honsbeek, "Radical extensions and Galois groups," PhD thesis, Radboud University Nijmegen (2005).** Free PDF (chapter): https://repository.ubn.ru.nl/bitstream/handle/2066/18722/18722.pdf. Contains the depth‑2 theory "Denesting certain nested radicals of depth two": an if‑and‑only‑if criterion (existence of integers m, n) for denesting √(∛α+∛β) when β/α is not a cube, using Kummer theory and the structure of the field ℚ_∞ generated by all roots of unity. A clean modern Galois‑theoretic treatment; thanks Frits Beukers.

**I. A. Krepkii, K. I. Pimenov, "Cube root Ramanujan formulas and elementary Galois theory," Vestnik St. Petersburg University: Mathematics 48 (2015), 214–223.** DOI 10.3103/S106345411504007X. Explains Ramanujan's cube‑root denestings via elementary Galois theory of cubic fields.

**M. A. Antipov, K. I. Pimenov, "Ramanujan denesting formulas for cubic radicals," Vestnik St. Petersburg University: Mathematics 53 (2) (2020), 115–121.** DOI 10.1134/S1063454120020028. A complete description of Ramanujan‑type cube‑radical formulas when the radicals live in a pure cubic extension, **answering a question of Zippel**: the abstract states "there must be no more than three summands in the right‑hand side and the norm of the irrationality in question must be a cube," and "Ramanujan‑type formulas are in some sense unique in this situation." The sharpest modern statement of the cube‑root theory. Related: Barbero–Cerruti–Murru–Abrate, "Identities involving zeros of Ramanujan and Shanks cubic polynomials," J. Integer Sequences 16 (2013), 13.8.1.

**N. N. Osipov, A. A. Kytmanov, "Simplification of nested real radicals revisited," CASC 2021, LNCS 12865, 293–313.** DOI 10.1007/978-3-030-85165-1_17. The abstract: "we give a detailed presentation of the theory that provides an algorithm which simplifies triply nested reals radicals over ℚ. Some examples of triply nested real radicals that cannot be simplified are also given." Goes one level beyond the depth‑2 barrier; builds directly on Landau and Borodin et al. Osipov also has a Russian‑language "On the simplification of nested real radicals" (Programming and Computer Software).

**A. Cavallo, "Denesting cubic radicals," arXiv:2403.04776 [math.GM] (v1 Feb 2024, v2 Sep 2024).** Abstract: https://arxiv.org/abs/2403.04776; PDF: https://arxiv.org/pdf/2403.04776. The abstract: "We study in details how and when the radical ∛(a+b√p) with rational numbers a,b and p positive can be simplified, providing a complete answer to the problem; furthermore, a program that computes the result is also made available. The solution highlights an interesting connection with the cubic formula." Concretely: set N=a²−b²p and test whether N is a rational cube and R(x)=x³−3Nx−2aN is reducible over ℚ. The accompanying program is hosted on the author's site (https://sites.google.com/view/albertocavallomath/misc, author‑stated in the PDF footnote; page contents unverified).

**A. Dokmeci, "Theorems on field extensions and radical denesting," MIT PRIMES (2017).** Free PDF: https://math.mit.edu/research/highschool/primes/materials/2017/Dokmeci.pdf. Develops denesting of real radicals **without Galois theory**, via the roots‑of‑unity filter and degree arguments, culminating in a general denesting theorem and algorithm that does not require roots of unity; extends to real and transcendental extensions ℚ(t) and to sums of radicals. A useful self‑contained modern treatment.

**E. Gkioulekas, "On the denesting of nested square roots," Int. J. of Mathematical Education in Science and Technology (2017/2018).** Free PDFs: https://faculty.utrgv.edu/eleftherios.gkioulekas/papers/024-denesting-square-roots.pdf and the submitted version. Rederives the depth‑2 denesting equation in a clean formal style suitable for teaching, including the √(a√p+b√q) case and a "splitting‑term" shortcut; good pedagogical companion to Borodin et al.

**B. C. Berndt, G. Andrews, and others, "Observations on some algebraic equations associated with Ramanujan's work."** Treats Ramanujan's x = √(t+√(t+√(t+x))) equation solved by radicals; a number‑theoretic sidelight to the denesting identities. (ResearchGate: https://www.researchgate.net/publication/318594159.)

**N. Mitra, "Generalization of Ramanujan's famous nested radicals to the nth root and their evaluation," arXiv:2404.04051 [math.GM] (2024).** https://arxiv.org/abs/2404.04051. Generalizes the *infinite* nested‑radical evaluation (as opposed to finite denesting) from square roots to n‑th roots via functional equations; adjacent to the denesting literature and useful for the special‑functions reader.

**Sum‑of‑square‑roots / identity‑testing strand:**

**N. Balaji, K. Nosan, M. Shirmohammadi, J. Worrell, "Identity testing for radical expressions," LICS 2022, Article 8, 1–11.** DOI 10.1145/3531130.3533331; arXiv:2202.07961 (v4, 2024): https://arxiv.org/abs/2202.07961; Oxford ORA PDF: https://ora.ox.ac.uk/objects/uuid:9d9bbfe8-d1a3-4397-91b1-57781e16c957. Radical Identity Testing (does a circuit polynomial vanish at real radicals ⁿ√a?) is placed, per the abstract, "in coNP assuming the Generalised Riemann Hypothesis (GRH), improving on the straightforward PSPACE upper bound obtained by reduction to the existential theory of reals." The restricted 2‑RIT (square roots of primes) is at least as hard as PIT (Chen–Kao), and is shown to be in coRP under GRH and in coNP unconditionally. The current frontier of the decidability/complexity side.

**L. Gaillard, G. Jindal, "On the order of power series and the sum of square roots problem," ISSAC 2023.** DOI 10.1145/3597066.3597079; arXiv:2304.13605: https://arxiv.org/pdf/2304.13605. Relates the sum‑of‑square‑roots problem to the order (lowest nonzero exponent) of a power series; recent progress on the long‑open SQRT‑SUM complexity.

**Square‑root sum problem (survey references).** Wikipedia "Square‑root sum problem" (https://en.wikipedia.org/wiki/Square-root_sum_problem) and "Sum of radicals" (https://en.wikipedia.org/wiki/Sum_of_radicals); Open Problem Garden "Complexity of square‑root sum" (http://garden.irmacs.sfu.ca/op/complexity_of_square_root_sum). **E. Allender, P. Bürgisser, J. Kjeldgaard‑Pedersen, P. B. Miltersen, "On the complexity of numerical analysis," SIAM J. Comput. 38 (5) (2009), 1987–2006**, places SQRT‑SUM in the Counting Hierarchy — the best unconditional upper bound. These frame why exact denesting/zero‑testing is hard in the Turing model.

---

## 4. Expository Articles, Textbooks, Encyclopedia Entries

**Wikipedia, "Nested radical" (§Denesting).** https://en.wikipedia.org/wiki/Nested_radical. Contains a complete, correct proof of the depth‑2 two‑square‑root theorem (denest √(a+√b) iff a²−b is a rational square) *and* the Galois‑theoretic argument (Klein four‑group over ℚ(√p,√q)) showing a denesting, when it exists, needs at most two surds. References Landau, Borodin et al., Jeffrey–Rich. The best free starting reference at expert level.

**B. Sury, "Ramanujan's route to roots of roots," lecture notes, ISI Bangalore (Ramanujan Day / IIT Madras talk).** Free PDF: https://www.isibang.ac.in/~sury/ramanujanday.pdf. Expert‑level exposition connecting Ramanujan's nested‑radical identities to units, the ratio‑not‑a‑cube condition, the asymmetry example (α=−4, β=5 denests but α=5, β=−4 does not), and Rogers–Ramanujan continued fractions. Excellent bridge between the historical identities and the Galois/Kummer theory.

**MathWorld, "Nested Radical."** https://mathworld.wolfram.com/NestedRadical.html. Weisstein's encyclopedic entry, with the denesting criterion and many identities; standard quick reference.

**D. J. Jeffrey, A. D. Rich, "Simplifying square roots of square roots by denesting," in Computer Algebra Systems: A Practical Guide, M. J. Wester (ed.), Wiley, Chichester, 1999 (ISBN 0‑471‑98353‑5).** Free PDF: https://cybertester.com/data/denest.pdf. Book contents: https://math.unm.edu/~wester/cas/book/contents.html. Defines the N(e) complexity measure (N(x)=1; N(x^(m/n))=1+N(x); N(x·y)=max; N(x+y)=N(x)+N(y)) used to control recursive denesting; **one of the two algorithms SymPy's `sqrtdenest` cites, and the complexity measure adopted by Maple and by Maxima's `raddenest`.**

**Textbook treatments:**
- **R. Zippel, Effective Polynomial Computation (Kluwer, 1993)** — the author's structure theorem in textbook form.
- **K. O. Geddes, S. R. Czapor, G. Labahn, Algorithms for Computer Algebra (Kluwer, 1992)** — the standard CAS‑algorithms text; radical simplification/normalization.
- **J. von zur Gathen, J. Gerhard, Modern Computer Algebra (CUP, 3rd ed. 2013)** — factoring over number fields and the algebraic machinery denesting depends on.
- **J. H. Davenport, Y. Siret, É. Tournier, Computer Algebra (Academic Press, 1988; French orig. Masson 1987)** — radical simplification in CAS.
- **H. Cohen, A Course in Computational Algebraic Number Theory (Springer GTM 138, 1993)** — number‑field algorithms underlying denesting.
- **D. A. Cox, Galois Theory (Wiley, 2nd ed. 2012)** — radical extensions, roots of unity: the theory background.

---

## 5. MathOverflow / Math.StackExchange & Developer Threads

*(I was unable to individually verify exact URLs for the Q&A threads within budget; where I cannot confirm a live URL I say so rather than fabricate one.)*
- **Math.SE, "Denesting √(a+b√c) — general method"**: substantive answers derive the a²−b²c criterion. Exact URL unverified.
- **MathOverflow, "Is there an algorithm to decide whether a nested radical denests?"**: answers point to Landau (1992) and Blömer, with Galois‑theoretic explanations. Exact URL unverified.
- **Math.SE, Ramanujan ∛(∛2−1) denesting**: answers reconstruct the identity via ℚ(∛2) arithmetic. Exact URL unverified.

**Verified developer discussions (most concretely useful):**
- **SymPy issue #2415** — `sqrtdenest` behavior/version differences: https://github.com/sympy/sympy/issues/2415.
- **SymPy issue #27082** — "simplify roots with base having surds," a Gröbner‑basis route to cube‑root denesting (recognizing (85+62√7)^(1/3)=1+2√7): https://github.com/sympy/sympy/issues/27082.
- **Maxima‑discuss thread announcing `raddenest`** (G. Schintgen, 2017): https://sourceforge.net/p/maxima/mailman/maxima-discuss/thread/slrno8nek9.2pg.robert.dodier@freekbox.fglan/.
- **Wolfram Community, "Radical Denest: an ancient difficult task in symbolic computation"**: https://community.wolfram.com/groups/-/m/t/2120629; and "Heuristic package to denest radicals": https://community.wolfram.com/groups/-/m/t/980264.

---

## 6. CAS Implementations & Source Code

**SymPy — `sympy.simplify.sqrtdenest`.** Docs: https://docs.sympy.org/latest/modules/simplify/simplify.html; source `sympy/simplify/sqrtdenest.py`. The `sqrtdenest(expr, max_iter=3)` entry point, with internal `_sqrtdenest0`, `_sqrt_match` (matches a+b√r choosing the maximal‑depth √r), `_denester`, `_sqrt_symbolic_denest`, `_subsets`, `is_algebraic`. Explicitly based on **[1] Borodin–Fagin–Hopcroft–Tompa (1985)** and **[2] Jeffrey–Rich, "Simplifying Square Roots of Square Roots by Denesting."** Handles depth‑2 square roots and some fourth roots; **does not denest cube roots** (open issue #27082). Example: `sqrtdenest(sqrt(5+2*sqrt(6))) → sqrt(2)+sqrt(3)`.

**Maxima — `raddenest` package (Gilles Schintgen).** GitHub: https://github.com/gschintgen/raddenest; distributed with Maxima under share/raddenest; test suite: https://fossies.org/linux/maxima/share/raddenest/rtest_raddenest.mac. A **direct port of SymPy's `sqrtdenest`** (hence Borodin et al.) **plus original extensions for cube roots and n‑th roots**, including a Cardano‑polynomial routine and use of the Jeffrey–Rich N(e) complexity measure; the author states he did **not** implement Landau's/Blömer's general algorithms. Denests e.g. `sqrt(5+2*sqrt(6)) → sqrt(3)+sqrt(2)`, `(41-29*sqrt(2))^(1/5) → 1-sqrt(2)`, `(5^(1/3)-4^(1/3))^(1/2) → (2^(1/3)+20^(1/3)-25^(1/3))/3`, and multi‑layer expressions like `sqrt(13-2*sqrt(10)+2*sqrt(2)*sqrt(11-2*sqrt(10))) → -1+sqrt(2)+sqrt(10)`. **The most capable free denester for cube/n‑th roots.**

**Maxima — legacy `sqdnst` / built‑in `sqrtdenest`, and `radcan`.** The old `sqdnst` package (`sqrtdenest`) denests sqrt of simple numerical binomial surds; `radcan` canonicalizes radicals; option `radexpand:all` forces some simplifications. As of Maxima 5.44, `sqrtdenest` is built‑in and `load(sqdnst)` is a no‑op. Docs: https://maxima.sourceforge.io/docs/manual/de/maxima_305.html.

**Mathematica / Wolfram Language — `RootReduce`, `ToRadicals`, `FullSimplify`.** `RootReduce` (https://reference.wolfram.com/language/ref/RootReduce.html) reduces algebraic numbers to canonical `Root` objects (methods "NumberField" and "Recursive"), effectively denesting when the result is a quadratic radical or rational (e.g. `RootReduce[Sqrt[7]/Sqrt[5+2Sqrt[6]]]`); `ToRadicals` (https://reference.wolfram.com/language/ref/ToRadicals.html) converts `Root` objects back to radicals. These give *de facto* denesting for algebraic numbers of low degree but there is no user‑facing general nested‑radical denester in the kernel.

**Wolfram Function Repository — `RadicalDenest`.** https://resources.wolframcloud.com/FunctionRepository/resources/RadicalDenest/. Contributed by Swastik Banerjee, based on work by Corey Ziegler, Bill Gosper, and Daniel Lichtblau. `ResourceFunction["RadicalDenest"][expr, TimeConstraint→t]` (default 5 s), accepts `Root` objects. Uses **heuristic methods** (may fail even when a denesting exists), comparing nesting degrees across several approaches and returning the best; versions 1.0.0 (Oct 2020) → 2.1.0 (Apr 2024).

**Maple — `radnormal`, `simplify(...,radical)`, `sqrt`, `rationalize`, `evala`.** `radnormal` (https://www.maplesoft.com/support/help/Maple/view.aspx?path=radnormal) normalizes expressions containing radical numbers and is the recommended tool for nested radicals; `sqrt` and `simplify` will denest √(r₁+r₂√n) with r₁,r₂ rational, n integer. Maple's denesting is reported to use the Jeffrey–Rich N(e) complexity measure. `simplify/radical`, `combine/radical`, `radsimp`, `surd`, and `root` are the associated helpers (Maple help pages under Simplifying).

**SageMath — `AlgebraicNumber.radical_expression()` on `QQbar`/`AA`.** Docs: https://doc.sagemath.org/html/en/reference/number_fields/sage/rings/qqbar.html; introduced in Sage ticket #14239. Computes an exact symbolic radical form for an algebraic number (degree ≤ 4 always, some higher cases), via the exact algebraic‑number machinery (minimal polynomials, isolating intervals), *not* SymPy. Coercing a nested radical into `QQbar` then calling `.radical_expression()` is the idiomatic Sage denesting trick. Sage's symbolic ring can additionally call SymPy's `sqrtdenest`; native `canonicalize_radical()`/`simplify_full()` generally do **not** denest.

**FriCAS / Axiom — `RadicalSolvePackage` (`radicalSolve`, `radicalRoots`); newer `rsimp`.** Solves polynomials in radicals (degree ≤ 4) but is a *solver*, not a denester; recent (2024) FriCAS work added `rsimp` (W. Hebisch) and a `recursiveRootSimplification` wrapper (R. Hemmecke) for `nthRoot` simplification. No general nested‑radical denesting facility comparable to `sqrtdenest`/`raddenest`.

**PARI/GP, Giac/Xcas, Magma — no dedicated denesting facility (documentation survey).** PARI/GP has rich number‑field tools (`nfroots`, `nffactor`, `polredabs`) but no denester. Giac/Xcas relies on general `simplify`/`radnormal`/`ratnormal`. Magma's `Simplify`/`OptimizedRepresentation` simplify number‑field *defining polynomials*, not surd expressions. (These negatives are based on documentation surveys, not explicit vendor statements.)

**Standalone / adjacent.** Cavallo's cube‑radical program (author's Google Sites page, above); Y. Honda's `GaloisGroupSolver` Maxima package (https://github.com/YasuakiHonda/GaloisGroupSolver) solves solvable polynomials by radicals via Galois‑group reduction (adjacent, not a denester).

---

## 7. Theses / Dissertations
- **R. Zippel, "Simplification of radicals with applications to solving polynomial equations," MIT (1977)** — the origin of the structure theorem.
- **J. Blömer, dissertation, FU Berlin (early 1990s)** — sums of radicals and denesting (behind the FOCS/ESA papers).
- **G. Horng (with M.-D. Huang), "Simplifying nested radicals and solving polynomials by nested radicals in minimum depth," USC** — ACM record https://dl.acm.org/doi/abs/10.5555/142931.
- **M. Honsbeek, "Radical extensions and Galois groups," Radboud Nijmegen (2005)** — depth‑2 cube‑root theory (PDF in §3).

---

## Open Problems / Gaps in the Literature
1. **No mainstream CAS implements Landau's or Blömer's general algorithms.** Every production denester is depth‑2 square‑root (Borodin et al./Jeffrey–Rich) plus ad hoc cube‑root heuristics. Implementing Landau (1992), Blömer (1992/2000), or Osipov–Kytmanov (2021, depth‑3 real) would be a genuine contribution — and directly relevant to a CAS‑internals engineer.
2. **Denesting of radicals of degree > 3 is essentially open in practice.** Blömer's bounded‑degree theory exists but is unimplemented; no CAS robustly denests, e.g., fifth roots except by pattern matching (raddenest's `(41-29√2)^(1/5)` case is special).
3. **Depth > 2 in general.** Only Osipov–Kytmanov (depth‑3 real over ℚ) and Blömer's partial depth‑>2 results exist; a complete *practical* algorithm for arbitrary depth (matching Landau's decidability) is missing.
4. **Complexity of SQRT‑SUM remains open** in the Turing model (not known to be in NP or P); the tightest results are Counting‑Hierarchy (Allender et al. 2009) and, under GRH, coNP for radical identity testing (Balaji et al. 2022).
5. **Real vs. complex denesting and the role of roots of unity.** Landau proved roots of unity are sometimes necessary; a clean practical criterion for when *real* denestings exist at depth > 2 is incomplete (Osipov–Kytmanov give only examples of the negative side).

## Most Productive Search Terms & Databases
- **Search terms:** "simplification of nested radicals" (Landau), "denest Ramanujan nested radicals" (Blömer), "decreasing the nesting depth" (Borodin et al.), "radnormal" (Maple), "sqrtdenest" (SymPy/Maxima), "raddenest" (Schintgen), "Ramanujan association with radicals" (Berndt), "radical identity testing" (Balaji et al.), "sum of square roots problem," "Cardan polynomials reduction of radicals" (Osler), "denesting cubic radicals" (Cavallo), "simplification of nested real radicals revisited" (Osipov–Kytmanov).
- **Databases/venues:** FOCS, ISSAC, ESA, LICS, J. Symbolic Computation, SIAM J. Computing, Algorithmica, via DBLP; arXiv math.NT/math.AC/cs.SC/math.HO/math.GM; Springer Link, EUDML (free), ScienceDirect open archive; SymPy/Maxima GitHub + issue trackers; Fossies (Maxima source browsing); Maplesoft and Wolfram documentation; Berndt's Illinois publications page; MIT PRIMES materials.