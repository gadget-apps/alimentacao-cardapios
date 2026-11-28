# -*- coding: utf-8 -*-
"""Confere se toda guarnição da montagem aparece na ordem de preparo."""
import re
from pathlib import Path

root = Path(__file__).resolve().parent

SIDES = {
    "brócolis": ["brócolis", "brocolis"],
    "couve": ["couve"],
    "abobrinha": ["abobrinha"],
    "chuchu": ["chuchu"],
    "pepino": ["pepino"],
    "berinjela": ["berinjela"],
}

# Proteínas / pratos que não são guarnição solta.
# Proteins / dishes that are not a loose side.
PROTEINISH = (
    "panela",
    "frango",
    "porco",
    "clássica",
    "classica",
    "almôndegas",
    "almondegas",
    "omelete",
    "rechead",
    "shoyu",
    "refogad",
)


def sides_in_assembly(html: str) -> set[str]:
    dishes = re.findall(r"<tr><td>[^<]+</td><td>([^<]+)</td>", html)
    found = set()
    for d in dishes:
        low = d.lower()
        for canon, keys in SIDES.items():
            if any(k in low for k in keys):
                # Recheado conta como prato próprio (já no prep de recheados).
                # Stuffed veg counts as its own dish (already in stuffed prep).
                if "rechead" in low and canon in ("abobrinha", "chuchu", "berinjela"):
                    continue
                if f"+ {keys[0]}" in low or any(
                    f"+ {k}" in low for k in keys
                ):
                    found.add(canon)
                elif any(k in low for k in keys) and not any(
                    p in low for p in PROTEINISH if p != "refogad"
                ):
                    # ex. "Couve" alone — raro
                    found.add(canon)
                elif any(k in low for k in keys):
                    # "Frango + brócolis" etc.
                    found.add(canon)
    return found


def sides_in_prep(html: str) -> set[str]:
    titles = re.findall(r"<h3>[A-Z]\)\s*([^<]+)</h3>", html)
    blob = " ".join(titles).lower()
    found = set()
    for canon, keys in SIDES.items():
        if any(k in blob for k in keys):
            found.add(canon)
    return found


def main() -> None:
    ok = True
    for w in range(1, 9):
        html = (root / f"semana-{w}.html").read_text(encoding="utf-8")
        need = sides_in_assembly(html)
        have = sides_in_prep(html)
        missing = sorted(need - have)
        extra = sorted(have - need)
        status = "OK" if not missing else "FALTA"
        if missing:
            ok = False
        print(f"semana-{w}: {status} need={sorted(need)} have={sorted(have)}"
              + (f" missing={missing}" if missing else "")
              + (f" extra={extra}" if extra else ""))
    if not ok:
        raise SystemExit(1)


if __name__ == "__main__":
    main()
