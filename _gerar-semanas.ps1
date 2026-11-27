# 8 semanas · recomp Márcio (86 kg) · rotina 8h–23h
# - Café 8:00 · Almoço 12:30 · Jantar 20:00 (todos os dias) · Dormir 23:00
# - Pote: ~180–200 g proteína crua; almoço 400–550 g; jantar 350–450 g sem arroz
# - Economia: frango 1 almoço/sem · omelete no dia · porco em cubos · acém vs patinho
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
  <link rel="stylesheet" href="estilo.css?v=46" />
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
        <li><strong>08:00</strong> Café</li>
        <li><strong>12:30</strong> Almoço — pote 400–550 g (~180–200 g proteína + legume + 2 cs arroz)</li>
        <li><strong>20:00</strong> Jantar — pote 350–450 g (~180–200 g proteína + legume, <em>sem</em> arroz/feijão)</li>
        <li><strong>23:00</strong> Dormir</li>
      </ul>
    </section>

    <section class="card">
      <div class="passo"><div class="passo-num">1</div><div class="passo-body">
        <h3>Compras da semana</h3>
      </div></div>
      <div id="lista-compras" data-semana="$n">
        <ul class="shop-check">
$(Shop $w.shop)
        </ul>
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
        <p class="footer-note">Cada linha = 1 refeição. Potes = lote do prep. <strong>Omelete reforçado</strong> = feito no dia (principal ou coadjuvante). Arroz/feijão só no almoço, onde indicado.</p>
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
        <h3>Durante a semana</h3>
      </div></div>
$daysHtml
    </section>
  </main>
  <script src="precos-store.js?v=14"></script>
  <script src="keep-lista.js?v=13"></script>
  <script src="tema.js?v=1"></script>
  <script src="nav-drawer.js?v=11"></script>
</body>
</html>
"@
  [IO.File]::WriteAllText((Join-Path $base "semana-$n.html"), $html, [Text.UTF8Encoding]::new($false))
  Write-Host "OK semana-$n"
}

# Após gerar as semanas, rode: python _separar-prep.py
# After generating weeks, run: python _separar-prep.py
$arroz = @"
        <h3>A) Cozinhar: arroz (lote)</h3>
        <p class="footer-note">Passo a passo: <a href="receitas.html#arroz">Arroz</a></p>
"@
$feijao = @"
        <h3>B) Cozinhar: feijão (lote)</h3>
        <p class="footer-note">Passo a passo: <a href="receitas.html#feijao">Feijão</a></p>
"@

# Ovos: omeletes no dia + café (2/dia × 7).
# Eggs: omelettes on the day + breakfast (2/day × 7).
$ovosShop = "Ovos - 2 dúzias (omeletes no dia + 2/dia no café)"

