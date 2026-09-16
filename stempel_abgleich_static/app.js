"use strict";

// Farbe pro Typ-Familie: ein stamp-Typ und der correspAction-Typ, auf den er
// üblicherweise gemappt wird, teilen sich dieselbe Farbe (z. B. transmission
// / transmitted), damit die Zuordnung auch optisch sofort erkennbar ist.
const TYPE_COLORS = {
  transmission: "#3b6fa8", transmitted: "#3b6fa8",
  delivery: "#3c8a53", delivered: "#3c8a53",
  redirection: "#b9862c", redirected: "#b9862c",
  arrival: "#2f8f95", arrived: "#2f8f95",
  transit: "#8a6a4b", in_transit: "#8a6a4b",
  "non-postal": "#8a857a",
  "other": "#a8532f",
  sent: "#5b6b7a",
  received: "#a35b8a",
};
const FALLBACK_COLOR = "#8a857a";

function typeColor(type) {
  return TYPE_COLORS[type] || FALLBACK_COLOR;
}

function hexToRgba(hex, alpha) {
  const h = hex.replace("#", "");
  const r = parseInt(h.substring(0, 2), 16);
  const g = parseInt(h.substring(2, 4), 16);
  const b = parseInt(h.substring(4, 6), 16);
  return `rgba(${r}, ${g}, ${b}, ${alpha})`;
}

function badgeHtml(type) {
  const color = typeColor(type);
  const style = `background:${hexToRgba(color, 0.15)}; color:${color};`;
  return `<span class="badge" style="${style}">${esc(type || "?")}</span>`;
}

const STAMP_TYPES = ["non-postal", "arrival", "transmission", "redirection", "delivery", "transit", "other"];

// Badge als editierbares Dropdown, für Stempel ohne (oder mit falschem)
// @type - schreibt @type direkt ins stamp-Element.
function stampTypeSelectHtml(s) {
  const color = typeColor(s.type || "");
  const style = `background:${hexToRgba(color, 0.15)}; color:${color};`;
  const placeholder = s.type ? "" : '<option value="" selected disabled>– Typ wählen –</option>';
  const options = STAMP_TYPES
    .map((t) => `<option value="${t}" ${t === s.type ? "selected" : ""}>${esc(t)}</option>`)
    .join("");
  return `<select data-role="stampType" class="badge-select" style="${style}" title="Stempeltyp setzen">${placeholder}${options}</select>`;
}

function wireStampTypeSelect(card, s) {
  const select = card.querySelector('[data-role="stampType"]');
  if (!select) return;
  select.addEventListener("click", (ev) => ev.stopPropagation());
  select.addEventListener("change", async () => {
    const newType = select.value;
    if (!newType) return;
    select.disabled = true;
    try {
      const data = await apiPost(`/api/file/${state.currentId}/set-stamp-type`, {
        stampIndex: s.index,
        type: newType,
      });
      state.file = data;
      render();
      toast(`Stempel Nr. ${s.n}: Typ auf "${newType}" gesetzt.`);
    } catch (e) {
      toast(e.message, true);
      select.disabled = false;
    }
  });
}

const ACTION_TYPE_ORDER = ["sent", "transmitted", "redirected", "in_transit", "arrived", "delivered", "received"];

const CHANGE_DATIERUNG_STEMPEL_TEXT = "Datierung und Stempel überprüft";

const EDITOR_STORAGE_KEY = "stempelAbgleich.editor";

function loadStoredEditor() {
  try {
    const v = localStorage.getItem(EDITOR_STORAGE_KEY);
    return v === "SJ" || v === "MAM" ? v : "";
  } catch {
    return "";
  }
}

function storeEditor(v) {
  try { localStorage.setItem(EDITOR_STORAGE_KEY, v); } catch { /* privater Modus o. ä. - egal */ }
}

const state = {
  candidates: [],
  filtered: [],
  mismatchOnly: false,
  currentId: null,
  file: null,       // aktuell geladene Datei (stamps + correspActions)
  activeStamp: null, // index des aktiven Stempels für manuelles Matchen
  openRaw: { stamp: new Set(), correspAction: new Set() }, // aufgeklappte XML-Editoren
  pendingRaw: {},    // "kind:index" -> noch ungespeicherter Textarea-Inhalt
  editor: loadStoredEditor(), // "SJ" | "MAM" | "" - für revisionDesc-Eintrag bei "weiter"
};

