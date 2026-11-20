/**
 * Persistência da checklist de compras (localStorage).
 * Os checkboxes já vêm no HTML — este script só salva/restaura as marcas.
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

  function updateProgress(root) {
    var boxes = root.querySelectorAll('input[type="checkbox"]');
    var done = 0;
    for (var i = 0; i < boxes.length; i++) {
      if (boxes[i].checked) done++;
    }
    var el = root.querySelector("[data-shop-progress]");
    if (el) el.textContent = done + " de " + boxes.length + " itens";
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

    root.addEventListener("click", function (ev) {
      var t = ev.target;
      var dl = t.closest ? t.closest("[data-keep-download]") : null;
      var rs = t.closest ? t.closest("[data-keep-reset]") : null;

      if (dl) {
        var lines = ["Compras — Semana " + semana, ""];
        var list = root.querySelectorAll("label.shop-item");
        for (var j = 0; j < list.length; j++) {
          var inp = list[j].querySelector("input");
          var span = list[j].querySelector("span");
          var mark = inp && inp.checked ? "☑" : "☐";
          lines.push(mark + " " + plainText(span));
        }
        downloadTxt("compras-semana-" + semana + "-keep.txt", lines.join("\r\n"));
        var hint = document.getElementById("keep-hint");
        if (hint) hint.hidden = false;
      }

      if (rs) {
        if (!confirm("Limpar todas as marcas desta semana?")) return;
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
