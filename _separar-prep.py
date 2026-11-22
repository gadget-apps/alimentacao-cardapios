# -*- coding: utf-8 -*-
"""Separa cada prato do prep em um bloco próprio com link de receita."""
import re
from pathlib import Path

root = Path(__file__).resolve().parent

LETTER = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"


def art(letter: str, title: str, note_html: str) -> str:
    return (
        f'      <article class="recipe">        <h3>{letter}) {title}</h3>\n'
        f'        <p class="footer-note">{note_html}</p></article>\n'
    )


def link(href: str, label: str) -> str:
    return f'<a href="receitas.html#{href}">{label}</a>'


# Prep separado por semana (ordem de execução no dia do lote).
# Separated prep per week (batch-day execution order).
PREP = {
    1: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: carne de panela (570 g)", f"Rende 3 potes · {link('panela', 'Receita')}"),
        ("Cozinhar: recheados (380 g)", f"Pimentão + abobrinha · {link('recheados', 'Recheados')} · {link('patinho', 'Patinho')}"),
        ("Cozinhar: porco em cubos (380 g)", f"{link('porco', 'Receita')}"),
        ("Cozinhar: clássica (200 g)", f"{link('classica', 'Receita')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
    2: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: carne de panela (200 g)", f"{link('panela', 'Receita')}"),
        ("Cozinhar: recheados (570 g)", f"Berinjela · tomate · chuchu · {link('recheados', 'Recheados')} · {link('patinho', 'Patinho')}"),
        ("Cozinhar: almôndegas (570 g)", f"{link('almondegas', 'Receita')}"),
        ("Cozinhar: porco shoyu (380 g)", f"{link('shoyu', 'Receita')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
    3: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: carne de panela (570 g)", f"Rende 3 potes · {link('panela', 'Receita')}"),
        ("Cozinhar: recheados", f"Abóbora / pimentão · {link('recheados', 'Recheados')} · {link('patinho', 'Patinho')}"),
        ("Cozinhar: porco (380 g)", f"{link('porco', 'Receita')}"),
        ("Cozinhar: clássica (380 g)", f"{link('classica', 'Receita')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
    4: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: clássica (acém)", f"{link('classica', 'Receita')}"),
        ("Cozinhar: almôndegas (acém)", f"{link('almondegas', 'Receita')}"),
        ("Cozinhar: porco em cubos", f"{link('porco', 'Receita')}"),
        ("Cozinhar: porco shoyu", f"{link('shoyu', 'Receita')}"),
        ("Cozinhar: porco / carne refogados", f"{link('refogados', 'Receita')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
    5: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: carne de panela (380 g)", f"{link('panela', 'Receita')}"),
        ("Cozinhar: brócolis (guarnição)", f"{link('brocolis', 'Receita')}"),
        ("Cozinhar: recheados (760 g)", f"4 unidades · {link('recheados', 'Recheados')} · {link('patinho', 'Patinho')}"),
        ("Cozinhar: porco (380 g)", f"{link('porco', 'Receita')} · {link('shoyu', 'Shoyu')}"),
        ("Cozinhar: clássica (200 g)", f"{link('classica', 'Receita')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
    6: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: carne de panela (380 g)", f"{link('panela', 'Receita')}"),
        ("Cozinhar: recheados (380 g)", f"Abóbora · chuchu · {link('recheados', 'Recheados')} · {link('patinho', 'Patinho')}"),
        ("Cozinhar: almôndegas (570 g)", f"{link('almondegas', 'Receita')}"),
        ("Cozinhar: porco (380 g)", f"{link('porco', 'Receita')} · {link('shoyu', 'Shoyu')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
    7: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: carne de panela (380 g)", f"{link('panela', 'Receita')}"),
        ("Cozinhar: brócolis (guarnição)", f"{link('brocolis', 'Receita')}"),
        ("Cozinhar: recheados (570 g)", f"{link('recheados', 'Recheados')} · {link('patinho', 'Patinho')}"),
        ("Cozinhar: porco (380 g)", f"{link('porco', 'Receita')} · {link('shoyu', 'Shoyu')}"),
        ("Cozinhar: almôndegas (380 g)", f"{link('almondegas', 'Receita')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
    8: [
        ("Cozinhar: arroz (lote)", f"Passo a passo: {link('arroz', 'Arroz')}"),
        ("Cozinhar: feijão (lote)", f"Passo a passo: {link('feijao', 'Feijão')}"),
        ("Cozinhar: carne de panela (570 g)", f"Rende 3 potes · {link('panela', 'Receita')}"),
        ("Cozinhar: recheados (380 g)", f"{link('recheados', 'Recheados')} · {link('patinho', 'Patinho')}"),
        ("Cozinhar: porco (380 g)", f"{link('porco', 'Receita')}"),
        ("Cozinhar: clássica (200 g)", f"{link('classica', 'Receita')}"),
        ("Cozinhar: frango", f"{link('frango', 'Receita')} · guarnição: {link('brocolis', 'Brócolis')}"),
        ("No dia: omelete reforçado", f"Não entra no lote · {link('omelete', 'Receita')}"),
    ],
}


def build_prep_html(week: int) -> str:
    steps = PREP[week]
    last = LETTER[len(steps) - 1]
    parts = []
    for i, (title, note) in enumerate(steps):
        parts.append(art(LETTER[i], title, note))
    return "".join(parts), last


def patch_week(path: Path, week: int) -> None:
    html = path.read_text(encoding="utf-8")
    prep_html, last = build_prep_html(week)
    html = re.sub(r"ordem A→[A-Z]", f"ordem A→{last}", html)
    # Troca o bloco de artigos de prep (do primeiro Cozinhar/No dia até antes de Depois).
    # Replace prep articles block (from first cook step until before Depois).
    pattern = re.compile(
        r'(</div></div>\r?\n)'
        r'(?:\s*<article class="recipe">[\s\S]*?</article>\r?\n)+'
        r'(\s*<article class="recipe">\s*\r?\n\s*<h3>Depois:)',
        re.MULTILINE,
    )

    def repl(m: re.Match) -> str:
        return m.group(1) + prep_html + m.group(2)

    new_html, n = pattern.subn(repl, html, count=1)
    if n != 1:
        raise SystemExit(f"Não achei bloco de prep em {path.name}")
    path.write_text(new_html, encoding="utf-8")
    print("week", week, "steps", len(PREP[week]), "→", last)


def split_arroz_feijao(path: Path) -> None:
    html = path.read_text(encoding="utf-8")
    # Separa a seção única em duas com âncoras próprias.
    # Split the single section into two with their own anchors.
    old = re.search(
        r'<section class="card" id="arroz">[\s\S]*?</section>\s*(?=</main>)',
        html,
    )
    if not old:
        print("receitas: bloco arroz não encontrado")
        return
    block = """    <section class="card" id="arroz">
      <h2>Arroz integral (lote)</h2>
      <p class="footer-note">Cozinha <strong>1 vez</strong> no domingo · Na marmita: <strong>2 colheres de sopa</strong></p>
      <article class="recipe">
        <h3>Como fazer</h3>
        <p class="meta">Tempo: 35–40 min · Rende o lote da semana</p>
        <p class="ing"><strong>Lote:</strong> 1⅓ xícara de arroz integral · água (siga a proporção da embalagem; em geral ~2,5 a 3 xícaras) · <strong>1</strong> dente de alho · <strong>1</strong> colher de chá de azeite · sal</p>
        <ol>
          <li>Opcional: lave o arroz em água corrente até sair menos nuvem.</li>
          <li>Escorra bem o arroz.</li>
          <li>Pique o alho.</li>
          <li>Aqueça a panela com azeite em fogo médio.</li>
          <li>Refogue o alho 30 s (não queime).</li>
          <li>Junte o arroz.</li>
          <li>Mexa 1 min para “selar”.</li>
          <li>Adicione a água.</li>
          <li>Adicione o sal.</li>
          <li>Espere ferver.</li>
          <li>Tampe a panela.</li>
          <li>Baixe o fogo.</li>
          <li>Cozinhe 30–35 min sem ficar abrindo.</li>
          <li>Apague o fogo.</li>
          <li>Deixe 5 min tampado.</li>
          <li>Solte o arroz com um garfo.</li>
          <li><strong>Na marmita:</strong> só 2 cs.</li>
          <li>Guarde o resto na geladeira até 4–5 dias.</li>
        </ol>
      </article>
    </section>

    <section class="card" id="feijao">
      <h2>Feijão (lote)</h2>
      <p class="footer-note">Cozinha <strong>1 vez</strong> no domingo · Na marmita: <strong>2 colheres de sopa</strong> · Só se o prato <em>não</em> tiver molho</p>
      <article class="recipe">
        <h3>Como fazer</h3>
        <p class="meta">Tempo ativo: ~40 min (+ atalho de 1 h de molho rápido)</p>
        <p class="ing"><strong>Lote:</strong> 1 xícara de feijão · água · <strong>1</strong> cebola · <strong>2</strong> dentes de alho · louro · azeite · sal</p>
        <ol>
          <li><strong>Atalho (sem molho de véspera):</strong> coloque o feijão numa panela com água.</li>
          <li>Ferva 2–3 min.</li>
          <li>Desligue o fogo.</li>
          <li>Tampe e deixe 1 h.</li>
          <li>Escorra.</li>
          <li>Coloque o feijão na panela de pressão.</li>
          <li>Cubra com água nova (~3 dedos acima).</li>
          <li>Adicione a folha de louro.</li>
          <li>Feche a panela de pressão.</li>
          <li>Espere pegar pressão.</li>
          <li>Conte ~25 min de pressão.</li>
          <li>Desligue e espere a pressão sair por completo.</li>
          <li>Abra e prove: deve estar macio.</li>
          <li>À parte: pique cebola e alho.</li>
          <li>Refogue cebola e alho no azeite.</li>
          <li>Junte o refogado ao feijão.</li>
          <li>Adicione sal a gosto.</li>
          <li>Ferva 5 min para pegar gosto.</li>
          <li><strong>Na marmita:</strong> 2 cs <strong>somente</strong> se o prato não tiver molho.</li>
          <li>Shoyu, tomate ou recheado com molho → sem feijão.</li>
        </ol>
      </article>
    </section>
"""
    html = html[: old.start()] + block + html[old.end() :]
    path.write_text(html, encoding="utf-8")
    print("receitas: arroz e feijão separados")


def main() -> None:
    for w in range(1, 9):
        patch_week(root / f"semana-{w}.html", w)
    split_arroz_feijao(root / "receitas.html")


if __name__ == "__main__":
    main()
