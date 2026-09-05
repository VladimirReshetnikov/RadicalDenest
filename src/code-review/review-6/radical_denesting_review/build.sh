#!/bin/sh
# Rebuild the self-contained article from this archive's root.
set -eu
cd "$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
command -v pdflatex >/dev/null 2>&1 || {
  printf '%s\n' 'pdflatex is required; see README.md for TeX packages.' >&2
  exit 2
}
for pass in 1 2 3; do
  pdflatex -interaction=nonstopmode -halt-on-error review.tex
done
