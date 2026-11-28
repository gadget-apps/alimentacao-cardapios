# -*- coding: utf-8 -*-
"""Inclui no prep as guarnições que aparecem na montagem das marmitas."""
import re
from pathlib import Path

root = Path(__file__).resolve().parent
LETTER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


def link(href: str, label: str) -> str:
    return f'<a href="receitas.html#{href}">{label}</a>'


def art(letter: str, title: str, note: str) -> str:
    return (
        f'      <article class="recipe">        <h3>{letter}) {title}</h3>\n'
        f'        <p class="footer-note">{note}</p></article>\n'
    )


def dishes_from_week(html: str) -> set[str]:
    texts = re.findall(r"<tr><td>[^<]+</td><td>([^<]+)</td>", html)
    texts += re.findall(r"20:00 jantar:</strong>\s*([^<\n]+)", html)
    texts += re.findall(r"12:30 almoço:</strong>\s*([^<]+)", html)
    blob = " | ".join(texts).lower()
    need = set()
    if "brócolis" in blob:
        need.add("brocolis")
    if "couve" in blob:
        need.add("couve")
    # Abobrinha como guarnição (não só recheada).
    # Zucchini as a side (not only stuffed).
    if re.search(r"\+\s*abobrinha|abobrinha\s*\+", blob) or re.search(
        r"(frango|porco|panela|clássica|almondegas|almôndegas|omelete)[^\n|]*abobrinha",
        blob,
    ):
        if "recheada" not in blob or "+ abobrinha" in blob or "abobrinha" in blob:
            # Se aparece " + abobrinha" como guarnição.
            if "+ abobrinha" in blob or " + abobrinha" in blob:
                need.add("abobrinha")
    if "+ abobrinha" in blob:
        need.add("abobrinha")
    if "chuchu" in blob and "recheado" not in blob.replace("chuchu recheado", ""):
        if "+ chuchu" in blob:
            need.add("chuchu")
    if "+ pepino" in blob:
        need.add("pepino")  # cru — só nota no prep
    if "+ tomate" in blob and "recheado" not in blob:
        # tomate fresco / omelete — sem cozimento de lote
        pass
    if "+ berinjela" in blob and "recheada" not in blob:
        need.add("berinjela")
    return need


SIDE_META = {
    "brocolis": (
        "Cozinhar: brócolis (guarnição)",
        f"Passo a passo: {link('brocolis', 'Brócolis')}",
    ),
    "couve": (
        "Cozinhar: couve (guarnição)",
        f"Passo a passo: {link('couve', 'Couve')}",
    ),
    "abobrinha": (
        "Cozinhar: abobrinha (guarnição)",
        f"Refogada · {link('refogados', 'Receita')}",
    ),
    "chuchu": (
        "Cozinhar: chuchu (guarnição)",
        f"Passo a passo: {link('refogados', 'Refogados')}",
    ),
    "berinjela": (
        "Cozinhar: berinjela (guarnição)",
        f"Ao molho · {link('refogados', 'Receita')}",
    ),
    "pepino": (
        "Separar: pepino (cru)",
        "Não cozinha no lote · fatia na hora de montar o pote",
    ),
}


def extract_protein_steps(html: str) -> list[tuple[str, str]]:
    """Extrai artigos de prep antes de Depois, sem omelete no dia."""
    block = re.search(
        r"(</div></div>\r?\n)((?:\s*<article class=\"recipe\">[\s\S]*?</article>\r?\n)+)"
        r"(\s*<article class=\"recipe\">\s*\r?\n\s*<h3>Depois:)",
        html,
    )
    if not block:
        raise SystemExit("bloco prep não encontrado")
    arts = re.findall(
        r'<article class="recipe">\s*<h3>[A-Z]\)\s*([^<]+)</h3>\s*'
        r'<p class="footer-note">([\s\S]*?)</p></article>',
        block.group(2),
    )
    return [(t.strip(), n.strip()) for t, n in arts], block


def rebuild(week: int) -> None:
    path = root / f"semana-{week}.html"
    html = path.read_text(encoding="utf-8")
    need = dishes_from_week(html)
    steps, block = extract_protein_steps(html)

    # Remove guarnições antigas / omelete para remontar limpo.
    # Drop old sides / omelette so we can rebuild cleanly.
    core = []
    omelete = None
    for title, note in steps:
        tl = title.lower()
        if tl.startswith("no dia: omelete"):
            omelete = (title, note)
            continue
        if any(
            x in tl
            for x in (
                "brócolis (guarnição)",
                "couve (guarnição)",
                "abobrinha (guarnição)",
                "chuchu (guarnição)",
                "berinjela (guarnição)",
                "pepino (cru)",
                "separar: pepino",
            )
        ):
            continue
        # Tira "guarnição: Brócolis" genérico do frango — lados ficam explícitos.
        # Strip generic "side: Broccoli" from chicken — sides become explicit steps.
        if "cozinhar: frango" in tl:
            note = re.sub(
                r"\s*·\s*guarnição:\s*<a href=\"receitas\.html#brocolis\">Brócolis</a>",
                "",
                note,
            )
            note = note or f"{link('frango', 'Receita')}"
        core.append((title, note))

    # Insere guarnições antes do omelete (depois das proteínas).
    # Insert sides before the omelette (after proteins).
    order = ["brocolis", "couve", "abobrinha", "chuchu", "berinjela", "pepino"]
    for key in order:
        if key in need:
            core.append(SIDE_META[key])
    if omelete:
        core.append(omelete)
    else:
        core.append(
            (
                "No dia: omelete reforçado",
                f"Não entra no lote · {link('omelete', 'Receita')}",
            )
        )

    parts = []
    for i, (title, note) in enumerate(core):
        parts.append(art(LETTER[i], title, note))
    last = LETTER[len(core) - 1]
    html = re.sub(r"ordem A→[A-Z]", f"ordem A→{last}", html)
    html = (
        html[: block.start()]
        + block.group(1)
        + "".join(parts)
        + block.group(3)
        + html[block.end() :]
    )
    path.write_text(html, encoding="utf-8")
    print(f"semana-{week}: sides={sorted(need)} steps={len(core)} → {last}")


def patch_receitas() -> None:
    path = root / "receitas.html"
    html = path.read_text(encoding="utf-8")
    if 'id="couve"' not in html:
        html = html.replace(
            '<article class="recipe">\n        <h3>Couve com alho</h3>',
            '<article class="recipe" id="couve">\n        <h3>Couve com alho</h3>',
        )
        path.write_text(html, encoding="utf-8")
        print("receitas: id=couve")


def main() -> None:
    patch_receitas()
    for w in range(1, 9):
        rebuild(w)


if __name__ == "__main__":
    main()