const el = (id) => document.getElementById(id);
const esc = (s) => (s == null ? "" : String(s)
  .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;"));

function normalizeId(raw) {
  let s = (raw || "").trim().toUpperCase();
  if (!s) return null;
  if (!s.startsWith("L")) s = "L" + s;
  const m = s.match(/^L(\d+)$/);
  if (m) s = "L" + m[1].padStart(5, "0");
  return s;
}

function toast(msg, isErr) {
  const t = el("toast");
  t.textContent = msg;
  t.classList.toggle("err", !!isErr);
  t.classList.add("show");
  clearTimeout(toast._timer);
  toast._timer = setTimeout(() => t.classList.remove("show"), isErr ? 4500 : 2200);
}

function setStatus(msg, kind) {
  const line = el("statusLine");
  line.textContent = msg || "";
  line.className = kind || "";
}

// ---------------------------------------------------------------------------
// API
// ---------------------------------------------------------------------------
async function apiGet(path) {
  const res = await fetch(path);
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
  return data;
}

async function apiPost(path, body) {
  const res = await fetch(path, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(body),
  });
  const data = await res.json();
  if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
  return data;
}

// ---------------------------------------------------------------------------
// Kandidatenliste / Navigation
// ---------------------------------------------------------------------------
async function loadCandidates() {
  const data = await apiGet("/api/list");
  state.candidates = data.files;
  applyFilter();
}

// Holt die Kandidatenliste frisch vom Server (statt der Momentaufnahme vom
// letzten Laden) und wendet den Filter neu an - wichtig, weil SJ und MAM
// gleichzeitig in getrennten Browser-Sessions arbeiten: sonst zeigt eine
// schon länger offene Seite Briefe, die die andere Person zwischenzeitlich
// schon als "Datierung und Stempel überprüft" markiert hat.
async function refreshCandidatesAndFilter() {
  try {
    const data = await apiGet("/api/list");
    state.candidates = data.files;
  } catch (e) {
    toast(e.message, true); // mit dem lokalen Stand weitermachen statt hängen zu bleiben
  }
  applyFilter();
}

function applyFilter() {
  // bereits abgeschlossene Briefe ("Datierung und Stempel überprüft")
  // fallen grundsätzlich aus der Warteschlange raus
  let list = state.candidates.filter((c) => !c.reviewed);
  if (state.mismatchOnly) list = list.filter((c) => c.mismatch);
  // SJ arbeitet die Liste von hinten nach vorne durch, MAM (bzw. niemand
  // gewählt) von vorne nach hinten - beide treffen sich so in der Mitte
  if (state.editor === "SJ") list = list.slice().reverse();
  state.filtered = list;
  updatePosIndicator();
}

function updatePosIndicator() {
  const idx = state.filtered.findIndex((c) => c.id === state.currentId);
  el("posIndicator").textContent = state.filtered.length
    ? `${idx >= 0 ? idx + 1 : "?"} / ${state.filtered.length}`
    : "";
  el("prevBtn").disabled = idx <= 0;
  el("nextBtn").disabled = idx < 0 || idx >= state.filtered.length - 1;
}

async function stepCandidate(delta) {
  await refreshCandidatesAndFilter();
  const idx = state.filtered.findIndex((c) => c.id === state.currentId);
  let next;
  if (idx < 0) {
    next = delta > 0 ? 0 : state.filtered.length - 1;
  } else {
    next = idx + delta;
  }
  if (next < 0 || next >= state.filtered.length) return;
  loadFile(state.filtered[next].id);
}

// ---------------------------------------------------------------------------
// Datei laden & rendern
// ---------------------------------------------------------------------------
async function loadFile(id) {
  const fid = normalizeId(id);
  if (!fid) return;
  setStatus(`Lade ${fid} …`);
  try {
    const data = await apiGet(`/api/file/${encodeURIComponent(fid)}`);
    state.file = data;
    state.currentId = fid;
    state.activeStamp = null;
    state.openRaw = { stamp: new Set(), correspAction: new Set() };
    state.pendingRaw = {};
    el("jumpInput").value = fid;
    el("browserBtn").href = data.htmlUrl;
    el("browserBtn").textContent = `${fid} im Browser öffnen ↗`;
    render();
    updatePosIndicator();
    setStatus(`${fid}: ${data.stamps.length} Stempel, ${data.correspActions.length} correspAction.`, "ok");
  } catch (e) {
    setStatus(`Fehler beim Laden von ${fid}: ${e.message}`, "err");
    toast(e.message, true);
  }
}

