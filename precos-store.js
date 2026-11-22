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
  /**
   * Despensa / gerais: ficam na lista de compras, mas sem valor na estimativa.
   * Pantry staples: stay on the shopping list, excluded from cost estimates.
   */
  /**
   * Só estoque seco / frasco — não frescos das receitas (cebola, alho, limão…).
   * Dry pantry only — not fresh recipe ingredients (onion, garlic, lemon…).
   */
  var PANTRY_KEYS = {
    arroz: 1,
    feijao: 1,
    azeite: 1,
    shoyu: 1,
    temperos: 1,
    aveia: 1,
    sal: 1,
    oregano: 1,
    cominho: 1,
    colorau: 1,
    paprica: 1,
    louro: 1,
    pimenta: 1,
    alho: 1
  };

  var DEFAULTS_AQA = {
    patinho: { name: "Patinho moído", unitPrice: 56.0, unit: "kg" },
    acem: { name: "Acém / músculo", unitPrice: 43.0, unit: "kg" },
    porco: { name: "Pernil / lombo (porco)", unitPrice: 28.0, unit: "kg" },
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
    pepino: { name: "Pepino", unitPrice: 8.0, unit: "kg" },
    abobora: { name: "Abóbora / cabocha", unitPrice: 6.5, unit: "kg" },
    mussarela: { name: "Mussarela", unitPrice: 45.0, unit: "kg" },
    cebola: { name: "Cebola", unitPrice: 7.0, unit: "kg" },
    limao: { name: "Limão", unitPrice: 10.0, unit: "kg" },
    molho_tomate: { name: "Molho de tomate / pelado", unitPrice: 6.5, unit: "un" },
    cheiro_verde: { name: "Cheiro-verde (maço)", unitPrice: 3.0, unit: "un" },
    // Despensa (estoque seco/frasco) — mesmos preços no catálogo e na lista.
    // Pantry (dry/jar stock) — same prices in catalog and list.
    arroz: { name: "Arroz integral", unitPrice: 8.0, unit: "kg" },
    feijao: { name: "Feijão", unitPrice: 9.0, unit: "kg" },
    azeite: { name: "Azeite (500 ml)", unitPrice: 28.0, unit: "un" },
    alho: { name: "Alho industrializado", unitPrice: 9.0, unit: "un" },
    sal: { name: "Sal", unitPrice: 3.0, unit: "kg" },
    colorau: { name: "Colorau", unitPrice: 4.0, unit: "un" },
    cominho: { name: "Cominho", unitPrice: 5.0, unit: "un" },
    paprica: { name: "Páprica", unitPrice: 6.0, unit: "un" },
    oregano: { name: "Orégano", unitPrice: 4.0, unit: "un" },
    pimenta: { name: "Pimenta-do-reino", unitPrice: 5.0, unit: "un" },
    louro: { name: "Louro", unitPrice: 3.0, unit: "un" },
    shoyu: { name: "Shoyu / agridoce", unitPrice: 12.0, unit: "un" },
    aveia: { name: "Aveia em flocos", unitPrice: 6.0, unit: "un" }
  };

  /**
   * Itens da página Despensa (qtde/nota); preço vem do catálogo.
   * Despensa page items (qty/note); price comes from the catalog.
   */
  var FIRST_BUY = [
    { name: "Arroz integral", qty: "1 kg", note: "lote semanal ~300 g" },
    { name: "Feijão", qty: "1 kg", note: "lote semanal ~250–350 g" },
    { name: "Azeite", qty: "1 un (500 ml)", note: "todas as receitas" },
    { name: "Alho industrializado", qty: "1 pote", note: "substitui alho fresco · todas as receitas" },
    { name: "Sal", qty: "1 kg", note: "despensa" },
    { name: "Colorau", qty: "1 pote", note: "refogados e moída" },
    { name: "Cominho", qty: "1 pote", note: "refogados e recheados" },
    { name: "Páprica", qty: "1 pote", note: "quase todos os pratos" },
    { name: "Orégano", qty: "1 pote", note: "molho e recheados" },
    { name: "Pimenta-do-reino", qty: "1 pote", note: "uso geral" },
    { name: "Louro", qty: "1 pacote", note: "feijão e refogados" },
    { name: "Shoyu / agridoce", qty: "1 frasco", note: "receita shoyu" },
    { name: "Aveia em flocos", qty: "1 pacote", note: "almôndegas (opcional)" }
  ];

  var ALIASES = {
    patinho: ["patinho", "patinho moido"],
    acem: ["acem", "acém", "musculo", "músculo", "paleta", "carne de panela", "panela", "acem moido", "acém moído"],
    porco: ["porco", "pernil", "lombo", "lombo suino", "lombo suíno", "porco em cubos", "pernil ou lombo"],
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
    pepino: ["pepino"],
    abobora: ["abobora", "abóbora", "cabocha", "moranga"],
    mussarela: ["mussarela", "muzarela", "queijo mussarela", "queijo"],
    arroz: ["arroz", "arroz integral"],
    feijao: ["feijao", "feijão"],
    cebola: ["cebola"],
    alho: ["alho", "alho industrializado", "alho paste", "alho em pasta", "alho triturado"],
    azeite: ["azeite"],
    limao: ["limao", "limão"],
    shoyu: ["shoyu", "molho shoyu", "agridoce"],
    molho_tomate: ["molho de tomate", "molho tomate", "pelado", "extrato"],
    temperos: ["temperos", "tempero"],
    aveia: ["aveia"],
    cheiro_verde: ["cheiro-verde", "cheiro verde", "salsa", "coentro"],
    louro: ["louro"],
    colorau: ["colorau"],
    cominho: ["cominho"],
    paprica: ["paprica", "páprica"],
    oregano: ["oregano", "orégano"],
    sal: ["sal"],
    pimenta: ["pimenta-do-reino", "pimenta do reino", "pimenta"]
  };

  function isPantryKey(key) {
    return !!(key && PANTRY_KEYS[key]);
  }

  function isPantryLabel(label) {
    var key = canonicalKey(label);
    if (isPantryKey(key)) return true;
    var f = fold(label);
    // Linha só de despensa (ex. "Arroz · Feijão · Temperos").
    // Pantry-only shopping line (e.g. rice · beans · seasonings).
    if (/arroz|feijao|tempero|azeite|shoyu|aveia|\bsal\b|colorau|cominho|paprica|oregano|louro|pimenta|alho industrializado|alho em pasta|alho triturado/.test(f)) {
      if (
        !/patinho|acem|musculo|porco|pernil|lombo|frango|ovo|quiabo|brocolis|vagem|couve|abobrinha|berinjela|pimentao|chuchu|tomate|pepino|abobora|mussarela|queijo|cebola|limao|molho|cheiro/.test(
          f
        )
      ) {
        return true;
      }
    }
    // Linha só de alho (despensa industrializado).
    // Garlic-only line (industrial pantry).
    if (/^alho\b/.test(f) && !/patinho|porco|frango|cebola/.test(f)) return true;
    return false;
  }

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
    // Ignora nota após "·" antes do fold (senão o ponto vira espaço).
    // Strip the note after "·" before fold (otherwise the dot becomes a space).
    var rawMain = String(name || "").split(/\s*[·•]\s*/)[0];
    var f = fold(rawMain);
    var main = f;
    var best = null;
    var bestLen = 0;
    for (var key in ALIASES) {
      if (!ALIASES.hasOwnProperty(key)) continue;
      var list = ALIASES[key];
      for (var i = 0; i < list.length; i++) {
        var alias = fold(list[i]);
        if (!alias) continue;
        if (main.indexOf(alias) !== -1 && alias.length > bestLen) {
          best = key;
          bestLen = alias.length;
        }
      }
    }
    if (best) return best;
    var parts = main.split(" ").filter(function (w) {
      return w.length > 2 && ["para", "com", "sem", "tipo", "kg", "maco", "frasco", "pote", "pacote"].indexOf(w) === -1;
    });
    return parts.slice(0, 2).join("_") || main;
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
      var d = DEFAULTS_AQA[key];
      // NF/manual não é sobrescrito.
      // NF/manual is never overwritten.
      if (cat[key] && cat[key].source && cat[key].source !== "seed-aqa") continue;
      if (!cat[key]) {
        cat[key] = {
          key: key,
          name: d.name,
          unitPrice: d.unitPrice,
          unit: d.unit,
          updatedAt: new Date().toISOString(),
          source: "seed-aqa"
        };
        changed = true;
        continue;
      }
      // Atualiza seed da despensa se nome/unidade/preço mudaram no app.
      // Refresh pantry seed when name/unit/price changed in the app.
      if (
        isPantryKey(key) &&
        cat[key].source === "seed-aqa" &&
        (cat[key].unit !== d.unit ||
          cat[key].unitPrice !== d.unitPrice ||
          cat[key].name !== d.name)
      ) {
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
    var changed = false;
    // Sempre completa chaves faltantes com seed Araraquara (não sobrescreve NF/manual).
    // Always fill missing keys with Araraquara seed (never overwrite NF/manual).
    if (seedAraraquara(cat)) changed = true;
    if (changed) {
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
    // Despensa e semanas usam o mesmo catálogo (preço unitário × quantidade da linha).
    // Pantry and weeks share the same catalog (unit price × line quantity).
    var entry = cat[key];
    if (!entry) {
      return {
        key: key,
        matched: false,
        estimate: null,
        detail: null,
        pantry: isPantryLabel(label) || isPantryKey(key)
      };
    }
    var q = parseQtyFromLabel(label);
    var estimate = null;
    var detail = "";
    if (entry.unit === "kg" && q.unit === "kg" && q.qty != null) {
      estimate = entry.unitPrice * q.qty;
      detail = q.qty.toFixed(3).replace(/\.?0+$/, "") + " kg × R$ " + entry.unitPrice.toFixed(2).replace(".", ",") + "/kg";
    } else if (entry.unit === "un" && q.unit === "un" && q.qty != null) {
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
    return {
      key: key,
      matched: true,
      estimate: estimate,
      detail: detail,
      entry: entry,
      pantry: isPantryLabel(label) || isPantryKey(key)
    };
  }

  function xmlKids(parent, name) {
    // NFC-e real usa namespace; getElementsByTagNameNS cobre os dois casos.
    // Real NFC-e uses a namespace; getElementsByTagNameNS covers both cases.
    if (!parent) return [];
    var list = parent.getElementsByTagName
      ? parent.getElementsByTagName(name)
      : [];
    if (list && list.length) return list;
    if (parent.getElementsByTagNameNS) {
      list = parent.getElementsByTagNameNS("*", name);
      if (list && list.length) return list;
    }
    return [];
  }

  function parseNFeXml(xmlText) {
    var items = [];
    var doc;
    try {
      doc = new DOMParser().parseFromString(xmlText, "text/xml");
    } catch (e) {
      return items;
    }
    var prods = xmlKids(doc, "prod");
    for (var i = 0; i < prods.length; i++) {
      var p = prods[i];
      function tag(n) {
        var el = xmlKids(p, n)[0];
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

  /**
   * Atualiza preços da NF só para produtos já no catálogo (não cria item novo).
   * Updates NF prices only for products already in the catalog (does not create items).
   * opts.onlyExisting padrão true — compras fora da lista não entram no orçamento.
   * opts.onlyExisting defaults to true — off-list purchases stay out of the budget.
   */
  function importItems(rawItems, opts) {
    opts = opts || {};
    var onlyExisting = opts.onlyExisting !== false;
    var cat = loadCatalog();
    var imported = [];
    var skipped = [];
    for (var i = 0; i < rawItems.length; i++) {
      var it = rawItems[i];
      if (!it.name || it.unitPrice == null) continue;
      var key = canonicalKey(it.name);
      if (!key) {
        skipped.push({ name: it.name, reason: "sem-chave" });
        continue;
      }
      if (onlyExisting && !cat[key]) {
        skipped.push({ name: it.name, key: key, reason: "fora-do-catalogo" });
        continue;
      }
      var src = opts.source || it.source || "import";
      if (cat[key]) {
        // Mantém nome/unidade do cadastro; só atualiza o preço.
        // Keeps catalog name/unit; only updates the price.
        cat[key].unitPrice = it.unitPrice;
        cat[key].source = src;
        cat[key].updatedAt = new Date().toISOString();
        imported.push(cat[key]);
      } else {
        var saved = upsertPrice(cat, it.name, it.unitPrice, it.unit, {
          source: src
        });
        if (saved) imported.push(saved);
      }
    }
    saveCatalog(cat);
    return { catalog: cat, imported: imported, skipped: skipped };
  }

  function formatBRL(n) {
    if (n == null || !isFinite(n)) return "—";
    return "R$ " + n.toFixed(2).replace(".", ",");
  }

  /**
   * Só renomeia nfe-xml → qr-code; demais origens ficam iguais.
   * Only renames nfe-xml → qr-code; other sources stay unchanged.
   */
  function sourceLabel(source) {
    // Só rótulos úteis na gestão; códigos internos não aparecem.
    // Show management-friendly labels; hide internal source codes.
    if (source === "nfe-xml") return "qr-code";
    if (source === "seed-aqa") return "estimativa";
    if (source === "qr-code") return "qr-code";
    if (source === "manual") return "manual";
    return source || "—";
  }

  global.AlimentacaoPrecos = {
    loadCatalog: loadCatalog,
    saveCatalog: saveCatalog,
    canonicalKey: canonicalKey,
    upsertPrice: upsertPrice,
    estimateLine: estimateLine,
    isPantryLabel: isPantryLabel,
    isPantryKey: isPantryKey,
    parseNFeXml: parseNFeXml,
    parseNFeText: parseNFeText,
    importItems: importItems,
    parseQtyFromLabel: parseQtyFromLabel,
    formatBRL: formatBRL,
    sourceLabel: sourceLabel,
    DEFAULTS_AQA: DEFAULTS_AQA,
    FIRST_BUY: FIRST_BUY,
    PANTRY_KEYS: PANTRY_KEYS,
    STORAGE_KEY: STORAGE_KEY,
    ALIASES: ALIASES
  };
})(window);
