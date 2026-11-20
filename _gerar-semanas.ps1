# 8 semanas · economia de proteína (aprovado):
# - porco 1–2 marmitas/semana (cubos refogados/shoyu — sem moída)
# - frango 1 almoço/semana
# - ovo 1 almoço/semana
# - clássica/almôndegas = acém/músculo moído; patinho só recheado
# - panela = acém/músculo (pedaço)
$ErrorActionPreference = "Stop"
$base = "c:\GadgetApps\alimentacao-cardapios"
$total = 8

function Get-NavHtml([int]$active) {
  # Drawer assume o menu; nav antiga fica vazia/escondida pelo CSS.
  # Drawer owns navigation; legacy nav hidden by CSS.
  return '    <nav class="nav" hidden></nav>'
}

function Shop($items) {
  $i = 0
  ($items | ForEach-Object {
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
  <title>Semana $n — $($w.title)</title>
  <link rel="stylesheet" href="estilo.css?v=13" />
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
      <div class="passo"><div class="passo-num">1</div><div class="passo-body">
        <h3>Compras da semana</h3>
        <p>Proteína econômica: porco 1–2× · frango 1 almoço · ovo 1 almoço · acém moído na clássica/almôndegas · patinho só no recheado.</p>
      </div></div>
      <div id="lista-compras" data-semana="$n">
        <ul class="shop-check">
$(Shop $w.shop)
        </ul>
        <div class="shop-actions">
          <button type="button" class="btn-keep" data-keep-download data-semana="$n">Baixar lista (Google Keep)</button>
          <button type="button" class="btn-keep btn-keep-secondary" data-keep-reset data-semana="$n">Limpar marcas</button>
        </div>
      </div>
    </section>

    <section class="card">
      <div class="passo"><div class="passo-num">2</div><div class="passo-body">
        <h3>Domingo — cozinhe tudo (~$($w.prepTime))</h3>
        <p>Monte cada pote 300–500 g no total (proteína ~150 g + guarnição + 2 cs arroz quando couber).</p>
      </div></div>
      <article class="recipe">$($w.prepA)</article>
      <article class="recipe">$($w.prepB)</article>
      <article class="recipe">$($w.prepC)</article>
      <article class="recipe">$($w.prepD)</article>
      <article class="recipe">
        <h3>Monte os potes</h3>
        <table class="table">
          <thead><tr><th>Tampa</th><th>Prato</th><th>Arroz / feijão</th></tr></thead>
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
        <p>Almoço: pote 300–500 g. Jantar Ter–Qui: 300–400 g sem arroz/feijão.</p>
      </div></div>
$daysHtml
    </section>
  </main>
  <script src="precos-store.js?v=3"></script>
  <script src="keep-lista.js?v=7"></script>
  <script src="tema.js?v=1"></script>
  <script src="nav-drawer.js?v=1"></script>
</body>
</html>
"@
  [IO.File]::WriteAllText((Join-Path $base "semana-$n.html"), $html, [Text.UTF8Encoding]::new($false))
  Write-Host "OK semana-$n"
}

$arroz = @"
        <h3>A) Arroz + feijão</h3>
        <p class="ing">Arroz: 1⅓ xícara cru · Feijão: 1 xícara cru (só dias sem molho)</p>
        <ol><li>Feijão na pressão · arroz integral. Na marmita: 2 cs.</li></ol>
"@

$weeks = @(
  @{
    n=1; title="Panela · porco · frango · ovo"; sub="Panela + quiabo · recheados (patinho) · porco em cubos refogado · frango e omelete no almoço"
    chips=@("Panela","Porco","Frango almoço","Ovo almoço"); prepTime="1h50"
    potNote="Receitas: <a href=`"receitas.html#s1`">semana 1</a>."
    shop=@(
      "Acém/músculo (panela) — 400 g",
      "Patinho moído — 320 g (só 2 recheados × ~160 g)",
      "Pernil ou lombo (porco) em cubos — 180 g (refogado)",
      "Peito de frango — 380 g (1 almoço + 1 jantar)",
      "Ovos — 8 un (1 almoço omelete 4 + 1 jantar omelete 4)",
      "Quiabo — 200 g",
      "Pimentão — 1 · Abobrinha — 2",
      "Brócolis — 400 g · Vagem — 200 g · Tomate/pepino",
      "Mussarela — 60 g · Tomate p/ molho · Shoyu",
      "Arroz integral — 300 g · Feijão — 250 g",
      "Cebola · alho · temperos · azeite · limão"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Carne de panela (400 g)</h3>
        <ol><li>2 potes de proteína (com quiabo / com brócolis). <a href="receitas.html#panela">Receita</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados (patinho 320 g) + porco em cubos refogado (180 g)</h3>
        <ol><li>Pimentão e abobrinha. Porco em cubos refogado (não moído). <a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#porco">Porco em cubos</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Frango 380 g + ovos</h3>
        <ol><li>Grelhe o frango (almoço + jantar). Omeletes na hora ou no domingo.</li></ol>
"@
    pots=@(
      @("Seg almoço","Panela + quiabo","2 cs arroz"),
      @("Ter almoço","Pimentão recheado (patinho)","2 cs arroz"),
      @("Ter jantar","Frango + brócolis","nada"),
      @("Qua almoço","porco em cubos refogado + vagem","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete + tomate/pepino","nada"),
      @("Qui almoço","Abobrinha recheada (patinho)","2 cs arroz"),
      @("Qui jantar","Panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sáb almoço","Omelete + abobrinha","2 cs — sem feijão"),
      @("Dom almoço","Panela + legume","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Panela + quiabo</strong>`n        <span class=`"dia-qtd`">pote 300–500 g</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango + brócolis</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: porco em cubos refogado + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: abobrinha recheada</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela + brócolis</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + brócolis</strong>`n        <span class=`"dia-qtd`">almoço econômico</span>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + abobrinha</strong>`n        <span class=`"dia-qtd`">almoço econômico</span>"},
      @{label="Domingo — almoço"; body="<strong>Panela + legume</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=2; title="Recheados · porco · frango · ovo"; sub="Recheados (patinho) · porco em cubos shoyu · almôndegas de acém · frango e omelete no almoço"
    chips=@("Recheados","Porco shoyu","Acém almôndegas","Frango/ovo almoço"); prepTime="1h45"
    potNote="<a href=`"receitas.html#s2`">Receitas semana 2</a>."
    shop=@(
      "Patinho moído — 480 g (3 recheados × ~160 g)",
      "Acém/músculo moído — 360 g (almôndegas × 2)",
      "Pernil ou lombo (porco) em cubos — 180 g (shoyu)",
      "Peito de frango — 200 g (1 almoço)",
      "Ovos — 1 dúzia (omelete almoço 4 + jantar 4 + liga almôndegas)",
      "Berinjela — 1 · Tomate firme — 3 · Chuchu — 1",
      "Brócolis — 400 g · Vagem — 400 g · Couve — 1 maço · Abobrinha — 1",
      "Mussarela — 90 g · Molho · Shoyu · Aveia",
      "Arroz — 300 g · Feijão — 300 g · Cebola · alho · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Patinho 480 g → 3 recheados</h3>
        <ol><li>Berinjela, tomate, chuchu. <a href="receitas.html#recheados">Guia</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Acém 360 g → almôndegas · porco 180 g → shoyu</h3>
        <ol><li><a href="receitas.html#almondegas">Almôndegas</a> · <a href="receitas.html#shoyu">Shoyu</a> com porco.</li></ol>
"@
    prepD=@"
        <h3>D) Frango 200 g + ovos</h3>
        <ol><li>Frango = almoço. Omelete almoço e jantar.</li></ol>
"@
    pots=@(
      @("Seg almoço","Berinjela recheada","2 cs arroz"),
      @("Ter almoço","Tomate recheado","2 cs arroz"),
      @("Ter jantar","Omelete + abobrinha","nada"),
      @("Qua almoço","Chuchu recheado","2 cs arroz"),
      @("Qua jantar","Almôndegas (acém) + brócolis","nada"),
      @("Qui almoço","porco em cubos shoyu + vagem","2 cs arroz"),
      @("Qui jantar","Almôndegas + couve","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sáb almoço","Omelete + vagem","2 cs"),
      @("Dom almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Berinjela recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: chuchu recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: almôndegas (acém)</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: porco em cubos shoyu + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: almôndegas + couve</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + vagem</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas + brócolis</strong>`n        <ul><li><a href=`"SEMANA_NEXT`">Próxima semana</a></li></ul>"}
    )
  },

  @{
    n=3; title="Panela · porco · frango · ovo"; sub="Panela · abóbora/pimentão recheados · porco em cubos + quiabo · frango e omelete no almoço"
    chips=@("Panela","Porco","Frango almoço","Ovo almoço"); prepTime="1h50"
    potNote="<a href=`"receitas.html#s3`">Receitas semana 3</a>."
    shop=@(
      "Acém/músculo (panela) — 400 g",
      "Patinho — 320 g (2 recheados)",
      "Pernil ou lombo (porco) em cubos — 360 g (quiabo + shoyu)",
      "Acém moído — 180 g (clássica)",
      "Peito de frango — 200 g",
      "Ovos — 8 un",
      "Abóbora — 1 fatia · Pimentão — 1 · Quiabo — 200 g · Berinjela — 1",
      "Brócolis — 200 g · Vagem — 200 g · Couve — 1 maço",
      "Mussarela — 60 g · Molho · Shoyu",
      "Arroz — 300 g · Feijão — 250 g · Temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 400 g</h3>
        <ol><li><a href="receitas.html#panela">Receita</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados (patinho) + porco (quiabo/shoyu) + clássica (acém)</h3>
        <ol><li>Abóbora e pimentão. Porco com quiabo e shoyu. Clássica de acém.</li></ol>
"@
    prepD=@"
        <h3>D) Frango + ovos</h3>
        <ol><li>1 almoço frango · 1 almoço omelete · jantares.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Panela + vagem","nada"),
      @("Qua almoço","Porco + quiabo","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete + tomate","nada"),
      @("Qui almoço","Berinjela ao molho (porco ou acém)","2 cs arroz"),
      @("Qui jantar","Panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sáb almoço","Omelete + couve","2 cs"),
      @("Dom almoço","Clássica de acém + couve","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abóbora recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela + vagem</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: porco + quiabo</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: berinjela ao molho</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + couve</strong>"},
      @{label="Domingo — almoço"; body="<strong>Clássica de acém + couve</strong>`n        <ul><li><a href=`"SEMANA_NEXT`">Próxima</a></li></ul>"}
    )
  },

  @{
    n=4; title="Moída econômica"; sub="Acém na clássica/almôndegas · porco no shoyu e refogados · frango e omelete no almoço · sem patinho"
    chips=@("Acém","Porco","Frango almoço","Ovo almoço"); prepTime="1h30"
    potNote="Semana sem recheado de patinho. <a href=`"receitas.html#s4`">Receitas</a>."
    shop=@(
      "Acém/músculo moído — 720 g (clássica + almôndegas×2 + 1 refogado)",
      "Pernil ou lombo (porco) em cubos — 540 g (shoyu + pimentão + chuchu)",
      "Peito de frango — 200 g",
      "Ovos — 1 dúzia",
      "Pimentão — 2 · Abobrinha — 1 · Chuchu — 1",
      "Brócolis — 400 g · Vagem — 400 g · Couve — 1 maço",
      "Shoyu · Temperos · Aveia",
      "Arroz — 300 g · Feijão — 350 g"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Acém 720 g</h3>
        <ol><li>Clássica · almôndegas (2) · carne+abobrinha. <a href="receitas.html#porco">Porco em cubos</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Porco 540 g</h3>
        <ol><li>Shoyu · carne+pimentão · carne+chuchu. <a href="receitas.html#shoyu">Shoyu</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Frango + ovos</h3>
        <ol><li>Almoço frango · almoço omelete.</li></ol>
"@
    pots=@(
      @("Seg almoço","Clássica (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Ter almoço","porco em cubos shoyu + vagem","2 cs arroz"),
      @("Ter jantar","Omelete + couve","nada"),
      @("Qua almoço","Almôndegas (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Porco + abobrinha","nada"),
      @("Qui almoço","Porco + pimentão","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Frango + vagem","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sáb almoço","Omelete + chuchu","2 cs"),
      @("Dom almoço","Almôndegas (acém) + couve","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Clássica (acém) + brócolis</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: porco em cubos shoyu</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: almôndegas (acém)</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: porco + abobrinha</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: porco + pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + chuchu</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas (acém) + couve</strong>`n        <ul><li><a href=`"SEMANA_NEXT`">Próxima</a></li></ul>"}
    )
  },

  @{
    n=5; title="Recheados · porco · frango · ovo"; sub="4 recheados (patinho) · panela · porco em cubos shoyu · frango e omelete no almoço"
    chips=@("Recheados","Porco","Frango almoço","Ovo almoço"); prepTime="1h50"
    potNote="<a href=`"receitas.html#s5`">Receitas semana 5</a>."
    shop=@(
      "Acém/músculo (panela) — 200 g",
      "Patinho — 640 g (4 recheados × 160 g)",
      "Pernil ou lombo (porco) em cubos — 180 g (shoyu)",
      "Acém moído — 180 g (clássica)",
      "Peito de frango — 200 g",
      "Ovos — 8 un",
      "Quiabo — 200 g",
      "Abobrinha — 2 · Pimentão — 1 · Berinjela — 1 · Tomate firme — 2",
      "Brócolis — 200 g · Vagem — 400 g · Pepino",
      "Mussarela — 120 g · Molho · Shoyu",
      "Arroz — 300 g · Feijão — 250 g"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 200 g + quiabo</h3>
        <ol><li>1 marmita. <a href="receitas.html#panela">Panela</a>.</li></ol>
"@
    prepC=@"
        <h3>C) 4 recheados (patinho) + porco shoyu + clássica (acém)</h3>
        <ol><li><a href="receitas.html#recheados">Recheados</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Frango + ovos</h3>
        <ol><li>Almoços econômicos.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abobrinha recheada","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete + pepino","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","porco em cubos shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + vagem","2 cs arroz"),
      @("Sáb almoço","Omelete + abobrinha","2 cs"),
      @("Dom almoço","Panela + quiabo","2 cs arroz")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abobrinha recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: berinjela</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: porco em cubos shoyu</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + vagem</strong>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + abobrinha</strong>"},
      @{label="Domingo — almoço"; body="<strong>Panela + quiabo</strong>`n        <ul><li><a href=`"SEMANA_NEXT`">Próxima</a></li></ul>"}
    )
  },

  @{
    n=6; title="Abóbora · porco · frango · ovo"; sub="Abóbora/chuchu recheados · almôndegas de acém · porco em cubos shoyu · frango e omelete no almoço"
    chips=@("Recheados","Acém","Porco","Frango/ovo almoço"); prepTime="1h45"
    potNote="<a href=`"receitas.html#s6`">Receitas semana 6</a>."
    shop=@(
      "Acém/músculo (panela jantar) — 200 g",
      "Patinho — 320 g (2 recheados)",
      "Acém moído — 360 g (almôndegas × 2)",
      "Pernil ou lombo (porco) em cubos — 360 g (shoyu + pimentão)",
      "Peito de frango — 200 g",
      "Ovos — 1 dúzia",
      "Abóbora — 1 fatia · Chuchu — 1 · Pimentão — 1",
      "Brócolis — 400 g · Vagem — 400 g · Couve — 1 maço",
      "Mussarela — 60 g · Molho · Shoyu · Aveia",
      "Arroz — 300 g · Feijão — 300 g"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 200 g (só jantar)</h3>
        <ol><li><a href="receitas.html#panela">Panela</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados + almôndegas (acém) + porco</h3>
        <ol><li>Abóbora e chuchu (patinho). Almôndegas acém. Shoyu e refogado de porco.</li></ol>
"@
    prepD=@"
        <h3>D) Frango + ovos</h3>
        <ol><li>Almoços econômicos.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1–2 cs arroz"),
      @("Ter almoço","Chuchu recheado","2 cs arroz"),
      @("Ter jantar","Omelete + couve","nada"),
      @("Qua almoço","Almôndegas (acém) + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","porco em cubos shoyu + vagem","nada"),
      @("Qui almoço","porco em cubos refogado + couve","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Panela + brócolis","nada"),
      @("Sex almoço","Frango + vagem","2 cs arroz"),
      @("Sáb almoço","Omelete + brócolis","2 cs"),
      @("Dom almoço","Almôndegas (acém) + legume","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abóbora recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: chuchu</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: almôndegas (acém)</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: porco em cubos shoyu</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: porco em cubos refogado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + vagem</strong>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + brócolis</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas (acém)</strong>`n        <ul><li><a href=`"SEMANA_NEXT`">Próxima</a></li></ul>"}
    )
  },

  @{
    n=7; title="Fecha ciclo econômico"; sub="Panela+quiabo · recheados (patinho) · porco em cubos shoyu · almôndegas de acém · frango e omelete no almoço"
    chips=@("Panela","Porco","Acém","Frango/ovo almoço"); prepTime="1h50"
    potNote="<a href=`"receitas.html#s7`">Receitas semana 7</a>."
    shop=@(
      "Acém/músculo (panela) — 200 g",
      "Patinho — 480 g (3 recheados)",
      "Pernil ou lombo (porco) em cubos — 180 g (shoyu)",
      "Acém moído — 360 g (almôndegas + clássica)",
      "Peito de frango — 200 g",
      "Ovos — 8 un",
      "Quiabo — 200 g · Pimentão — 1 · Berinjela — 1 · Tomate firme — 2 · Abobrinha — 1",
      "Brócolis — 400 g · Vagem — 400 g",
      "Mussarela — 90 g · Molho · Shoyu · Aveia",
      "Arroz — 300 g · Feijão — 250 g"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 200 g + quiabo</h3>
        <ol><li>1 almoço. <a href="receitas.html#panela">Panela</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados (patinho) + porco shoyu + acém</h3>
        <ol><li>Pimentão, berinjela, tomate. porco em cubos shoyu. Almôndegas/clássica de acém.</li></ol>
"@
    prepD=@"
        <h3>D) Frango + ovos</h3>
        <ol><li>Almoços econômicos.</li></ol>
"@
    pots=@(
      @("Seg almoço","Panela + quiabo","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete + abobrinha","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","porco em cubos shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Frango + vagem","2 cs arroz"),
      @("Sáb almoço","Omelete + brócolis","2 cs"),
      @("Dom almoço","Almôndegas (acém) + vagem","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Panela + quiabo</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: berinjela</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: porco em cubos shoyu</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + vagem</strong>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + brócolis</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas (acém)</strong>`n        <ul><li><a href=`"SEMANA_NEXT`">Próxima</a></li></ul>"}
    )
  },

  @{
    n=8; title="Panela · porco · frango · ovo"; sub="Panela + quiabo · recheados · porco em cubos refogado · frango e omelete no almoço"
    chips=@("Panela","Porco","Frango almoço","Ovo almoço"); prepTime="1h50"
    potNote="<a href=`"receitas.html#s8`">Receitas semana 8</a>."
    shop=@(
      "Acém/músculo (panela) — 400 g",
      "Patinho — 320 g (2 recheados)",
      "Pernil ou lombo (porco) em cubos — 180 g (refogado)",
      "Peito de frango — 380 g (1 almoço + 1 jantar)",
      "Ovos — 8 un",
      "Quiabo — 200 g · Pimentão — 1 · Abobrinha — 2",
      "Brócolis — 400 g · Vagem — 200 g",
      "Mussarela — 60 g · Molho · Shoyu",
      "Arroz — 300 g · Feijão — 250 g · Temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela 400 g</h3>
        <ol><li><a href="receitas.html#panela">Panela</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados (patinho) + porco em cubos refogado</h3>
        <ol><li><a href="receitas.html#recheados">Recheados</a> · <a href="receitas.html#classica">Clássica</a> com porco.</li></ol>
"@
    prepD=@"
        <h3>D) Frango + ovos</h3>
        <ol><li>Almoços econômicos + jantar frango.</li></ol>
"@
    pots=@(
      @("Seg almoço","Panela + quiabo","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Frango + brócolis","nada"),
      @("Qua almoço","porco em cubos refogado + vagem","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete + tomate","nada"),
      @("Qui almoço","Abobrinha recheada","2 cs arroz"),
      @("Qui jantar","Panela + brócolis","nada"),
      @("Sex almoço","Frango + brócolis","2 cs arroz"),
      @("Sáb almoço","Omelete + abobrinha","2 cs"),
      @("Dom almoço","Panela + quiabo","2 cs arroz")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Panela + quiabo</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: porco em cubos refogado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: abobrinha recheada</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela</strong>"},
      @{label="Sexta — almoço"; body="<strong>Frango + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Omelete + abobrinha</strong>"},
      @{label="Domingo — almoço"; body="<strong>Panela + quiabo</strong>`n        <ul><li>Ciclo: <a href=`"SEMANA_NEXT`">Semana 1</a></li></ul>"}
    )
  }
)

foreach ($w in $weeks) { Write-Week $w }
Write-Host "DONE $total weeks"