function findMappedStamps(actionType) {
  if (!state.file) return [];
  return state.file.stamps
    .map((s, i) => ({ ...s, i }))
    .filter((s) => s.suggestedType === actionType);
}

function fieldsMatch(a, b) {
  // grobe Übereinstimmungsprüfung: @when bzw. normalisierter Text
  const aw = a?.when, bw = b?.when;
  if (aw || bw) return (aw || "") === (bw || "");
  return (a?.text || "") === (b?.text || "");
}

function placesMatch(a, b) {
  const ar = a?.ref, br = b?.ref;
  if (ar || br) return (ar || "") === (br || "");
  return (a?.text || "") === (b?.text || "");
}

function render() {
  renderGrid();
  renderBody();
}

// Baut die Zeilen des Abgleichs-Rasters: pro correspAction-Typ (in
// kanonischer Reihenfolge sent/transmitted/redirected/in_transit/arrived/
// delivered/received) werden gleichtypige Stempel und correspAction paarweise auf
// dieselbe Zeile gesetzt (Stempel[i] neben correspAction[i]); reichen die
// Stempel oder die correspAction nicht, bleibt die jeweils andere Seite in
// der Zeile leer. Stempeltypen ohne correspAction-Entsprechung (z. B.
// Zensurvermerke) stehen als eigene Zeilen oben.
function buildRows() {
  if (!state.file) return [];
  const stamps = state.file.stamps;
  const actions = state.file.correspActions;
  const usedStampIdx = new Set();
  const usedActionIdx = new Set();
  const rows = [];

  const exclusiveTypes = [...new Set(stamps.filter((s) => !s.suggestedType).map((s) => s.type))];
  exclusiveTypes.forEach((type) => {
    stamps.filter((s) => s.type === type).forEach((s) => {
      rows.push({ stamp: s, action: null });
      usedStampIdx.add(s.index);
    });
  });

  ACTION_TYPE_ORDER.forEach((type) => {
    const typeStamps = stamps.filter((s) => s.suggestedType === type);
    const typeActions = actions.filter((a) => a.type === type);
    const n = Math.max(typeStamps.length, typeActions.length);
    for (let i = 0; i < n; i++) {
      const s = typeStamps[i] || null;
      const a = typeActions[i] || null;
      if (s) usedStampIdx.add(s.index);
      if (a) usedActionIdx.add(a.index);
      // neben correspAction[@type='sent'] (erste Zeile) steht - falls kein
      // Stempel da ist - stattdessen die dateline-Datierung aus dem Brieftext
      rows.push({ stamp: s, action: a, showDateline: type === "sent" && i === 0 });
    }
  });

  // Sicherheitsnetz, falls doch mal etwas durchs Raster fällt
  stamps.forEach((s) => { if (!usedStampIdx.has(s.index)) rows.push({ stamp: s, action: null }); });
  actions.forEach((a) => { if (!usedActionIdx.has(a.index)) rows.push({ stamp: null, action: a }); });

  return rows;
}

function emptyCell(msg) {
  const div = document.createElement("div");
  div.className = "empty-cell";
  div.textContent = `– ${msg} –`;
  return div;
}

// tei:TEI/descendant::tei:dateline[1]/tei:date[1]: die vom Absender selbst
// geschriebene Datierung im Brieftext, zum Abgleich mit dem gesendet-Datum.
function datelineCell() {
  const d = state.file.datelineDate;
  const div = document.createElement("div");
  div.className = "dateline-cell";
  div.innerHTML = `
    <div class="field-label">Datierung im Brieftext</div>
    <div class="dateline-value">${esc(dateStr(d) || "?")}</div>
  `;
  return div;
}

