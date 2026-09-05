# Source-access ledger

Audit date: 2026-09-05. All repository links below target the mutable `main` branch.
No checkout, commit pin, or original-source byte hash was obtained. Web rendering
line counts were not treated as stable checkout line numbers. The distributed
checksum manifest covers newly generated deliverables only.

## User-designated repository materials

### Corrected implementation — complete raw web rendering inspected

- https://github.com/VladimirReshetnikov/RadicalDenest/blob/main/src/corrected/StradFixed.wl
- https://raw.githubusercontent.com/VladimirReshetnikov/RadicalDenest/main/src/corrected/StradFixed.wl

Inspected the factorizer, denominator rationalization, public wrappers, marker
traversal, quadratic fast path, exact/numeric certification, multiplier scheduling,
polynomial-GCD/root-of-unity reconstruction, and discriminant-derived generator.
Source-implied reproductions are not represented as executed native output.

### Current unified report — relevant technical sections inspected

- https://github.com/VladimirReshetnikov/RadicalDenest/tree/main/docs/report
- https://raw.githubusercontent.com/VladimirReshetnikov/RadicalDenest/main/docs/report/radical_denesting_unified.tex

Used the current TeX rendering for branch/output models, direct and indirect
quadratic criteria, cubic reconstruction, equality versus denesting, complexity and
implementation contracts. An older Library PDF was encountered but was not used as
proof that the current report had identical bytes or contents.

### Literature collection — directory/README level inspection

- https://github.com/VladimirReshetnikov/RadicalDenest/tree/main/docs/literature

The directory/README identified the supporting collection. Retrieval of its full
individual manifest/catalogue was unsuccessful. The audit does not claim to have
read every archived paper. Relevant primary literature was accessed through the
public copies listed below instead.

### Previous unified code review — directory/README level inspection

- https://github.com/VladimirReshetnikov/RadicalDenest/tree/main/src/code-review/unified

The README/listing was accessible. The body section files and detailed experiment
logs could not be retrieved reliably. The present article therefore does not claim
to have independently rechecked every previous finding or reproduced its reported
kernel experiments. It reviews the corrected code directly and identifies these
access limitations explicitly.

## Targeted primary literature

1. A. Borodin, R. Fagin, J. E. Hopcroft, M. Tompa, *Decreasing the nesting depth of
   expressions involving square roots*, J. Symbolic Computation 1 (1985), 169–188.
   https://www.cs.toronto.edu/~bor/Papers/decreasing-nesting-depth-for-expressions.pdf
   Used for the restricted denesting model and structural/representation distinctions.

2. D. J. Jeffrey, A. D. Rich, *Simplifying square roots of square roots by denesting*,
   in M. J. Wester (ed.), *Computer Algebra Systems: A Practical Guide* (1999), 61–72.
   https://cybertester.com/data/denest.pdf
   Inspected relevant practical expression-measure and recursive-method passages.
   This does not establish that the reviewed implementation realizes the entire method.

3. E. Gkioulekas, *On the denesting of nested square roots*, International Journal of
   Mathematical Education in Science and Technology 48 (2017), 942–953.
   https://faculty.utrgv.edu/eleftherios.gkioulekas/papers/submitted/denesting-square-roots.pdf
   Direct/indirect criteria inspected; the relevant theorem page was also successfully
   viewed as an image. Reconstruction identities are independently derived in the article.

4. A. Cavallo, *Denesting cube radicals*, arXiv:2403.04776, version 2 (2024).
   https://arxiv.org/html/2403.04776v2
   Used for the restricted quadratic-field cubic criterion. The trace–norm reconstruction
   is derived and checked independently; no claim of unrestricted cubic completeness.

5. M. Honsbeek, *Radical Extensions and Galois Groups*, doctoral dissertation,
   Radboud University Nijmegen (2005).
   https://www.math.ru.nl/~bosma/students/honsbeek/M_Honsbeek_thesis.pdf
   Selected chapter 3–4 passages inspected, including reconstruction context and a
   quartic identity. Not a claim of a cover-to-cover audit. The latter producer is not
   implemented in the proposed replacement.

Some PDF screenshot requests failed. The review uses accessible parsed passages,
successful page images, and explicit derivations rather than treating inaccessible
formula images as inspected.

## Wolfram official documentation

Documentation, not claims of local/native runtime results:

- https://reference.wolfram.com/language/ref/RootReduce.html
- https://reference.wolfram.com/language/ref/TimeConstrained.html
- https://reference.wolfram.com/language/ref/MemoryConstrained.html
- https://reference.wolfram.com/language/ref/Order.html
- https://reference.wolfram.com/language/ref/TestReportObject.html

These support the canonical algebraic normalization, cooperative resource semantics,
ordering convention, and native test-report interface discussed in the article.

## Execution evidence

- Independent Python/SymPy mathematics and finite models: executed; JSON results supplied.
- Lexical Wolfram delimiter scan: executed; JSON results supplied; not a native parser.
- Wolfram context/evaluator service: both attempted calls returned HTTP 404 at the
  service endpoint, before any user-code evaluation could be confirmed.
- Local Wolfram kernel: not present.
- Native replacement load, unit tests, timings, memory measurements, and full
  original-versus-replacement comparison: pending, not passed.
