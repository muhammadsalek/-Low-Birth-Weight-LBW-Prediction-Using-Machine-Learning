<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1.0"/>
<title>LBW Prediction – Bangladesh & Nepal</title>
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@400;700;900&family=JetBrains+Mono:wght@300;400;600&family=Sora:wght@300;400;600;700&display=swap" rel="stylesheet"/>
<style>
  :root {
    --bg: #020409;
    --surface: #0a0f1a;
    --surface2: #0f1828;
    --border: #1a2d4a;
    --accent: #00d4ff;
    --accent2: #7c3aed;
    --accent3: #10b981;
    --gold: #f59e0b;
    --red: #ef4444;
    --text: #e2e8f0;
    --muted: #64748b;
    --glow: 0 0 20px rgba(0,212,255,0.3);
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    background: var(--bg);
    color: var(--text);
    font-family: 'Sora', sans-serif;
    overflow-x: hidden;
    cursor: default;
  }

  /* PARTICLE CANVAS */
  #particles {
    position: fixed; top: 0; left: 0;
    width: 100%; height: 100%;
    pointer-events: none; z-index: 0;
    opacity: 0.4;
  }

  /* GRID OVERLAY */
  body::before {
    content: '';
    position: fixed; inset: 0;
    background-image:
      linear-gradient(rgba(0,212,255,0.03) 1px, transparent 1px),
      linear-gradient(90deg, rgba(0,212,255,0.03) 1px, transparent 1px);
    background-size: 50px 50px;
    pointer-events: none; z-index: 0;
  }

  .container {
    max-width: 1100px;
    margin: 0 auto;
    padding: 0 24px;
    position: relative; z-index: 1;
  }

  /* ─── HERO ─── */
  .hero {
    min-height: 100vh;
    display: flex; flex-direction: column;
    align-items: center; justify-content: center;
    text-align: center;
    padding: 80px 24px 60px;
    position: relative;
  }

  .champion-badge {
    display: inline-flex; align-items: center; gap: 8px;
    background: linear-gradient(135deg, #f59e0b22, #f59e0b44);
    border: 1px solid var(--gold);
    border-radius: 100px;
    padding: 6px 18px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: var(--gold);
    margin-bottom: 32px;
    animation: pulse-gold 2s ease-in-out infinite;
  }

  @keyframes pulse-gold {
    0%, 100% { box-shadow: 0 0 10px rgba(245,158,11,0.3); }
    50% { box-shadow: 0 0 25px rgba(245,158,11,0.6); }
  }

  .hero-title {
    font-family: 'Orbitron', sans-serif;
    font-size: clamp(2rem, 6vw, 4.5rem);
    font-weight: 900;
    line-height: 1.1;
    letter-spacing: -1px;
    background: linear-gradient(135deg, #fff 0%, var(--accent) 50%, var(--accent2) 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-bottom: 12px;
    animation: slide-in 0.8s ease-out;
  }

  .hero-subtitle {
    font-family: 'Orbitron', sans-serif;
    font-size: clamp(1rem, 3vw, 1.6rem);
    font-weight: 400;
    color: var(--accent);
    letter-spacing: 4px;
    text-transform: uppercase;
    margin-bottom: 24px;
    animation: slide-in 1s ease-out;
  }

  .hero-desc {
    max-width: 640px;
    color: var(--muted);
    font-size: 15px;
    line-height: 1.8;
    margin-bottom: 40px;
    animation: fade-in 1.2s ease-out;
  }

  @keyframes slide-in {
    from { opacity: 0; transform: translateY(30px); }
    to { opacity: 1; transform: translateY(0); }
  }
  @keyframes fade-in {
    from { opacity: 0; }
    to { opacity: 1; }
  }

  /* TECH ICONS ROW */
  .tech-row {
    display: flex; gap: 16px; flex-wrap: wrap;
    justify-content: center;
    margin-bottom: 48px;
    animation: fade-in 1.5s ease-out;
  }

  .tech-pill {
    display: flex; align-items: center; gap: 8px;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 8px;
    padding: 8px 16px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
    color: var(--accent);
    transition: all 0.3s;
    cursor: default;
  }

  .tech-pill:hover {
    border-color: var(--accent);
    background: rgba(0,212,255,0.08);
    transform: translateY(-3px);
    box-shadow: var(--glow);
  }

  .tech-pill span { font-size: 18px; }

  /* STATS ROW */
  .stats-row {
    display: grid; grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    margin-bottom: 80px;
    animation: fade-in 1.6s ease-out;
  }

  @media (max-width: 600px) { .stats-row { grid-template-columns: repeat(2, 1fr); } }

  .stat-card {
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    transition: all 0.3s;
    position: relative; overflow: hidden;
  }

  .stat-card::before {
    content: '';
    position: absolute; top: 0; left: 0; right: 0;
    height: 2px;
    background: linear-gradient(90deg, var(--accent), var(--accent2));
    opacity: 0;
    transition: opacity 0.3s;
  }

  .stat-card:hover { transform: translateY(-4px); border-color: var(--accent); }
  .stat-card:hover::before { opacity: 1; }

  .stat-num {
    font-family: 'Orbitron', monospace;
    font-size: 2rem; font-weight: 900;
    color: var(--accent);
    display: block;
  }

  .stat-label {
    font-size: 11px;
    color: var(--muted);
    letter-spacing: 1.5px;
    text-transform: uppercase;
    margin-top: 4px;
  }

  /* ─── SECTIONS ─── */
  section {
    padding: 80px 0;
    border-top: 1px solid var(--border);
  }

  .section-label {
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px;
    letter-spacing: 4px;
    color: var(--accent);
    text-transform: uppercase;
    margin-bottom: 8px;
  }

  .section-title {
    font-family: 'Orbitron', sans-serif;
    font-size: clamp(1.4rem, 3vw, 2.2rem);
    font-weight: 700;
    margin-bottom: 32px;
    color: #fff;
  }

  /* FEATURE GRID */
  .feature-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
    gap: 20px;
  }

  .feature-card {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 28px;
    transition: all 0.4s;
    position: relative; overflow: hidden;
  }

  .feature-card::after {
    content: '';
    position: absolute;
    inset: 0;
    background: radial-gradient(circle at 80% 20%, rgba(0,212,255,0.05), transparent 60%);
    opacity: 0;
    transition: opacity 0.3s;
  }

  .feature-card:hover {
    border-color: var(--accent);
    transform: translateY(-6px);
    box-shadow: 0 12px 40px rgba(0,212,255,0.1);
  }
  .feature-card:hover::after { opacity: 1; }

  .feature-icon {
    font-size: 2rem;
    margin-bottom: 14px;
  }

  .feature-title {
    font-family: 'Orbitron', sans-serif;
    font-size: 13px;
    font-weight: 700;
    color: var(--accent);
    letter-spacing: 1px;
    margin-bottom: 10px;
    text-transform: uppercase;
  }

  .feature-desc {
    font-size: 13px;
    color: var(--muted);
    line-height: 1.7;
  }

  /* MODEL CARDS */
  .model-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
    gap: 16px;
    margin-bottom: 32px;
  }

  .model-card {
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 12px;
    padding: 20px;
    text-align: center;
    transition: all 0.3s;
    cursor: default;
  }

  .model-card:hover {
    border-color: var(--accent2);
    box-shadow: 0 0 20px rgba(124,58,237,0.2);
    transform: scale(1.04);
  }

  .model-name {
    font-family: 'Orbitron', monospace;
    font-size: 11px;
    color: var(--accent2);
    letter-spacing: 2px;
    margin-bottom: 8px;
  }

  .model-full {
    font-size: 12px;
    color: var(--muted);
  }

  /* METRICS TABLE */
  .metrics-wrap {
    overflow-x: auto;
    border-radius: 12px;
    border: 1px solid var(--border);
  }

  table {
    width: 100%;
    border-collapse: collapse;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px;
  }

  thead { background: var(--surface2); }

  th {
    padding: 14px 18px;
    text-align: left;
    color: var(--accent);
    letter-spacing: 1.5px;
    text-transform: uppercase;
    font-size: 10px;
    border-bottom: 1px solid var(--border);
  }

  td {
    padding: 12px 18px;
    color: var(--text);
    border-bottom: 1px solid #0f1828;
    transition: background 0.2s;
  }

  tr:hover td { background: rgba(0,212,255,0.04); }
  tr:last-child td { border-bottom: none; }

  .badge-green {
    display: inline-block;
    background: rgba(16,185,129,0.15);
    color: var(--accent3);
    border-radius: 4px;
    padding: 2px 8px;
    font-size: 10px;
  }

  /* FILE TREE */
  .file-tree {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 16px;
    overflow: hidden;
  }

  .file-tree-header {
    background: var(--surface2);
    padding: 14px 20px;
    display: flex; align-items: center; gap: 8px;
    border-bottom: 1px solid var(--border);
  }

  .dot { width: 12px; height: 12px; border-radius: 50%; }
  .dot-r { background: #ef4444; }
  .dot-y { background: #f59e0b; }
  .dot-g { background: #10b981; }

  .file-tree-title {
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px; color: var(--muted);
    margin-left: 8px;
  }

  .file-tree-body {
    padding: 24px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 13px;
    line-height: 2;
  }

  .file-line { display: flex; align-items: center; gap: 10px; }
  .file-icon { font-size: 14px; }
  .file-name { color: var(--text); }
  .file-name.dir { color: var(--accent); }
  .file-comment { color: var(--muted); font-size: 11px; }
  .indent { padding-left: 28px; }
  .indent2 { padding-left: 56px; }

  /* CODE BLOCK */
  .code-block {
    background: var(--surface);
    border: 1px solid var(--border);
    border-radius: 12px;
    overflow: hidden;
  }

  .code-header {
    background: var(--surface2);
    padding: 12px 20px;
    display: flex; align-items: center; justify-content: space-between;
    border-bottom: 1px solid var(--border);
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px; color: var(--muted);
  }

  .copy-btn {
    background: transparent;
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 4px 12px;
    color: var(--accent);
    font-family: 'JetBrains Mono', monospace;
    font-size: 10px; cursor: pointer;
    transition: all 0.2s;
  }

  .copy-btn:hover {
    background: rgba(0,212,255,0.1);
    border-color: var(--accent);
  }

  pre {
    padding: 24px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 12px; line-height: 1.8;
    overflow-x: auto;
    color: #94a3b8;
  }

  .kw { color: #c084fc; }
  .fn { color: var(--accent); }
  .str { color: var(--accent3); }
  .cm { color: #4b5563; font-style: italic; }

  /* AUTHORS */
  .author-grid {
    display: grid; grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));
    gap: 20px;
  }

  .author-card {
    background: var(--surface2);
    border: 1px solid var(--border);
    border-radius: 16px;
    padding: 28px;
    display: flex; gap: 20px;
    transition: all 0.3s;
  }

  .author-card:hover {
    border-color: var(--accent2);
    box-shadow: 0 0 30px rgba(124,58,237,0.15);
  }

  .author-avatar {
    width: 56px; height: 56px;
    border-radius: 50%;
    background: linear-gradient(135deg, var(--accent), var(--accent2));
    display: flex; align-items: center; justify-content: center;
    font-family: 'Orbitron', sans-serif;
    font-size: 18px; font-weight: 900;
    color: #fff; flex-shrink: 0;
  }

  .author-name {
    font-family: 'Orbitron', sans-serif;
    font-size: 13px; font-weight: 700;
    color: #fff; margin-bottom: 4px;
  }

  .author-affil {
    font-size: 12px; color: var(--muted);
    margin-bottom: 8px;
  }

  .author-link {
    display: inline-flex; align-items: center; gap: 6px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px; color: var(--accent);
    text-decoration: none; border-bottom: 1px solid transparent;
    transition: border-color 0.2s;
  }

  .author-link:hover { border-color: var(--accent); }

  /* PIPELINE STEPS */
  .pipeline {
    display: flex; gap: 0;
    flex-wrap: nowrap;
    overflow-x: auto;
    padding-bottom: 8px;
  }

  .pipe-step {
    flex: 1; min-width: 120px;
    background: var(--surface2);
    border: 1px solid var(--border);
    border-right: none;
    padding: 20px 16px;
    text-align: center;
    position: relative;
    transition: all 0.3s;
  }

  .pipe-step:first-child { border-radius: 12px 0 0 12px; }
  .pipe-step:last-child { border-radius: 0 12px 12px 0; border-right: 1px solid var(--border); }

  .pipe-step::after {
    content: '→';
    position: absolute; right: -14px; top: 50%;
    transform: translateY(-50%);
    color: var(--accent); font-size: 20px;
    z-index: 1; background: var(--bg);
    padding: 2px;
  }
  .pipe-step:last-child::after { display: none; }

  .pipe-step:hover {
    background: rgba(0,212,255,0.06);
    border-color: var(--accent);
  }

  .pipe-num {
    font-family: 'Orbitron', monospace;
    font-size: 22px; font-weight: 900;
    color: var(--accent);
    display: block;
    line-height: 1;
    margin-bottom: 6px;
  }

  .pipe-label {
    font-size: 10px; color: var(--muted);
    text-transform: uppercase;
    letter-spacing: 1px;
  }

  /* FOOTER */
  footer {
    border-top: 1px solid var(--border);
    padding: 48px 0;
    text-align: center;
  }

  .footer-logo {
    font-family: 'Orbitron', sans-serif;
    font-size: 1.4rem; font-weight: 900;
    color: var(--accent);
    letter-spacing: 4px;
    margin-bottom: 12px;
  }

  .footer-text {
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px; color: var(--muted);
    letter-spacing: 2px;
  }

  .license-badge {
    display: inline-block;
    margin-top: 16px;
    background: rgba(16,185,129,0.1);
    border: 1px solid var(--accent3);
    border-radius: 100px;
    padding: 5px 16px;
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px; color: var(--accent3);
    letter-spacing: 2px;
  }

  /* SCROLLBAR */
  ::-webkit-scrollbar { width: 6px; height: 6px; }
  ::-webkit-scrollbar-track { background: var(--bg); }
  ::-webkit-scrollbar-thumb { background: var(--border); border-radius: 3px; }
  ::-webkit-scrollbar-thumb:hover { background: var(--accent); }

  /* NAV */
  nav {
    position: fixed; top: 0; left: 0; right: 0;
    z-index: 100;
    background: rgba(2,4,9,0.85);
    backdrop-filter: blur(20px);
    border-bottom: 1px solid var(--border);
    padding: 14px 0;
  }

  .nav-inner {
    max-width: 1100px;
    margin: 0 auto; padding: 0 24px;
    display: flex; align-items: center; justify-content: space-between;
  }

  .nav-brand {
    font-family: 'Orbitron', sans-serif;
    font-size: 14px; font-weight: 900;
    color: var(--accent);
    letter-spacing: 3px;
  }

  .nav-links {
    display: flex; gap: 24px;
    list-style: none;
  }

  .nav-links a {
    font-family: 'JetBrains Mono', monospace;
    font-size: 11px; letter-spacing: 1.5px;
    color: var(--muted); text-decoration: none;
    text-transform: uppercase;
    transition: color 0.2s;
  }

  .nav-links a:hover { color: var(--accent); }

  /* GLOW LINE SEPARATOR */
  .glow-line {
    height: 1px;
    background: linear-gradient(90deg, transparent, var(--accent), var(--accent2), transparent);
    opacity: 0.4;
    margin: 0 0 0 0;
  }

  /* ANIMATE ON SCROLL */
  .reveal {
    opacity: 0;
    transform: translateY(24px);
    transition: all 0.6s ease-out;
  }
  .reveal.visible {
    opacity: 1;
    transform: translateY(0);
  }
</style>
</head>
<body>

<canvas id="particles"></canvas>

<!-- NAV -->
<nav>
  <div class="nav-inner">
    <div class="nav-brand">LBW·PRED</div>
    <ul class="nav-links">
      <li><a href="#overview">Overview</a></li>
      <li><a href="#pipeline">Pipeline</a></li>
      <li><a href="#models">Models</a></li>
      <li><a href="#structure">Structure</a></li>
      <li><a href="#authors">Authors</a></li>
    </ul>
  </div>
</nav>

<!-- HERO -->
<div class="hero">
  <div class="champion-badge">🏆 Q1 Journal Submission · ICPC-Grade ML Research</div>

  <h1 class="hero-title">Low Birth Weight<br/>Prediction</h1>
  <div class="hero-subtitle">Bangladesh & Nepal</div>

  <p class="hero-desc">
    A complete, reproducible machine-learning workflow for predicting neonatal low birth weight in South Asia — featuring SMOTE, RFE feature selection, multi-model benchmarking, SHAP interpretability, and publication-ready figures.
  </p>

  <div class="tech-row">
    <div class="tech-pill"><span>🔵</span> R 4.2+</div>
    <div class="tech-pill"><span>🤖</span> XGBoost</div>
    <div class="tech-pill"><span>🌲</span> Random Forest</div>
    <div class="tech-pill"><span>📊</span> SHAP</div>
    <div class="tech-pill"><span>⚖️</span> SMOTE</div>
    <div class="tech-pill"><span>🎯</span> RFE</div>
    <div class="tech-pill"><span>📈</span> ROC / PR Curves</div>
  </div>

  <div class="stats-row">
    <div class="stat-card">
      <span class="stat-num">5</span>
      <div class="stat-label">ML Models</div>
    </div>
    <div class="stat-card">
      <span class="stat-num">2</span>
      <div class="stat-label">Countries</div>
    </div>
    <div class="stat-card">
      <span class="stat-num">7+</span>
      <div class="stat-label">Eval Metrics</div>
    </div>
    <div class="stat-card">
      <span class="stat-num">Q1</span>
      <div class="stat-label">Journal Ready</div>
    </div>
  </div>
</div>

<!-- OVERVIEW -->
<section id="overview">
  <div class="container">
    <div class="section-label">// 001</div>
    <h2 class="section-title">Project Overview</h2>

    <div class="feature-grid reveal">
      <div class="feature-card">
        <div class="feature-icon">🧬</div>
        <div class="feature-title">Data Preprocessing</div>
        <div class="feature-desc">Full pipelines for Bangladesh and Nepal DHS datasets. Handles missing data, encoding, and normalization with reproducible R scripts.</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon">⚖️</div>
        <div class="feature-title">Class Imbalance → SMOTE</div>
        <div class="feature-desc">Synthetic Minority Oversampling ensures balanced training sets, improving minority-class recall for LBW cases in skewed population data.</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon">🎯</div>
        <div class="feature-title">Feature Selection via RFE</div>
        <div class="feature-desc">Recursive Feature Elimination with cross-validation selects the most predictive maternal and socioeconomic features for each country.</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon">🔍</div>
        <div class="feature-title">Explainability — SHAP</div>
        <div class="feature-desc">Waterfall and beeswarm SHAP plots reveal which features drive individual predictions, supporting clinical and policy interpretation.</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon">📊</div>
        <div class="feature-title">ROC & PR Curves</div>
        <div class="feature-desc">Side-by-side model comparison curves for both countries. Precision-Recall curves highlight performance under class imbalance.</div>
      </div>
      <div class="feature-card">
        <div class="feature-icon">🏆</div>
        <div class="feature-title">Journal-Ready Output</div>
        <div class="feature-desc">All figures and tables are formatted to Q1 journal standards — 300 DPI PNG exports and CSV performance tables included.</div>
      </div>
    </div>
  </div>
</section>

<!-- PIPELINE -->
<section id="pipeline">
  <div class="container">
    <div class="section-label">// 002</div>
    <h2 class="section-title">ML Pipeline</h2>

    <div class="pipeline reveal">
      <div class="pipe-step">
        <span class="pipe-num">01</span>
        <div class="pipe-label">Data Ingestion</div>
      </div>
      <div class="pipe-step">
        <span class="pipe-num">02</span>
        <div class="pipe-label">Preprocessing</div>
      </div>
      <div class="pipe-step">
        <span class="pipe-num">03</span>
        <div class="pipe-label">SMOTE</div>
      </div>
      <div class="pipe-step">
        <span class="pipe-num">04</span>
        <div class="pipe-label">RFE Select</div>
      </div>
      <div class="pipe-step">
        <span class="pipe-num">05</span>
        <div class="pipe-label">Train / Tune</div>
      </div>
      <div class="pipe-step">
        <span class="pipe-num">06</span>
        <div class="pipe-label">Evaluate</div>
      </div>
      <div class="pipe-step">
        <span class="pipe-num">07</span>
        <div class="pipe-label">SHAP / Export</div>
      </div>
    </div>
  </div>
</section>

<!-- MODELS -->
<section id="models">
  <div class="container">
    <div class="section-label">// 003</div>
    <h2 class="section-title">Models & Metrics</h2>

    <div class="model-grid reveal">
      <div class="model-card">
        <div class="model-name">DT</div>
        <div class="model-full">Decision Tree</div>
      </div>
      <div class="model-card">
        <div class="model-name">RF</div>
        <div class="model-full">Random Forest</div>
      </div>
      <div class="model-card">
        <div class="model-name">LR</div>
        <div class="model-full">Logistic Regression</div>
      </div>
      <div class="model-card">
        <div class="model-name">SVM</div>
        <div class="model-full">Support Vector Machine</div>
      </div>
      <div class="model-card">
        <div class="model-name">XGB</div>
        <div class="model-full">XGBoost</div>
      </div>
    </div>

    <div class="metrics-wrap reveal">
      <table>
        <thead>
          <tr>
            <th>Metric</th>
            <th>Description</th>
            <th>Range</th>
            <th>Focus</th>
          </tr>
        </thead>
        <tbody>
          <tr><td>Accuracy</td><td>Overall correct predictions</td><td>0 – 1</td><td><span class="badge-green">Both</span></td></tr>
          <tr><td>Kappa</td><td>Agreement beyond chance</td><td>-1 – 1</td><td><span class="badge-green">Both</span></td></tr>
          <tr><td>Sensitivity</td><td>True LBW detection rate</td><td>0 – 1</td><td><span class="badge-green">LBW Class</span></td></tr>
          <tr><td>Specificity</td><td>True normal detection rate</td><td>0 – 1</td><td><span class="badge-green">Normal</span></td></tr>
          <tr><td>F1-Score</td><td>Harmonic mean of precision & recall</td><td>0 – 1</td><td><span class="badge-green">Imbalance</span></td></tr>
          <tr><td>G-Mean</td><td>Geometric mean of sensitivity & specificity</td><td>0 – 1</td><td><span class="badge-green">Imbalance</span></td></tr>
          <tr><td>AUC-ROC</td><td>Area under the ROC curve</td><td>0 – 1</td><td><span class="badge-green">Ranking</span></td></tr>
        </tbody>
      </table>
    </div>
  </div>
</section>

<!-- STRUCTURE -->
<section id="structure">
  <div class="container">
    <div class="section-label">// 004</div>
    <h2 class="section-title">Repository Structure</h2>

    <div style="display:grid;grid-template-columns:1fr 1fr;gap:24px;flex-wrap:wrap;">
      <div class="file-tree reveal">
        <div class="file-tree-header">
          <div class="dot dot-r"></div>
          <div class="dot dot-y"></div>
          <div class="dot dot-g"></div>
          <span class="file-tree-title">LBW-Prediction/</span>
        </div>
        <div class="file-tree-body">
          <div class="file-line"><span class="file-icon">📄</span><span class="file-name">README.md</span></div>
          <div class="file-line"><span class="file-icon">📜</span><span class="file-name">LBW_Prediction.R</span>&nbsp;<span class="file-comment">← main workflow</span></div>
          <div class="file-line"><span class="file-icon">📁</span><span class="file-name dir">data/</span></div>
          <div class="file-line indent"><span class="file-icon">🗃️</span><span class="file-name">bangladesh_data.dta</span></div>
          <div class="file-line indent"><span class="file-icon">🗃️</span><span class="file-name">nepal_data.dta</span></div>
          <div class="file-line"><span class="file-icon">📁</span><span class="file-name dir">figures/</span></div>
          <div class="file-line indent"><span class="file-icon">🖼️</span><span class="file-name">ROC_Curves.png</span></div>
          <div class="file-line indent"><span class="file-icon">🖼️</span><span class="file-name">PR_Curves.png</span></div>
          <div class="file-line indent"><span class="file-icon">🖼️</span><span class="file-name">DT_Feature_Importance.png</span></div>
          <div class="file-line indent"><span class="file-icon">🖼️</span><span class="file-name">LR_Feature_Importance.png</span></div>
          <div class="file-line"><span class="file-icon">📁</span><span class="file-name dir">tables/</span></div>
          <div class="file-line indent"><span class="file-icon">📊</span><span class="file-name">Model_Performance.csv</span></div>
          <div class="file-line"><span class="file-icon">📋</span><span class="file-name">LICENSE</span></div>
        </div>
      </div>

      <div class="code-block reveal">
        <div class="code-header">
          <span>install.R</span>
          <button class="copy-btn" onclick="copyCode()">COPY</button>
        </div>
        <pre id="code-content"><span class="fn">install.packages</span>(<span class="fn">c</span>(
  <span class="str">"tidyverse"</span>,
  <span class="str">"caret"</span>,
  <span class="str">"Boruta"</span>,
  <span class="str">"xgboost"</span>,
  <span class="str">"randomForest"</span>,
  <span class="str">"e1071"</span>,     <span class="cm"># SVM</span>
  <span class="str">"shapley"</span>,
  <span class="str">"lime"</span>,
  <span class="str">"DMwR"</span>,      <span class="cm"># SMOTE</span>
  <span class="str">"pROC"</span>,
  <span class="str">"ROCR"</span>
))

<span class="cm"># R version >= 4.2 required</span>
<span class="fn">sessionInfo</span>()</pre>
      </div>
    </div>
  </div>
</section>

<!-- AUTHORS -->
<section id="authors">
  <div class="container">
    <div class="section-label">// 005</div>
    <h2 class="section-title">Authors & Affiliations</h2>

    <div class="author-grid reveal">
      <div class="author-card">
        <div class="author-avatar">MO</div>
        <div>
          <div class="author-name">Mohammad Ohid Ullah</div>
          <div class="author-affil">Dept. of Statistics · Shahjalal University<br/>of Science & Technology</div>
          <a href="mailto:ohid-sta@sust.edu" class="author-link">✉ ohid-sta@sust.edu</a>
        </div>
      </div>
      <div class="author-card">
        <div class="author-avatar">MS</div>
        <div>
          <div class="author-name">Md Salek Miah</div>
          <div class="author-affil">Dept. of Statistics · Shahjalal University<br/>of Science & Technology</div>
          <a href="mailto:saleksta@gmail.com" class="author-link">✉ saleksta@gmail.com</a><br/>
          <a href="https://www.linkedin.com/in/md-salek-miah-b34309329/" class="author-link" target="_blank">🔗 LinkedIn Profile</a><br/>
          <span style="font-family:'JetBrains Mono',monospace;font-size:10px;color:var(--muted);">ORCID: 0009-0005-5973-461X</span>
        </div>
      </div>
    </div>
  </div>
</section>

<!-- GLOW SEPARATOR -->
<div class="glow-line"></div>

<!-- FOOTER -->
<footer>
  <div class="container">
    <div class="footer-logo">LBW · PRED</div>
    <div class="footer-text">BANGLADESH &amp; NEPAL · SHAHJALAL UNIVERSITY OF SCIENCE AND TECHNOLOGY</div>
    <div class="footer-text" style="margin-top:6px;color:#2d3748;">Focus: Maternal &amp; Neonatal Health · Explainable AI · Epidemiology</div>
    <div class="license-badge">MIT LICENSE · OPEN FOR RESEARCH &amp; ACADEMIC USE</div>
  </div>
</footer>

<script>
// ─── PARTICLES ───
const canvas = document.getElementById('particles');
const ctx = canvas.getContext('2d');
let particles = [];

function resize() {
  canvas.width = window.innerWidth;
  canvas.height = window.innerHeight;
}
resize();
window.addEventListener('resize', resize);

class Particle {
  constructor() { this.reset(); }
  reset() {
    this.x = Math.random() * canvas.width;
    this.y = Math.random() * canvas.height;
    this.vx = (Math.random() - 0.5) * 0.3;
    this.vy = (Math.random() - 0.5) * 0.3;
    this.size = Math.random() * 1.5 + 0.5;
    this.opacity = Math.random() * 0.5 + 0.1;
  }
  update() {
    this.x += this.vx; this.y += this.vy;
    if (this.x < 0 || this.x > canvas.width || this.y < 0 || this.y > canvas.height) this.reset();
  }
  draw() {
    ctx.save();
    ctx.globalAlpha = this.opacity;
    ctx.fillStyle = '#00d4ff';
    ctx.beginPath();
    ctx.arc(this.x, this.y, this.size, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }
}

for (let i = 0; i < 100; i++) particles.push(new Particle());

function connectParticles() {
  for (let i = 0; i < particles.length; i++) {
    for (let j = i + 1; j < particles.length; j++) {
      const dx = particles[i].x - particles[j].x;
      const dy = particles[i].y - particles[j].y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist < 100) {
        ctx.save();
        ctx.globalAlpha = (1 - dist / 100) * 0.08;
        ctx.strokeStyle = '#00d4ff';
        ctx.lineWidth = 0.5;
        ctx.beginPath();
        ctx.moveTo(particles[i].x, particles[i].y);
        ctx.lineTo(particles[j].x, particles[j].y);
        ctx.stroke();
        ctx.restore();
      }
    }
  }
}

function animateParticles() {
  ctx.clearRect(0, 0, canvas.width, canvas.height);
  particles.forEach(p => { p.update(); p.draw(); });
  connectParticles();
  requestAnimationFrame(animateParticles);
}
animateParticles();

// ─── REVEAL ON SCROLL ───
const reveals = document.querySelectorAll('.reveal');
const observer = new IntersectionObserver((entries) => {
  entries.forEach(e => { if (e.isIntersecting) e.target.classList.add('visible'); });
}, { threshold: 0.1 });
reveals.forEach(r => observer.observe(r));

// ─── COPY CODE ───
function copyCode() {
  const code = `install.packages(c(\n  "tidyverse",\n  "caret",\n  "Boruta",\n  "xgboost",\n  "randomForest",\n  "e1071",\n  "shapley",\n  "lime",\n  "DMwR",\n  "pROC",\n  "ROCR"\n))`;
  navigator.clipboard.writeText(code).then(() => {
    const btn = document.querySelector('.copy-btn');
    btn.textContent = 'COPIED!';
    btn.style.color = '#10b981';
    setTimeout(() => { btn.textContent = 'COPY'; btn.style.color = ''; }, 2000);
  });
}

// ─── SMOOTH SCROLL ───
document.querySelectorAll('a[href^="#"]').forEach(a => {
  a.addEventListener('click', e => {
    e.preventDefault();
    document.querySelector(a.getAttribute('href')).scrollIntoView({ behavior: 'smooth' });
  });
});

// ─── STAT COUNTER ANIMATION ───
function animateCounters() {
  document.querySelectorAll('.stat-num').forEach(el => {
    const target = el.textContent;
    const num = parseInt(target);
    if (!isNaN(num)) {
      let cur = 0;
      const step = Math.ceil(num / 30);
      const timer = setInterval(() => {
        cur = Math.min(cur + step, num);
        el.textContent = cur + (target.includes('+') ? '+' : '');
        if (cur >= num) clearInterval(timer);
      }, 40);
    }
  });
}

const heroObserver = new IntersectionObserver((entries) => {
  if (entries[0].isIntersecting) { animateCounters(); heroObserver.disconnect(); }
}, { threshold: 0.5 });
heroObserver.observe(document.querySelector('.stats-row'));
</script>
</body>
</html>
