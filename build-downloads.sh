#!/bin/bash
# Rebuild downloads.html from enabled entries in downloads-manifest.json.
# Usage:  bash build-downloads.sh
set -e
cd "$(dirname "$0")"
ROOT="$(pwd)"
OUT="$ROOT/downloads.html"

# MIME map by extension
mime_of() {
  case "$1" in
    *.pdf) echo "application/pdf";;
    *.md|*.markdown) echo "text/markdown";;
    *.txt) echo "text/plain";;
    *.json) echo "application/json";;
    *.csv) echo "text/csv";;
    *.zip) echo "application/zip";;
    *.docx) echo "application/vnd.openxmlformats-officedocument.wordprocessingml.document";;
    *.xlsx) echo "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet";;
    *.png) echo "image/png";;
    *.jpg|*.jpeg) echo "image/jpeg";;
    *) echo "application/octet-stream";;
  esac
}

# Build FILES array as JS
FILES_JS=""
while IFS=$'\t' read -r f section title desc name subitem; do
    [ -f "$f" ] || { echo "Missing download source: $f" >&2; exit 1; }
    b64="$(base64 -i "$f" | tr -d '\n')"
    mime="$(mime_of "$name")"
    FILES_JS+="  { section: $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$section"), title: $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$title"), desc: $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$desc"), filename: $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$name"), subitem: $subitem, type: $(python3 -c "import json,sys; print(json.dumps(sys.argv[1]))" "$mime"), b64: \"$b64\" },\n"
done < <(python3 -c 'import json; data=json.load(open("downloads-manifest.json")); [print("\t".join([*(str(item.get(k, "")) for k in ("source", "section", "title", "description", "filename")), str(bool(item.get("subitem"))).lower()])) for item in data["files"] if item.get("enabled")]')

