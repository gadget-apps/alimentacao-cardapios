# -*- coding: utf-8 -*-
"""
Marmita em 3 divisórias: proteína | legume | arroz+feijão (contam como 1).
Troca pepino → cabotiá e garante legume em todos os 14 potes.
"""
import re
from pathlib import Path

root = Path(__file__).resolve().parent
LETTER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

# Cardápio por semana: (proteína, legume, arroz_feijao) × 14 na ordem da tabela.
# Meal plan per week: (protein, veg, rice_beans) × 14 in table order.
# Jantar: 3ª divisória vazia (sem arroz/feijão), alinhado ao plano low-carb.
# Dinner: 3rd compartment empty (no rice/beans), matching the low-carb plan.
MEALS = {
    1: [
        ("Carne de panela", "Brócolis", "2 cs arroz"),
        ("Frango", "Abobrinha", "nada"),
        ("Recheio (carne de segunda)", "Pimentão", "2 cs arroz"),
        ("Carne de panela", "Couve", "nada"),
        ("Porco em cubos", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Cabotiá", "nada"),
        ("Recheio (carne de segunda)", "Abobrinha", "2 cs arroz"),
        ("Frango", "Cabotiá", "nada"),
        ("Frango", "Brócolis", "2 cs arroz"),
        ("Porco em cubos", "Abobrinha", "nada"),
        ("Omelete reforçado", "Abobrinha", "2 cs arroz"),
        ("Clássica", "Couve", "nada"),
        ("Carne de panela", "Abobrinha", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Tomate", "nada"),
    ],
    2: [
        ("Recheio (carne de segunda)", "Berinjela", "2 cs arroz"),
        ("Almôndegas", "Couve", "nada"),
        ("Recheio (carne de segunda)", "Tomate", "2 cs arroz"),
        ("Omelete reforçado", "Abobrinha", "nada"),
        ("Recheio (carne de segunda)", "Chuchu", "2 cs arroz"),
        ("Almôndegas", "Couve", "nada"),
        ("Porco shoyu", "Brócolis", "2 cs arroz"),
        ("Carne de panela", "Abobrinha", "nada"),
        ("Frango", "Brócolis", "2 cs arroz"),
        ("Porco shoyu", "Abobrinha", "nada"),
        ("Omelete reforçado", "Abobrinha", "2 cs arroz"),
        ("Almôndegas", "Couve", "nada"),
        ("Almôndegas", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Couve", "nada"),
    ],
    3: [
        ("Recheio (carne de segunda)", "Abóbora / cabotiá", "1–2 cs arroz"),
        ("Carne de panela", "Couve", "nada"),
        ("Recheio (carne de segunda)", "Pimentão", "2 cs arroz"),
        ("Clássica", "Couve", "nada"),
        ("Porco", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Cabotiá", "nada"),
        ("Porco", "Berinjela", "2 cs arroz"),
        ("Carne de panela", "Abobrinha", "nada"),
        ("Frango", "Brócolis", "2 cs arroz"),
        ("Porco", "Berinjela", "nada"),
        ("Omelete reforçado", "Couve", "2 cs arroz"),
        ("Clássica", "Couve", "nada"),
        ("Carne de panela", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Tomate", "nada"),
    ],
    4: [
        ("Clássica", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Porco shoyu", "Chuchu", "nada"),
        ("Porco shoyu", "Abobrinha", "2 cs arroz"),
        ("Omelete reforçado", "Couve", "nada"),
        ("Almôndegas", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Porco", "Abobrinha", "nada"),
        ("Porco", "Pimentão", "2 cs arroz + 2 cs feijão"),
        ("Frango", "Brócolis", "nada"),
        ("Frango", "Couve", "2 cs arroz"),
        ("Clássica", "Couve", "nada"),
        ("Omelete reforçado", "Chuchu", "2 cs arroz"),
        ("Almôndegas", "Abobrinha", "nada"),
        ("Almôndegas", "Couve", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Abobrinha", "nada"),
    ],
    5: [
        ("Recheio (carne de segunda)", "Abobrinha", "2 cs arroz"),
        ("Carne de panela", "Cabotiá", "nada"),
        ("Recheio (carne de segunda)", "Pimentão", "2 cs arroz"),
        ("Omelete reforçado", "Cabotiá", "nada"),
        ("Recheio (carne de segunda)", "Berinjela", "2 cs arroz"),
        ("Porco shoyu", "Brócolis", "nada"),
        ("Recheio (carne de segunda)", "Tomate", "2 cs arroz"),
        ("Frango", "Abobrinha", "nada"),
        ("Frango", "Brócolis", "2 cs arroz"),
        ("Clássica", "Abobrinha", "nada"),
        ("Omelete reforçado", "Abobrinha", "2 cs arroz"),
        ("Porco", "Cabotiá", "nada"),
        ("Carne de panela", "Brócolis", "2 cs arroz"),
        ("Omelete reforçado", "Tomate", "nada"),
    ],
    6: [
        ("Recheio (carne de segunda)", "Abóbora / cabotiá", "1–2 cs arroz"),
        ("Almôndegas", "Couve", "nada"),
        ("Recheio (carne de segunda)", "Chuchu", "2 cs arroz"),
        ("Omelete reforçado", "Couve", "nada"),
        ("Almôndegas", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Porco shoyu", "Abobrinha", "nada"),
        ("Porco", "Couve", "2 cs arroz + 2 cs feijão"),
        ("Carne de panela", "Couve", "nada"),
        ("Frango", "Brócolis", "2 cs arroz"),
        ("Carne de panela", "Brócolis", "nada"),
        ("Omelete reforçado", "Abobrinha", "2 cs arroz"),
        ("Almôndegas", "Couve", "nada"),
        ("Almôndegas", "Chuchu", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Cabotiá", "nada"),
    ],
    7: [
        ("Carne de panela", "Brócolis", "2 cs arroz"),
        ("Almôndegas", "Couve", "nada"),
        ("Recheio (carne de segunda)", "Pimentão", "2 cs arroz"),
        ("Omelete reforçado", "Abobrinha", "nada"),
        ("Recheio (carne de segunda)", "Berinjela", "2 cs arroz"),
        ("Porco shoyu", "Abobrinha", "nada"),
        ("Recheio (carne de segunda)", "Tomate", "2 cs arroz"),
        ("Frango", "Brócolis", "nada"),
        ("Frango", "Abobrinha", "2 cs arroz"),
        ("Porco", "Abobrinha", "nada"),
        ("Omelete reforçado", "Cabotiá", "2 cs arroz"),
        ("Almôndegas", "Brócolis", "nada"),
        ("Carne de panela", "Couve", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Tomate", "nada"),
    ],
    8: [
        ("Carne de panela", "Brócolis", "2 cs arroz"),
        ("Frango", "Abobrinha", "nada"),
        ("Recheio (carne de segunda)", "Pimentão", "2 cs arroz"),
        ("Carne de panela", "Couve", "nada"),
        ("Porco", "Brócolis", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Cabotiá", "nada"),
        ("Recheio (carne de segunda)", "Abobrinha", "2 cs arroz"),
        ("Frango", "Cabotiá", "nada"),
        ("Frango", "Brócolis", "2 cs arroz"),
        ("Porco", "Abobrinha", "nada"),
        ("Omelete reforçado", "Abobrinha", "2 cs arroz"),
        ("Clássica", "Couve", "nada"),
        ("Carne de panela", "Abobrinha", "2 cs arroz + 2 cs feijão"),
        ("Omelete reforçado", "Tomate", "nada"),
    ],
}

DAYS = [
    ("Segunda", 0, 1),
    ("Terça", 2, 3),
    ("Quarta", 4, 5),
    ("Quinta", 6, 7),
    ("Sexta", 8, 9),
    ("Sábado", 10, 11),
    ("Domingo", 12, 13),
]

SLOTS = [
    "Seg almoço", "Seg jantar", "Ter almoço", "Ter jantar",
    "Qua almoço", "Qua jantar", "Qui almoço", "Qui jantar",
    "Sex almoço", "Sex jantar", "Sáb almoço", "Sáb jantar",
    "Dom almoço", "Dom jantar",
]


def count_veg(meals):
    from collections import Counter
    c = Counter()
    for _, veg, _ in meals:
        v = veg.lower()
        if "brócolis" in v or "brocolis" in v:
            c["brocolis"] += 1
        elif "couve" in v:
            c["couve"] += 1
        elif "abobrinha" in v:
            c["abobrinha"] += 1
        elif "caboti" in v or "abóbora" in v or "abobora" in v:
            c["cabotia"] += 1
        elif "chuchu" in v:
            c["chuchu"] += 1
        elif "berinjela" in v:
            c["berinjela"] += 1
        elif "pimentão" in v or "pimentao" in v:
            c["pimentao"] += 1
        elif "tomate" in v:
            c["tomate"] += 1
    return c


def shop_veg_lines(counts):
    lines = []
    # ~120 g por pote de guarnição; recheado usa a unidade do legume.
    # ~120 g per side pot; stuffed uses the vegetable unit.
    if counts.get("brocolis"):
        n = counts["brocolis"]
        g = ((n * 120 + 49) // 50) * 50
        lines.append(f"Brócolis - {g} g (~{(g + 149) // 150} un)")
    if counts.get("couve"):
        lines.append("Couve - 1 maço" if counts["couve"] <= 4 else "Couve - 2 maços")
    if counts.get("abobrinha"):
        # 1 unidade por uso (guarnição ou recheada), mínimo 2.
        # 1 unit per use (side or stuffed), minimum 2.
        n = max(2, counts["abobrinha"])
        lines.append(f"Abobrinha - {n}")
    if counts.get("cabotia"):
        n = counts["cabotia"]
        g = max(400, ((n * 150 + 49) // 50) * 50)
        lines.append(f"Abóbora cabotiá - {g} g")
    if counts.get("chuchu"):
        lines.append(f"Chuchu - {max(1, counts['chuchu'])}")
    if counts.get("berinjela"):
        lines.append(f"Berinjela - {max(1, (counts['berinjela'] + 1) // 2)}")
    if counts.get("pimentao"):
        lines.append(f"Pimentão - {counts['pimentao']}")
    if counts.get("tomate"):
        # Tomate: recheio + guarnição + molho — mínimo 3.
        # Tomato: stuffing + side + sauce — minimum 3.
        lines.append(f"Tomate - {max(3, counts['tomate'] + 2)}")
    return lines


def link(href, label):
    return f'<a href="receitas.html#{href}">{label}</a>'


def art(letter, title, note):
    return (
        f'      <article class="recipe">        <h3>{letter}) {title}</h3>\n'
        f'        <p class="footer-note">{note}</p></article>\n'
    )


def build_table(meals):
    rows = []
    for i, (prot, veg, carb) in enumerate(meals):
        rows.append(
            f"            <tr><td>{SLOTS[i]}</td><td>{prot}</td><td>{veg}</td><td>{carb}</td></tr>"
        )
    return "\n".join(rows)


def build_days(meals):
    parts = []
    for i, (label, li, di) in enumerate(DAYS):
        p1, v1, c1 = meals[li]
        p2, v2, c2 = meals[di]
        style = "" if i == 0 else ' style="margin-top:0.75rem"'
        lunch = f"{p1} + {v1}" + (f" · {c1}" if c1 != "nada" else "")
        dinner = f"{p2} + {v2}" + (f" · {c2}" if c2 != "nada" else "")
        parts.append(
            f'      <article class="meal"{style}>\n'
            f'        <span class="label">{label}</span>\n'
            f"        <strong>12:30 almoço:</strong> {lunch}"
            f'<strong style="margin-top:0.6rem;display:block">20:00 jantar:</strong> {dinner}\n'
            f"      </article>"
        )
    return "\n".join(parts)


def needed_sides(meals):
    need = set()
    for _, veg, _ in meals:
        v = veg.lower()
        if "brócolis" in v:
            need.add("brocolis")
        if "couve" in v:
            need.add("couve")
        if "abobrinha" in v:
            need.add("abobrinha")
        if "caboti" in v or "abóbora" in v:
            need.add("cabotia")
        if "chuchu" in v:
            need.add("chuchu")
        if "berinjela" in v:
            need.add("berinjela")
        if "pimentão" in v:
            need.add("pimentao")  # via recheados
    return need


SIDE_META = {
    "brocolis": ("Cozinhar: brócolis (guarnição)", f"Passo a passo: {link('brocolis', 'Brócolis')}"),
    "couve": ("Cozinhar: couve (guarnição)", f"Passo a passo: {link('couve', 'Couve')}"),
    "abobrinha": ("Cozinhar: abobrinha (guarnição)", f"Refogada · {link('refogados', 'Receita')}"),
    "cabotia": ("Cozinhar: cabotiá (guarnição)", f"Escalda em água · {link('cabotia', 'Receita')}"),
    "chuchu": ("Cozinhar: chuchu (guarnição)", f"Passo a passo: {link('refogados', 'Refogados')}"),
    "berinjela": ("Cozinhar: berinjela (guarnição)", f"Ao molho · {link('refogados', 'Receita')}"),
}


def rebuild_prep(html, meals):
    block = re.search(
        r"(</div></div>\r?\n)((?:\s*<article class=\"recipe\">[\s\S]*?</article>\r?\n)+)"
        r"(\s*<article class=\"recipe\">\s*\r?\n\s*<h3>Depois:)",
        html,
    )
    if not block:
        raise SystemExit("prep block missing")
    arts = re.findall(
        r'<article class="recipe">\s*<h3>[A-Z]\)\s*([^<]+)</h3>\s*'
        r'<p class="footer-note">([\s\S]*?)</p></article>',
        block.group(2),
    )
    core = []
    omelete = None
    for title, note in arts:
        tl = title.lower()
        if tl.startswith("no dia: omelete"):
            omelete = (title.strip(), note.strip())
            continue
        if any(
            x in tl
            for x in (
                "brócolis (guarnição)",
                "couve (guarnição)",
                "abobrinha (guarnição)",
                "cabotiá",
                "chuchu (guarnição)",
                "berinjela (guarnição)",
                "pepino",
                "separar:",
            )
        ):
            continue
        if "feijão" in tl:
            note = (
                f"De molho na véspera · panela de pressão · "
                f"{link('feijao', 'Receita')}"
            )
        if "cozinhar: frango" in tl:
            note = re.sub(
                r"\s*·\s*guarnição:\s*<a[^>]*>[^<]*</a>",
                "",
                note,
            ) or f"{link('frango', 'Receita')}"
        core.append((title.strip(), note.strip()))

    for key in ["brocolis", "couve", "abobrinha", "cabotia", "chuchu", "berinjela"]:
        if key in needed_sides(meals):
            core.append(SIDE_META[key])
    if omelete:
        core.append(omelete)
    else:
        core.append(
            ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}")
        )

    parts = [art(LETTER[i], t, n) for i, (t, n) in enumerate(core)]
    last = LETTER[len(core) - 1]
    html = re.sub(r"ordem A→[A-Z]", f"ordem A→{last}", html)
    html = html[: block.start()] + block.group(1) + "".join(parts) + block.group(3) + html[block.end() :]
    return html


def upsert_shop(html, lines_to_set, remove_prefixes):
    # Remove pepino e linhas de legume que vamos reescrever.
    # Drop cucumber and veg lines we are about to rewrite.
    for pref in remove_prefixes:
        html = re.sub(
            rf'\s*<li><label class="shop-item"><input type="checkbox" data-id="[^"]*" />'
            rf"<span>{re.escape(pref)}[^<]*</span></label></li>\r?\n?",
            "\n",
            html,
            flags=re.I,
        )
    # Insere após o último item de proteína (ovos) ou no fim da lista.
    # Insert after the last protein item (eggs) or at end of list.
    insert = "".join(
        f'          <li><label class="shop-item"><input type="checkbox" data-id="veg{i}" />'
        f"<span>{line}</span></label></li>\n"
        for i, line in enumerate(lines_to_set)
    )
    m = re.search(
        r'(<span>Ovos[^<]*</span></label></li>\r?\n)',
        html,
    )
    if m:
        html = html[: m.end()] + insert + html[m.end() :]
    return html


def patch_week(week: int) -> None:
    path = root / f"semana-{week}.html"
    html = path.read_text(encoding="utf-8")
    meals = MEALS[week]
    assert len(meals) == 14

    html = rebuild_prep(html, meals)

    note = (
        "Cada linha = 1 pote. Marmita de <strong>3 divisórias</strong>: "
        "proteína · legume · arroz+feijão (contam como <strong>1</strong>). "
        "No jantar a 3ª divisória fica vazia. "
        "<strong>Omelete reforçado</strong> = feito no dia."
    )
    table = (
        f'        <h3>Depois: monte os potes da semana</h3>\n'
        f'        <p class="footer-note">{note}</p>\n'
        f'        <table class="table">\n'
        f"          <thead><tr><th>Dia</th><th>Proteína</th><th>Legume</th><th>Arroz / feijão</th></tr></thead>\n"
        f"          <tbody>\n"
        f"{build_table(meals)}\n"
        f"          </tbody>\n"
        f"        </table>\n"
    )
    html = re.sub(
        r"<h3>Depois: monte os potes da semana</h3>[\s\S]*?</table>",
        table.rstrip(),
        html,
        count=1,
    )

    days = build_days(meals)
    html, n = re.subn(
        r'(<h3>Durante a semana</h3>\s*</div></div>\s*)'
        r'(?:<article class="meal"[\s\S]*?</article>\s*)+',
        rf"\1{days}\n",
        html,
        count=1,
    )
    if n != 1:
        raise SystemExit(f"semana-{week}: durante a semana")

    counts = count_veg(meals)
    veg_lines = shop_veg_lines(counts)
    html = upsert_shop(
        html,
        veg_lines,
        [
            "Brócolis",
            "Couve",
            "Abobrinha",
            "Pepino",
            "Chuchu",
            "Berinjela",
            "Pimentão",
            "Tomate",
            "Abóbora",
            "Abóbora cabotiá",
            "Tomate firme",
        ],
    )
    # Reindex data-ids
    n = {"i": 0}

    def rid(_m):
        i = n["i"]
        n["i"] += 1
        return f'data-id="i{i}"'

    html = re.sub(r'data-id="[^"]+"', rid, html)
    html = re.sub(r"</li>\s*<li>", "</li>\n          <li>", html)
    path.write_text(html, encoding="utf-8")
    print(f"semana-{week}: 14 potes · veg {dict(counts)}")


def patch_receitas():
    path = root / "receitas.html"
    html = path.read_text(encoding="utf-8")
    if 'id="cabotia"' not in html:
        block = """
    <section class="card" id="cabotia">
      <h2>Abóbora cabotiá (guarnição)</h2>
      <p class="footer-note">Tempo: ~20 min · ~120–150 g ≈ 1 guarnição · <strong>Sem forno</strong> — só água</p>
      <article class="recipe">
        <h3>Como fazer</h3>
        <p class="ing"><strong>~150 g</strong> cabotiá · água · sal · opcional: 1 dente de alho · 1 colher de chá de azeite</p>
        <ol>
          <li>Descasque a cabotiá (se a casca estiver dura).</li>
          <li>Corte em cubos de bocado.</li>
          <li>Ferva água com sal.</li>
          <li>Escalde os cubos 12–15 min até o garfo entrar.</li>
          <li>Escorra bem.</li>
          <li>Opcional: refogue 1 min com alho e azeite.</li>
          <li><strong>Pote:</strong> use como guarnição na 2ª divisória.</li>
        </ol>
      </article>
    </section>
"""
        html = html.replace(
            '<section class="card" id="recheados">',
            block + '\n    <section class="card" id="recheados">',
        )
    # Alias cabocha name
    html = html.replace(
        'Abóbora / cabocha',
        'Abóbora / cabotiá',
    )
    path.write_text(html, encoding="utf-8")
    print("receitas: cabotiá")


def patch_precos():
    path = root / "precos-store.js"
    text = path.read_text(encoding="utf-8")
    text = text.replace(
        'abobora: { name: "Abóbora / cabocha", unitPrice: 6.5, unit: "kg" },',
        'abobora: { name: "Abóbora cabotiá", unitPrice: 6.5, unit: "kg" },',
    )
    text = text.replace(
        'abobora: ["abobora", "abóbora", "cabocha", "moranga"],',
        'abobora: ["abobora", "abóbora", "cabocha", "cabotia", "cabotiá", "moranga"],',
    )
    path.write_text(text, encoding="utf-8")
    print("precos: cabotiá alias")


def main():
    patch_receitas()
    patch_precos()
    for w in range(1, 9):
        patch_week(w)


if __name__ == "__main__":
    main()
