/**
 * Baixa a lista de compras da semana em .txt (checklist para Google Keep).
 * O navegador NÃO grava no celular via cabo — só baixa no PC (pasta Downloads).
 */
(function () {
  function plainText(el) {
    return (el.innerText || el.textContent || "").replace(/\s+/g, " ").trim();
  }

  function collectItems(root) {
    var items = [];
    root.querySelectorAll("li").forEach(function (li) {
      var t = plainText(li);
      if (t) items.push(t);
    });
    return items;
  }

  function buildKeepText(semana, items) {
    var lines = [
      "Compras — Semana " + semana,
      "Checklist para o mercado",
      ""
    ];
    items.forEach(function (item) {
      lines.push("☐ " + item);
    });
    lines.push("");
    lines.push("Dica Keep: cole na nota e toque no icone de checklist.");
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

  function onClick(btn) {
    var semana = btn.getAttribute("data-semana") || "1";
    var root = document.getElementById("lista-compras");
    if (!root) {
      alert("Lista de compras nao encontrada nesta pagina.");
      return;
    }
    var items = collectItems(root);
    if (!items.length) {
      alert("Nenhum item na lista.");
      return;
    }
    downloadTxt(
      "compras-semana-" + semana + "-keep.txt",
      buildKeepText(semana, items)
    );
    var hint = document.getElementById("keep-hint");
    if (hint) hint.hidden = false;
  }

  document.addEventListener("DOMContentLoaded", function () {
    document.querySelectorAll("[data-keep-download]").forEach(function (btn) {
      btn.addEventListener("click", function () {
        onClick(btn);
      });
    });
  });
})();
