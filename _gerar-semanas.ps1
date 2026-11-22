# 8 semanas · recomp Márcio (86 kg) · rotina 8h–23h
# - Café 8:00 · Almoço 12:30 · Jantar 20:00 (todos os dias) · Dormir 23:00
# - Pote: ~180–200 g proteína crua; almoço 400–550 g; jantar 350–450 g sem arroz
# - Economia: frango 1 almoço/sem · muffin 1 almoço/sem · porco em cubos · acém vs patinho
# 8 weeks · Márcio recomp · fixed meal times; dinner every day; larger protein pots
$ErrorActionPreference = "Stop"
$base = "c:\GadgetApps\alimentacao-cardapios"
$total = 8

function Get-NavHtml([int]$active) {
  # Drawer assume o menu; nav antiga fica vazia/escondida pelo CSS.
  # Drawer owns navigation; legacy nav hidden by CSS.
  return '    <nav class="nav" hidden></nav>'
}

function Test-SkipShopItem([string]$t) {
  # Fora da lista semanal: só estoque seco (despensa). Frescos ficam na semana.
  # Weekly list excludes dry pantry only. Fresh ingredients stay on the week.
  $f = $t.ToLowerInvariant()
  if ($f -match '^(arroz|feij)') { return $true }
  if ($f -match '^(temperos?|shoyu|aveia|azeite|\bsal\b|colorau|cominho|p[aá]prica|or[eé]gano|louro|pimenta|alho)(\s|$|·)') { return $true }
  if ($f -match '^(temperos?|shoyu|aveia|azeite|alho)\s*$') { return $true }
  return $false
}

function Expand-ShopItems($items) {
  # Um checkbox por item (quebra em " · ").
  # One checkbox per item (split on " · ").
  $out = New-Object System.Collections.Generic.List[string]
  foreach ($raw in $items) {
    foreach ($part in ($raw -split '\s*·\s*')) {
      $t = $part.Trim()
      if (-not $t) { continue }
      if (Test-SkipShopItem $t) { continue }
      $out.Add($t)
    }
  }
  return ,$out.ToArray()
}

function Shop($items) {
  $expanded = Expand-ShopItems $items
  ($expanded | ForEach-Object {
    $id = "i$script:i"; $script:i++
    "          <li><label class=`"shop-item`"><input type=`"checkbox`" data-id=`"$id`" /><span>$_</span></label></li>"
  }) -join "`n"
}

function Pots($rows) {
  ($rows | ForEach-Object {
    "            <tr><td>$($_[0])</td><td>$($_[1])</td><td>$($_[2])</td></tr>"
  }) -join "`n"
}

