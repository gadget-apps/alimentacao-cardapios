/**
 * Checklist de compras + total só dos itens marcados.
 * Shopping checklist + total sums only checked items.
 */
(function () {
  function storageKey(semana) {
    return "alimentacao-compras-semana-" + semana;
  }

  function loadState(semana) {
    try {
      var raw = localStorage.getItem(storageKey(semana));
      return raw ? JSON.parse(raw) : {};
    } catch (e) {
      return {};
    }
  }

  function saveState(semana, state) {
    try {
      localStorage.setItem(storageKey(semana), JSON.stringify(state));
    } catch (e) {}
  }

  function plainText(el) {
    return (el.innerText || el.textContent || "").replace(/\s+/g, " ").trim();
  }

  function downloadTxt(filename, text) {
    var blob = new Blob([text], { type: "text/plain;charset=utf-8" });
    var url = URL.createObjectURL(blob);
    var a = document.createElement("a");
    a.href = url;
    a.download = filename;
    document.body.appendChild(a);
    a.click();
    a.remove();
    setTimeout(function () {
      URL.revokeObjectURL(url);
    }, 500);
  }

  function parsePriceText(s) {
    if (!s) return null;
    var m = String(s).replace(/\s/g, "").match(/R\$\s*([\d.]+),(\d{2})/);
    if (!m) return null;
    var n = parseFloat(m[1].replace(/\./g, "") + "." + m[2]);
    return isFinite(n) ? n : null;
  }

  /**
   * Soma só os checkboxes marcados (o que vai comprar).
   * Sums only checked boxes (what you will buy).
   */
  function updateTotal(root) {
    var P = window.AlimentacaoPrecos;
    if (!P) return;
    var labels = root.querySelectorAll("label.shop-item");
    var total = 0;
    var marked = 0;
    for (var i = 0; i < labels.length; i++) {
      var label = labels[i];
      var inp = label.querySelector('input[type="checkbox"]');
      if (!inp || !inp.checked) continue;
      var raw = label.getAttribute("data-estimate");
      var val = raw != null && raw !== "" ? parseFloat(raw) : null;
      if (val == null || !isFinite(val)) {
        var priceEl = label.querySelector(".shop-price");
        val = parsePriceText(priceEl ? plainText(priceEl) : "");
      }
      if (val != null && isFinite(val) && val > 0) {
        total += val;
        marked++;
      }
    }
    var sum = root.querySelector("[data-shop-total]");
    if (!sum) {
      sum = document.createElement("p");
      sum.className = "shop-total";
      sum.setAttribute("data-shop-total", "1");
      var actions = root.querySelector(".shop-actions");
      if (actions) root.insertBefore(sum, actions);
      else root.appendChild(sum);
    }
    sum.innerHTML =
      "<strong>Total a comprar (marcados):</strong> " +
      P.formatBRL(total) +
      ' <span class="footer-note">(' +
      marked +
      " item" +
      (marked === 1 ? "" : "s") +
      " · marque o que precisa comprar)</span>";
  }

  function paintEstimates(root) {
    var P = window.AlimentacaoPrecos;
    if (!P) return;

    // Despensa: preços já no HTML — só garante data-estimate.
    // Pantry: prices already in HTML — ensure data-estimate.
    if (root.getAttribute("data-despensa") === "1") {
      var dLabels = root.querySelectorAll("label.shop-item");
      for (var d = 0; d < dLabels.length; d++) {
        var dl = dLabels[d];
        if (dl.getAttribute("data-estimate")) continue;
        var pe = dl.querySelector(".shop-price");
        var pv = parsePriceText(pe ? plainText(pe) : "");
        if (pv != null) dl.setAttribute("data-estimate", String(pv));
      }
      updateProgress(root);
      updateTotal(root);
      return;
    }

    var cat = P.loadCatalog();
    var labels = root.querySelectorAll("label.shop-item");
    for (var i = 0; i < labels.length; i++) {
      var label = labels[i];
      var span = label.querySelector("span:not(.shop-price)");
      if (!span) continue;
      var text = plainText(span).replace(/\s*≈.*$/, "").replace(/\s*R\$.*$/, "");
      var nameSpan = label.querySelector("[data-item-name]") || span;
      if (!nameSpan.getAttribute("data-item-name")) {
        nameSpan.setAttribute("data-item-name", "1");
      }
      var est = P.estimateLine(text, cat);
      var priceEl = label.querySelector(".shop-price");
      if (!priceEl) {
        priceEl = document.createElement("span");
        priceEl.className = "shop-price";
        label.appendChild(priceEl);
      }
      label.removeAttribute("data-estimate");
      if (est.pantry) {
        priceEl.textContent = "";
        priceEl.title = "Despensa — fora da estimativa";
        priceEl.className = "shop-price";
      } else if (est.matched && est.estimate != null) {
        priceEl.textContent = P.formatBRL(est.estimate);
        priceEl.title = est.detail || "";
        priceEl.className = "shop-price shop-price-ok";
        label.setAttribute("data-estimate", String(est.estimate));
      } else if (est.matched && est.detail) {
        priceEl.textContent = est.detail;
        priceEl.className = "shop-price shop-price-ref";
      } else {
        priceEl.textContent = "—";
        priceEl.className = "shop-price";
        priceEl.title = "Sem preço no catálogo";
      }
    }
    updateTotal(root);
  }

  function updateProgress(root) {
    // Só itens da lista (não o “selecionar todas”).
    // Only list items (not the “select all” control).
    var boxes = root.querySelectorAll('input[type="checkbox"][data-id]');
    var done = 0;
    for (var i = 0; i < boxes.length; i++) {
      if (boxes[i].checked) done++;
    }
    var el = root.querySelector("[data-shop-progress]");
    if (el) el.textContent = done + " de " + boxes.length + " marcados para comprar";
    syncSelectAll(root, boxes, done);
  }

  /**
   * Destaca o atalho ativo (tudo / nada) conforme a lista.
   * Highlights the active bulk action (all / none) from list state.
   */
  function syncSelectAll(root, boxes, done) {
    var allBtn = root.querySelector("[data-select-all]");
    var noneBtn = root.querySelector("[data-select-none]");
    if (!allBtn || !noneBtn) return;
    var n = boxes.length;
    var allOn = n > 0 && done === n;
    var noneOn = done === 0;
    allBtn.classList.toggle("is-active", allOn);
    noneBtn.classList.toggle("is-active", noneOn);
    allBtn.setAttribute("aria-pressed", allOn ? "true" : "false");
    noneBtn.setAttribute("aria-pressed", noneOn ? "true" : "false");
  }

  /**
   * Marca ou desmarca todos os itens e grava no localStorage.
   * Checks or unchecks every item and persists to localStorage.
   */
  function setAllChecked(root, semana, boxes, checked) {
    var s = {};
    for (var i = 0; i < boxes.length; i++) {
      var input = boxes[i];
      var id = input.getAttribute("data-id");
      var li = input.closest ? input.closest("li") : null;
      input.checked = checked;
      if (checked) {
        if (id) s[id] = true;
        if (li)
          li.className = (li.className.replace(/\bdone\b/g, "") + " done")
            .replace(/\s+/g, " ")
            .trim();
      } else if (li) {
        li.className = li.className.replace(/\bdone\b/g, "").replace(/\s+/g, " ").trim();
      }
    }
    if (checked) saveState(semana, s);
    else {
      try {
        localStorage.removeItem(storageKey(semana));
      } catch (e) {}
    }
    updateProgress(root);
    updateTotal(root);
  }

  function ensureSelectAll(root) {
    if (root.querySelector(".shop-bulk")) return;
    var ul = root.querySelector("ul.shop-check");
    if (!ul) return;
    // Atalhos de carrinho: levar tudo ou tirar marcas.
    // Cart shortcuts: take everything or clear marks.
    var wrap = document.createElement("div");
    wrap.className = "shop-bulk";
    wrap.innerHTML =
      '<span class="shop-bulk-label">Carrinho rápido</span>' +
      '<div class="shop-bulk-actions">' +
      '<button type="button" class="shop-bulk-btn" data-select-all>Levar tudo</button>' +
      '<button type="button" class="shop-bulk-btn shop-bulk-btn-ghost" data-select-none>Tirar tudo</button>' +
      "</div>";
    root.insertBefore(wrap, ul);
  }

  function init() {
    var root = document.getElementById("lista-compras");
    if (!root) return;

    var semana = root.getAttribute("data-semana") || "1";
    var state = loadState(semana);
    var boxes = root.querySelectorAll('input[type="checkbox"][data-id]');

    ensureSelectAll(root);

    for (var i = 0; i < boxes.length; i++) {
      (function (input) {
        var id = input.getAttribute("data-id");
        var li = input.closest ? input.closest("li") : input.parentNode.parentNode;
        if (state[id]) {
          input.checked = true;
          if (li) li.className = (li.className + " done").replace(/^\s+/, "");
        }
        input.addEventListener("change", function () {
          var s = loadState(semana);
          if (input.checked) {
            s[id] = true;
            if (li)
              li.className = (li.className.replace(/\bdone\b/g, "") + " done")
                .replace(/\s+/g, " ")
                .trim();
          } else {
            delete s[id];
            if (li) li.className = li.className.replace(/\bdone\b/g, "").replace(/\s+/g, " ").trim();
          }
          saveState(semana, s);
          updateProgress(root);
          updateTotal(root);
        });
      })(boxes[i]);
    }

    var allBtn = root.querySelector("[data-select-all]");
    var noneBtn = root.querySelector("[data-select-none]");
    if (allBtn) {
      allBtn.addEventListener("click", function () {
        setAllChecked(root, semana, boxes, true);
      });
    }
    if (noneBtn) {
      noneBtn.addEventListener("click", function () {
        setAllChecked(root, semana, boxes, false);
      });
    }

    if (!root.querySelector("[data-shop-progress]")) {
      var progress = document.createElement("p");
      progress.className = "shop-progress footer-note";
      progress.setAttribute("data-shop-progress", "1");
      var actions = root.querySelector(".shop-actions");
      if (actions) root.insertBefore(progress, actions);
      else root.appendChild(progress);
    }
    paintEstimates(root);
    updateProgress(root);
    updateTotal(root);

    root.addEventListener("click", function (ev) {
      var t = ev.target;
      var dl = t.closest ? t.closest("[data-keep-download]") : null;
      var rs = t.closest ? t.closest("[data-keep-reset]") : null;

      if (dl) {
        var title =
          semana === "despensa" ? "Despensa — 1ª compra" : "Compras — Semana " + semana;
        var lines = [title, ""];
        var list = root.querySelectorAll("label.shop-item");
        for (var j = 0; j < list.length; j++) {
          var inp = list[j].querySelector("input");
          var nameEl = list[j].querySelector("[data-item-name]") || list[j].querySelector("span");
          var priceEl = list[j].querySelector(".shop-price");
          var mark = inp && inp.checked ? "☑" : "☐";
          var price = priceEl ? "  " + plainText(priceEl) : "";
          lines.push(mark + " " + plainText(nameEl) + price);
        }
        var tot = root.querySelector("[data-shop-total]");
        if (tot) {
          lines.push("");
          lines.push(plainText(tot));
        }
        var fname =
          semana === "despensa"
            ? "despensa-primeira-compra-keep.txt"
            : "compras-semana-" + semana + "-keep.txt";
        downloadTxt(fname, lines.join("\r\n"));
        var hint = document.getElementById("keep-hint");
        if (hint) hint.hidden = false;
      }

      if (rs) {
        var resetMsg =
          semana === "despensa"
            ? "Limpar todas as marcas da despensa?"
            : "Limpar todas as marcas desta semana?";
        if (!confirm(resetMsg)) return;
        localStorage.removeItem(storageKey(semana));
        for (var k = 0; k < boxes.length; k++) {
          boxes[k].checked = false;
          var li2 = boxes[k].closest ? boxes[k].closest("li") : null;
          if (li2) li2.className = li2.className.replace(/\bdone\b/g, "").trim();
        }
        updateProgress(root);
        updateTotal(root);
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
