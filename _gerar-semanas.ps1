# 7 semanas · sem repetir prato · quantidades pela marmita TOTAL 300–500 g.
# Base de cálculo (cru → pote):
#   proteína almoço ~180 g cru (~150 g no pote)
#   proteína jantar ~200 g cru
#   guarnição ~150–180 g
#   arroz 2 cs ~45 g cozido (~18 g cru) · feijão 2 cs só sem molho
$ErrorActionPreference = "Stop"
$base = "C:\Users\Dell\Downloads\Alimentacao"
$total = 7

function Get-Nav([int]$active) {
  $lines = @("      <a href=`"index.html`">Início</a>")
  foreach ($n in 1..$total) {
    $cls = if ($n -eq $active) { ' class="active"' } else { '' }
    $lines += "      <a$cls href=`"semana-$n.html`">Semana $n</a>"
  }
  $lines += "      <a href=`"receitas-favoritas.html`">Favoritas</a>"
  $lines += "      <a href=`"legumes-recheados.html`">Recheados</a>"
  return ($lines -join "`n")
}
function Shop-Html($items) {
  $i = 0
  ($items | ForEach-Object { $id = "i$i"; $i++; "          <li><label class=`"shop-item`"><input type=`"checkbox`" data-id=`"$id`" /><span>$_</span></label></li>" }) -join "`n"
}
function Pots-Html($rows) {
  ($rows | ForEach-Object { "            <tr>`n              <td>$($_[0])</td>`n              <td>$($_[1])</td>`n              <td>$($_[2])</td>`n            </tr>" }) -join "`n"
}
function Days-Html($days) {
  $first = $true
  ($days | ForEach-Object {
    $style = if ($first) { "" } else { ' style="margin-top:0.75rem"' }
    $first = $false
    @"
      <article class="meal"$style>
        <span class="label">$($_.label)</span>
        $($_.body)
      </article>
"@
  }) -join "`n"
}
function Chips-Html($chips) {
  ($chips | ForEach-Object { "        <span class=`"chip`">$_</span>" }) -join "`n"
}

function Write-Week($w) {
  $n = $w.n
  $next = if ($n -lt $total) { $n + 1 } else { 1 }
  $days = (Days-Html $w.days) -replace 'SEMANA_NEXT', "semana-$next.html"
  $html = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Semana $n — $($w.title)</title>
  <link rel="stylesheet" href="estilo.css?v=9" />
</head>
<body>
  <main class="wrap">
    <nav class="nav">
$(Get-Nav $n)
    </nav>
    <section class="hero">
      <h1>Semana $n</h1>
      <p>$($w.sub)</p>
      <div class="chips">
$(Chips-Html $w.chips)
      </div>
    </section>
    <section class="card">
      <div class="passo"><div class="passo-num">1</div><div class="passo-body">
        <h3>Compras da semana</h3>
        <p>Quantidades recalculadas: <strong>pote 300–500 g no total</strong> (proteína ~150 g + guarnição ~150–180 g + 2 cs arroz). Cada prato 1× na semana.</p>
      </div></div>
      <div id="lista-compras" data-semana="$n">
        <ul class="shop-check">
$(Shop-Html $w.shop)
        </ul>
        <p class="footer-note" data-shop-estimate>Estimativa: use a página Preços (ou foto do cupom no chat) para valores em R$.</p>
        <div class="shop-actions">
          <button type="button" class="btn-keep" data-keep-download data-semana="$n">Baixar lista (Google Keep)</button>
          <button type="button" class="btn-keep btn-keep-secondary" data-keep-reset data-semana="$n">Limpar marcas</button>
        </div>
      </div>
    </section>
    <section class="card">
      <div class="passo"><div class="passo-num">2</div><div class="passo-body">
        <h3>Domingo — cozinhe tudo (~$($w.prepTime))</h3>
        <p>Monte cada pote já no peso final (balança ajuda). Proteína ~150 g · guarnição completa o resto.</p>
      </div></div>
      <article class="recipe">$($w.prepA)</article>
      <article class="recipe">$($w.prepB)</article>
      <article class="recipe">$($w.prepC)</article>
      <article class="recipe">$($w.prepD)</article>
      <article class="recipe">
        <h3>Monte os potes</h3>
        <table class="table">
          <thead><tr><th>Tampa</th><th>Prato (1× na semana)</th><th>Arroz / feijão</th></tr></thead>
          <tbody>
$(Pots-Html $w.pots)
          </tbody>
        </table>
        <p class="footer-note">$($w.potNote)</p>
      </article>
    </section>
    <section class="card">
      <div class="passo"><div class="passo-num">3</div><div class="passo-body">
        <h3>Durante a semana — só esquentar</h3>
        <p>Micro-ondas 3–4 min. Almoço: pote 300–500 g (tudo junto). Jantar Ter–Qui: 300–400 g sem arroz/feijão.</p>
      </div></div>
$days
    </section>
  </main>
  <script src="keep-lista.js?v=7"></script>
  <script src="precos-store.js?v=1"></script>
</body>
</html>
"@
  [IO.File]::WriteAllText((Join-Path $base "semana-$n.html"), $html, [Text.UTF8Encoding]::new($false))
  Write-Host "OK semana-$n"
}

$arroz = @"
        <h3>A) Arroz + feijão (lote da semana)</h3>
        <p class="ing"><strong>Arroz:</strong> 1⅓ xícara cru (≈ 7 × 2 cs cozido). <strong>Feijão:</strong> 1 xícara cru (só nos dias sem molho).</p>
        <ol><li>Feijão na pressão · arroz integral no fogão. Na montagem: 2 cs de cada quando couber na regra.</li></ol>
"@

$weeks = @(
  @{
    # Proteína: panela 180+200 · recheios 160×2 · shoyu 180 · clássica 180 · almôndegas 180 · refogado 180 · frango 200
    # Guarnições: quiabo 180 · brócolis 180×3 · vagem 180×2
    n=1; title="Panela · quiabo · recheados"; sub="Cada prato 1× · quantidades pela marmita total 300–500 g"
    chips=@("Sem repetir","~150 g proteína","Guarnição ~170 g"); prepTime="1h50"
    potNote="Cru→pote: ~180 g carne/almoço · ~200 g jantar carne · guarnição 150–180 g. Favoritas + Recheados + Moída."
    shop=@(
      "Acém/músculo — 400 g (almoço panela 180 g + jantar 200 g)",
      "Patinho moído — 1,1 kg (2 recheios 160 g + shoyu + clássica + almôndegas + refogado ≈ 180 g cada)",
      "Peito de frango — 200 g (1 jantar)",
      "Ovos — 4 un (1 omelete)",
      "Quiabo — 200 g (1 guarnição)",
      "Pimentão — 2 (1 recheado + 1 refogado)",
      "Abobrinha — 2 (recheado; rende 1 pote)",
      "Brócolis — 550 g (3 guarnições × ~180 g)",
      "Vagem — 400 g (2 guarnições)",
      "Mussarela — 60 g (2 recheados × ~25–30 g)",
      "Tomate p/ molho — 3 ou ½ lata",
      "Molho shoyu pronto — 1 frasco pequeno",
      "Arroz integral — 300 g · Feijão — 300 g",
      "Cebola (3) · alho · tomate · pepino · temperos · azeite · limão"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Carne de panela (400 g cru)</h3>
        <ol>
          <li>Rende 2 potes de proteína (~150–170 g cada): almoço com quiabo · jantar com brócolis. <a href="receitas-favoritas.html">Favoritas</a>.</li>
        </ol>
"@
    prepC=@"
        <h3>C) Quiabo (200 g) + patinho (1,1 kg)</h3>
        <ol>
          <li>Quiabo sem baba = 1 guarnição (~180 g). <a href="receitas-favoritas.html">Receita</a>.</li>
          <li>Divida o patinho: 2×160 g recheio · 4×180 g (shoyu, clássica, almôndegas, refogado). <a href="carne-moida.html">Moída</a>.</li>
        </ol>
"@
    prepD=@"
        <h3>D) Recheados + frango (200 g)</h3>
        <ol><li>Pimentão e abobrinha com ~160 g recheio cada + molho/queijo; o legume entra no peso do pote. Frango grelhado 200 g. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Carne de panela (~150 g) + quiabo (~180 g)","2 cs arroz → total 300–500 g"),
      @("Ter almoço","Pimentão recheado (~160 g carne + legume/molho)","2 cs arroz"),
      @("Ter jantar","Frango (~170 g) + brócolis (~180 g)","nada · 300–400 g"),
      @("Qua almoço","Abobrinha recheada","2 cs arroz"),
      @("Qua jantar","Omelete (4 ovos) + tomate/pepino","nada · 300–400 g"),
      @("Qui almoço","Carne shoyu (~150 g) + vagem (~180 g)","2 cs arroz"),
      @("Qui jantar","Panela (~170 g) + brócolis (~180 g)","nada"),
      @("Sex almoço","Clássica (~150 g) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Almôndegas (~150 g) + vagem","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Carne + pimentão refogado (~150 g + guarnição)","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Carne de panela + quiabo</strong>`n        <span class=`"dia-qtd`">pote 300–500 g (proteína + guarnição + arroz)</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango + brócolis (300–400 g)</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: abobrinha recheada</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: shoyu + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela + brócolis</strong>"},
      @{label="Sexta — almoço"; body="<strong>Clássica + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Almôndegas + vagem</strong>"},
      @{label="Domingo — almoço"; body="<strong>Carne + pimentão refogado</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    # 3 recheios 160 · almôndegas 180×2 · shoyu 180 · clássica 180 · couve-carne 180 · frango 200 = patinho ~1,2 kg + frango
    n=2; title="Fornada recheados A"; sub="Berinjela · tomate · chuchu · almôndegas · shoyu · clássica — pesos pela marmita total"
    chips=@("Recheados","~160 g recheio","Guarnição"); prepTime="1h45"
    potNote="Recheado: ~160 g carne + legume/molho/queijo + 2 cs arroz = 300–500 g."
    shop=@(
      "Patinho moído — 1,2 kg (3 recheios 160 g + almôndegas 360 g + shoyu 180 g + clássica 180 g + carne/couve 180 g)",
      "Peito de frango — 200 g",
      "Ovos — 1 dúzia (omelete 4 + liga almôndegas)",
      "Berinjela — 1 · Tomate firme — 3 · Chuchu — 1",
      "Brócolis — 400 g (2 guarnições)",
      "Vagem — 400 g (2 guarnições)",
      "Couve — 1 maço (~200 g útil)",
      "Abobrinha — 1 (omelete)",
      "Mussarela — 90 g (3 recheados)",
      "Tomate p/ molho · Shoyu · Aveia (liga)",
      "Arroz integral — 300 g · Feijão — 300 g",
      "Cebola · alho · temperos · azeite"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Patinho 1,2 kg — divisão na balança</h3>
        <ol><li>3×160 g recheio · 360 g almôndegas (2 marmitas) · 180 g shoyu · 180 g clássica · 180 g com couve. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados A</h3>
        <ol><li>Berinjela, tomate, chuchu — ~160 g recheio cada. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Almôndegas + frango 200 g</h3>
        <ol><li>Forno 200 °C 20–25 min. Frango = 1 jantar.</li></ol>
"@
    pots=@(
      @("Seg almoço","Berinjela recheada","2 cs arroz"),
      @("Ter almoço","Tomate recheado","2 cs arroz"),
      @("Ter jantar","Omelete + abobrinha","nada · 300–400 g"),
      @("Qua almoço","Chuchu recheado","2 cs arroz"),
      @("Qua jantar","Almôndegas (~150 g) + brócolis","nada"),
      @("Qui almoço","Shoyu + vagem","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Carne + couve","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Almôndegas + vagem","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Berinjela recheada</strong>`n        <span class=`"dia-qtd`">pote 300–500 g</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: chuchu recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: almôndegas + brócolis</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: shoyu + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Clássica + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Carne + couve</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas + vagem</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=3; title="Panela · abóbora · moída"; sub="Panela 2 usos distintos · abóbora/pimentão recheados · quiabo com moída"
    chips=@("Panela 400 g","Recheados","Moída"); prepTime="1h50"
    potNote="Panela 400 g cru = 2 proteínas. Não repetir o mesmo prato montado."
    shop=@(
      "Acém/músculo — 400 g (2 potes de proteína)",
      "Patinho moído — 1,0 kg (2 recheios 160 g + quiabo-moída 180 g + berinjela molho 180 g + shoyu 180 g + clássica 180 g)",
      "Peito de frango — 200 g",
      "Ovos — 4 un",
      "Abóbora cabocha — 1 fatia grossa (~300 g com casca)",
      "Pimentão — 1 · Quiabo — 200 g · Berinjela — 1",
      "Brócolis — 200 g · Vagem — 200 g · Couve — 1 maço",
      "Mussarela — 60 g",
      "Tomate p/ molho · Shoyu",
      "Arroz integral — 300 g · Feijão — 250 g",
      "Cebola · alho · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 400 g</h3>
        <ol><li>Jantar terça: + vagem · Almoço domingo: + couve. <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Abóbora + pimentão (~160 g recheio cada)</h3>
        <ol><li><a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Moída restante + frango 200 g</h3>
        <ol><li>Quiabo+moída · berinjela ao molho · shoyu · clássica — 180 g carne cada. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Panela + vagem","nada · 300–400 g"),
      @("Qua almoço","Moída + quiabo","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete + tomate","nada"),
      @("Qui almoço","Berinjela ao molho","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Shoyu + brócolis","2 cs arroz"),
      @("Sáb almoço","Clássica + couve","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Panela + couve","2 cs arroz")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abóbora recheada</strong>`n        <span class=`"dia-qtd`">pote 300–500 g</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela + vagem</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: moída + quiabo</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: berinjela ao molho</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Shoyu + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Clássica + couve</strong>"},
      @{label="Domingo — almoço"; body="<strong>Panela + couve</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=4; title="Moída completa"; sub="6 pratos de moída distintos + frango/omelete — ~180 g proteína cada almoço"
    chips=@("1,3 kg patinho","Sem panela","Sem repetir"); prepTime="1h30"
    potNote="6×180 g almoço + 1 jantar carne/abobrinha 200 g + frango 200 g ≈ 1,5 kg; usamos 1,3 kg moída + 200 g frango."
    shop=@(
      "Patinho moído — 1,3 kg (clássica · shoyu · almôndegas×2 · pimentão · chuchu · couve · abobrinha jantar)",
      "Peito de frango — 200 g",
      "Ovos — 1 dúzia",
      "Pimentão — 2 · Abobrinha — 1 · Chuchu — 1",
      "Brócolis — 400 g · Vagem — 400 g · Couve — 1 maço",
      "Molho shoyu · Tomate · cebola · alho · aveia",
      "Arroz integral — 300 g · Feijão — 350 g (mais dias sem molho)",
      "Temperos · azeite"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Patinho 1,3 kg na balança</h3>
        <ol><li>Porções de ~180 g (almoço) e ~200 g (jantar abobrinha). <a href="carne-moida.html">Receitas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Legumes (~180 g por guarnição)</h3>
        <ol><li>Brócolis, vagem, couve, chuchu, pimentão em tiras.</li></ol>
"@
    prepD=@"
        <h3>D) Frango 200 g</h3>
        <ol><li>1 jantar.</li></ol>
"@
    pots=@(
      @("Seg almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Ter almoço","Shoyu + vagem","2 cs arroz"),
      @("Ter jantar","Omelete + couve","nada"),
      @("Qua almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Carne + abobrinha (~200 g carne)","nada"),
      @("Qui almoço","Carne + pimentão","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Frango + vagem","nada"),
      @("Sex almoço","Carne + chuchu","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Carne + couve","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Almôndegas + vagem","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Clássica + brócolis</strong>`n        <span class=`"dia-qtd`">pote 300–500 g</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: shoyu + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: almôndegas</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: carne + abobrinha</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: carne + pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Carne + chuchu</strong>"},
      @{label="Sábado — almoço"; body="<strong>Carne + couve</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas + vagem</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=5; title="Recheados B + panela"; sub="4 recheados · 1 panela+quiabo · shoyu · clássica — pesos recalculados"
    chips=@("4 recheados","Panela 200 g","Moída"); prepTime="1h50"
    potNote="Panela só 200 g cru = 1 almoço. Recheios 4×160 g."
    shop=@(
      "Acém/músculo — 200 g (1 almoço panela + quiabo)",
      "Patinho moído — 1,0 kg (4×160 g recheio + shoyu 180 g + clássica 180 g + carne/vagem 180 g)",
      "Peito de frango — 200 g",
      "Ovos — 4 un",
      "Quiabo — 200 g",
      "Abobrinha — 2 · Pimentão — 1 · Berinjela — 1 · Tomate firme — 2",
      "Brócolis — 200 g · Vagem — 400 g · Pepino (salada)",
      "Mussarela — 120 g (4 recheados)",
      "Tomate p/ molho · Shoyu",
      "Arroz integral — 300 g · Feijão — 250 g",
      "Cebola · alho · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 200 g + quiabo 200 g</h3>
        <ol><li>1 marmita sábado. <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) 4 recheados × ~160 g carne</h3>
        <ol><li>Abobrinha, pimentão, berinjela, tomate. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Shoyu · clássica · carne+vagem · frango 200 g</h3>
        <ol><li>~180 g cada prato de moída. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abobrinha recheada","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete + pepino","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Panela + quiabo","2 cs arroz"),
      @("Dom almoço","Carne + vagem (sem shoyu)","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abobrinha recheada</strong>`n        <span class=`"dia-qtd`">pote 300–500 g</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: berinjela</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: shoyu + vagem</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Clássica + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Panela + quiabo</strong>"},
      @{label="Domingo — almoço"; body="<strong>Carne + vagem</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=6; title="Abóbora · chuchu · almôndegas"; sub="2 recheados · almôndegas · shoyu · clássica · panela jantar · frango almoço"
    chips=@("Abóbora","Chuchu","Panela jantar"); prepTime="1h45"
    potNote="Panela 200 g = só jantar. Frango 200 g no almoço de sábado (exceção: proteína de ave no almoço)."
    shop=@(
      "Acém/músculo — 200 g (1 jantar)",
      "Patinho moído — 1,1 kg (2×160 g recheio + almôndegas 360 g + shoyu 180 g + clássica 180 g + pimentão 180 g)",
      "Peito de frango — 200 g (almoço sábado)",
      "Ovos — 1 dúzia",
      "Abóbora — 1 fatia · Chuchu — 1 · Pimentão — 1",
      "Brócolis — 400 g · Vagem — 400 g · Couve — 1 maço",
      "Mussarela — 60 g · Molho · Shoyu · Aveia",
      "Arroz integral — 300 g · Feijão — 300 g",
      "Cebola · alho · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 200 g</h3>
        <ol><li>Só jantar quinta + brócolis. <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Abóbora + chuchu (~160 g recheio)</h3>
        <ol><li><a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Moída + frango 200 g</h3>
        <ol><li>Almôndegas (2 potes) · shoyu · clássica · carne+pimentão. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Ter almoço","Chuchu recheado","2 cs arroz"),
      @("Ter jantar","Omelete + couve","nada"),
      @("Qua almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Shoyu + vagem","nada"),
      @("Qui almoço","Clássica + couve","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Panela + brócolis","nada"),
      @("Sex almoço","Carne + pimentão","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Frango + vagem","2 cs arroz"),
      @("Dom almoço","Almôndegas + legume","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abóbora recheada</strong>`n        <span class=`"dia-qtd`">pote 300–500 g</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: chuchu</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: almôndegas</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: shoyu</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: clássica</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela</strong>"},
      @{label="Sexta — almoço"; body="<strong>Carne + pimentão</strong>"},
      @{label="Sábado — almoço"; body="<strong>Frango + vagem</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas + legume</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=7; title="Fecha o ciclo"; sub="Panela+quiabo 1× · 3 recheados · shoyu · almôndegas · clássica · refogado"
    chips=@("Fecha ciclo","Pesos recalculados"); prepTime="1h50"
    potNote="Volta à Semana 1. Panela 200 g + quiabo 200 g = 1 almoço."
    shop=@(
      "Acém/músculo — 200 g",
      "Patinho moído — 1,0 kg (3×160 g recheio + shoyu 180 g + almôndegas 180 g + clássica 180 g + abobrinha-refogada 180 g)",
      "Peito de frango — 200 g",
      "Ovos — 4 un",
      "Quiabo — 200 g",
      "Pimentão — 1 · Berinjela — 1 · Tomate firme — 2 · Abobrinha — 1",
      "Brócolis — 400 g · Vagem — 400 g",
      "Mussarela — 90 g",
      "Tomate p/ molho · Shoyu · Aveia",
      "Arroz integral — 300 g · Feijão — 250 g",
      "Cebola · alho · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 200 g + quiabo 200 g</h3>
        <ol><li>Só segunda. <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) 3 recheados × ~160 g</h3>
        <ol><li>Pimentão, berinjela, tomate. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Shoyu · almôndegas · clássica · refogado · frango 200 g</h3>
        <ol><li>~180 g cada. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Panela + quiabo","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete + abobrinha","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Clássica + vagem","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Carne + abobrinha refogada","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Panela + quiabo</strong>`n        <span class=`"dia-qtd`">pote 300–500 g</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: berinjela</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: shoyu</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Almôndegas + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Clássica + vagem</strong>"},
      @{label="Domingo — almoço"; body="<strong>Carne + abobrinha</strong>`n        <ul><li>Ciclo: <a href=`"SEMANA_NEXT`">Semana 1</a></li></ul>"}
    )
  }
)

foreach ($w in $weeks) { Write-Week $w }
foreach ($n in 8..10) {
  $p = Join-Path $base "semana-$n.html"
  if (Test-Path $p) { Remove-Item $p -Force; Write-Host "REMOVED semana-$n" }
}

function Make-NavHtml([string]$activeHref) {
  $items = @(
    @{h='index.html';t='Início'},
    @{h='semana-1.html';t='Semana 1'},@{h='semana-2.html';t='Semana 2'},@{h='semana-3.html';t='Semana 3'},
    @{h='semana-4.html';t='Semana 4'},@{h='semana-5.html';t='Semana 5'},@{h='semana-6.html';t='Semana 6'},
    @{h='semana-7.html';t='Semana 7'},
    @{h='receitas-favoritas.html';t='Favoritas'},@{h='legumes-recheados.html';t='Recheados'}
  )
  $lines = @('    <nav class="nav">')
  foreach ($i in $items) {
    if ($i.h -eq $activeHref) { $lines += "      <a class=`"active`" href=`"$($i.h)`">$($i.t)</a>" }
    else { $lines += "      <a href=`"$($i.h)`">$($i.t)</a>" }
  }
  $lines += '    </nav>'
  $lines -join "`n"
}

# Início não leva nav no topo — as semanas já estão no corpo da página.
# Home page has no top nav — weeks are already listed in the body.
$sat = @{
  'receitas-favoritas.html'='receitas-favoritas.html'
  'legumes-recheados.html'='legumes-recheados.html'
  'carne-moida.html'='carne-moida.html'
  'precos.html'='precos.html'
}
foreach ($f in $sat.Keys) {
  $path = Join-Path $base $f
  if (-not (Test-Path $path)) { continue }
  $c = [IO.File]::ReadAllText($path)
  $nav = Make-NavHtml $sat[$f]
  if ($c -match '(?s)<nav class="nav">.*?</nav>') {
    $c = [regex]::Replace($c, '(?s)<nav class="nav">.*?</nav>', [System.Text.RegularExpressions.MatchEvaluator]{ param($m) $nav }, 1)
  }
  $c = $c -replace 'estilo\.css(\?v=\d+)?"', 'estilo.css?v=9"'
  [IO.File]::WriteAllText($path, $c)
}
# Garante que o index fique sem <nav> no topo.
# Ensure index has no top <nav>.
$idxTmp = Join-Path $base 'index.html'
if (Test-Path $idxTmp) {
  $ic = [IO.File]::ReadAllText($idxTmp)
  $ic = [regex]::Replace($ic, '(?s)\s*<nav class="nav">.*?</nav>\s*', "`n", 1)
  $ic = $ic -replace 'estilo\.css(\?v=\d+)?"', 'estilo.css?v=9"'
  [IO.File]::WriteAllText($idxTmp, $ic)
}

$idxPath = Join-Path $base 'index.html'
$idx = [IO.File]::ReadAllText($idxPath)
$weekList = @'
      <div class="week-list">
        <a href="semana-1.html"><strong>Semana 1</strong>Panela · quiabo · recheados (pesos recalculados)</a>
        <a href="semana-2.html"><strong>Semana 2</strong>Recheados A · almôndegas · shoyu</a>
        <a href="semana-3.html"><strong>Semana 3</strong>Panela · abóbora · moída</a>
        <a href="semana-4.html"><strong>Semana 4</strong>Moída completa</a>
        <a href="semana-5.html"><strong>Semana 5</strong>Recheados B · panela+quiabo</a>
        <a href="semana-6.html"><strong>Semana 6</strong>Abóbora · chuchu · almôndegas</a>
        <a href="semana-7.html"><strong>Semana 7</strong>Fecha o ciclo</a>
      </div>
'@
$idx = [regex]::Replace($idx, '(?s)<div class="week-list">.*?</div>', $weekList.TrimEnd(), 1)
[IO.File]::WriteAllText($idxPath, $idx)
Write-Host "DONE"
