<div align="center">

<!-- ANIMATED HEADER -->
<img src="https://capsule-render.vercel.app/api?type=waving&color=0:0d1117,50:00d4ff,100:7c3aed&height=200&section=header&text=LBW%20Prediction&fontSize=50&fontColor=ffffff&fontAlignY=38&desc=Bangladesh%20%26%20Nepal%20%7C%20Machine%20Learning%20for%20Neonatal%20Health&descAlignY=58&descSize=16&animation=fadeIn" width="100%"/>

<!-- CHAMPION BADGE -->
<br/>

[![🏆  Research](https://img.shields.io/badge/🏆-ICPC--Grade%20ML%20Research-f59e0b?style=for-the-badge&labelColor=0d1117)](https://github.com)
[![Journal](https://img.shields.io/badge/📄-Q1%20Journal%20Ready-00d4ff?style=for-the-badge&labelColor=0d1117)](https://github.com)
[![MIT License](https://img.shields.io/badge/License-MIT-10b981?style=for-the-badge&labelColor=0d1117)](LICENSE)

<br/>

<!-- TECH STACK BADGES -->
![R](https://img.shields.io/badge/R%204.2+-276DC3?style=flat-square&logo=r&logoColor=white)
![XGBoost](https://img.shields.io/badge/XGBoost-FF6600?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PC9zdmc+&logoColor=white)
![Machine Learning](https://img.shields.io/badge/Machine%20Learning-7c3aed?style=flat-square&logo=scikit-learn&logoColor=white)
![SMOTE](https://img.shields.io/badge/SMOTE-ef4444?style=flat-square&logoColor=white)
![SHAP](https://img.shields.io/badge/SHAP%20XAI-10b981?style=flat-square&logoColor=white)
![RFE](https://img.shields.io/badge/RFE%20Selection-f59e0b?style=flat-square&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=flat-square&logo=github&logoColor=white)

<br/><br/>

<!-- STATS ROW -->
<table>
<tr>
<td align="center"><img src="https://img.shields.io/badge/5-ML%20MODELS-00d4ff?style=for-the-badge&labelColor=0d1117"/></td>
<td align="center"><img src="https://img.shields.io/badge/2-COUNTRIES-7c3aed?style=for-the-badge&labelColor=0d1117"/></td>
<td align="center"><img src="https://img.shields.io/badge/7%2B-EVAL%20METRICS-10b981?style=for-the-badge&labelColor=0d1117"/></td>
<td align="center"><img src="https://img.shields.io/badge/Q1-JOURNAL%20READY-f59e0b?style=for-the-badge&labelColor=0d1117"/></td>
</tr>
</table>

</div>

---

## 🧑‍🔬 Authors & Affiliations

<table>
<tr>
<td>

**Mohammad Ohid Ullah**
- 🏛️ Dept. of Statistics, Shahjalal University of Science & Technology
- 📧 [ohid-sta@sust.edu](mailto:ohid-sta@sust.edu)

</td>
<td>

**Md Salek Miah**
- 🏛️ Dept. of Statistics, Shahjalal University of Science & Technology
- 📧 [saleksta@gmail.com](mailto:saleksta@gmail.com)
- 🔗 [LinkedIn](https://www.linkedin.com/in/md-salek-miah-b34309329/)
- 🆔 ORCID: `0009-0005-5973-461X`

</td>
</tr>
</table>

> 🌍 **Country / Focus:** Bangladesh & Nepal &nbsp;|&nbsp; 📌 **Commit:** Final Q1 Journal Submission

---

## 🌟 Project Overview

> A **complete, reproducible workflow** for predicting Low Birth Weight (LBW) in newborns using machine learning — designed for South Asian demographic & health survey data.

<div align="center">

| Feature | Details |
|:---|:---|
| 🧬 **Datasets** | Full Bangladesh & Nepal DHS data (`.dta` format) |
| ⚖️ **Imbalance Handling** | SMOTE (Synthetic Minority Oversampling Technique) |
| 🎯 **Feature Selection** | Recursive Feature Elimination (RFE) |
| 🤖 **Models Trained** | DT · RF · LR · SVM · XGBoost |
| 📊 **Evaluation** | Accuracy · Kappa · Sensitivity · Specificity · F1 · G-Mean · AUC-ROC |
| 🔍 **Interpretability** | SHAP Waterfall Plots · Feature Importance |
| 📈 **Visualization** | ROC Curves · Precision-Recall Curves |
| 🏆 **Output Format** | Q1 Journal Ready (300 DPI PNG + CSV Tables) |

</div>

---

## ⚙️ ML Pipeline

```
┌─────────────┐   ┌──────────────┐   ┌────────┐   ┌────────────┐   ┌─────────────┐   ┌──────────┐   ┌─────────────┐
│ 01          │ → │ 02           │ → │ 03     │ → │ 04         │ → │ 05          │ → │ 06       │ → │ 07          │
│ Data        │   │ Preprocessing│   │ SMOTE  │   │ RFE Select │   │ Train/Tune  │   │ Evaluate │   │ SHAP/Export │
│ Ingestion   │   │              │   │        │   │            │   │             │   │          │   │             │
└─────────────┘   └──────────────┘   └────────┘   └────────────┘   └─────────────┘   └──────────┘   └─────────────┘
```

---

## 🤖 Models Benchmarked

<div align="center">

| Model | Abbreviation | Hyperparameter Tuning |
|:---:|:---:|:---:|
| Decision Tree | `DT` | ✅ Grid Search |
| Random Forest | `RF` | ✅ Grid Search |
| Logistic Regression | `LR` | ✅ Regularization |
| Support Vector Machine | `SVM` | ✅ Kernel + C tuning |
| XGBoost | `XGB` | ✅ Full HPO |

</div>

---

## 📊 Evaluation Metrics

<div align="center">

| Metric | Description | Range | Best For |
|:---|:---|:---:|:---|
| **Accuracy** | Overall correct predictions | 0 – 1 | Balanced datasets |
| **Kappa** | Agreement beyond chance | -1 – 1 | Imbalanced classes |
| **Sensitivity** | True LBW detection rate | 0 – 1 | LBW class recall |
| **Specificity** | True normal detection rate | 0 – 1 | Normal class |
| **F1-Score** | Harmonic mean (precision + recall) | 0 – 1 | Imbalanced data |
| **G-Mean** | √(Sensitivity × Specificity) | 0 – 1 | Imbalanced data |
| **AUC-ROC** | Area under ROC curve | 0 – 1 | Model ranking |

</div>

---

## 🗂 Repository Structure

```
LBW-Prediction/
│
├── 📄 README.md
├── 📜 LBW_Prediction.R          ← Full R workflow: preprocessing, modeling, evaluation
│
├── 📁 data/
│   ├── 🗃️  bangladesh_data.dta   ← Full Bangladesh dataset
│   └── 🗃️  nepal_data.dta        ← Full Nepal dataset
│
├── 📁 figures/
│   ├── 🖼️  ROC_Curves.png
│   ├── 🖼️  PR_Curves.png
│   ├── 🖼️  DT_Feature_Importance.png
│   └── 🖼️  LR_Feature_Importance.png
│
├── 📁 tables/
│   └── 📊 Model_Performance.csv
│
└── 📋 LICENSE
```

---

## ⚡ Installation & Requirements

- **R version:** `>= 4.2`

```r
install.packages(c(
  "tidyverse",
  "caret",
  "Boruta",
  "xgboost",
  "randomForest",
  "e1071",      # SVM
  "shapley",
  "lime",
  "DMwR",       # SMOTE
  "pROC",
  "ROCR"
))
```

---

## 🔬 Key Highlights

- ✅ **Feature Selection:** Recursive Feature Elimination (RFE) with cross-validation
- ✅ **Imbalance Handling:** SMOTE for improved minority-class recall
- ✅ **Model Evaluation:** 7 metrics including G-Mean and AUC-ROC
- ✅ **Interpretability:** SHAP waterfall plots + feature importance charts
- ✅ **Visualization:** ROC & Precision-Recall curves for all models & countries
- ✅ **Reproducible:** Fully scripted in R with seed control

---

## 🌐 Research Impact

<div align="center">

```
🏥 AI-driven maternal & neonatal health screening
🌍 Early LBW identification across South Asia
🔬 Explainable ML applications in epidemiology
📢 Supports evidence-based health policy decisions
```

</div>

---

## 🧾 License

This project is licensed under the **MIT License** — open for **research & academic use**.

See [`LICENSE`](LICENSE) for full terms.

---

<div align="center">

<img src="https://capsule-render.vercel.app/api?type=waving&color=0:7c3aed,50:00d4ff,100:0d1117&height=100&section=footer" width="100%"/>

**Shahjalal University of Science and Technology**
*Department of Statistics · Bangladesh*

[![Made with R](https://img.shields.io/badge/Made%20with-R-276DC3?style=flat-square&logo=r&logoColor=white)](https://www.r-project.org/)
[![Research](https://img.shields.io/badge/Focus-Maternal%20%26%20Neonatal%20Health-00d4ff?style=flat-square)](https://github.com)
[![XAI](https://img.shields.io/badge/XAI-SHAP%20Explainability-7c3aed?style=flat-square)](https://github.com)

</div>
