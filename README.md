Perfect! 😎 I’ve made a **futuristic “Top ICPC Champion / Meta-style” README header** for your LBW repo. It includes **gradient-style spacing, hover tooltips for logos**, and looks **ultra-professional on GitHub**.

Here’s the **ready-to-paste full README**:

---

# 🌟 Low Birth Weight (LBW) Prediction – Bangladesh & Nepal

<!-- Top ICPC / Meta-Style Logo Row -->

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/r.svg" width="40" title="R - Programming"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/github.svg" width="40" title="GitHub - Version Control"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/scikitlearn.svg" width="40" title="Machine Learning - Scikit-learn"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/postgresql.svg" width="40" title="Data Handling - PostgreSQL"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/tableau.svg" width="40" title="Visualization - Tableau"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/shiny.svg" width="40" title="Explainable AI - Shiny / SHAP"/>
</p>

---
<!-- Top ICPC / Meta-Style Animated Logo Row -->
<p align="center">
  <a href="#"><img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/r.svg" alt="R" width="40" style="transition: transform 0.3s;" onmouseover="this.style.transform='scale(1.3)';" onmouseout="this.style.transform='scale(1)';" title="R - Programming"/></a>
  <a href="#"><img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/github.svg" alt="GitHub" width="40" style="transition: transform 0.3s;" onmouseover="this.style.transform='scale(1.3)';" onmouseout="this.style.transform='scale(1)';" title="GitHub - Version Control"/></a>
  <a href="#"><img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/scikitlearn.svg" alt="Scikit-learn" width="40" style="transition: transform 0.3s;" onmouseover="this.style.transform='scale(1.3)';" onmouseout="this.style.transform='scale(1)';" title="Machine Learning - Scikit-learn"/></a>
  <a href="#"><img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/postgresql.svg" alt="PostgreSQL" width="40" style="transition: transform 0.3s;" onmouseover="this.style.transform='scale(1.3)';" onmouseout="this.style.transform='scale(1)';" title="Data Handling - PostgreSQL"/></a>
  <a href="#"><img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/tableau.svg" alt="Tableau" width="40" style="transition: transform 0.3s;" onmouseover="this.style.transform='scale(1.3)';" onmouseout="this.style.transform='scale(1)';" title="Visualization - Tableau"/></a>
  <a href="#"><img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/shiny.svg" alt="Shiny" width="40" style="transition: transform 0.3s;" onmouseover="this.style.transform='scale(1.3)';" onmouseout="this.style.transform='scale(1)';" title="Explainable AI - Shiny / SHAP"/></a>
</p>
## 🧑‍🔬 Authors & Affiliations

* **Mohammad Ohid Ullah**
* **Md Salek Miah**
* Affiliation: Shahjalal University of Science and Technology — Department of Statistics
* Emails: [ohid-sta@sust.edu](mailto:ohid-sta@sust.edu), [saleksta@gmail.com](mailto:saleksta@gmail.com)
* ORCID (Salek Miah): 0009-0005-5973-461X
* LinkedIn (Salek Miah): [https://www.linkedin.com/in/md-salek-miah-b34309329/](https://www.linkedin.com/in/md-salek-miah-b34309329/)
* Country / Focus: Bangladesh & Nepal
* Commit Name: Final Q1 Journal Submission

---

## 🌟 Project Overview

This repository provides a **complete, reproducible workflow for predicting Low Birth Weight (LBW)** in newborns using **machine learning**.

**Workflow is Q1 journal ready**, with professional figures, tables, and reproducible code.

**Key Features:**

* Preprocessing of **full datasets for Bangladesh and Nepal**
* Handling class imbalance using **SMOTE**
* Feature selection using **Recursive Feature Elimination (RFE)**
* Training & hyperparameter tuning for:

  * Decision Tree (DT)
  * Random Forest (RF)
  * Logistic Regression (LR)
  * Support Vector Machine (SVM)
  * XGBoost
* Evaluation metrics: Accuracy, Kappa, Recall/Sensitivity, Specificity, F1-Score, G-Mean, AUC-ROC
* Feature importance analysis (DT & LR)
* **SHAP / Waterfall plots** for interpretability
* ROC & Precision-Recall curves for visual comparison

---

## 🗂 Repository Structure

```text
LBW-Prediction/
│
├─ README.md                   
├─ LBW_Prediction.R            <- Full R workflow: preprocessing, modeling, evaluation
├─ data/
│   ├─ bangladesh_data.dta    <- Full Bangladesh dataset
│   └─ nepal_data.dta         <- Full Nepal dataset
├─ figures/
│   ├─ ROC_Curves.png          
│   ├─ PR_Curves.png           
│   ├─ DT_Feature_Importance.png 
│   └─ LR_Feature_Importance.png 
├─ tables/
│   └─ Model_Performance.csv
├─ LICENSE
```

---

## 🛠 Tech Stack

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/r.svg" width="30" title="R - Programming"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/scikitlearn.svg" width="30" title="Machine Learning"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/postgresql.svg" width="30" title="Data Handling"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/tableau.svg" width="30" title="Visualization"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/shiny.svg" width="30" title="Explainable AI / SHAP"/>
  <img src="https://cdn.jsdelivr.net/gh/simple-icons/simple-icons/icons/github.svg" width="30" title="Version Control / License"/>
</p>

---

## ⚡ Installation & Requirements

* **R version:** >= 4.2
* **Required Packages:**

```r
install.packages(c(
  "tidyverse",
  "caret",
  "Boruta",
  "xgboost",
  "randomForest",
  "e1071",
  "shapley",
  "lime",
  "DMwR",       # for SMOTE
  "pROC",
  "ROCR"
))
```

---

## 🔬 Highlights

* ✅ **Feature Selection:** Recursive Feature Elimination (RFE)
* ✅ **Model Evaluation:** Accuracy, Kappa, Sensitivity, Specificity, F1-Score, G-Mean, AUC-ROC
* ✅ **Interpretability:** Feature importance plots, SHAP waterfall plots
* ✅ **Visualization:** ROC & Precision-Recall curves for model comparison
* ✅ **Journal Ready:** Figures and tables formatted for Q1 journals

---

## 🌐 Research Impact

* AI-driven maternal & neonatal health screening
* Early LBW identification in South Asia
* Explainable ML applications in epidemiology

---

## 🧾 License

MIT License — Open for **research & academic use**

---