function renderGrid() {
  const grid = el("matchGrid");
  grid.querySelectorAll(".grid-cell, .empty-row-msg").forEach((n) => n.remove());
  if (!state.file) return;

  const rows = buildRows();
  if (!rows.length) {
    const msg = document.createElement("div");
    msg.className = "empty-row-msg empty-column";
    msg.textContent = "Keine Poststempel und keine correspAction in dieser Datei.";
    grid.appendChild(msg);
    return;
  }

  rows.forEach((row) => {
    const leftCell = document.createElement("div");
    leftCell.className = "grid-cell stamp-col";
    if (row.stamp) {
      leftCell.appendChild(createStampCard(row.stamp));
    } else if (row.showDateline && state.file.datelineDate) {
      leftCell.appendChild(datelineCell());
    } else {
      leftCell.appendChild(emptyCell("kein Stempel für diesen Typ"));
    }

    const rightCell = document.createElement("div");
    rightCell.className = "grid-cell action-col";
    rightCell.appendChild(row.action ? createActionCard(row.action) : emptyCell("keine correspAction für diesen Typ"));

    grid.appendChild(leftCell);
    grid.appendChild(rightCell);
  });
}

function renderBody() {
  const container = el("bodyText");
  const titleEl = el("bodyTitle");
  if (!state.file) {
    container.innerHTML = "";
    titleEl.textContent = "";
    return;
  }
  titleEl.textContent = state.file.title || "";
  container.innerHTML = state.file.bodyHtml
    ? state.file.bodyHtml
    : '<div class="empty-column">Kein Brieftext.</div>';
}

function dateStr(d) {
  if (!d) return null;
  if (d.text) return d.text;
  if (d.when) return d.when;
  if (d.notBefore || d.notAfter) return `${d.notBefore || "?"}–${d.notAfter || "?"}`;
  return null;
}

const WEEKDAYS_DE = ["So", "Mo", "Di", "Mi", "Do", "Fr", "Sa"];

function weekdayLabel(d) {
  if (!d || !d.when || !/^\d{4}-\d{2}-\d{2}$/.test(d.when)) return null;
  // per UTC parsen/auslesen, damit die Ortszeit des Browsers den Wochentag
  // bei einem reinen Kalenderdatum nicht verschieben kann
  const dt = new Date(`${d.when}T00:00:00Z`);
  if (Number.isNaN(dt.getTime())) return null;
  return WEEKDAYS_DE[dt.getUTCDay()];
}

function dateWithWeekdayHtml(d) {
  const str = dateStr(d);
  if (!str) return '<span class="empty-field">kein Datum</span>';
  const wd = weekdayLabel(d);
  return esc(str) + (wd ? ` <span class="weekday">${wd}</span>` : "");
}

function attrChipsHtml(attrs) {
  const entries = Object.entries(attrs || {});
  if (!entries.length) return "";
  const chips = entries
    .map(([k, v]) => `<span class="attr-chip"><span class="attr-key">${esc(k)}</span>=<span class="attr-val">"${esc(v)}"</span></span>`)
    .join(" ");
  return `<div class="attrs">${chips}</div>`;
}

// Orte für correspAction: Auswahl aus allen placeName in der Adresse
// (div[@type='address']) und den Poststempeln (incident[@type='postal']),
// damit sich Orte per Klick statt Handarbeit im XML anpassen lassen.
function placeOptionHtml(c, source, i) {
  return `<option value="${source}:${i}">${esc(c.text)}${c.ref ? ` (${esc(c.ref)})` : ""}</option>`;
}

