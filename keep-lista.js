/**
 * Checklist de compras + estimativa de preços (AlimentacaoPrecos).
 * Shopping checklist + price estimates.
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

  function paintEstimates(root) {
    var P = window.AlimentacaoPrecos;
    if (!P) return;
    // Despensa: preços já vêm no HTML (FIRST_BUY).
    // Pantry checklist: prices already rendered from FIRST_BUY.
    if (root.getAttribute("data-despensa") === "1") {
      updateProgress(root);
      return;
    }
    var cat = P.loadCatalog();
    var total = 0;
    var matched = 0;
    var labels = root.querySelectorAll("label.shop-item");
    for (var i = 0; i < labels.length; i++) {
      var label = labels[i];
      var span = label.querySelector("span:not(.shop-price)");
      if (!span) continue;
      var text = plainText(span).replace(/\s*≈.*$/, "").replace(/\s*R\$.*$/, "");
      // restore clean text in first span if we nested before
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
      if (est.pantry) {
        priceEl.textContent = "";
        priceEl.title = "Despensa — fora da estimativa";
        priceEl.className = "shop-price";
      } else if (est.matched && est.estimate != null) {
        priceEl.textContent = P.formatBRL(est.estimate);
        priceEl.title = est.detail || "";
        priceEl.className = "shop-price shop-price-ok";
        total += est.estimate;
        matched++;
      } else if (est.matched && est.detail) {
        priceEl.textContent = est.detail;
        priceEl.className = "shop-price shop-price-ref";
      } else {
        priceEl.textContent = "—";
        priceEl.className = "shop-price";
        priceEl.title = "Sem preço no catálogo";
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
      "<strong>Estimativa da lista:</strong> " +
      P.formatBRL(total) +
      ' <span class="footer-note">(' +
      matched +
      " itens · sem arroz/feijão/temperos · <a href=\"precos.html\">atualizar após a compra</a>)</span>";
  }

  function updateProgress(root) {
    var boxes = root.querySelectorAll('input[type="checkbox"]');
    var done = 0;
    for (var i = 0; i < boxes.length; i++) {
      if (boxes[i].checked) done++;
    }
    var el = root.querySelector("[data-shop-progress]");
    if (el) el.textContent = done + " de " + boxes.length + " itens";
  }

  function init() {
    var root = document.getElementById("lista-compras");
    if (!root) return;

    var semana = root.getAttribute("data-semana") || "1";
    var state = loadState(semana);
    var boxes = root.querySelectorAll('input[type="checkbox"][data-id]');

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
            if (li) li.className = (li.className.replace(/\bdone\b/g, "") + " done").replace(/\s+/g, " ").trim();
          } else {
            delete s[id];
            if (li) li.className = li.className.replace(/\bdone\b/g, "").replace(/\s+/g, " ").trim();
          }
          saveState(semana, s);
          updateProgress(root);
        });
      })(boxes[i]);
    }

    if (!root.querySelector("[data-shop-progress]")) {
      var progress = document.createElement("p");
      progress.className = "shop-progress footer-note";
      progress.setAttribute("data-shop-progress", "1");
      var actions = root.querySelector(".shop-actions");
      if (actions) root.insertBefore(progress, actions);
      else root.appendChild(progress);
    }
    updateProgress(root);
    paintEstimates(root);

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
      }
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", init);
  } else {
    init();
  }
})();
