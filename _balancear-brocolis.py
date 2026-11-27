# -*- coding: utf-8 -*-
"""Reduz porção de brócolis e diversifica guarnições nas 8 semanas."""
import re
from pathlib import Path

root = Path(__file__).resolve().parent

# Porção por pote após o ajuste.
# Portion per box after the adjustment.
PORCAO_G = 120

# Trocas de guarnição por semana (texto exato → novo).
# Side swaps per week (exact text → new).
SWAPS = {
    1: [
        ("Frango + brócolis", "Frango + abobrinha"),  # will replace all; restore some below
    ],
    # Feito com mapas explícitos de linha do pote + meal — ver APPLY.
}

# Plano final por semana: (dia_prato, texto_final) só onde muda o lado.
# Final plan per week: only rows that should not stay as default broccoli overload.
# Lista completa de potes que levam brócolis (os demais já não têm).
# Full list of pots that keep broccoli (others get a different side).

KEEP_BROCCOLI = {
    1: {
        "Seg almoço": "Carne de panela + brócolis",
        "Seg jantar": "Frango + abobrinha",
        "Ter jantar": "Carne de panela + couve",
        "Qua almoço": "Porco em cubos + brócolis",
        "Qui jantar": "Frango + pepino",
        "Sex almoço": "Frango + brócolis",
        "Dom almoço": "Carne de panela + abobrinha",
    },
    2: {
        "Seg jantar": "Almôndegas + couve",
        "Qui almoço": "Porco shoyu + brócolis",
        "Qui jantar": "Carne de panela + abobrinha",
        "Sex almoço": "Frango + brócolis",
        "Sáb almoço": "Omelete reforçado + abobrinha",
        "Sáb jantar": "Almôndegas + couve",
        "Dom almoço": "Almôndegas + brócolis",
    },
    3: {
        "Seg jantar": "Carne de panela + couve",
        "Qua almoço": "Porco + brócolis",
        "Qui jantar": "Carne de panela + abobrinha",
        "Sex almoço": "Frango + brócolis",
        "Sex jantar": "Porco + berinjela",
        "Sáb jantar": "Clássica + couve",
        "Dom almoço": "Carne de panela + brócolis",
    },
    4: {
        "Seg almoço": "Clássica + brócolis",
        "Seg jantar": "Porco shoyu + chuchu",
        "Ter almoço": "Porco shoyu + abobrinha",
        "Qua almoço": "Almôndegas + brócolis",
        "Qui jantar": "Frango + brócolis",
        "Sex almoço": "Frango + couve",
        "Sáb jantar": "Almôndegas + abobrinha",
    },
    5: {
        "Seg jantar": "Carne de panela + pepino",
        "Qua jantar": "Porco shoyu + brócolis",
        "Qui jantar": "Frango + abobrinha",
        "Sex almoço": "Frango + brócolis",
        "Sex jantar": "Clássica + abobrinha",
        "Sáb jantar": "Porco + pepino",
        "Dom almoço": "Carne de panela + brócolis",
    },
    6: {
        "Seg jantar": "Almôndegas + couve",
        "Qua almoço": "Almôndegas + brócolis",
        "Qua jantar": "Porco shoyu + abobrinha",
        "Qui jantar": "Carne de panela + couve",
        "Sex almoço": "Frango + brócolis",
        "Sex jantar": "Carne de panela + brócolis",
        "Sáb almoço": "Omelete reforçado + abobrinha",
        "Dom almoço": "Almôndegas + chuchu",
    },
    7: {
        "Seg almoço": "Carne de panela + brócolis",
        "Seg jantar": "Almôndegas + couve",
        "Qua jantar": "Porco shoyu + abobrinha",
        "Qui jantar": "Frango + brócolis",
        "Sex almoço": "Frango + abobrinha",
        "Sáb almoço": "Omelete reforçado + tomate",
        "Sáb jantar": "Almôndegas + brócolis",
        "Dom almoço": "Carne de panela + couve",
    },
    8: {
        "Seg almoço": "Carne de panela + brócolis",
        "Seg jantar": "Frango + abobrinha",
        "Ter jantar": "Carne de panela + couve",
        "Qua almoço": "Porco refogado + brócolis",
        "Qui jantar": "Frango + tomate",
        "Sex almoço": "Frango + brócolis",
        "Dom almoço": "Carne de panela + abobrinha",
    },
}