function placeSelectHtml(a) {
  const allOptions = state.file.placeOptions || [];
  const residenceOptions = a.residenceOptions || [];
  const currentKey = (a.place && (a.place.ref || a.place.text)) || null;
  const currentLabel = a.place && a.place.text
    ? `${a.place.text}${a.place.ref ? ` (${a.place.ref})` : ""}`
    : "– kein Ort –";

  // aktuellen Wert nicht nochmal als normale Option auflisten - sonst
  // erscheint dieselbe PMB-Nummer doppelt (einmal als Vorauswahl, einmal
  // als Eintrag darunter)
  const notCurrent = (c) => (c.ref || c.text) !== currentKey;

  // bei correspAction[@type='sent'] stehen ggf. Vorschläge aus
  // residence_options_for_action oben: Arthur Schnitzlers Aufenthalte
  // außerhalb Wiens am genauen Briefdatum (aus dem Wiener-Schnitzler-
  // Projekt) vor den Wohnadressen (Zeitraum schließt das Datum nur
  // plausibel ein) - beide separat von den generischen Adress-/
  // Poststempel-Kandidaten. Nur mehr als eine Gruppe bekommt sichtbare
  // <optgroup>-Überschriften, bei nur einer bleibt es eine flache Liste.
  const residenceIndexed = residenceOptions
    .map((c, i) => ({ c, i }))
    .filter(({ c }) => notCurrent(c));
  const aufenthaltHtml = residenceIndexed
    .filter(({ c }) => c.kind === "aufenthalt")
    .map(({ c, i }) => placeOptionHtml(c, "residence", i))
    .join("");
  const wohnadresseHtml = residenceIndexed
    .filter(({ c }) => c.kind !== "aufenthalt")
    .map(({ c, i }) => placeOptionHtml(c, "residence", i))
    .join("");
  const candidateHtml = allOptions
    .map((c, i) => ({ c, i }))
    .filter(({ c }) => notCurrent(c))
    .map(({ c, i }) => placeOptionHtml(c, "candidate", i))
    .join("");

  const groups = [
    ["Aufenthalt (nicht Wien)", aufenthaltHtml],
    ["Wohnadresse zum Zeitpunkt", wohnadresseHtml],
    ["Adresse/Poststempel", candidateHtml],
  ].filter(([, html]) => html);
  const optionsHtml = groups.length > 1
    ? groups.map(([label, html]) => `<optgroup label="${label}">${html}</optgroup>`).join("")
    : groups.map(([, html]) => html).join("");

  return `
    <select data-role="placeSelect" class="place-select" title="Ort aus Adresse/Poststempeln bzw. Wohnadresse übernehmen">
      <option value="-1" selected>${esc(currentLabel)}</option>
      ${optionsHtml}
    </select>`;
}

function wirePlaceSelect(card, a) {
  const select = card.querySelector('[data-role="placeSelect"]');
  if (!select) return;
  select.addEventListener("click", (ev) => ev.stopPropagation());
  select.addEventListener("change", async (ev) => {
    ev.stopPropagation();
    if (select.value === "-1") return;
    const [source, idxStr] = select.value.split(":");
    const placeIndex = Number(idxStr);
    select.disabled = true;
    try {
      const data = await apiPost(`/api/file/${state.currentId}/set-place`, {
        actionIndex: a.index,
        placeIndex,
        source,
      });
      state.file = data;
      render();
      toast(`Ort von correspAction[@type="${a.type}"] übernommen.`);
    } catch (e) {
      toast(e.message, true);
      select.disabled = false;
    }
  });
}

function rawEditorHtml(kind, idx, raw) {
  const key = `${kind}:${idx}`;
  const value = Object.prototype.hasOwnProperty.call(state.pendingRaw, key) ? state.pendingRaw[key] : raw;
  const isOpen = state.openRaw[kind].has(idx);
  const dirty = value !== raw;
  const rows = Math.min(14, Math.max(3, value.split("\n").length));
  return `
    <details class="raw-editor" ${isOpen ? "open" : ""} data-kind="${kind}" data-idx="${idx}">
      <summary>XML${dirty ? ' <span class="dirty-dot" title="ungespeicherte Änderung">●</span>' : ""}</summary>
      <textarea data-role="raw-textarea" spellcheck="false" rows="${rows}">${esc(value)}</textarea>
      <div class="card-actions">
        <button data-role="save-raw" type="button">Speichern</button>
        <button data-role="reset-raw" type="button">Zurücksetzen</button>
      </div>
    </details>`;
}