# Emit the HTML — use a plain heredoc for the template, then inject FILES_JS
TEMPLATE_HEAD='<meta charset="utf-8">
<title>Project Downloads</title>
<link rel="icon" href="favicon.svg" type="image/svg+xml">
<link rel="stylesheet" href="https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,500;9..144,700&family=Inter:wght@400;500;600&display=swap">
<style>
:root { --ground:#f4f1e9; --panel:#fbf9f2; --ink:#211f27; --ink-soft:#524f5c; --muted:#918d95; --line:#e5dfd0; --line-strong:#cec7b3; --accent:#1f3b5c; --accent-soft:#e8eef6; }
@media (prefers-color-scheme: dark) { :root:not([data-theme="light"]) { --ground:#15171c; --panel:#1e2128; --ink:#ecebe4; --ink-soft:#b8bcc4; --muted:#85889a; --line:#2b2f38; --line-strong:#3a3f4a; --accent:#8bb3ea; --accent-soft:#22314b; } }
:root[data-theme="dark"] { --ground:#15171c; --panel:#1e2128; --ink:#ecebe4; --ink-soft:#b8bcc4; --muted:#85889a; --line:#2b2f38; --line-strong:#3a3f4a; --accent:#8bb3ea; --accent-soft:#22314b; }
:root[data-theme-name="modern"] { --ground:#f6f7fb; --panel:#ffffff; --ink:#111827; --ink-soft:#4b5563; --muted:#7c8493; --line:#e5e7eb; --line-strong:#cbd5e1; --accent:#4f46e5; --accent-soft:#eef2ff; }
@media (prefers-color-scheme: dark) { :root[data-theme-name="modern"]:not([data-theme="light"]) { --ground:#090c14; --panel:#111827; --ink:#f8fafc; --ink-soft:#cbd5e1; --muted:#8993a4; --line:#263244; --line-strong:#3c4a60; --accent:#a5b4fc; --accent-soft:#202a52; } }
:root[data-theme-name="modern"][data-theme="dark"] { --ground:#090c14; --panel:#111827; --ink:#f8fafc; --ink-soft:#cbd5e1; --muted:#8993a4; --line:#263244; --line-strong:#3c4a60; --accent:#a5b4fc; --accent-soft:#202a52; }
:root[data-theme-name="modern"] body, :root[data-theme-name="modern"] h1, :root[data-theme-name="modern"] h2, :root[data-theme-name="modern"] .section-head, :root[data-theme-name="modern"] .brand, :root[data-theme-name="modern"] .file-title { font-family: '"'"'Inter'"'"', sans-serif !important; letter-spacing: -0.01em; }
:root[data-theme-name="modern"] h1 { font-weight: 700; }
:root[data-theme-name="modern"] .file, :root[data-theme-name="modern"] .section { border-radius: 4px; }
* { box-sizing: border-box; }
body { margin:0; background:var(--ground); color:var(--ink-soft); font-family: '"'"'Inter'"'"', system-ui, sans-serif; font-size:15px; line-height:1.6; -webkit-font-smoothing:antialiased; }
.topnav { position:sticky; top:0; z-index:90; background:var(--panel); border-bottom:1px solid var(--line); padding:12px 32px; display:flex; align-items:center; gap:22px; flex-wrap:wrap; box-shadow:0 8px 28px rgba(20,30,50,.08); }
.topnav .brand { font-family: '"'"'Fraunces'"'"', serif; font-weight:600; font-size:15px; color:var(--ink); margin-right:6px; }
.topnav a { color:var(--ink-soft); text-decoration:none; font-size:13px; padding:4px 2px; border-bottom:2px solid transparent; }
.topnav a:hover { color:var(--ink); }
.topnav a.on { color:var(--accent); border-bottom-color:var(--accent); font-weight:600; }
.topnav .theme-controls { margin-left:auto; display:flex; gap:10px; align-items:center; }
.topnav .theme-controls .grp { display:flex; border:1px solid var(--line-strong); border-radius:5px; overflow:hidden; }
.topnav .theme-controls .grp button { background:transparent; border:none; color:var(--muted); font:inherit; font-size:11px; padding:4px 8px; cursor:pointer; }
.topnav .theme-controls .grp button.on { background:var(--accent); color:var(--panel); }
.wrap { max-width:900px; margin:0 auto; padding:32px 32px 100px; }
header { margin-bottom:28px; }
.eyebrow { font-size:11px; letter-spacing:0.14em; text-transform:uppercase; color:var(--muted); margin-bottom:8px; }
h1 { font-family: '"'"'Fraunces'"'"', serif; font-weight:500; font-size:32px; color:var(--ink); margin:0 0 8px; letter-spacing:-0.015em; }
.sub { color:var(--ink-soft); max-width:62ch; }
.section { margin-top:28px; }
.section-head { font-family: '"'"'Fraunces'"'"', serif; font-size:12px; letter-spacing:0.14em; text-transform:uppercase; color:var(--accent); margin-bottom:10px; }
.file { background:var(--panel); border:1px solid var(--line); border-radius:10px; padding:16px 18px; margin-bottom:10px; display:grid; grid-template-columns:1fr auto; gap:14px; align-items:center; }
.file.parent { margin-bottom:0; border-radius:10px 10px 0 0; }
.file.subitem { margin:0; border-top-style:dashed; border-radius:0; background:var(--accent-soft); box-shadow:none; }
.file.subitem.last { margin-bottom:10px; border-radius:0 0 10px 10px; }
.file-kind { display:inline-block; margin-bottom:5px; color:var(--accent); font-size:10px; font-weight:700; letter-spacing:.12em; text-transform:uppercase; }
.file-title { font-family: '"'"'Fraunces'"'"', serif; font-weight:600; font-size:15px; color:var(--ink); margin-bottom:2px; }
.file-desc { font-size:13px; color:var(--ink-soft); margin-bottom:4px; }
.file-meta { font-size:11.5px; color:var(--muted); letter-spacing:0.04em; text-transform:uppercase; font-weight:500; }
.file button { background:var(--accent); color:var(--panel); border:none; padding:8px 14px; border-radius:6px; font:inherit; font-weight:600; font-size:13px; cursor:pointer; }
:root[data-theme-name="modern"] .file button, :root[data-theme="dark"] .file button, :root:not([data-theme="light"]) .file button { color:var(--ground); }
.file button:hover { opacity:0.9; }
.file button:disabled { opacity:0.5; cursor:default; }
.file, button { transition:border-color .18s ease, background-color .18s ease, box-shadow .18s ease, transform .18s ease; }
.file { box-shadow:0 12px 30px rgba(20,30,50,.06); }
.file:hover { transform:translateY(-1px); box-shadow:0 16px 34px rgba(20,30,50,.09); }
.notice { padding:10px 14px; background:var(--accent-soft); border-radius:8px; font-size:12.5px; color:var(--ink-soft); margin-top:12px; }
@media (max-width:640px) { .file { grid-template-columns:1fr; } }
</style>
<nav class="topnav">
  <div class="brand">Maldives Building Regulations Hub</div>
  <a href="building-reg.html">Guideline</a>
  <a href="islands-checker.html">Rules Checker</a>
  <a href="checklist.html">Checklist</a>
  <a class="on" href="#">Downloads</a>
  <a href="disclaimer.html">Disclaimer</a>
  <div class="theme-controls">
    <div class="grp" id="theme-name-picker">
      <button data-name="classic">Classic</button>
      <button data-name="modern">Modern</button>
    </div>
    <div class="grp" id="theme-mode-picker">
      <button data-mode="light">☀</button>
      <button data-mode="system">◑</button>
      <button data-mode="dark">☾</button>
    </div>
  </div>
</nav>
<div class="wrap">
<header>
  <div class="eyebrow">Project files</div>
  <h1>Downloads</h1>
  <div class="sub">Source files used to build this navigator, plus a JSON export of your current project state.</div>
</header>
<div id="content"></div>
<footer class="site-footer">An independent, unofficial resource by <strong>Arkido Studio</strong>. AI-assisted content may contain errors. <a href="disclaimer.html">Read the disclaimer</a> · <a href="https://github.com/arkidostudio/maldives-building-regulations/issues/new?template=correction.yml" target="_blank" rel="noopener">Report a correction</a></footer>
</div>
<script>
const FILES = [
'

TEMPLATE_TAIL='const content = document.getElementById("content");
const bySec = {};
FILES.forEach((f) => { (bySec[f.section] = bySec[f.section] || []).push(f); });
function b64ToBlob(b64, type) { const bin = atob(b64); const bytes = new Uint8Array(bin.length); for (let i = 0; i < bin.length; i++) bytes[i] = bin.charCodeAt(i); return new Blob([bytes], { type }); }
function browserSave(filename, blob) { const url = URL.createObjectURL(blob); const a = document.createElement("a"); a.href = url; a.download = filename; a.click(); setTimeout(() => URL.revokeObjectURL(url), 1000); }
function fmtSize(bytes) { if (bytes < 1024) return bytes + " B"; if (bytes < 1024*1024) return (bytes/1024).toFixed(1) + " KB"; return (bytes/1024/1024).toFixed(2) + " MB"; }
Object.entries(bySec).forEach(([sec, files]) => {
  const s = document.createElement("div"); s.className = "section";
  const h = document.createElement("div"); h.className = "section-head"; h.textContent = sec; s.appendChild(h);
  files.forEach((f, index) => {
    const size = Math.floor(f.b64.length * 0.75);
    const isParent = !f.subitem && files[index + 1]?.subitem;
    const isLastSubitem = f.subitem && !files[index + 1]?.subitem;
    const row = document.createElement("div");
    row.className = "file" + (isParent ? " parent" : "") + (f.subitem ? " subitem" : "") + (isLastSubitem ? " last" : "");
    row.innerHTML = `<div>${f.subitem ? `<div class="file-kind">Amendment</div>` : ""}<div class="file-title">${f.title}</div>${f.desc ? `<div class="file-desc">${f.desc}</div>` : ""}<div class="file-meta">${f.filename} · ${fmtSize(size)}</div></div>`;
    const btn = document.createElement("button"); btn.textContent = "Download";
    btn.addEventListener("click", async () => {
      btn.disabled = true; btn.textContent = "Saving…";
      try { const blob = b64ToBlob(f.b64, f.type); browserSave(f.filename, blob); btn.textContent = "Saved ✓"; }
      catch (e) { btn.textContent = e.code === "cancelled" ? "Cancelled" : "Failed"; }
      setTimeout(() => { btn.disabled = false; btn.textContent = "Download"; }, 2000);
    });
    row.appendChild(btn); s.appendChild(row);
  });
  content.appendChild(s);
});
const jsonSec = document.createElement("div"); jsonSec.className = "section";
jsonSec.innerHTML = `<div class="section-head">Project state</div>`;
const jsonRow = document.createElement("div"); jsonRow.className = "file";
jsonRow.innerHTML = `<div><div class="file-title">Export project state as JSON</div><div class="file-desc">Bundles your Rules Checker inputs, Checklist ticks and Plot details into one .json file.</div><div class="file-meta">project.json</div></div>`;
const jsonBtn = document.createElement("button"); jsonBtn.textContent = "Export JSON";
jsonBtn.addEventListener("click", async () => {
  const project = { version: 1, exported: new Date().toISOString(), rulesChecker: safeJson(localStorage.getItem("islands-checker-v1")), checklist: safeJson(localStorage.getItem("islands-checklist-v1")), plotDetails: safeJson(localStorage.getItem("islands-project-details-v1")), professionalsRoster: safeJson(localStorage.getItem("islands-pro-roster-v1")) };
  const blob = new Blob([JSON.stringify(project, null, 2)], { type: "application/json" });
  jsonBtn.disabled = true; jsonBtn.textContent = "Saving…";
  try { browserSave("project.json", blob); jsonBtn.textContent = "Saved ✓"; }
  catch (e) { jsonBtn.textContent = e.code === "cancelled" ? "Cancelled" : "Failed"; }
  setTimeout(() => { jsonBtn.disabled = false; jsonBtn.textContent = "Export JSON"; }, 2000);
});
function safeJson(s) { try { return JSON.parse(s || "null"); } catch(e) { return null; } }
jsonRow.appendChild(jsonBtn); jsonSec.appendChild(jsonRow); content.appendChild(jsonSec);
const importBtn = document.createElement("button"); importBtn.textContent = "Import JSON"; importBtn.style.marginLeft = "6px";
const importFile = document.createElement("input"); importFile.type = "file"; importFile.accept = "application/json,.json"; importFile.hidden = true;
importBtn.addEventListener("click", () => importFile.click());
importFile.addEventListener("change", async () => {
  const file = importFile.files[0]; if (!file) return;
  try {
    const project = JSON.parse(await file.text());
    const entries = [["islands-checker-v1", project.rulesChecker], ["islands-checklist-v1", project.checklist], ["islands-project-details-v1", project.plotDetails], ["islands-pro-roster-v1", project.professionalsRoster]];
    if (!project || typeof project !== "object" || !entries.some(([, value]) => value && typeof value === "object")) throw new Error();
    entries.forEach(([key, value]) => { if (value && typeof value === "object") localStorage.setItem(key, JSON.stringify(value)); });
    location.reload();
  } catch(e) { alert("That file is not a valid Islands Navigator project export."); }
  finally { importFile.value = ""; }
});
jsonRow.append(importBtn, importFile);
const root = document.documentElement;
function applyTheme() { const name = localStorage.getItem("themeName") || "classic"; const mode = localStorage.getItem("themeMode") || "system"; if (name === "modern") root.setAttribute("data-theme-name", "modern"); else root.removeAttribute("data-theme-name"); if (mode === "light" || mode === "dark") root.setAttribute("data-theme", mode); else root.removeAttribute("data-theme"); document.querySelectorAll("#theme-name-picker button").forEach((b) => b.classList.toggle("on", b.dataset.name === name)); document.querySelectorAll("#theme-mode-picker button").forEach((b) => b.classList.toggle("on", b.dataset.mode === mode)); }
document.querySelectorAll("#theme-name-picker button").forEach((b) => { b.addEventListener("click", () => { try { localStorage.setItem("themeName", b.dataset.name); } catch(e) {} applyTheme(); }); });
document.querySelectorAll("#theme-mode-picker button").forEach((b) => { b.addEventListener("click", () => { try { localStorage.setItem("themeMode", b.dataset.mode); } catch(e) {} applyTheme(); }); });
applyTheme();
</script>
'

# Assemble
printf "%s" "$TEMPLATE_HEAD" > "$OUT"
printf "%b" "$FILES_JS" >> "$OUT"
printf "];\n" >> "$OUT"
printf "%s" "$TEMPLATE_TAIL" >> "$OUT"
echo "Wrote $OUT ($(wc -c < "$OUT") bytes)"
