/**
 * Checklist da despensa — monta a lista a partir do catálogo de preços.
 * Pantry checklist — builds the list from the price catalog.
 */
(function () {
  function renderInto(boxId) {
    var P = window.AlimentacaoPrecos;
    var box = document.getElementById(boxId);
    if (!P || !P.FIRST_BUY || !box) return null;

    // Só nome/qtde; preço e lápis vêm do keep-lista + catálogo.
    // Name/qty only; price and pencil come from keep-lista + catalog.
    var lis = P.FIRST_BUY.map(function (it, i) {
      var label = it.name + " — " + it.qty;
      return (
        '<li><label class="shop-item"><input type="checkbox" data-id="d' +
        i +
        '" /><span data-item-name="1">' +
        label +
        "</span></label></li>"
      );
    }).join("");

    box.innerHTML =
      '<div id="lista-compras" data-semana="despensa">' +
      '<ul class="shop-check">' +
      lis +
      "</ul></div>";

    return box.querySelector("#lista-compras");
  }

  function boot() {
    renderInto("lista-despensa");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