function Days($days) {
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

function Chips($arr) {
  ($arr | ForEach-Object { "        <span class=`"chip`">$_</span>" }) -join "`n"
}

function MealBody([string]$almoco, [string]$jantar) {
  # Almoço 12:30 e jantar 20:00 — texto padrão de cada dia.
  # Lunch 12:30 and dinner 20:00 — standard day copy.
  return "<strong>12:30 almoço:</strong> $almoco<strong style=`"margin-top:0.6rem;display:block`">20:00 jantar:</strong> $jantar"
}

function Write-Week($w) {
  $script:i = 0
  $n = $w.n
  $next = if ($n -lt $total) { $n + 1 } else { 1 }
  $daysHtml = (Days $w.days) -replace 'SEMANA_NEXT', "semana-$next.html"
  $html = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <title>Semana $n - $($w.title)</title>
  <link rel="stylesheet" href="estilo.css?v=14" />
</head>
<body class="semana-$n">
  <main class="wrap">
$(Get-NavHtml $n)
    <section class="hero">
      <h1>Semana $n</h1>
      <p>$($w.sub)</p>
      <div class="chips">
$(Chips $w.chips)
      </div>
    </section>
    <p class="footer-note"><a href="receitas.html#s$n">Receitas desta semana</a></p>

    <section class="card">
      <h2>Rotina do dia</h2>
      <ul>
        <li><strong>08:00</strong> Café — pão francês · 2 mussarela · tomate · manteiga · <strong>2 ovos</strong></li>
        <li><strong>12:30</strong> Almoço — pote 400–550 g (~180–200 g proteína + legume + 2 cs arroz)</li>
        <li><strong>20:00</strong> Jantar — pote 350–450 g (~180–200 g proteína + legume, <em>sem</em> arroz/feijão)</li>
        <li><strong>23:00</strong> Dormir</li>
      </ul>
      <p class="footer-note">Dia de academia: almoço no teto (~500–550 g) ou +2 cs feijão. Fome 2–3 h depois → aumente legume/proteína no pote, não pule refeição.</p>
    </section>

    <section class="card">
      <div class="passo"><div class="passo-num">1</div><div class="passo-body">
        <h3>Compras da semana</h3>
      </div></div>
      <div id="lista-compras" data-semana="$n">
        <ul class="shop-check">
$(Shop $w.shop)
        </ul>
        <div class="shop-actions">
          <button type="button" class="btn-keep btn-keep-secondary" data-keep-reset data-semana="$n">Limpar marcas</button>
        </div>
      </div>
    </section>

    <section class="card">
      <div class="passo"><div class="passo-num">2</div><div class="passo-body">
        <h3>Ordem de preparo (~$($w.prepTime))</h3>
        <p><strong>Não é receita.</strong> É a lista do que cozinhar no dia do prep, na ordem A→D (qualquer dia da semana). O passo a passo fica em <a href="receitas.html">Receitas</a>.</p>
        <p>No fim: monte <strong>14 potes</strong> (7 almoços + 7 jantares). Proteína ~180–200 g crua por pote.</p>
      </div></div>
      <article class="recipe">$($w.prepA)</article>
      <article class="recipe">$($w.prepB)</article>
      <article class="recipe">$($w.prepC)</article>
      <article class="recipe">$($w.prepD)</article>
      <article class="recipe">
        <h3>Depois: monte os potes da semana</h3>
        <p class="footer-note">Cada linha = 1 pote. Arroz/feijão só no almoço, onde indicado. Jantar = nada.</p>
        <table class="table">
          <thead><tr><th>Dia</th><th>Prato</th><th>Arroz / feijão</th></tr></thead>
          <tbody>
$(Pots $w.pots)
          </tbody>
        </table>
        <p class="footer-note">$($w.potNote)</p>
      </article>
    </section>

    <section class="card">
      <div class="passo"><div class="passo-num">3</div><div class="passo-body">
        <h3>Durante a semana — só esquentar</h3>
      </div></div>
$daysHtml
    </section>
  </main>
  <script src="precos-store.js?v=9"></script>
  <script src="keep-lista.js?v=13"></script>
  <script src="tema.js?v=1"></script>
  <script src="nav-drawer.js?v=6"></script>
</body>
</html>
"@
  [IO.File]::WriteAllText((Join-Path $base "semana-$n.html"), $html, [Text.UTF8Encoding]::new($false))
  Write-Host "OK semana-$n"
}

$arroz = @"
        <h3>A) Cozinhar: arroz + feijão (lote)</h3>
        <p class="footer-note">Passo a passo: <a href="receitas.html#arroz">Receitas → Arroz e feijão</a></p>
"@

# Ovos: muffins (3 potes × 4 ovos) + café (2/dia × 7).
# Eggs: muffins (3 pots × 4) + breakfast (2/day × 7).
$ovosShop = "Ovos - 2 dúzias (muffins + 2/dia no café)"

$weeks = @(
  @{
    n=1; title="Panela · porco · frango · ovo"; sub="14 potes · jantar todo dia · panela · recheados · porco · frango/muffin"
    chips=@("14 potes","Jantar 20:00","Frango almoço","Muffin almoço"); prepTime="2h10"
    potNote="Receitas: <a href=`"receitas.html#s1`">semana 1</a>."
    shop=@(
      "Acém/músculo (panela) - 570 g",
      "Patinho moído - 380 g (2 recheados)",
      "Acém/músculo moído - 200 g (clássica 1 pote)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 570 g",
      $ovosShop,
      "Quiabo - 300 g",
      "Pimentão - 1",
      "Abobrinha - 2",
      "Brócolis - 600 g",
      "Vagem - 400 g",
      "Tomate - 3",
      "Pepino - 1",
      "Couve - 1 maço",
      "Mussarela - 60 g (recheados)",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (570 g)</h3>
        <p class="footer-note">Rende 3 potes · <a href="receitas.html#panela">Receita</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: recheados (380 g) + porco (380 g) + clássica (200 g)</h3>
        <p class="footer-note">Pimentão + abobrinha · <a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#classica">Clássica</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (570 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a> — 12 ovos nos potes; resto do ovo = café</p>
"@
    pots=@(
      @("Seg almoço","Carne de panela + quiabo","2 cs arroz"),
      @("Seg jantar","Frango + brócolis","nada"),
      @("Ter almoço","Pimentão recheado (patinho)","2 cs arroz"),
      @("Ter jantar","Carne de panela + vagem","nada"),
      @("Qua almoço","Porco em cubos + vagem","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Muffin de ovo + tomate/pepino","nada"),
      @("Qui almoço","Abobrinha recheada (patinho)","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco em cubos + abobrinha","nada"),
      @("Sáb almoço","Muffin de ovo + abobrinha","2 cs arroz"),
      @("Sáb jantar","Clássica (acém) + couve","nada"),
      @("Dom almoço","Carne de panela + quiabo","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Muffin de ovo + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Carne de panela + quiabo" "Frango + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Carne de panela + vagem")},
      @{label="Quarta"; body=(MealBody "Porco em cubos + vagem" "Muffin de ovo + tomate/pepino")},
      @{label="Quinta"; body=(MealBody "Abobrinha recheada" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco em cubos + abobrinha")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + abobrinha" "Clássica (acém) + couve")},
      @{label="Domingo"; body=(MealBody "Carne de panela + quiabo" "Muffin de ovo + tomate")}
    )
  },

  @{
    n=2; title="Recheados · porco · frango · ovo"; sub="14 potes · recheados · almôndegas · porco shoyu · frango/muffin"
    chips=@("14 potes","Jantar 20:00","Acém","Porco shoyu"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s2`">Receitas semana 2</a>."
    shop=@(
      "Patinho moído - 570 g (3 recheados)",
      "Acém/músculo moído - 570 g (almôndegas × 3)",
      "Acém/músculo (panela) - 200 g",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Berinjela - 1",
      "Tomate firme - 3",
      "Chuchu - 1",
      "Brócolis - 600 g",
      "Vagem - 500 g",
      "Couve - 1 maço",
      "Abobrinha - 2",
      "Mussarela - 90 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (200 g) + 3 recheados (570 g patinho)</h3>
        <p class="footer-note">Berinjela · tomate · chuchu · <a href="receitas.html#panela">Carne de panela</a> · <a href="receitas.html#recheados">Recheados</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: almôndegas (570 g acém) + porco shoyu (380 g)</h3>
        <p class="footer-note"><a href="receitas.html#almondegas">Almôndegas</a> · <a href="receitas.html#porco">Porco</a> / <a href="receitas.html#shoyu">Shoyu</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (380 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a></p>
"@
    pots=@(
      @("Seg almoço","Berinjela recheada","2 cs arroz"),
      @("Seg jantar","Almôndegas (acém) + brócolis","nada"),
      @("Ter almoço","Tomate recheado","2 cs arroz"),
      @("Ter jantar","Muffin de ovo + abobrinha","nada"),
      @("Qua almoço","Chuchu recheado","2 cs arroz"),
      @("Qua jantar","Almôndegas (acém) + couve","nada"),
      @("Qui almoço","Porco shoyu + vagem","2 cs arroz"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco shoyu + abobrinha","nada"),
      @("Sáb almoço","Muffin de ovo + vagem","2 cs arroz"),
      @("Sáb jantar","Almôndegas (acém) + vagem","nada"),
      @("Dom almoço","Almôndegas (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Muffin de ovo + couve","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Berinjela recheada" "Almôndegas (acém) + brócolis")},
      @{label="Terça"; body=(MealBody "Tomate recheado" "Muffin de ovo + abobrinha")},
      @{label="Quarta"; body=(MealBody "Chuchu recheado" "Almôndegas (acém) + couve")},
      @{label="Quinta"; body=(MealBody "Porco shoyu + vagem" "Carne de panela + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco shoyu + abobrinha")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + vagem" "Almôndegas (acém) + vagem")},
      @{label="Domingo"; body=(MealBody "Almôndegas (acém) + brócolis" "Muffin de ovo + couve")}
    )
  },

  @{
    n=3; title="Panela · porco · frango · ovo"; sub="14 potes · panela · recheados · porco · clássica · frango/muffin"
    chips=@("14 potes","Jantar 20:00","Carne panela","Porco"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s3`">Receitas semana 3</a>."
    shop=@(
      "Acém/músculo (panela) - 570 g",
      "Patinho - 380 g (2 recheados)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Acém moído - 380 g (clássica × 2)",
      "Peito de frango - 380 g",
      $ovosShop,
      "Abóbora - 1 fatia",
      "Pimentão - 1",
      "Quiabo - 300 g",
      "Berinjela - 1",
      "Brócolis - 500 g",
      "Vagem - 400 g",
      "Couve - 1 maço",
      "Tomate - 2",
      "Mussarela - 60 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (570 g)</h3>
        <p class="footer-note">Rende 3 potes · <a href="receitas.html#panela">Receita</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: recheados + porco (380 g) + clássica (380 g)</h3>
        <p class="footer-note">Abóbora · pimentão · <a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#classica">Clássica</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (380 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a></p>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Seg jantar","Carne de panela + vagem","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Clássica (acém) + couve","nada"),
      @("Qua almoço","Porco + quiabo","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Muffin de ovo + tomate","nada"),
      @("Qui almoço","Berinjela ao molho (porco)","2 cs arroz"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco + vagem","nada"),
      @("Sáb almoço","Muffin de ovo + couve","2 cs arroz"),
      @("Sáb jantar","Clássica (acém) + brócolis","nada"),
      @("Dom almoço","Carne de panela + quiabo","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Muffin de ovo + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Abóbora recheada" "Carne de panela + vagem")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Clássica de acém + couve")},
      @{label="Quarta"; body=(MealBody "Porco + quiabo" "Muffin de ovo + tomate")},
      @{label="Quinta"; body=(MealBody "Berinjela ao molho" "Carne de panela + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco + vagem")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + couve" "Clássica de acém + brócolis")},
      @{label="Domingo"; body=(MealBody "Carne de panela + quiabo" "Muffin de ovo + tomate")}
    )
  },

  @{
    n=4; title="Moída econômica"; sub="14 potes · acém · porco · frango/muffin · sem patinho"
    chips=@("14 potes","Acém","Porco","Sem patinho"); prepTime="2h00"
    potNote="Semana sem recheado de patinho. <a href=`"receitas.html#s4`">Receitas</a>."
    shop=@(
      "Acém/músculo moído - 950 g",
      "Pernil ou lombo (porco) em cubos - 760 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Pimentão - 2",
      "Abobrinha - 2",
      "Chuchu - 1",
      "Brócolis - 600 g",
      "Vagem - 500 g",
      "Couve - 1 maço",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: acém moído (950 g)</h3>
        <p class="footer-note">5 potes · clássica · almôndegas · refogado · <a href="receitas.html#classica">Clássica</a> · <a href="receitas.html#almondegas">Almôndegas</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: porco em cubos (760 g)</h3>
        <p class="footer-note">4 potes · shoyu · pimentão · chuchu · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#shoyu">Shoyu</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (380 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a></p>
"@
    pots=@(
      @("Seg almoço","Clássica (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Seg jantar","Porco shoyu + vagem","nada"),
      @("Ter almoço","Porco shoyu + vagem","2 cs arroz"),
      @("Ter jantar","Muffin de ovo + couve","nada"),
      @("Qua almoço","Almôndegas (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Porco + abobrinha","nada"),
      @("Qui almoço","Porco + pimentão","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Frango + vagem","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Clássica (acém) + couve","nada"),
      @("Sáb almoço","Muffin de ovo + chuchu","2 cs arroz"),
      @("Sáb jantar","Almôndegas (acém) + vagem","nada"),
      @("Dom almoço","Almôndegas (acém) + couve","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Muffin de ovo + abobrinha","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Clássica de acém + brócolis" "Porco shoyu + vagem")},
      @{label="Terça"; body=(MealBody "Porco shoyu + vagem" "Muffin de ovo + couve")},
      @{label="Quarta"; body=(MealBody "Almôndegas (acém) + brócolis" "Porco + abobrinha")},
      @{label="Quinta"; body=(MealBody "Porco + pimentão" "Frango + vagem")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Clássica + couve")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + chuchu" "Almôndegas (acém) + vagem")},
      @{label="Domingo"; body=(MealBody "Almôndegas (acém) + couve" "Muffin de ovo + abobrinha")}
    )
  },

  @{
    n=5; title="Recheados · porco · frango · ovo"; sub="14 potes · 4 recheados · panela · porco · frango/muffin"
    chips=@("14 potes","4 recheados","Jantar 20:00"); prepTime="2h15"
    potNote="<a href=`"receitas.html#s5`">Receitas semana 5</a>."
    shop=@(
      "Acém/músculo (panela) - 380 g",
      "Patinho - 760 g (4 recheados)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Acém moído - 200 g (clássica)",
      "Peito de frango - 380 g",
      $ovosShop,
      "Quiabo - 300 g",
      "Abobrinha - 2",
      "Pimentão - 1",
      "Berinjela - 1",
      "Tomate firme - 3",
      "Brócolis - 500 g",
      "Vagem - 500 g",
      "Pepino - 1",
      "Mussarela - 120 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (380 g) + quiabo</h3>
        <p class="footer-note">2 potes · <a href="receitas.html#panela">Carne de panela</a> · <a href="receitas.html#quiabo">Quiabo</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: 4 recheados (760 g) + porco (380 g) + clássica (200 g)</h3>
        <p class="footer-note"><a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#classica">Clássica</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (380 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a></p>
"@
    pots=@(
      @("Seg almoço","Abobrinha recheada","2 cs arroz"),
      @("Seg jantar","Carne de panela + quiabo","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Muffin de ovo + pepino","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Porco shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + vagem","2 cs arroz"),
      @("Sex jantar","Clássica (acém) + vagem","nada"),
      @("Sáb almoço","Muffin de ovo + abobrinha","2 cs arroz"),
      @("Sáb jantar","Porco + brócolis","nada"),
      @("Dom almoço","Carne de panela + quiabo","2 cs arroz"),
      @("Dom jantar","Muffin de ovo + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Abobrinha recheada" "Carne de panela + quiabo")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Muffin de ovo + pepino")},
      @{label="Quarta"; body=(MealBody "Berinjela recheada" "Porco shoyu + vagem")},
      @{label="Quinta"; body=(MealBody "Tomate recheado" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + vagem" "Clássica + vagem")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + abobrinha" "Porco + brócolis")},
      @{label="Domingo"; body=(MealBody "Carne de panela + quiabo" "Muffin de ovo + tomate")}
    )
  },

  @{
    n=6; title="Abóbora · porco · frango · ovo"; sub="14 potes · abóbora/chuchu · almôndegas · porco · frango/muffin"
    chips=@("14 potes","Abóbora","Acém","Porco"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s6`">Receitas semana 6</a>."
    shop=@(
      "Acém/músculo (panela) - 380 g",
      "Patinho - 380 g (2 recheados)",
      "Acém moído - 570 g (almôndegas × 3)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Abóbora - 1 fatia",
      "Chuchu - 1",
      "Pimentão - 1",
      "Brócolis - 600 g",
      "Vagem - 500 g",
      "Couve - 1 maço",
      "Tomate - 2",
      "Mussarela - 60 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (380 g)</h3>
        <p class="footer-note">2 potes · <a href="receitas.html#panela">Receita</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: recheados (380 g) + almôndegas (570 g) + porco (380 g)</h3>
        <p class="footer-note">Abóbora · chuchu · <a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#almondegas">Almôndegas</a> · <a href="receitas.html#porco">Porco</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (380 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a></p>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Seg jantar","Almôndegas (acém) + brócolis","nada"),
      @("Ter almoço","Chuchu recheado","2 cs arroz"),
      @("Ter jantar","Muffin de ovo + couve","nada"),
      @("Qua almoço","Almôndegas (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Porco shoyu + vagem","nada"),
      @("Qui almoço","Porco refogado + couve","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Frango + vagem","2 cs arroz"),
      @("Sex jantar","Carne de panela + vagem","nada"),
      @("Sáb almoço","Muffin de ovo + brócolis","2 cs arroz"),
      @("Sáb jantar","Almôndegas (acém) + couve","nada"),
      @("Dom almoço","Almôndegas (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Muffin de ovo + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Abóbora recheada" "Almôndegas (acém) + brócolis")},
      @{label="Terça"; body=(MealBody "Chuchu recheado" "Muffin de ovo + couve")},
      @{label="Quarta"; body=(MealBody "Almôndegas (acém) + brócolis" "Porco shoyu + vagem")},
      @{label="Quinta"; body=(MealBody "Porco refogado + couve" "Carne de panela + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + vagem" "Carne de panela + vagem")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + brócolis" "Almôndegas (acém) + couve")},
      @{label="Domingo"; body=(MealBody "Almôndegas (acém) + brócolis" "Muffin de ovo + tomate")}
    )
  },

  @{
    n=7; title="Fecha ciclo econômico"; sub="14 potes · panela · recheados · porco · almôndegas · frango/muffin"
    chips=@("14 potes","Carne panela","Acém","Porco"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s7`">Receitas semana 7</a>."
    shop=@(
      "Acém/músculo (panela) - 380 g",
      "Patinho - 570 g (3 recheados)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Acém moído - 380 g (almôndegas × 2)",
      "Peito de frango - 380 g",
      $ovosShop,
      "Quiabo - 300 g",
      "Pimentão - 1",
      "Berinjela - 1",
      "Tomate firme - 3",
      "Abobrinha - 2",
      "Brócolis - 600 g",
      "Vagem - 500 g",
      "Mussarela - 90 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (380 g) + quiabo</h3>
        <p class="footer-note">2 potes · <a href="receitas.html#panela">Carne de panela</a> · <a href="receitas.html#quiabo">Quiabo</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: recheados (570 g) + porco (380 g) + almôndegas (380 g)</h3>
        <p class="footer-note">Pimentão · berinjela · tomate · <a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#almondegas">Almôndegas</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (380 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a></p>
"@
    pots=@(
      @("Seg almoço","Carne de panela + quiabo","2 cs arroz"),
      @("Seg jantar","Almôndegas (acém) + brócolis","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Muffin de ovo + abobrinha","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Porco shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + vagem","2 cs arroz"),
      @("Sex jantar","Porco + abobrinha","nada"),
      @("Sáb almoço","Muffin de ovo + brócolis","2 cs arroz"),
      @("Sáb jantar","Almôndegas (acém) + vagem","nada"),
      @("Dom almoço","Carne de panela + quiabo","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Muffin de ovo + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Carne de panela + quiabo" "Almôndegas (acém) + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Muffin de ovo + abobrinha")},
      @{label="Quarta"; body=(MealBody "Berinjela recheada" "Porco shoyu + vagem")},
      @{label="Quinta"; body=(MealBody "Tomate recheado" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + vagem" "Porco + abobrinha")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + brócolis" "Almôndegas (acém) + vagem")},
      @{label="Domingo"; body=(MealBody "Carne de panela + quiabo" "Muffin de ovo + tomate")}
    )
  },

  @{
    n=8; title="Panela · porco · frango · ovo"; sub="14 potes · panela · recheados · porco · frango/muffin · fecha ciclo"
    chips=@("14 potes","Jantar 20:00","Fecha ciclo"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s8`">Receitas semana 8</a>."
    shop=@(
      "Acém/músculo (panela) - 570 g",
      "Patinho - 380 g (2 recheados)",
      "Acém/músculo moído - 200 g (clássica)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 570 g",
      $ovosShop,
      "Quiabo - 300 g",
      "Pimentão - 1",
      "Abobrinha - 2",
      "Brócolis - 600 g",
      "Vagem - 400 g",
      "Tomate - 3",
      "Couve - 1 maço",
      "Mussarela - 60 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (570 g)</h3>
        <p class="footer-note">3 potes · <a href="receitas.html#panela">Receita</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: recheados (380 g) + porco (380 g) + clássica (200 g)</h3>
        <p class="footer-note"><a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#classica">Clássica</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango (570 g) + muffins (3 potes)</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#muffins">Muffins</a></p>
"@
    pots=@(
      @("Seg almoço","Carne de panela + quiabo","2 cs arroz"),
      @("Seg jantar","Frango + brócolis","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Carne de panela + vagem","nada"),
      @("Qua almoço","Porco refogado + vagem","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Muffin de ovo + tomate","nada"),
      @("Qui almoço","Abobrinha recheada","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco + abobrinha","nada"),
      @("Sáb almoço","Muffin de ovo + abobrinha","2 cs arroz"),
      @("Sáb jantar","Clássica (acém) + couve","nada"),
      @("Dom almoço","Carne de panela + quiabo","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Muffin de ovo + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Carne de panela + quiabo" "Frango + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Carne de panela + vagem")},
      @{label="Quarta"; body=(MealBody "Porco refogado + vagem" "Muffin de ovo + tomate")},
      @{label="Quinta"; body=(MealBody "Abobrinha recheada" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco + abobrinha")},
      @{label="Sábado"; body=(MealBody "Muffin de ovo + abobrinha" "Clássica + couve")},
      @{label="Domingo"; body=(MealBody "Carne de panela + quiabo" "Muffin de ovo + tomate")}
    )
  }
)

foreach ($w in $weeks) { Write-Week $w }
Write-Host "DONE $total weeks"