# Dias da semana para o bloco "Durante a semana" (almoço, jantar).
# Weekday block (lunch, dinner).
DAYS = [
    ("Segunda", "Seg almoço", "Seg jantar"),
    ("Terça", "Ter almoço", "Ter jantar"),
    ("Quarta", "Qua almoço", "Qua jantar"),
    ("Quinta", "Qui almoço", "Qui jantar"),
    ("Sexta", "Sex almoço", "Sex jantar"),
    ("Sábado", "Sáb almoço", "Sáb jantar"),
    ("Domingo", "Dom almoço", "Dom jantar"),
]

# Extras de compra quando a diversificação pede mais legume.
# Extra shopping when diversification needs more veg.
SHOP_EXTRA = {
    1: {"Abobrinha": "Abobrinha - 3"},
    3: {"Abobrinha": "Abobrinha - 2"},  # may already exist as other
    5: {},  # pepino já na lista
    7: {},
}


def count_broccoli(plan: dict) -> int:
    return sum(1 for v in plan.values() if "brócolis" in v.lower())


def shop_broccoli_label(n: int) -> str:
    g = n * PORCAO_G
    # Arredonda para cima em múltiplos de 50 g.
    # Round up to multiples of 50 g.
    g = ((g + 49) // 50) * 50
    un = max(1, (g + 149) // 150)
    return f"Brócolis - {g} g (~{un} un)"


def patch_table_row(html: str, day_slot: str, dish: str) -> str:
    pattern = re.compile(
        rf"(<tr><td>{re.escape(day_slot)}</td><td>)[^<]*(</td>)",
        re.IGNORECASE,
    )
    return pattern.sub(rf"\g<1>{dish}\g<2>", html, count=1)


def extract_dish_map(html: str) -> dict:
    """Lê o mapa atual dia→prato da tabela de potes."""
    m = {}
    for day, dish in re.findall(
        r"<tr><td>([^<]+)</td><td>([^<]+)</td><td>", html
    ):
        m[day.strip()] = dish.strip()
    return m


def patch_meals_section(html: str, dishes: dict) -> str:
    """Reconstrói o bloco Durante a semana a partir do mapa de pratos."""
    parts = []
    first = True
    for label, lunch_key, dinner_key in DAYS:
        lunch = dishes.get(lunch_key)
        dinner = dishes.get(dinner_key)
        if not lunch or not dinner:
            continue
        style = "" if first else ' style="margin-top:0.75rem"'
        first = False
        parts.append(
            f'      <article class="meal"{style}>\n'
            f"        <span class=\"label\">{label}</span>\n"
            f"        <strong>12:30 almoço:</strong> {lunch}"
            f'<strong style="margin-top:0.6rem;display:block">20:00 jantar:</strong> {dinner}\n'
            f"      </article>"
        )
    block = "\n".join(parts)
    new_html, n = re.subn(
        r'(<h3>Durante a semana</h3>\s*</div></div>\s*)'
        r'(?:<article class="meal"[\s\S]*?</article>\s*)+',
        rf"\1{block}\n",
        html,
        count=1,
    )
    if n != 1:
        raise SystemExit("bloco Durante a semana não encontrado")
    return new_html


def set_shop_item(html: str, name_prefix: str, new_span: str) -> str:
    """Atualiza ou insere item de compra pelo prefixo do nome."""
    pat = re.compile(
        rf'(<li><label class="shop-item"><input type="checkbox" data-id="[^"]*" /><span>)'
        rf"{re.escape(name_prefix)}[^<]*(</span></label></li>)"
    )
    if pat.search(html):
        return pat.sub(rf"\g<1>{new_span}\g<2>", html, count=1)
    # Insere após o item de brócolis se for outro legume, senão após ovos.
    # Insert after broccoli if another veg, else after eggs.
    insert = (
        f'          <li><label class="shop-item"><input type="checkbox" data-id="i-extra" />'
        f"<span>{new_span}</span></label></li>\n"
    )
    if "Brócolis" in html:
        return re.sub(
            r'(<span>Brócolis[^<]*</span></label></li>\r?\n)',
            rf"\1{insert}",
            html,
            count=1,
        )
    return html


def patch_week(week: int) -> None:
    path = root / f"semana-{week}.html"
    html = path.read_text(encoding="utf-8")
    html = re.sub(r"</li>\s*<li>", "</li>\n          <li>", html)

    current = extract_dish_map(html)
    plan = dict(current)
    plan.update(KEEP_BROCCOLI[week])

    for day, dish in KEEP_BROCCOLI[week].items():
        html = patch_table_row(html, day, dish)

    # Releia mapa completo após patches (linhas não listadas ficam iguais).
    # Re-read full map after patches (unlisted rows stay the same).
    dishes = extract_dish_map(html)
    dishes.update(KEEP_BROCCOLI[week])
    html = patch_meals_section(html, dishes)

    n_broc = count_broccoli({k: v for k, v in dishes.items()})
    html = set_shop_item(html, "Brócolis", shop_broccoli_label(n_broc))

    # Garante abobrinha/couve/pepino/chuchu se o plano usa e a lista ainda não tem.
    # Ensure zucchini/kale/cucumber/chayote if the plan uses them and the list lacks them.
    joined = " ".join(dishes.values()).lower()
    needs = []
    if "abobrinha" in joined and "Abobrinha" not in html:
        needs.append("Abobrinha - 2")
    if "couve" in joined and "Couve" not in html:
        needs.append("Couve - 1 maço")
    if "pepino" in joined and "Pepino" not in html:
        needs.append("Pepino - 1")
    if "chuchu" in joined and "Chuchu" not in html:
        needs.append("Chuchu - 1")
    for item in needs:
        html = set_shop_item(html, item.split(" -")[0], item)

    # Ajuste fino: semana 1 sobe abobrinha para 3 (recheio + guarnições).
    # Fine-tune: week 1 bumps zucchini to 3 (stuffed + sides).
    if week == 1:
        html = set_shop_item(html, "Abobrinha", "Abobrinha - 3")
    if week in (2, 6, 8) and "Abobrinha" in html:
        # Mantém ou sobe levemente se há vários usos como guarnição.
        # Keep or bump slightly if there are several side uses.
        uses = sum(1 for v in dishes.values() if "abobrinha" in v.lower())
        if uses >= 2:
            html = set_shop_item(html, "Abobrinha", "Abobrinha - 3")

    path.write_text(html, encoding="utf-8")
    print(f"semana-{week}: brócolis×{n_broc} → {shop_broccoli_label(n_broc)}")


def patch_receitas() -> None:
    path = root / "receitas.html"
    html = path.read_text(encoding="utf-8")
    html = html.replace("~180 g ≈ 1 guarnição", f"~{PORCAO_G} g ≈ 1 guarnição")
    html = html.replace("<strong>~180 g</strong> brócolis", f"<strong>~{PORCAO_G} g</strong> brócolis")
    html = html.replace("· <strong>~180 g</strong> brócolis", f"· <strong>~{PORCAO_G} g</strong> brócolis")
    # Frango / shoyu lines that still say 180 g brócolis.
    html = re.sub(
        r"(brócolis[^<]{0,40})~?180 g",
        rf"\1~{PORCAO_G} g",
        html,
        flags=re.IGNORECASE,
    )
    path.write_text(html, encoding="utf-8")
    print("receitas.html: porção brócolis", PORCAO_G, "g")


def main() -> None:
    for w in range(1, 9):
        patch_week(w)
    patch_receitas()


if __name__ == "__main__":
    main()
