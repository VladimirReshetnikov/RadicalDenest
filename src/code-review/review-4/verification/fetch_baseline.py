#!/usr/bin/env python3
"""Optional pinned baseline download. No execution of downloaded content."""
from pathlib import Path
import hashlib
import urllib.request

COMMIT = '6d7739bda3478f0d9cd70ffb9f7c49ee2576bee7'
BLOB = '0625aca12ac28cbe16cb09489c22150aa294c1fc'
URL = ('https://raw.githubusercontent.com/VladimirReshetnikov/RadicalDenest/'
       + COMMIT + '/src/corrected/StradFixed.wl')


def main() -> None:
    destination = Path(__file__).resolve().parent / 'StradFixed.baseline.wl'
    with urllib.request.urlopen(URL, timeout=30) as response:
        data = response.read(2_000_000)
    digest = hashlib.sha1(b'blob ' + str(len(data)).encode('ascii') + b'\0' + data).hexdigest()
    if digest != BLOB:
        raise RuntimeError(f'Git blob hash mismatch: expected {BLOB}; got {digest}. Nothing saved.')
    destination.write_bytes(data)
    print(f'Verified {BLOB}; saved {destination}')


if __name__ == '__main__':
    main()