$weeks = @(
  @{
    n=1; title="Carne de panela · porco · frango · ovo"; sub="14 potes · carne de panela · recheados · porco · frango/omelete"
    chips=@("14 potes","Jantar 20:00","Frango almoço","Omelete no dia"); prepTime="2h10"
    potNote="Receitas: <a href=`"receitas.html#s1`">semana 1</a>."
    shop=@(
      "Acém/músculo (panela) - 570 g",
      "Carne de segunda (moída) - 580 g (recheados + clássica)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 570 g",
      $ovosShop,
      "Pimentão - 1",
      "Abobrinha - 2",
      "Brócolis - 600 g",
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
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Carne de panela + brócolis","2 cs arroz"),
      @("Seg jantar","Frango + brócolis","nada"),
      @("Ter almoço","Pimentão recheado ","2 cs arroz"),
      @("Ter jantar","Carne de panela + brócolis","nada"),
      @("Qua almoço","Porco em cubos + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete reforçado + tomate/pepino","nada"),
      @("Qui almoço","Abobrinha recheada ","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco em cubos + abobrinha","nada"),
      @("Sáb almoço","Omelete reforçado + abobrinha","2 cs arroz"),
      @("Sáb jantar","Clássica + couve","nada"),
      @("Dom almoço","Carne de panela + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Omelete reforçado + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Carne de panela + brócolis" "Frango + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Carne de panela + brócolis")},
      @{label="Quarta"; body=(MealBody "Porco em cubos + brócolis" "Omelete reforçado + tomate/pepino")},
      @{label="Quinta"; body=(MealBody "Abobrinha recheada" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco em cubos + abobrinha")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + abobrinha" "Clássica + couve")},
      @{label="Domingo"; body=(MealBody "Carne de panela + brócolis" "Omelete reforçado + tomate")}
    )
  },

  @{
    n=2; title="Recheados · porco · frango · ovo"; sub="14 potes · recheados · almôndegas · porco shoyu · frango/omelete"
    chips=@("14 potes","Jantar 20:00","Acém","Porco shoyu"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s2`">Receitas semana 2</a>."
    shop=@(
      "Carne de segunda (moída) - 1140 g (recheados + almôndegas)",
      "Acém/músculo (panela) - 200 g",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Berinjela - 1",
      "Tomate firme - 3",
      "Chuchu - 1",
      "Brócolis - 600 g",
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
        <h3>B) Cozinhar: carne de panela (200 g) + 3 recheados (570 g carne de segunda)</h3>
        <p class="footer-note">Berinjela · tomate · chuchu · <a href="receitas.html#panela">Carne de panela</a> · <a href="receitas.html#recheados">Recheados</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: almôndegas (570 g acém) + porco shoyu (380 g)</h3>
        <p class="footer-note"><a href="receitas.html#almondegas">Almôndegas</a> · <a href="receitas.html#porco">Porco</a> / <a href="receitas.html#shoyu">Shoyu</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Berinjela recheada","2 cs arroz"),
      @("Seg jantar","Almôndegas + brócolis","nada"),
      @("Ter almoço","Tomate recheado","2 cs arroz"),
      @("Ter jantar","Omelete reforçado + abobrinha","nada"),
      @("Qua almoço","Chuchu recheado","2 cs arroz"),
      @("Qua jantar","Almôndegas + couve","nada"),
      @("Qui almoço","Porco shoyu + brócolis","2 cs arroz"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco shoyu + abobrinha","nada"),
      @("Sáb almoço","Omelete reforçado + brócolis","2 cs arroz"),
      @("Sáb jantar","Almôndegas + brócolis","nada"),
      @("Dom almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Omelete reforçado + couve","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Berinjela recheada" "Almôndegas + brócolis")},
      @{label="Terça"; body=(MealBody "Tomate recheado" "Omelete reforçado + abobrinha")},
      @{label="Quarta"; body=(MealBody "Chuchu recheado" "Almôndegas + couve")},
      @{label="Quinta"; body=(MealBody "Porco shoyu + brócolis" "Carne de panela + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco shoyu + abobrinha")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + brócolis" "Almôndegas + brócolis")},
      @{label="Domingo"; body=(MealBody "Almôndegas + brócolis" "Omelete reforçado + couve")}
    )
  },

  @{
    n=3; title="Carne de panela · porco · frango · ovo"; sub="14 potes · carne de panela · recheados · porco · clássica · frango/omelete"
    chips=@("14 potes","Jantar 20:00","Carne de panela","Porco"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s3`">Receitas semana 3</a>."
    shop=@(
      "Acém/músculo (panela) - 570 g",
      "Carne de segunda (moída) - 760 g (recheados + clássica)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Abóbora - 1 fatia",
      "Pimentão - 1",
      "Berinjela - 1",
      "Brócolis - 500 g",
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
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Seg jantar","Carne de panela + brócolis","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Clássica + couve","nada"),
      @("Qua almoço","Porco + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete reforçado + tomate","nada"),
      @("Qui almoço","Berinjela ao molho (porco)","2 cs arroz"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco + brócolis","nada"),
      @("Sáb almoço","Omelete reforçado + couve","2 cs arroz"),
      @("Sáb jantar","Clássica + brócolis","nada"),
      @("Dom almoço","Carne de panela + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Omelete reforçado + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Abóbora recheada" "Carne de panela + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Clássica + couve")},
      @{label="Quarta"; body=(MealBody "Porco + brócolis" "Omelete reforçado + tomate")},
      @{label="Quinta"; body=(MealBody "Berinjela ao molho" "Carne de panela + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco + brócolis")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + couve" "Clássica + brócolis")},
      @{label="Domingo"; body=(MealBody "Carne de panela + brócolis" "Omelete reforçado + tomate")}
    )
  },

  @{
    n=4; title="Acém · porco · frango · omelete"; sub="14 potes · acém · porco · frango/omelete"
    chips=@("14 potes","Acém","Porco","Omelete no dia"); prepTime="2h00"
    potNote="<a href=`"receitas.html#s4`">Receitas semana 4</a>."
    shop=@(
      "Carne de segunda (moída) - 950 g (clássica + almôndegas + refogados)",
      "Pernil ou lombo (porco) em cubos - 760 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Pimentão - 2",
      "Abobrinha - 2",
      "Chuchu - 1",
      "Brócolis - 600 g",
      "Couve - 1 maço",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de segunda (950 g)</h3>
        <p class="footer-note">5 potes · clássica · almôndegas · refogado · <a href="receitas.html#classica">Clássica</a> · <a href="receitas.html#almondegas">Almôndegas</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: porco em cubos (760 g)</h3>
        <p class="footer-note">4 potes · shoyu · pimentão · chuchu · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#shoyu">Shoyu</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Seg jantar","Porco shoyu + brócolis","nada"),
      @("Ter almoço","Porco shoyu + brócolis","2 cs arroz"),
      @("Ter jantar","Omelete reforçado + couve","nada"),
      @("Qua almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Porco + abobrinha","nada"),
      @("Qui almoço","Porco + pimentão","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Clássica + couve","nada"),
      @("Sáb almoço","Omelete reforçado + chuchu","2 cs arroz"),
      @("Sáb jantar","Almôndegas + brócolis","nada"),
      @("Dom almoço","Almôndegas + couve","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Omelete reforçado + abobrinha","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Clássica + brócolis" "Porco shoyu + brócolis")},
      @{label="Terça"; body=(MealBody "Porco shoyu + brócolis" "Omelete reforçado + couve")},
      @{label="Quarta"; body=(MealBody "Almôndegas + brócolis" "Porco + abobrinha")},
      @{label="Quinta"; body=(MealBody "Porco + pimentão" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Clássica + couve")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + chuchu" "Almôndegas + brócolis")},
      @{label="Domingo"; body=(MealBody "Almôndegas + couve" "Omelete reforçado + abobrinha")}
    )
  },

  @{
    n=5; title="Recheados · porco · frango · ovo"; sub="14 potes · 4 recheados · carne de panela · porco · frango/omelete"
    chips=@("14 potes","4 recheados","Jantar 20:00"); prepTime="2h15"
    potNote="<a href=`"receitas.html#s5`">Receitas semana 5</a>."
    shop=@(
      "Acém/músculo (panela) - 380 g",
      "Carne de segunda (moída) - 960 g (recheados + clássica)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Abobrinha - 2",
      "Pimentão - 1",
      "Berinjela - 1",
      "Tomate firme - 3",
      "Brócolis - 500 g",
      "Pepino - 1",
      "Mussarela - 120 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (380 g) + brócolis</h3>
        <p class="footer-note">2 potes · <a href="receitas.html#panela">Carne de panela</a> · <a href="receitas.html#brocolis">Brócolis</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: 4 recheados (760 g) + porco (380 g) + clássica (200 g)</h3>
        <p class="footer-note"><a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#classica">Clássica</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Abobrinha recheada","2 cs arroz"),
      @("Seg jantar","Carne de panela + brócolis","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete reforçado + pepino","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Porco shoyu + brócolis","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Clássica + brócolis","nada"),
      @("Sáb almoço","Omelete reforçado + abobrinha","2 cs arroz"),
      @("Sáb jantar","Porco + brócolis","nada"),
      @("Dom almoço","Carne de panela + brócolis","2 cs arroz"),
      @("Dom jantar","Omelete reforçado + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Abobrinha recheada" "Carne de panela + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Omelete reforçado + pepino")},
      @{label="Quarta"; body=(MealBody "Berinjela recheada" "Porco shoyu + brócolis")},
      @{label="Quinta"; body=(MealBody "Tomate recheado" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Clássica + brócolis")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + abobrinha" "Porco + brócolis")},
      @{label="Domingo"; body=(MealBody "Carne de panela + brócolis" "Omelete reforçado + tomate")}
    )
  },

  @{
    n=6; title="Abóbora · porco · frango · ovo"; sub="14 potes · abóbora/chuchu · almôndegas · porco · frango/omelete"
    chips=@("14 potes","Abóbora","Acém","Porco"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s6`">Receitas semana 6</a>."
    shop=@(
      "Acém/músculo (panela) - 380 g",
      "Carne de segunda (moída) - 950 g (recheados + almôndegas)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Abóbora - 1 fatia",
      "Chuchu - 1",
      "Pimentão - 1",
      "Brócolis - 600 g",
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
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Seg jantar","Almôndegas + brócolis","nada"),
      @("Ter almoço","Chuchu recheado","2 cs arroz"),
      @("Ter jantar","Omelete reforçado + couve","nada"),
      @("Qua almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Porco shoyu + brócolis","nada"),
      @("Qui almoço","Porco refogado + couve","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Carne de panela + brócolis","nada"),
      @("Sáb almoço","Omelete reforçado + brócolis","2 cs arroz"),
      @("Sáb jantar","Almôndegas + couve","nada"),
      @("Dom almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Omelete reforçado + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Abóbora recheada" "Almôndegas + brócolis")},
      @{label="Terça"; body=(MealBody "Chuchu recheado" "Omelete reforçado + couve")},
      @{label="Quarta"; body=(MealBody "Almôndegas + brócolis" "Porco shoyu + brócolis")},
      @{label="Quinta"; body=(MealBody "Porco refogado + couve" "Carne de panela + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Carne de panela + brócolis")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + brócolis" "Almôndegas + couve")},
      @{label="Domingo"; body=(MealBody "Almôndegas + brócolis" "Omelete reforçado + tomate")}
    )
  },

  @{
    n=7; title="Carne de panela · recheados · porco · omelete"; sub="14 potes · carne de panela · recheados · porco · almôndegas · frango/omelete"
    chips=@("14 potes","Carne de panela","Acém","Porco"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s7`">Receitas semana 7</a>."
    shop=@(
      "Acém/músculo (panela) - 380 g",
      "Carne de segunda (moída) - 950 g (recheados + almôndegas)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 380 g",
      $ovosShop,
      "Pimentão - 1",
      "Berinjela - 1",
      "Tomate firme - 3",
      "Abobrinha - 2",
      "Brócolis - 600 g",
      "Mussarela - 90 g",
      "Molho de tomate - 1 lata",
      "Cebola - 2",
      "Limão - 2 un",
      "Cheiro-verde - 1 maço"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Cozinhar: carne de panela (380 g) + brócolis</h3>
        <p class="footer-note">2 potes · <a href="receitas.html#panela">Carne de panela</a> · <a href="receitas.html#brocolis">Brócolis</a></p>
"@
    prepC=@"
        <h3>C) Cozinhar: recheados (570 g) + porco (380 g) + almôndegas (380 g)</h3>
        <p class="footer-note">Pimentão · berinjela · tomate · <a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco</a> · <a href="receitas.html#almondegas">Almôndegas</a></p>
"@
    prepD=@"
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Carne de panela + brócolis","2 cs arroz"),
      @("Seg jantar","Almôndegas + brócolis","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete reforçado + abobrinha","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Porco shoyu + brócolis","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco + abobrinha","nada"),
      @("Sáb almoço","Omelete reforçado + brócolis","2 cs arroz"),
      @("Sáb jantar","Almôndegas + brócolis","nada"),
      @("Dom almoço","Carne de panela + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Omelete reforçado + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Carne de panela + brócolis" "Almôndegas + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Omelete reforçado + abobrinha")},
      @{label="Quarta"; body=(MealBody "Berinjela recheada" "Porco shoyu + brócolis")},
      @{label="Quinta"; body=(MealBody "Tomate recheado" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco + abobrinha")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + brócolis" "Almôndegas + brócolis")},
      @{label="Domingo"; body=(MealBody "Carne de panela + brócolis" "Omelete reforçado + tomate")}
    )
  },

  @{
    n=8; title="Carne de panela · porco · frango · ovo"; sub="14 potes · carne de panela · recheados · porco · frango/omelete"
    chips=@("14 potes","Jantar 20:00","frango/omelete"); prepTime="2h10"
    potNote="<a href=`"receitas.html#s8`">Receitas semana 8</a>."
    shop=@(
      "Acém/músculo (panela) - 570 g",
      "Carne de segunda (moída) - 580 g (recheados + clássica)",
      "Pernil ou lombo (porco) em cubos - 380 g",
      "Peito de frango - 570 g",
      $ovosShop,
      "Pimentão - 1",
      "Abobrinha - 2",
      "Brócolis - 600 g",
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
        <h3>D) Cozinhar: frango</h3>
        <p class="footer-note"><a href="receitas.html#frango">Frango</a> · <a href="receitas.html#omelete">Omelete reforçado</a> é feito <strong>no dia</strong> (não entra no lote do prep)</p>
"@
    pots=@(
      @("Seg almoço","Carne de panela + brócolis","2 cs arroz"),
      @("Seg jantar","Frango + brócolis","nada"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Carne de panela + brócolis","nada"),
      @("Qua almoço","Porco refogado + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete reforçado + tomate","nada"),
      @("Qui almoço","Abobrinha recheada","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sex jantar","Porco + abobrinha","nada"),
      @("Sáb almoço","Omelete reforçado + abobrinha","2 cs arroz"),
      @("Sáb jantar","Clássica + couve","nada"),
      @("Dom almoço","Carne de panela + brócolis","2 cs arroz + 2 cs feijão"),
      @("Dom jantar","Omelete reforçado + tomate","nada")
    )
    days=@(
      @{label="Segunda"; body=(MealBody "Carne de panela + brócolis" "Frango + brócolis")},
      @{label="Terça"; body=(MealBody "Pimentão recheado" "Carne de panela + brócolis")},
      @{label="Quarta"; body=(MealBody "Porco refogado + brócolis" "Omelete reforçado + tomate")},
      @{label="Quinta"; body=(MealBody "Abobrinha recheada" "Frango + brócolis")},
      @{label="Sexta"; body=(MealBody "Frango + brócolis" "Porco + abobrinha")},
      @{label="Sábado"; body=(MealBody "Omelete reforçado + abobrinha" "Clássica + couve")},
      @{label="Domingo"; body=(MealBody "Carne de panela + brócolis" "Omelete reforçado + tomate")}
    )
  }
)

foreach ($w in $weeks) { Write-Week $w }
Write-Host "DONE $total weeks"
