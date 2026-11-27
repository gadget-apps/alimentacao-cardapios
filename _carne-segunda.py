# -*- coding: utf-8 -*-
"""Padroniza carne moída como carne de segunda e junta lotes de compra."""
import re
from pathlib import Path

root = Path(__file__).resolve().parent

# Compra única de moída por semana (soma dos usos) + usos no rótulo.
# Single ground-meat buy per week (sum of uses) + uses on the label.
SHOP = {
    1: ("580 g", "recheados + clássica"),
    2: ("1140 g", "recheados + almôndegas"),
    3: ("760 g", "recheados + clássica"),
    4: ("950 g", "clássica + almôndegas + refogados"),
    5: ("960 g", "recheados + clássica"),
    6: ("950 g", "recheados + almôndegas"),
    7: ("950 g", "recheados + almôndegas"),
    8: ("580 g", "recheados + clássica"),
}

# Regex das linhas de compra de moída (patinho / acém moído).
# Shopping-line regex for ground meat (patinho / ground chuck).
MOIDA_LI = re.compile(
    r'\s*<li><label class="shop-item"><input type="checkbox" data-id="[^"]*" />'
    r"<span>(?:Patinho(?: moído)?|Acém(?:/músculo)? moído)[^<]*</span></label></li>\r?\n",
    re.IGNORECASE,
)


def shop_line(qty: str, uses: str, data_id: str = "i1") -> str:
    return (
        f'          <li><label class="shop-item"><input type="checkbox" data-id="{data_id}" />'
        f"<span>Carne de segunda (moída) - {qty} ({uses})</span></label></li>\n"
    )


def patch_week(path: Path, week: int) -> None:
    html = path.read_text(encoding="utf-8")
    qty, uses = SHOP[week]
    matches = list(MOIDA_LI.finditer(html))
    if not matches:
        raise SystemExit(f"{path.name}: nenhuma linha de moída encontrada")

    # Troca o primeiro match pelo lote único e remove os demais.
    # Replace the first match with the single lot and drop the rest.
    first = matches[0]
    html = html[: first.start()] + shop_line(qty, uses, "i1") + html[first.end() :]
    # Re-scan after first replacement (offsets change).
    # Re-scan after the first replacement (offsets shift).
    while True:
        m = MOIDA_LI.search(html)
        if not m:
            break
        html = html[: m.start()] + html[m.end() :]

    # Referências de corte nos textos da semana.
    # Cut references in week copy.
    html = html.replace('receitas.html#patinho">Patinho</a>', 'receitas.html#carne-segunda">Carne de segunda</a>')
    html = html.replace("(patinho)", "")
    html = html.replace("Clássica (acém)", "Clássica")
    html = html.replace("Almôndegas (acém)", "Almôndegas")
    html = html.replace("clássica (acém)", "clássica")
    html = html.replace("almôndegas (acém)", "almôndegas")
    html = html.replace("Clássica de acém", "Clássica")
    html = html.replace("Almôndegas de acém", "Almôndegas")
    # Prep titles week 4.
    html = html.replace("clássica (acém)", "clássica")
    html = html.replace("<h3>C) Cozinhar: clássica (acém)</h3>", "<h3>C) Cozinhar: clássica</h3>")
    html = html.replace("<h3>D) Cozinhar: almôndegas (acém)</h3>", "<h3>D) Cozinhar: almôndegas</h3>")

    path.write_text(html, encoding="utf-8")
    print(path.name, "→", qty, uses)


def patch_receitas(path: Path) -> None:
    html = path.read_text(encoding="utf-8")
    html = html.replace('href="#patinho">Patinho</a>', 'href="#carne-segunda">Carne de segunda</a>')
    html = html.replace(
        'Preferir <strong>acém moído</strong> · patinho só nos recheados · Tempo:',
        "Sempre <strong>carne de segunda (moída)</strong> · Tempo:",
    )
    html = html.replace(
        "<strong>190 g</strong> acém moído ·",
        "<strong>190 g</strong> carne de segunda (moída) ·",
    )
    html = html.replace(
        "alternativa: acém moído · Tempo:",
        "alternativa: carne de segunda (moída) · Tempo:",
    )
    html = html.replace(
        "<strong>190 g</strong> porco em cubos (ou acém moído) ·",
        "<strong>190 g</strong> porco em cubos (ou carne de segunda moída) ·",
    )
    html = html.replace(
        "<strong>Se for acém moído:</strong>",
        "<strong>Se for carne de segunda moída:</strong>",
    )
    html = html.replace(
        "<strong>Acém moído</strong> (não patinho) · Tempo:",
        "<strong>Carne de segunda (moída)</strong> · Tempo:",
    )
    html = html.replace(
        "<strong>360 g</strong> acém moído ·",
        "<strong>360 g</strong> carne de segunda (moída) ·",
    )
    html = html.replace(
        "Recheio de <strong>patinho</strong> (~160 g)",
        "Recheio de <strong>carne de segunda</strong> (~160 g)",
    )
    html = html.replace(
        '<article class="recipe" id="patinho">\n        <h3>1) Recheio de patinho (base)</h3>',
        '<article class="recipe" id="carne-segunda">\n        <h3>1) Recheio de carne de segunda (base)</h3>',
    )
    html = html.replace(
        "320 g patinho moído ·",
        "320 g carne de segunda (moída) ·",
    )
    html = html.replace("Junte o patinho.", "Junte a carne de segunda.")
    html = html.replace("recheio de patinho.", "recheio de carne de segunda.")
    path.write_text(html, encoding="utf-8")
    print("receitas.html ok")


