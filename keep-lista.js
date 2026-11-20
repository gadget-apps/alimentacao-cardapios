/**
 * Checklist de compras na página + persistência local (localStorage).
 * Também baixa .txt para Google Keep.
 */
(function () {
  function storageKey(semana) {
    return "alimentacao-compras-semana-" + semana;
  }

  function plainText(el) {
    return (el.innerText || el.textContent || "").replace(/\s+/g, " ").trim();
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
    } catch (e) {
      /* ignore quota / private mode */
    }
  }

  function itemId(text, index) {
    return "i" + index + "-" + text.toLowerCase().replace(/[^a-z0-9à-ü]+/gi, "-").slice(0, 40);
  }

  function collectLabels(root) {
    var labels = [];
    root.querySelectorAll('label.shop-item span, label.shop-item').forEach(function (el) {
      if (el.tagName === "SPAN") {
        var t = plainText(el);
        if (t) labels.push(t);
      }
    });
    if (labels.length) return labels;
    root.querySelectorAll("li").forEach(function (li) {
      var t = plainText(li).replace(/^[☐✓]\s*/, "");
      if (t) labels.push(t);
    });
    return labels;
  }

  function buildChecklist(root, semana) {
    var items = collectLabels(root);
    if (!items.length) return;

    var state = loadState(semana);
    var ul = document.createElement("ul");
    ul.className = "shop-check";
    ul.setAttribute("role", "list");

    items.forEach(function (text, index) {
      var id = itemId(text, index);
      var checked = !!state[id];
      var li = document.createElement("li");
      li.className = checked ? "done" : "";

      var label = document.createElement("label");
      label.className = "shop-item";

      var input = document.createElement("input");
      input.type = "checkbox";
      input.checked = checked;
      input.setAttribute("data-id", id);

      var span = document.createElement("span");
      span.textContent = text;

      label.appendChild(input);
      label.appendChild(span);
      li.appendChild(label);
      ul.appendChild(li);

      input.addEventListener("change", function () {
        var s = loadState(semana);
        if (input.checked) {
          s[id] = true;
          li.classList.add("done");
        } else {
          delete s[id];
          li.classList.remove("done");
        }
        saveState(semana, s);
        updateProgress(root, semana);
      });
    });

    // Replace old content (lists/grids) but keep action buttons outside if present
    var actions = root.querySelector(".shop-actions");
    var hint = root.querySelector("#keep-hint");
    root.innerHTML = "";
    root.appendChild(ul);
    if (!actions) {
      actions = document.createElement("div");
      actions.className = "shop-actions";
      actions.innerHTML =
        '<button type="button" class="btn-keep" data-keep-download data-semana="' +
        semana +
        '">Baixar lista (Google Keep)</button>' +
        '<button type="button" class="btn-keep btn-keep-secondary" data-keep-reset data-semana="' +
        semana +
        '">Limpar marcas</button>';
    }
    root.appendChild(actions);
    if (hint) root.appendChild(hint);
    else {
      var h = document.createElement("div");
      h.id = "keep-hint";
      h.className = "keep-hint";
      h.hidden = true;
      h.innerHTML =
        "<strong>No Keep:</strong> abra o arquivo, copie tudo, cole numa nota nova e toque no ícone de checklist.";
      root.appendChild(h);
    }

    var progress = document.createElement("p");
    progress.className = "shop-progress footer-note";
    progress.setAttribute("data-shop-progress", "1");
    root.insertBefore(progress, actions);
    updateProgress(root, semana);
  }

  function updateProgress(root, semana) {
    var boxes = root.querySelectorAll('input[type="checkbox"]');
    var done = 0;
    boxes.forEach(function (b) {
      if (b.checked) done++;
    });
    var el = root.querySelector("[data-shop-progress]");
    if (el) {
      el.textContent =
        done +
        " de " +
        boxes.length +
        " itens · marcas salvas neste aparelho/navegador";
    }
  }

  function buildKeepText(semana, items, state) {
    var lines = ["Compras — Semana " + semana, "", ""];
    items.forEach(function (text, index) {
      var id = itemId(text, index);
      var mark = state[id] ? "☑" : "☐";
      lines.push(mark + " " + text);
    });
    return lines.join("\r\n");
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
    }, 1000);
  }

  document.addEventListener("DOMContentLoaded", function () {
    var root = document.getElementById("lista-compras");
    if (!root) return;

    var semanaBtn = document.querySelector("[data-semana]");
    var semana =
      (semanaBtn && semanaBtn.getAttribute("data-semana")) ||
      root.getAttribute("data-semana") ||
      "1";
    root.setAttribute("data-semana", semana);

    buildChecklist(root, semana);

    root.addEventListener("click", function (ev) {
      var t = ev.target;
      if (t.closest && t.closest("[data-keep-download]")) {
        var items = [];
        root.querySelectorAll("label.shop-item span").forEach(function (span) {
          items.push(plainText(span));
        });
        downloadTxt(
          "compras-semana-" + semana + "-keep.txt",
          buildKeepText(semana, items, loadState(semana))
        );
        var hint = document.getElementById("keep-hint");
        if (hint) hint.hidden = false;
      }
      if (t.closest && t.closest("[data-keep-reset]")) {
        if (!confirm("Limpar todas as marcas desta semana?")) return;
        localStorage.removeItem(storageKey(semana));
        root.querySelectorAll('input[type="checkbox"]').forEach(function (b) {
          b.checked = false;
          b.closest("li").classList.remove("done");
        });
        updateProgress(root, semana);
      }
    });
  });
})();
