# -*- coding: utf-8 -*-
from pathlib import Path
import re

root = Path(__file__).resolve().parent
for w in range(1, 9):
    p = root / f"semana-{w}.html"
    html = p.read_text(encoding="utf-8")
    html = re.sub(r"</li>\s*<li>", "</li>\n          <li>", html)
    # Reindex data-id em ordem i0, i1, i2...
    # Reindex data-id as i0, i1, i2...
    n = {"i": 0}

    def repl(_m):
        i = n["i"]
        n["i"] += 1
        return f'data-id="i{i}"'

    html2, count = re.subn(r'data-id="[^"]+"', repl, html)
    p.write_text(html2, encoding="utf-8")
    print(p.name, "ids", count)
