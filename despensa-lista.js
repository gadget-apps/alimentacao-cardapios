/**
 * Checklist da despensa (1ª compra) — home e Preços.
 * Pantry first-buy checklist — home and Prices pages.
 */
(function () {
  function renderInto(boxId, totalId) {
    var P = window.AlimentacaoPrecos;
    var box = document.getElementById(boxId);
    if (!P || !P.FIRST_BUY || !box) return null;

    var total = 0;
    var lis = P.FIRST_BUY.map(function (it, i) {
      total += it.estimate || 0;
      var label =
        it.name +
        " — " +
        it.qty +
        (it.note ? " · " + it.note : "");
      return (
        '<li><label class="shop-item"><input type="checkbox" data-id="d' +
        i +
        '" /><span data-item-name="1">' +
        label +
        '</span><span class="shop-price shop-price-ok">' +
        P.formatBRL(it.estimate) +
        "</span></label></li>"
      );
    }).join("");

    box.innerHTML =
      '<div id="lista-compras" data-semana="despensa" data-despensa="1">' +
      '<ul class="shop-check">' +
      lis +
      "</ul>" +
      '<p class="shop-total" data-shop-total="1"><strong>Total estimado:</strong> ' +
      P.formatBRL(total) +
      ' <span class="footer-note">(1ª compra · marque o que já comprou)</span></p>' +
      '<div class="shop-actions">' +
      '<button type="button" class="btn-keep" data-keep-download data-semana="despensa">Baixar lista (Google Keep)</button>' +
      '<button type="button" class="btn-keep btn-keep-secondary" data-keep-reset data-semana="despensa">Limpar marcas</button>' +
      "</div></div>";

    var totEl = document.getElementById(totalId);
    if (totEl) totEl.hidden = true;
    return box.querySelector("#lista-compras");
  }

  function boot() {
    renderInto("first-buy-home", "first-buy-home-total");
    renderInto("first-buy-table", "first-buy-total");
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", boot);
  } else {
    boot();
  }
})();
