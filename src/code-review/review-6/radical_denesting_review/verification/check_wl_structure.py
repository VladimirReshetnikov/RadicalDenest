#!/usr/bin/env python3
"""Only a string/comment-aware delimiter check; NOT a Wolfram parser or runtime."""
import json
from pathlib import Path
root=Path(__file__).resolve().parents[1]
results=[]
for p in sorted(root.rglob('*')):
    if p.suffix not in {'.wl','.wlt','.wls'}: continue
    text=p.read_text(); stack=[]; i=0; line=1; comment=0; string=False
    while i<len(text):
        pair=text[i:i+2]; c=text[i]
        if c=='\n': line+=1
        if comment:
            if pair=='(*': comment+=1; i+=2; continue
            if pair=='*)': comment-=1; i+=2; continue
        elif string:
            if c=='\\': i+=2; continue
            if c=='"': string=False
        elif pair=='(*': comment=1; i+=2; continue
        elif c=='"': string=True
        elif c in '[{(': stack.append((c,line))
        elif c in ']})':
            assert stack and stack[-1][0]=={']':'[','}':'{',')':'('}[c], (p,line,c,stack[-3:])
            stack.pop()
        i+=1
    assert not stack and not comment and not string, (p,stack,comment,string)
    results.append({'file':str(p.relative_to(root)),'balanced':True,'lines':line})
out={'scope':'Lexical delimiter check only; not native parse/execution','results':results}
(root/'verification'/'wl_structure_results.json').write_text(json.dumps(out,indent=2))
print(json.dumps(out,indent=2))
