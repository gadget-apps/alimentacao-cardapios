/**
 * Menu drawer em todas as páginas.
 * Side drawer navigation on every page.
 */
(function () {
  var LINKS = [
    { href: "index.html", label: "Início" },
    { href: "precos.html", label: "Preços" },
    { href: "semana-1.html", label: "Semana 1" },
    { href: "semana-2.html", label: "Semana 2" },
    { href: "semana-3.html", label: "Semana 3" },
    { href: "semana-4.html", label: "Semana 4" },
    { href: "semana-5.html", label: "Semana 5" },
    { href: "semana-6.html", label: "Semana 6" },
    { href: "semana-7.html", label: "Semana 7" },
    { href: "semana-8.html", label: "Semana 8" },
    { href: "receitas.html", label: "Receitas" }
  ];

  function currentFile() {
    var p = (location.pathname || "").split("/").pop() || "index.html";
    if (!p || p === "") return "index.html";
    return p;
  }

  function build() {
    // Remove nav antiga (pills)
    var old = document.querySelectorAll("nav.nav");
    for (var i = 0; i < old.length; i++) old[i].parentNode.removeChild(old[i]);

    if (document.getElementById("app-drawer")) return;

    var file = currentFile();
    var linksHtml = LINKS.map(function (l) {
      var active = file === l.href || (file === "" && l.href === "index.html");
      return (
        '<a class="drawer-link' +
        (active ? " active" : "") +
        '" href="' +
        l.href +
        '">' +
        l.label +
        "</a>"
      );
    }).join("");

    var bar = document.createElement("div");
    bar.className = "topbar";
    bar.innerHTML =
      '<button type="button" class="drawer-toggle" id="drawer-open" aria-label="Abrir menu">' +
      '<span></span><span></span><span></span></button>' +
      '<span class="topbar-title">Cardápio Light</span>';

    var backdrop = document.createElement("div");
    backdrop.className = "drawer-backdrop";
    backdrop.id = "drawer-backdrop";

    var drawer = document.createElement("aside");
    drawer.className = "drawer";
    drawer.id = "app-drawer";
    drawer.innerHTML =
      '<div class="drawer-head">' +
      "<strong>Menu</strong>" +
      '<button type="button" class="drawer-close" id="drawer-close" aria-label="Fechar">×</button>' +
      "</div>" +
      '<nav class="drawer-nav">' +
      linksHtml +
      "</nav>";

    document.body.insertBefore(backdrop, document.body.firstChild);
    document.body.insertBefore(drawer, document.body.firstChild);
    document.body.insertBefore(bar, document.body.firstChild);

    function open() {
      document.body.classList.add("drawer-open");
    }
    function close() {
      document.body.classList.remove("drawer-open");
    }

    document.getElementById("drawer-open").addEventListener("click", open);
    document.getElementById("drawer-close").addEventListener("click", close);
    backdrop.addEventListener("click", close);
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") close();
    });
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", build);
  } else {
    build();
  }
})();
