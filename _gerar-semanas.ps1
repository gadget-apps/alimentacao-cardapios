# 7 semanas · cada receita aparece no máximo 1× por semana.
# 7 weeks · each recipe at most once per week.
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
  ($items | ForEach-Object {
    $id = "i$i"; $i++
    "          <li><label class=`"shop-item`"><input type=`"checkbox`" data-id=`"$id`" /><span>$_</span></label></li>"
  }) -join "`n"
}

function Pots-Html($rows) {
  ($rows | ForEach-Object {
    "            <tr>`n              <td>$($_[0])</td>`n              <td>$($_[1])</td>`n              <td>$($_[2])</td>`n            </tr>"
  }) -join "`n"
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
  <link rel="stylesheet" href="estilo.css?v=8" />
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
        <p>Marque conforme for comprando. <em>Nesta semana cada prato aparece só uma vez.</em></p>
      </div></div>
      <div id="lista-compras" data-semana="$n">
        <ul class="shop-check">
$(Shop-Html $w.shop)
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
        <p>Cozinhe nesta ordem e monte os potes (1 pote = 1 prato diferente).</p>
      </div></div>
      <article class="recipe">$($w.prepA)</article>
      <article class="recipe">$($w.prepB)</article>
      <article class="recipe">$($w.prepC)</article>
      <article class="recipe">$($w.prepD)</article>
      <article class="recipe">
        <h3>Monte os potes</h3>
        <table class="table">
          <thead><tr><th>Tampa</th><th>Prato (único na semana)</th><th>Arroz / feijão</th></tr></thead>
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
        <p>Micro-ondas 3–4 min. Peso do pote inteiro: almoço 300–500 g (proteína + guarnições + arroz/feijão) · jantar 300–400 g.</p>
      </div></div>
$days
    </section>
  </main>
  <script src="keep-lista.js?v=6"></script>
</body>
</html>
"@
  [IO.File]::WriteAllText((Join-Path $base "semana-$n.html"), $html, [Text.UTF8Encoding]::new($false))
  Write-Host "OK semana-$n"
}

$arroz = @"
        <h3>A) Arroz + feijão</h3>
        <ol><li>Feijão na pressão · arroz integral. Na marmita: 2 cs (feijão só se o prato <em>não</em> tiver molho).</li></ol>
"@

# Regra: nenhum nome de prato se repete na mesma semana.
# Panela em lote menor (rende 1–2 marmitas distintas por acompanhamento).