function wireRawEditor(card, kind, idx, raw) {
  const details = card.querySelector(".raw-editor");
  if (!details) return;
  const key = `${kind}:${idx}`;
  const textarea = details.querySelector('[data-role="raw-textarea"]');

  details.addEventListener("toggle", () => {
    if (details.open) state.openRaw[kind].add(idx);
    else state.openRaw[kind].delete(idx);
  });

  textarea.addEventListener("input", () => {
    if (textarea.value === raw) delete state.pendingRaw[key];
    else state.pendingRaw[key] = textarea.value;
    const dot = details.querySelector(".dirty-dot");
    const isDirty = textarea.value !== raw;
    if (isDirty && !dot) {
      details.querySelector("summary").insertAdjacentHTML(
        "beforeend", ' <span class="dirty-dot" title="ungespeicherte Änderung">●</span>');
    } else if (!isDirty && dot) {
      dot.remove();
    }
  });

  details.querySelector('[data-role="save-raw"]').addEventListener("click", async (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    const btn = ev.currentTarget;
    btn.disabled = true;
    try {
      const data = await apiPost(`/api/file/${state.currentId}/raw`, {
        kind, index: idx, xml: textarea.value,
      });
      state.file = data;
      delete state.pendingRaw[key];
      state.openRaw[kind].add(idx);
      render();
      toast(`${kind === "stamp" ? "Stempel" : "correspAction"} #${idx}: XML gespeichert.`);
    } catch (e) {
      toast(e.message, true);
    } finally {
      btn.disabled = false;
    }
  });

  details.querySelector('[data-role="reset-raw"]').addEventListener("click", (ev) => {
    ev.preventDefault();
    ev.stopPropagation();
    delete state.pendingRaw[key];
    textarea.value = raw;
    const dot = details.querySelector(".dirty-dot");
    if (dot) dot.remove();
  });
}

function createStampCard(s) {
  const card = document.createElement("div");
  card.className = "card stamp-card" + (state.activeStamp === s.index ? " active" : "");
  const dStr = dateStr(s.date);
  const placeStr = s.place && s.place.text ? s.place.text : null;

  const options = ACTION_TYPE_ORDER
    .map((t) => `<option value="${t}" ${t === (s.suggestedType || "transmitted") ? "selected" : ""}>${esc(t)}</option>`)
    .join("");

  card.innerHTML = `
    <div class="card-head">
      ${stampTypeSelectHtml(s)}
      <span class="card-n">Stempel Nr. ${esc(s.n ?? "?")}</span>
    </div>
    <div class="card-body">
      <div>${placeStr ? esc(placeStr) : '<span class="empty-field">kein Ort</span>'}</div>
      <div>${dStr ? esc(dStr) : '<span class="empty-field">kein Datum</span>'}${s.time ? " · " + esc(s.time) + " Uhr" : ""}
        ${s.dateHasGap ? ' <span class="date-flag date-flag-gap" title="Lücke (gap) im Datum">gap</span>' : ""}
        ${s.dateHasSupplied ? ' <span class="date-flag date-flag-supplied" title="Teil des Datums ergänzt (supplied)">supplied</span>' : ""}
      </div>
    </div>
    ${attrChipsHtml(s.attrs)}
    <div class="card-actions">
      <select data-role="targetType" ${!s.suggestedType && !ACTION_TYPE_ORDER.length ? "disabled" : ""}>${options}</select>
      <button data-role="insert">+ als neue correspAction einfügen</button>
    </div>
    <div class="hint">${state.activeStamp === s.index
      ? "aktiv – rechts eine correspAction anklicken, um Datum/Ort zu übernehmen"
      : "anklicken, um mit einer correspAction zu matchen"}</div>
    ${rawEditorHtml("stamp", s.index, s.raw)}
  `;

  wireStampTypeSelect(card, s);

  card.addEventListener("click", (ev) => {
    if (ev.target.closest(".card-actions, .raw-editor, .badge-select")) return; // Klicks in Formularzeile/XML-Editor/Typ-Auswahl nicht als Auswahl werten
    state.activeStamp = state.activeStamp === s.index ? null : s.index;
    render();
  });

  card.querySelector('[data-role="insert"]').addEventListener("click", async (ev) => {
    ev.stopPropagation();
    const select = card.querySelector('[data-role="targetType"]');
    const targetType = select.value;
    const btn = ev.currentTarget;

    // Stempel-Datum mit einer Lücke (gap): statt automatisch zu normieren
    // (das Datum könnte ja gerade deshalb unsicher sein) vorher nachfragen.
    const body = { stampIndex: s.index, targetType };
    if (s.dateHasGap) {
      const entered = window.prompt(
        "Der Stempel hat eine Lücke (gap) im Datum. Datum für die neue correspAction eingeben, " +
        "oder Feld leeren/Abbrechen für kein <date>-Element:",
        s.dateNormalizedPreview || ""
      );
      body.dateOverride = (entered == null || entered.trim() === "") ? null : entered.trim();
    }

    btn.disabled = true;
    try {
      const data = await apiPost(`/api/file/${state.currentId}/insert`, body);
      state.file = data;
      render();
      const dateNote = "dateOverride" in body
        ? (body.dateOverride === null ? " (ohne Datum)" : ` (Datum: "${body.dateOverride}")`)
        : "";
      toast(`Neue correspAction[@type="${targetType}"] aus Stempel Nr. ${s.n} eingefügt${dateNote}.`);
    } catch (e) {
      toast(e.message, true);
    } finally {
      btn.disabled = false;
    }
  });

  wireRawEditor(card, "stamp", s.index, s.raw);
  return card;
}

