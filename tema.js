/**
 * Aplica cor pastel da semana e dos pratos.
 * Applies pastel week theme and dish colors.
 */
(function () {
  function weekFromPage() {
    var lista = document.getElementById("lista-compras");
    if (lista && lista.getAttribute("data-semana")) {
      return lista.getAttribute("data-semana");
    }
    var m = (location.pathname || "").match(/semana-(\d+)/i);
    return m ? m[1] : null;
  }

  function dishClass(text) {
    var t = String(text || "").toLowerCase();
    if (/omelete|muffin/.test(t)) return "prato-omelete";
    if (/porco|pernil|lombo/.test(t)) return "prato-porco";
    if (/frango/.test(t)) return "prato-frango";
    if (/alm[oô]ndega/.test(t)) return "prato-almondegas";
    if (/rechead|piment[aã]o|abobrinha|berinjela|tomate reche|chuchu|ab[oó]bora/.test(t) && !/panela/.test(t)) {
      return "prato-recheado";
    }
    if (/shoyu/.test(t)) return "prato-shoyu";
    if (/quiabo/.test(t) && /panela/.test(t)) return "prato-panela";
    if (/quiabo/.test(t)) return "prato-quiabo";
    if (/panela/.test(t)) return "prato-panela";
    if (/cl[aá]ssica/.test(t)) return "prato-classica";
    if (/carne|mo[ií]da|patinho|segunda/.test(t)) return "prato-moida";
    return "";
  }

  function apply() {
    var w = weekFromPage();
    if (w) document.body.classList.add("semana-" + w);

    var meals = document.querySelectorAll("article.meal");
    for (var i = 0; i < meals.length; i++) {
      var strongs = meals[i].querySelectorAll("strong");
      var blob = "";
      for (var s = 0; s < strongs.length; s++) blob += " " + (strongs[s].textContent || "");
      var cls = dishClass(blob);
      if (cls) meals[i].classList.add(cls);
    }

    var chips = document.querySelectorAll(".chip");
    for (var c = 0; c < chips.length; c++) {
      var dc = dishClass(chips[c].textContent || "");
      if (dc) chips[c].classList.add(dc);
    }
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", apply);
  } else {
    apply();
  }
})();