$weeks = @(
  @{
    n=1; title="Panela · quiabo · recheados"; sub="Cada prato 1× · carne de panela · quiabo · pimentão · abobrinha · clássica · shoyu"
    chips=@("Sem repetir","Panela","Recheados"); prepTime="1h50"
    potNote="Favoritas = panela/quiabo · Legumes recheados · Carne moída = clássica/shoyu."
    shop=@(
      "Acém/músculo — 700 g (1 marmita panela + 1 jantar)",
      "Patinho moído — 1,2 kg",
      "Peito de frango — 350 g",
      "Ovos — ½ dúzia",
      "Quiabo — 300 g",
      "Pimentão — 1",
      "Abobrinha — 1–2",
      "Brócolis — 400 g",
      "Vagem — 300 g",
      "Mussarela — 120 g · Tomate p/ molho",
      "Molho shoyu pronto",
      "Arroz integral — 500 g · Feijão — 500 g",
      "Cebola · alho · tomate · pepino · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Carne de panela (700 g) — só 2 usos diferentes</h3>
        <ol>
          <li>1 marmita com quiabo (almoço) · 1 jantar com brócolis. <a href="receitas-favoritas.html">Favoritas</a>.</li>
        </ol>
"@
    prepC=@"
        <h3>C) Quiabo + patinho (clássica + shoyu + recheios)</h3>
        <ol>
          <li>Quiabo sem baba (acompanha só a panela de segunda). <a href="receitas-favoritas.html">Receita</a>.</li>
          <li>Patinho: clássica · shoyu+vagem · recheio pimentão · recheio abobrinha. <a href="carne-moida.html">Moída</a>.</li>
        </ol>
"@
    prepD=@"
        <h3>D) Recheados + frango</h3>
        <ol><li>Pimentão e abobrinha: molho + queijo. <a href="legumes-recheados.html">Guia</a>. Frango grelhado.</li></ol>
"@
    pots=@(
      @("Seg almoço","Carne de panela + quiabo","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Frango + brócolis","nada"),
      @("Qua almoço","Abobrinha recheada","2 cs arroz"),
      @("Qua jantar","Omelete + tomate/pepino","nada"),
      @("Qui almoço","Carne shoyu + vagem","2 cs arroz"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Almôndegas + vagem","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Carne + pimentão refogado","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Carne de panela + quiabo</strong>`n        <span class=`"dia-qtd`">marmita 300–500 g (total) · 2 cs arroz</span>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango + brócolis</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: abobrinha recheada</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: carne shoyu + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela + brócolis</strong>"},
      @{label="Sexta — almoço"; body="<strong>Clássica + brócolis</strong>`n        <span class=`"dia-qtd`">arroz + feijão</span>"},
      @{label="Sábado — almoço"; body="<strong>Almôndegas + vagem</strong>"},
      @{label="Domingo — almoço"; body="<strong>Carne + pimentão refogado</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=2; title="Fornada recheados A"; sub="Berinjela · tomate · chuchu recheados · almôndegas · shoyu · clássica — sem repetir"
    chips=@("Berinjela","Tomate","Chuchu","Almôndegas"); prepTime="1h45"
    potNote="Seis legumes recheados no ciclo: esta semana berinjela, tomate e chuchu."
    shop=@(
      "Patinho moído — 1,8 kg",
      "Peito de frango — 350 g",
      "Ovos — 1 dúzia",
      "Berinjela — 1",
      "Tomate firme — 3",
      "Chuchu — 1",
      "Brócolis — 400 g",
      "Vagem — 300 g",
      "Abobrinha — 1 (jantar omelete)",
      "Mussarela — 200 g · Tomate p/ molho",
      "Molho shoyu",
      "Arroz · feijão · cebola · alho · temperos · aveia (almôndegas)"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Patinho (1,8 kg) em 5 destinos</h3>
        <ol><li>Recheio berinjela · tomate · chuchu · almôndegas · clássica · shoyu. Tudo prato diferente. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados A</h3>
        <ol><li>Berinjela, tomate, chuchu — molho + queijo. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Almôndegas + frango</h3>
        <ol><li>Forno 200 °C 20–25 min · frango grelhado.</li></ol>
"@
    pots=@(
      @("Seg almoço","Berinjela recheada","2 cs arroz"),
      @("Ter almoço","Tomate recheado","2 cs arroz"),
      @("Ter jantar","Omelete + abobrinha","nada"),
      @("Qua almoço","Chuchu recheado","2 cs arroz"),
      @("Qua jantar","Almôndegas + brócolis","nada"),
      @("Qui almoço","Carne shoyu + vagem","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Carne + couve no alho","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Almôndegas + vagem (se sobrou unidades; senão clássica com outro legume)","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Berinjela recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete + abobrinha</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: chuchu recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: almôndegas + brócolis</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: shoyu + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango + brócolis</strong>"},
      @{label="Sexta — almoço"; body="<strong>Clássica + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Carne + couve no alho</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas + vagem</strong> <span class=`"dia-qtd`">(só se ainda houver unidades; senão troque por clássica + outro legume — não repita prato já usado)</span>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=3; title="Panela · abóbora · moída"; sub="Panela 1× · abóbora recheada · pimentão · quiabo com moída · berinjela ao molho"
    chips=@("Panela","Abóbora","Quiabo moída"); prepTime="1h50"
    potNote="Panela só no domingo almoço e no jantar de terça (acompanhamentos diferentes)."
    shop=@(
      "Acém/músculo — 700 g",
      "Patinho moído — 1,3 kg",
      "Peito de frango — 350 g",
      "Ovos — ½ dúzia",
      "Abóbora cabocha — 1 fatia grossa",
      "Pimentão — 1",
      "Quiabo — 350 g",
      "Berinjela — 1",
      "Brócolis — 300 g · Vagem — 250 g · Couve — 1 maço",
      "Mussarela — 150 g · Tomate p/ molho · Shoyu",
      "Arroz · feijão · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Carne de panela (700 g)</h3>
        <ol><li>Almoço domingo: panela + couve · Jantar terça: panela + vagem. <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Abóbora + pimentão recheados</h3>
        <ol><li>Pré-asse abóbora; recheie com patinho, molho, queijo. Pimentão idem. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Moída: quiabo · berinjela ao molho · shoyu · frango</h3>
        <ol><li>Quiabo sem baba com moída. Berinjela em cubos no molho. Shoyu + brócolis. Frango. <a href="carne-moida.html">Receitas</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Carne de panela + vagem","nada"),
      @("Qua almoço","Carne moída + quiabo","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Omelete + tomate","nada"),
      @("Qui almoço","Berinjela ao molho","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Carne shoyu + brócolis","2 cs arroz"),
      @("Sáb almoço","Clássica + couve","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Carne de panela + couve","2 cs arroz")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abóbora recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela + vagem</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: moída + quiabo</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: berinjela ao molho</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Shoyu + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Clássica + couve</strong>"},
      @{label="Domingo — almoço"; body="<strong>Panela + couve</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=4; title="Moída completa"; sub="Clássica · shoyu · almôndegas · pimentão refogado · abobrinha · chuchu — 1× cada"
    chips=@("Clássica","Shoyu","Almôndegas","Refogados"); prepTime="1h30"
    potNote="Semana sem panela e sem fornada grande — só variações da carne-moida.html."
    shop=@(
      "Patinho moído — 1,8 kg",
      "Peito de frango — 350 g",
      "Ovos — 1 dúzia",
      "Pimentão — 2",
      "Abobrinha — 1",
      "Chuchu — 1",
      "Brócolis — 400 g · Vagem — 300 g · Couve — 1 maço",
      "Molho shoyu · Tomate · cebola · alho",
      "Arroz · feijão · aveia · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Patinho (1,8 kg) — 6 pratos distintos</h3>
        <ol><li>Clássica · shoyu+vagem · almôndegas · carne+pimentão · carne+abobrinha · carne+chuchu. <a href="carne-moida.html">Receitas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Legumes</h3>
        <ol><li>Brócolis, vagem, couve no alho, chuchu cozido/refogado com a carne.</li></ol>
"@
    prepD=@"
        <h3>D) Frango</h3>
        <ol><li>Grelhado para o jantar de quinta.</li></ol>
"@
    pots=@(
      @("Seg almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Ter almoço","Carne shoyu + vagem","2 cs arroz"),
      @("Ter jantar","Omelete + couve","nada"),
      @("Qua almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Carne + abobrinha refogada","nada"),
      @("Qui almoço","Carne + pimentão refogado","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Frango + vagem","nada"),
      @("Sex almoço","Carne + chuchu","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Carne + couve","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Almôndegas + pimentão (unidades que sobraram / outro legume se acabou)","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Clássica + brócolis</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: shoyu + vagem</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete + couve</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: almôndegas + brócolis</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: carne + abobrinha</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: carne + pimentão</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango + vagem</strong>"},
      @{label="Sexta — almoço"; body="<strong>Carne + chuchu</strong>"},
      @{label="Sábado — almoço"; body="<strong>Carne + couve</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas + legume</strong> <span class=`"dia-qtd`">(não repita clássica/shoyu/pimentão já usados)</span>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=5; title="Recheados B + panela"; sub="Abobrinha · pimentão · berinjela recheados · panela+quiabo 1× · tomate recheado"
    chips=@("Recheados","Panela + quiabo","Tomate"); prepTime="1h50"
    potNote="Fecha pimentão/abobrinha/berinjela de novo no ciclo, sem repetir o mesmo prato na semana."
    shop=@(
      "Acém/músculo — 500 g (só 1 marmita panela+quiabo)",
      "Patinho moído — 1,4 kg",
      "Peito de frango — 350 g",
      "Ovos — ½ dúzia",
      "Quiabo — 250 g",
      "Abobrinha — 2 · Pimentão — 1 · Berinjela — 1 · Tomate firme — 2",
      "Brócolis — 300 g · Vagem — 250 g",
      "Mussarela — 220 g · Molho · Shoyu",
      "Arroz · feijão · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Carne de panela (500 g) + quiabo</h3>
        <ol><li>Uma única marmita: panela + quiabo (sábado). <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Recheados B</h3>
        <ol><li>Abobrinha, pimentão, berinjela, tomate — cada um 1 pote. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Shoyu + clássica + frango</h3>
        <ol><li>Dois pratos de moída distintos + frango. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abobrinha recheada","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete + pepino","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Carne shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Clássica + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Carne de panela + quiabo","2 cs arroz"),
      @("Dom almoço","Carne + vagem (sem shoyu — prato diferente do jantar de quarta)","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abobrinha recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: berinjela recheada</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: shoyu + vagem</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Clássica + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Panela + quiabo</strong>"},
      @{label="Domingo — almoço"; body="<strong>Carne + vagem</strong> <span class=`"dia-qtd`">(sem shoyu — não é o mesmo prato de quarta)</span>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=6; title="Abóbora · chuchu · almôndegas"; sub="Abóbora · chuchu recheados · almôndegas · shoyu · panela+brócolis · clássica"
    chips=@("Abóbora","Chuchu","Almôndegas","Panela"); prepTime="1h45"
    potNote="Panela só no jantar de quinta (com brócolis), sem quiabo nesta semana."
    shop=@(
      "Acém/músculo — 400 g (1 jantar)",
      "Patinho moído — 1,5 kg",
      "Peito de frango — 350 g",
      "Ovos — 1 dúzia",
      "Abóbora — 1 fatia · Chuchu — 1 · Pimentão — 1 (refogado)",
      "Brócolis — 400 g · Vagem — 300 g · Couve — 1 maço",
      "Mussarela — 120 g · Molho · Shoyu",
      "Arroz · feijão · temperos · aveia"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela pequena (400 g)</h3>
        <ol><li>Só o jantar de quinta: panela + brócolis. <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Abóbora + chuchu recheados</h3>
        <ol><li>Molho + queijo. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Almôndegas · shoyu · clássica · carne+pimentão · frango</h3>
        <ol><li>Cinco pratos distintos de moída/frango. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Abóbora recheada","1 cs arroz"),
      @("Ter almoço","Chuchu recheado","2 cs arroz"),
      @("Ter jantar","Omelete + couve","nada"),
      @("Qua almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Qua jantar","Carne shoyu + vagem","nada"),
      @("Qui almoço","Clássica + couve","2 cs arroz + 2 cs feijão"),
      @("Qui jantar","Carne de panela + brócolis","nada"),
      @("Sex almoço","Carne + pimentão refogado","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Frango + vagem (almoço — sem jantar)","2 cs arroz"),
      @("Dom almoço","Almôndegas + legume diferente do de quarta","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Abóbora recheada</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: chuchu recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete + couve</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: almôndegas + brócolis</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: shoyu + vagem</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: clássica + couve</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: panela + brócolis</strong>"},
      @{label="Sexta — almoço"; body="<strong>Carne + pimentão refogado</strong>"},
      @{label="Sábado — almoço"; body="<strong>Frango + vagem</strong>"},
      @{label="Domingo — almoço"; body="<strong>Almôndegas + outro legume</strong>`n        <ul><li>Prep da <a href=`"SEMANA_NEXT`">próxima semana</a></li></ul>"}
    )
  },

  @{
    n=7; title="Fecha o ciclo"; sub="Panela+quiabo · os 3 recheados que faltam no rodízio · shoyu · almôndegas · clássica — 1× cada"
    chips=@("Panela + quiabo","Recheados","Fecha ciclo"); prepTime="1h50"
    potNote="Depois desta semana, volta à Semana 1."
    shop=@(
      "Acém/músculo — 500 g",
      "Patinho moído — 1,4 kg",
      "Peito de frango — 350 g",
      "Ovos — ½ dúzia",
      "Quiabo — 250 g",
      "Pimentão — 1 · Berinjela — 1 · Tomate firme — 2",
      "Brócolis — 300 g · Vagem — 250 g · Abobrinha — 1",
      "Mussarela — 180 g · Molho · Shoyu",
      "Arroz · feijão · temperos"
    )
    prepA=$arroz
    prepB=@"
        <h3>B) Panela (500 g) + quiabo</h3>
        <ol><li>Só segunda: panela + quiabo. <a href="receitas-favoritas.html">Favoritas</a>.</li></ol>
"@
    prepC=@"
        <h3>C) Pimentão · berinjela · tomate recheados</h3>
        <ol><li>Três recheados, três potes. <a href="legumes-recheados.html">Guia</a>.</li></ol>
"@
    prepD=@"
        <h3>D) Shoyu · almôndegas · clássica · frango</h3>
        <ol><li>Sem repetir entre si. <a href="carne-moida.html">Moída</a>.</li></ol>
"@
    pots=@(
      @("Seg almoço","Carne de panela + quiabo","2 cs arroz"),
      @("Ter almoço","Pimentão recheado","2 cs arroz"),
      @("Ter jantar","Omelete + abobrinha","nada"),
      @("Qua almoço","Berinjela recheada","2 cs arroz"),
      @("Qua jantar","Carne shoyu + vagem","nada"),
      @("Qui almoço","Tomate recheado","2 cs arroz"),
      @("Qui jantar","Frango + brócolis","nada"),
      @("Sex almoço","Almôndegas + brócolis","2 cs arroz + 2 cs feijão"),
      @("Sáb almoço","Clássica + vagem","2 cs arroz + 2 cs feijão"),
      @("Dom almoço","Carne + abobrinha refogada","2 cs arroz + 2 cs feijão")
    )
    days=@(
      @{label="Segunda — almoço"; body="<strong>Carne de panela + quiabo</strong>"},
      @{label="Terça — almoço + jantar"; body="<strong>Almoço: pimentão recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: omelete</strong>"},
      @{label="Quarta — almoço + jantar"; body="<strong>Almoço: berinjela recheada</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: shoyu + vagem</strong>"},
      @{label="Quinta — almoço + jantar"; body="<strong>Almoço: tomate recheado</strong><strong style=`"margin-top:0.6rem;display:block`">Jantar: frango</strong>"},
      @{label="Sexta — almoço"; body="<strong>Almôndegas + brócolis</strong>"},
      @{label="Sábado — almoço"; body="<strong>Clássica + vagem</strong>"},
      @{label="Domingo — almoço"; body="<strong>Carne + abobrinha refogada</strong>`n        <ul><li>Ciclo reinicia: <a href=`"SEMANA_NEXT`">Semana 1</a></li></ul>"}
    )
  }
)

foreach ($w in $weeks) { Write-Week $w }

foreach ($n in 8..10) {
  $p = Join-Path $base "semana-$n.html"
  if (Test-Path $p) { Remove-Item $p -Force; Write-Host "REMOVED semana-$n" }
}

# Nav + lista no index e páginas satélite
function Make-NavHtml([string]$activeHref) {
  $items = @(
    @{h='index.html';t='Início'},
    @{h='semana-1.html';t='Semana 1'},
    @{h='semana-2.html';t='Semana 2'},
    @{h='semana-3.html';t='Semana 3'},
    @{h='semana-4.html';t='Semana 4'},
    @{h='semana-5.html';t='Semana 5'},
    @{h='semana-6.html';t='Semana 6'},
    @{h='semana-7.html';t='Semana 7'},
    @{h='receitas-favoritas.html';t='Favoritas'},
    @{h='legumes-recheados.html';t='Recheados'}
  )
  $lines = @('    <nav class="nav">')
  foreach ($i in $items) {
    if ($i.h -eq $activeHref) { $lines += "      <a class=`"active`" href=`"$($i.h)`">$($i.t)</a>" }
    else { $lines += "      <a href=`"$($i.h)`">$($i.t)</a>" }
  }
  $lines += '    </nav>'
  $lines -join "`n"
}

$sat = @{
  'index.html'='index.html'
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
  } elseif ($f -eq 'index.html') {
    $c = $c -replace '(<main class="wrap">)', "`$1`n$nav"
  }
  $c = $c -replace 'estilo\.css(\?v=\d+)?"', 'estilo.css?v=8"'
  [IO.File]::WriteAllText($path, $c)
  Write-Host "nav OK $f"
}

$idxPath = Join-Path $base 'index.html'
$idx = [IO.File]::ReadAllText($idxPath)
$weekList = @'
      <div class="week-list">
        <a href="semana-1.html"><strong>Semana 1</strong>Panela · quiabo · recheados (sem repetir)</a>
        <a href="semana-2.html"><strong>Semana 2</strong>Recheados A · almôndegas · shoyu</a>
        <a href="semana-3.html"><strong>Semana 3</strong>Panela · abóbora · quiabo moída</a>
        <a href="semana-4.html"><strong>Semana 4</strong>Moída completa (variações)</a>
        <a href="semana-5.html"><strong>Semana 5</strong>Recheados B · panela+quiabo</a>
        <a href="semana-6.html"><strong>Semana 6</strong>Abóbora · chuchu · almôndegas</a>
        <a href="semana-7.html"><strong>Semana 7</strong>Fecha o ciclo</a>
      </div>
'@
$idx = [regex]::Replace($idx, '(?s)<div class="week-list">.*?</div>', $weekList.TrimEnd(), 1)
[IO.File]::WriteAllText($idxPath, $idx)
Write-Host "index week-list OK"
Write-Host "DONE"