function createActionCard(a) {
  const card = document.createElement("div");
  const mapped = findMappedStamps(a.type);
  const activeStamp = state.activeStamp != null
    ? state.file.stamps.find((s) => s.index === state.activeStamp)
    : null;
  const isSuggestedForActive = activeStamp && activeStamp.suggestedType === a.type;
  card.className = "card action-card"
    + (isSuggestedForActive ? " suggested" : "")
    + (activeStamp ? " matchable" : "");

  const persons = a.persons.map((p) => esc(p.text)).join(", ");

  let compareHtml = "";
  if (mapped.length === 1) {
    const m = mapped[0];
    const dOk = fieldsMatch(a.date, m.date);
    const pOk = placesMatch(a.place, m.place);
    if (dOk && pOk) {
      compareHtml = `<div class="hint" style="color:var(--ok)">✓ stimmt mit Stempel Nr. ${esc(m.n)} überein</div>`;
    } else {
      const mDate = dateStr(m.date) || "–";
      const mPlace = m.place && m.place.text ? m.place.text : "–";
      compareHtml = `
        <div class="hint" style="color:var(--warn)">⚠ Stempel Nr. ${esc(m.n)}: ${esc(mPlace)}, ${esc(mDate)}</div>
        <div class="card-actions">
          <button data-role="quicksync" data-stamp="${m.index}">aus Stempel Nr. ${esc(m.n)} übernehmen</button>
        </div>`;
    }
  } else if (mapped.length > 1) {
    compareHtml = `<div class="hint">${mapped.length} Stempel vom Typ „${esc(mapped[0].type)}“ vorhanden – Auswahl links per Klick.</div>`;
  }

  // Titel + correspAction[@type='sent']/date als "[Vortag oder Tag]"
  // markieren (XSLT brief_normalisierung_datum-plusminus-1-tag.xsl)
  const dateUncertainHtml = a.type === "sent" ? `
    <div class="card-actions">
      <button data-role="date-uncertain" ${a.date && a.date.when ? "" : "disabled"}
        title="Titel und dieses Datum als '[Vortag oder Tag]' markieren, @when durch @notBefore/@notAfter ersetzen (XSLT: brief_normalisierung_datum-plusminus-1-tag.xsl)">
        Datum unsicher (±1 Tag)
      </button>
    </div>` : "";

  card.innerHTML = `
    <div class="card-head">
      ${badgeHtml(a.type)}
    </div>
    <div class="card-body">
      <div>${persons ? esc(persons) : '<span class="empty-field">keine Person</span>'}</div>
      <div>${placeSelectHtml(a)}</div>
      <div>${dateWithWeekdayHtml(a.date)}</div>
    </div>
    ${attrChipsHtml(a.attrs)}
    ${compareHtml}
    ${dateUncertainHtml}
    ${rawEditorHtml("correspAction", a.index, a.raw)}
  `;

  wirePlaceSelect(card, a);

  const dateUncertainBtn = card.querySelector('[data-role="date-uncertain"]');
  if (dateUncertainBtn) {
    dateUncertainBtn.addEventListener("click", async (ev) => {
      ev.stopPropagation();
      dateUncertainBtn.disabled = true;
      try {
        const data = await apiPost(`/api/file/${state.currentId}/date-uncertain`, {});
        state.file = data;
        render();
        toast(`Datum als "±1 Tag unsicher" markiert (Titel + correspAction[@type="sent"]).`);
      } catch (e) {
        toast(e.message, true);
        dateUncertainBtn.disabled = false;
      }
    });
  }

  if (activeStamp) {
    card.addEventListener("click", async (ev) => {
      if (ev.target.closest(".card-actions, .raw-editor, .place-select")) return;
      try {
        const data = await apiPost(`/api/file/${state.currentId}/update`, {
          stampIndex: activeStamp.index,
          actionIndex: a.index,
        });
        state.file = data;
        state.activeStamp = null;
        render();
        toast(`Datum/Ort aus Stempel Nr. ${activeStamp.n} in correspAction[@type="${a.type}"] übernommen.`);
      } catch (e) {
        toast(e.message, true);
      }
    });
  }

  const quickBtn = card.querySelector('[data-role="quicksync"]');
  if (quickBtn) {
    quickBtn.addEventListener("click", async (ev) => {
      ev.stopPropagation();
      quickBtn.disabled = true;
      try {
        const data = await apiPost(`/api/file/${state.currentId}/update`, {
          stampIndex: Number(quickBtn.dataset.stamp),
          actionIndex: a.index,
        });
        state.file = data;
        render();
        toast(`correspAction[@type="${a.type}"] aktualisiert.`);
      } catch (e) {
        toast(e.message, true);
        quickBtn.disabled = false;
      }
    });
  }

  wireRawEditor(card, "correspAction", a.index, a.raw);
  return card;
}