def patch_como_fazer(path: Path) -> None:
    if not path.exists():
        return
    html = path.read_text(encoding="utf-8")
    html = html.replace("Patinho</a>", "Carne de segunda</a>")
    html = html.replace("180 g patinho ·", "180 g carne de segunda ·")
    html = html.replace("360 g patinho (", "360 g carne de segunda (")
    html = html.replace("recheio de patinho por unidade", "recheio de carne de segunda por unidade")
    html = html.replace("Prepare o patinho seco", "Prepare a carne de segunda seca")
    path.write_text(html, encoding="utf-8")
    print("como-fazer.html ok")


def patch_separar_prep(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = text.replace("link('patinho', 'Patinho')", "link('carne-segunda', 'Carne de segunda')")
    text = text.replace("clássica (acém)", "clássica")
    text = text.replace("almôndegas (acém)", "almôndegas")
    path.write_text(text, encoding="utf-8")
    print("_separar-prep.py ok")


def patch_precos(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = text.replace(
        'patinho: { name: "Patinho moído", unitPrice: 56.0, unit: "kg" },',
        'carne_segunda: { name: "Carne de segunda (moída)", unitPrice: 36.0, unit: "kg" },',
    )
    text = text.replace(
        'patinho: ["patinho", "patinho moido"],\n    acem: ["acem", "acém", "musculo", "músculo", "paleta", "carne de panela", "panela", "acem moido", "acém moído"],',
        'carne_segunda: ["carne de segunda", "segunda", "patinho", "patinho moido", "acem moido", "acém moído", "carne moida", "carne moída"],\n'
        '    acem: ["acem", "acém", "musculo", "músculo", "paleta", "carne de panela", "panela"],',
    )
    text = text.replace(
        "!/patinho|acem|musculo|porco|",
        "!/patinho|carne de segunda|segunda|acem|musculo|porco|",
    )
    text = text.replace(
        "if (/^alho\\b/.test(f) && !/patinho|porco|frango|cebola/.test(f)) return true;",
        "if (/^alho\\b/.test(f) && !/patinho|segunda|porco|frango|cebola/.test(f)) return true;",
    )
    path.write_text(text, encoding="utf-8")
    print("precos-store.js ok")


def patch_generator(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    # Trocas simples de rótulos de compra — o gerador ainda lista separado;
    # weeks HTML já são a fonte viva.
    # Simple shopping-label swaps — generator may still list separately;
    # live week HTML is the source of truth.
    reps = [
        ('"Patinho moído - 380 g (2 recheados)",\n      "Acém/músculo moído - 200 g (clássica 1 pote)",',
         '"Carne de segunda (moída) - 580 g (recheados + clássica)",'),
        ('"Patinho moído - 570 g (3 recheados)",\n      "Acém/músculo moído - 570 g (almôndegas × 3)",',
         '"Carne de segunda (moída) - 1140 g (recheados + almôndegas)",'),
        ('"Patinho - 380 g (2 recheados)",\n      "Pernil ou lombo (porco) em cubos - 380 g",\n      "Acém moído - 380 g (clássica × 2)",',
         '"Carne de segunda (moída) - 760 g (recheados + clássica)",\n      "Pernil ou lombo (porco) em cubos - 380 g",'),
        ('"Acém/músculo moído - 950 g",',
         '"Carne de segunda (moída) - 950 g (clássica + almôndegas + refogados)",'),
        ('"Patinho - 760 g (4 recheados)",\n      "Pernil ou lombo (porco) em cubos - 380 g",\n      "Acém moído - 200 g (clássica)",',
         '"Carne de segunda (moída) - 960 g (recheados + clássica)",\n      "Pernil ou lombo (porco) em cubos - 380 g",'),
        ('"Patinho - 380 g (2 recheados)",\n      "Acém moído - 570 g (almôndegas × 3)",',
         '"Carne de segunda (moída) - 950 g (recheados + almôndegas)",'),
        ('"Patinho - 570 g (3 recheados)",\n      "Pernil ou lombo (porco) em cubos - 380 g",\n      "Acém moído - 380 g (almôndegas × 2)",',
         '"Carne de segunda (moída) - 950 g (recheados + almôndegas)",\n      "Pernil ou lombo (porco) em cubos - 380 g",'),
        ('"Patinho - 380 g (2 recheados)",\n      "Acém/músculo moído - 200 g (clássica)",',
         '"Carne de segunda (moída) - 580 g (recheados + clássica)",'),
        ("(patinho)", ""),
        ("Clássica (acém)", "Clássica"),
        ("Almôndegas (acém)", "Almôndegas"),
        ("Clássica de acém", "Clássica"),
        ("570 g patinho", "570 g carne de segunda"),
        ("#patinho", "#carne-segunda"),
        (">Patinho</a>", ">Carne de segunda</a>"),
        ("acém moído (950 g)", "carne de segunda (950 g)"),
    ]
    for a, b in reps:
        text = text.replace(a, b)
    path.write_text(text, encoding="utf-8")
    print("_gerar-semanas.ps1 ok")


def main() -> None:
    for w in range(1, 9):
        patch_week(root / f"semana-{w}.html", w)
    patch_receitas(root / "receitas.html")
    patch_como_fazer(root / "como-fazer.html")
    patch_separar_prep(root / "_separar-prep.py")
    patch_precos(root / "precos-store.js")
    patch_generator(root / "_gerar-semanas.ps1")


if __name__ == "__main__":
    main()
