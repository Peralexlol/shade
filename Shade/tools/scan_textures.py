# File: tools/scan_textures.py
# Usage: python tools/scan_textures.py /path/to/Interface/AddOns/Shade
# Scans .lua files for risky Set*Texture calls (passing color tables / unpack / numbers).

import sys, re, pathlib

RISKY = re.compile(r"\bSet(?:Normal|Pushed|Highlight|Checked)Texture\s*\(([^)]*)\)")
COLORISH = re.compile(r"\{[^}]*\}|unpack\s*\(|\b[0-9]+\s*,\s*[0-9]+\s*,\s*[0-9]+")


def scan(path: pathlib.Path):
    for p in sorted(path.rglob('*.lua')):
        try:
            text = p.read_text(encoding='utf-8', errors='ignore')
        except Exception as e:
            print(f"! cannot read {p}: {e}")
            continue
        for i, line in enumerate(text.splitlines(), 1):
            m = RISKY.search(line)
            if not m:
                continue
            arg = m.group(1)
            if COLORISH.search(arg):
                print(f"{p}:{i}: RISKY -> {line.strip()}")

if __name__ == '__main__':
    root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else '.')
    scan(root)
    print('scan complete')
