/**
 * Catálogo de preços (localStorage) + seed Araraquara.
 * Usado em precos.html e nas listas de compras das semanas.
 *
 * Price catalog (localStorage) + Araraquara seed defaults.
 * Used by precos.html and week shopping lists.
 */
(function (global) {
  var STORAGE_KEY = "alimentacao-precos-v1";
  var SEEDED_FLAG = "alimentacao-precos-seeded-aqa-v1";

  /**
   * Preços aproximados varejo região Araraquara (CEAGESP atacado × ~2 + IEA carnes).
   * Approximate retail prices for Araraquara region.
   */
  var DEFAULTS_AQA = {
    patinho: { name: "Patinho moído", unitPrice: 56.0, unit: "kg" },
    acem: { name: "Acém / músculo", unitPrice: 43.0, unit: "kg" },
    frango: { name: "Peito de frango", unitPrice: 23.0, unit: "kg" },
    ovo: { name: "Ovo", unitPrice: 1.0, unit: "un" },
    quiabo: { name: "Quiabo", unitPrice: 26.0, unit: "kg" },
    brocolis: { name: "Brócolis", unitPrice: 7.0, unit: "kg" },
    vagem: { name: "Vagem", unitPrice: 25.0, unit: "kg" },
    couve: { name: "Couve (maço)", unitPrice: 4.5, unit: "un" },
    abobrinha: { name: "Abobrinha", unitPrice: 6.5, unit: "kg" },
    berinjela: { name: "Berinjela", unitPrice: 7.5, unit: "kg" },
    pimentao: { name: "Pimentão", unitPrice: 11.0, unit: "kg" },
    chuchu: { name: "Chuchu", unitPrice: 5.0, unit: "un" },
    tomate: { name: "Tomate", unitPrice: 8.0, unit: "kg" },
    cebola: { name: "Cebola", unitPrice: 7.0, unit: "kg" },
    alho: { name: "Alho", unitPrice: 28.0, unit: "kg" },
    pepino: { name: "Pepino", unitPrice: 8.0, unit: "kg" },
    abobora: { name: "Abóbora / cabocha", unitPrice: 6.5, unit: "kg" },
    mussarela: { name: "Mussarela", unitPrice: 45.0, unit: "kg" },
    arroz: { name: "Arroz integral", unitPrice: 8.0, unit: "kg" },
    feijao: { name: "Feijão", unitPrice: 9.0, unit: "kg" },
    azeite: { name: "Azeite", unitPrice: 42.0, unit: "un" },
    limao: { name: "Limão", unitPrice: 10.0, unit: "kg" },
    shoyu: { name: "Molho shoyu", unitPrice: 12.0, unit: "un" },
    molho_tomate: { name: "Molho de tomate", unitPrice: 6.5, unit: "un" }
  };

  var ALIASES = {
    patinho: ["patinho", "patinho moido", "carne moida", "moído", "moido"],
    acem: ["acem", "acém", "musculo", "músculo", "paleta", "carne de panela", "panela"],
    frango: ["frango", "peito de frango", "peito"],
    ovo: ["ovo", "ovos", "duzia", "dúzia"],
    quiabo: ["quiabo"],
    brocolis: ["brocolis", "brócolis", "broccoli"],
    vagem: ["vagem"],
    couve: ["couve"],
    abobrinha: ["abobrinha"],
    berinjela: ["berinjela"],
    pimentao: ["pimentao", "pimentão"],
    chuchu: ["chuchu"],
    tomate: ["tomate"],
    cebola: ["cebola"],
    alho: ["alho"],
    pepino: ["pepino"],
    abobora: ["abobora", "abóbora", "cabocha", "moranga"],
    mussarela: ["mussarela", "muzarela", "queijo mussarela", "queijo"],
    arroz: ["arroz", "arroz integral"],
    feijao: ["feijao", "feijão"],
    azeite: ["azeite"],
    limao: ["limao", "limão"],
    shoyu: ["shoyu", "molho shoyu", "agridoce"],
    molho_tomate: ["molho de tomate", "molho tomate", "pelado", "extrato", "lata"]
  };

  function fold(s) {
    return String(s || "")
      .toLowerCase()
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .replace(/[^a-z0-9\s½]/g, " ")
      .replace(/\s+/g, " ")
      .trim();
  }

  function canonicalKey(name) {
    var f = fold(name);
    for (var key in ALIASES) {
      if (!ALIASES.hasOwnProperty(key)) continue;
      var list = ALIASES[key];
      for (var i = 0; i < list.length; i++) {
        if (f.indexOf(fold(list[i])) !== -1) return key;
      }
    }
    var parts = f.split(" ").filter(function (w) {
      return w.length > 2 && ["para", "com", "sem", "tipo", "kg", "maco", "frasco"].indexOf(w) === -1;
    });
    return parts.slice(0, 2).join("_") || f;
  }

  function parseMoney(s) {
    if (s == null) return null;
    var t = String(s).trim();
    if (!t) return null;
    if (t.indexOf(",") >= 0 && t.indexOf(".") >= 0) {
      t = t.replace(/\./g, "").replace(",", ".");
    } else if (t.indexOf(",") >= 0) {
      t = t.replace(",", ".");
    }
    var n = parseFloat(t);
    return isFinite(n) ? n : null;
  }

  function parseQtyFromLabel(label) {
    var f = fold(label);
    var mKg = f.match(/(\d+(?:[.,]\d+)?)\s*kg/);
    if (mKg) return { qty: parseMoney(mKg[1]), unit: "kg" };
    var mG = f.match(/(\d+(?:[.,]\d+)?)\s*g\b/);
    if (mG) {
      var g = parseMoney(mG[1]);
      return { qty: g != null ? g / 1000 : null, unit: "kg" };
    }
    if (/½\s*duzia|1\/2\s*duzia/.test(f)) return { qty: 6, unit: "un" };
    var mDu = f.match(/(\d+(?:[.,]\d+)?)\s*duzia/);
    if (mDu) return { qty: (parseMoney(mDu[1]) || 1) * 12, unit: "un" };
    if (/\bovos?\b/.test(f) && /(\d+)\s*un/.test(f)) {
      return { qty: parseInt(RegExp.$1, 10), unit: "un" };
    }
    var mUn = f.match(/(\d+)\s*(unidades?|und|un\b)/);
    if (mUn) return { qty: parseInt(mUn[1], 10), unit: "un" };
    if (/\bmaco\b|\bmaço\b/.test(label) || /\bmaco\b/.test(f)) return { qty: 1, unit: "un" };
    var mEnd = label.match(/[—\-–]\s*(\d+)\s*$/);
    if (mEnd) return { qty: parseInt(mEnd[1], 10), unit: "un" };
    // Pimentão / berinjela / chuchu sem número → 1 un
    if (/pimentao|berinjela|chuchu|abobrinha|abobora/.test(f) && !/\d/.test(f)) {
      return { qty: 1, unit: "un" };
    }
    return { qty: 1, unit: "un" };
  }

  function seedAraraquara(cat) {
    var changed = false;
    for (var key in DEFAULTS_AQA) {
      if (!DEFAULTS_AQA.hasOwnProperty(key)) continue;
      if (cat[key] && cat[key].source && cat[key].source !== "seed-aqa") continue;
      if (cat[key] && cat[key].source && cat[key].source !== "seed-aqa") {
        // keep NF/manual
        continue;
      }
      if (!cat[key]) {
        var d = DEFAULTS_AQA[key];
        cat[key] = {
          key: key,
          name: d.name,
          unitPrice: d.unitPrice,
          unit: d.unit,
          updatedAt: new Date().toISOString(),
          source: "seed-aqa"
        };
        changed = true;
      }
    }
    return changed;
  }

  function loadCatalog() {
    var cat = {};
    try {
      var raw = localStorage.getItem(STORAGE_KEY);
      if (raw) cat = JSON.parse(raw) || {};
    } catch (e) {
      cat = {};
    }
    // Sempre completa chaves faltantes com seed Araraquara (não sobrescreve NF/manual).
    // Always fill missing keys with Araraquara seed (never overwrite NF/manual).
    if (seedAraraquara(cat)) {
      try {
        localStorage.setItem(STORAGE_KEY, JSON.stringify(cat));
        localStorage.setItem(SEEDED_FLAG, "1");
      } catch (e2) {}
    }
    return cat;
  }

  function saveCatalog(cat) {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(cat));
  }

  function upsertPrice(cat, name, unitPrice, unit, meta) {
    var key = canonicalKey(name);
    if (!key) return null;
    cat[key] = {
      key: key,
      name: name,
      unitPrice: unitPrice,
      unit: unit || "un",
      updatedAt: new Date().toISOString(),
      source: (meta && meta.source) || "manual"
    };
    return cat[key];
  }

  function estimateLine(label, cat) {
    cat = cat || loadCatalog();
    var key = canonicalKey(label);
    var entry = cat[key];
    if (!entry) return { key: key, matched: false, estimate: null, detail: null };
    var q = parseQtyFromLabel(label);
    var estimate = null;
    var detail = "";
    if (entry.unit === "kg" && q.unit === "kg" && q.qty != null) {
      estimate = entry.unitPrice * q.qty;
      detail = q.qty.toFixed(3).replace(/\.?0+$/, "") + " kg × R$ " + entry.unitPrice.toFixed(2).replace(".", ",") + "/kg";
    } else if (entry.unit === "un" && q.qty != null) {
      estimate = entry.unitPrice * q.qty;
      detail = q.qty + " × R$ " + entry.unitPrice.toFixed(2).replace(".", ",");
    } else if (entry.unit === "kg" && q.unit === "un") {
      // Unidade sem peso: 1 un ≈ peso típico leve (ex. pimentão ~200 g)
      var approxKg = 0.2;
      estimate = entry.unitPrice * approxKg * (q.qty || 1);
      detail = "~" + (q.qty || 1) + " un × R$ " + entry.unitPrice.toFixed(2).replace(".", ",") + "/kg";
    } else {
      estimate = entry.unitPrice;
      detail = "R$ " + entry.unitPrice.toFixed(2).replace(".", ",") + " / " + entry.unit;
    }
    return { key: key, matched: true, estimate: estimate, detail: detail, entry: entry };
  }

  function parseNFeXml(xmlText) {
    var items = [];
    var doc;
    try {
      doc = new DOMParser().parseFromString(xmlText, "text/xml");
    } catch (e) {
      return items;
    }
    var prods = doc.getElementsByTagName("prod");
    for (var i = 0; i < prods.length; i++) {
      var p = prods[i];
      function tag(n) {
        var el = p.getElementsByTagName(n)[0];
        return el ? el.textContent : "";
      }
      var name = tag("xProd");
      var q = parseMoney(tag("qCom"));
      var u = fold(tag("uCom") || "un");
      var vUn = parseMoney(tag("vUnCom"));
      var vProd = parseMoney(tag("vProd"));
      if (!name || vUn == null) continue;
      var unit = u.indexOf("kg") >= 0 ? "kg" : "un";
      items.push({
        name: name,
        unitPrice: vUn,
        unit: unit,
        qty: q,
        total: vProd,
        source: "nfe-xml"
      });
    }
    return items;
  }

  function parseNFeText(text) {
    var items = [];
    var lines = String(text).split(/\r?\n/);
    var re = /^(.{3,}?)\s+(\d+[.,]\d+|\d+)\s*(kg|g|un|und|unid)?\s*[x×]\s*(\d+[.,]\d+)\s+(\d+[.,]\d+)\s*$/i;
    for (var i = 0; i < lines.length; i++) {
      var line = lines[i].trim();
      if (!line || line.length < 5) continue;
      if (/^(total|subtotal|pagamento|nfc|cnpj|chave)/i.test(line)) continue;
      var m = line.match(re);
      if (m) {
        var unitRaw = fold(m[3] || "un");
        var unit = unitRaw.indexOf("kg") >= 0 || unitRaw === "g" ? "kg" : "un";
        items.push({
          name: m[1].trim(),
          unitPrice: parseMoney(m[4]),
          unit: unit,
          qty: parseMoney(m[2]),
          total: parseMoney(m[5]),
          source: "nfe-text"
        });
      }
    }
    return items;
  }

  function importItems(rawItems) {
    var cat = loadCatalog();
    var imported = [];
    for (var i = 0; i < rawItems.length; i++) {
      var it = rawItems[i];
      if (!it.name || it.unitPrice == null) continue;
      var saved = upsertPrice(cat, it.name, it.unitPrice, it.unit, { source: it.source || "import" });
      if (saved) imported.push(saved);
    }
    saveCatalog(cat);
    return { catalog: cat, imported: imported };
  }

  function formatBRL(n) {
    if (n == null || !isFinite(n)) return "—";
    return "R$ " + n.toFixed(2).replace(".", ",");
  }

  global.AlimentacaoPrecos = {
    loadCatalog: loadCatalog,
    saveCatalog: saveCatalog,
    canonicalKey: canonicalKey,
    upsertPrice: upsertPrice,
    estimateLine: estimateLine,
    parseNFeXml: parseNFeXml,
    parseNFeText: parseNFeText,
    importItems: importItems,
    parseQtyFromLabel: parseQtyFromLabel,
    formatBRL: formatBRL,
    DEFAULTS_AQA: DEFAULTS_AQA,
    STORAGE_KEY: STORAGE_KEY,
    ALIASES: ALIASES
  };
})(window);