// ---------------------------------------------------------------------------
// Init
// ---------------------------------------------------------------------------
function updateNextBtnTitle() {
  el("nextBtn").title = state.editor
    ? `Nächster Kandidat (ergänzt vorher revisionDesc/change "${CHANGE_DATIERUNG_STEMPEL_TEXT}" als ${state.editor})`
    : "Nächster Kandidat";
}

function wireToolbar() {
  el("jumpBtn").addEventListener("click", () => loadFile(el("jumpInput").value));
  el("jumpInput").addEventListener("keydown", (ev) => {
    if (ev.key === "Enter") loadFile(el("jumpInput").value);
  });

  const editorSelect = el("editorSelect");
  editorSelect.value = state.editor;
  updateNextBtnTitle();
  editorSelect.addEventListener("change", async (ev) => {
    state.editor = ev.target.value;
    storeEditor(state.editor);
    updateNextBtnTitle();
    // sofort zum richtigen Startpunkt springen (SJ: allerletzter Brief,
    // MAM: allererster) statt nur die künftige Richtung umzustellen
    await refreshCandidatesAndFilter();
    if (state.filtered.length) {
      await loadFile(state.filtered[0].id);
    }
  });

  el("prevBtn").addEventListener("click", () => stepCandidate(-1));
  el("nextBtn").addEventListener("click", async () => {
    if (state.currentId && state.editor) {
      try {
        const idx = state.filtered.findIndex((c) => c.id === state.currentId);
        await apiPost(`/api/file/${state.currentId}/revision-change`, { who: state.editor });
        toast(`${state.currentId}: revisionDesc ergänzt ("${CHANGE_DATIERUNG_STEMPEL_TEXT}", ${state.editor}).`);
        // Datei ist ab jetzt "reviewed" und fällt aus der Warteschlange -
        // Liste frisch vom Server holen (nicht nur lokal patchen), damit
        // auch Briefe rausfallen, die MAM/SJ zwischenzeitlich in einer
        // anderen Session abgeschlossen hat, und an ungefähr der Stelle
        // weitermachen, an der der Brief eben noch stand
        await refreshCandidatesAndFilter();
        if (idx >= 0 && idx < state.filtered.length) {
          await loadFile(state.filtered[idx].id);
        } else if (state.filtered.length) {
          await loadFile(state.filtered[state.filtered.length - 1].id);
        } else {
          toast("Keine weiteren Kandidaten.");
        }
        return;
      } catch (e) {
        toast(e.message, true);
      }
    }
    stepCandidate(1);
  });
  el("mismatchOnly").addEventListener("change", (ev) => {
    state.mismatchOnly = ev.target.checked;
    applyFilter();
  });
  el("oxygenBtn").addEventListener("click", async () => {
    if (!state.currentId) return;
    try {
      await apiGet(`/api/open-oxygen/${state.currentId}`);
    } catch (e) {
      toast(e.message, true);
    }
  });
}

async function init() {
  wireToolbar();
  try {
    await loadCandidates();
    const first = state.filtered[0] || state.candidates[0];
    if (first) await loadFile(first.id);
  } catch (e) {
    setStatus(`Fehler beim Laden der Kandidatenliste: ${e.message}`, "err");
  }
}

init();
