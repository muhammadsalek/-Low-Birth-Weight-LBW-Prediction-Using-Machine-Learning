# 🌟 Low Birth Weight (LBW) Prediction Using Machine Learning

**Authors:** Mohammad Ohid Ullah, Md Salek Miah  
**Affiliation:** Shahjalal University of Science and Technology (SUST), Department of Statistics  
**Country / Focus:** Bangladesh & Nepal  
**Commit Name:** Final Q1 Journal Submission  

---

## 📌 Project Overview

This repository presents a **complete workflow for predicting Low Birth Weight (LBW)** in newborns using machine learning techniques.  
The workflow is structured for **Q1 journal submission**, with professional figures, tables, and reproducible code.  

**Highlights:**

- Preprocessing of full datasets for Bangladesh and Nepal  
- Handling class imbalance using **SMOTE**  
- Feature selection via **Recursive Feature Elimination (RFE)**  
- Training and hyperparameter tuning of models:
  - Decision Tree (DT)  
  - Random Forest (RF)  
  - Logistic Regression (LR)  
  - Support Vector Machine (SVM)  
  - XGBoost  
- Evaluation with metrics: Accuracy, Kappa, Recall/Sensitivity, Specificity, F1-Score, G-Mean, AUC-ROC  
- Feature importance analysis for DT and LR  
- SHAP / Waterfall plots for model interpretability  
- ROC and Precision-Recall curves for visual comparison  

---

## 🗂 Repository Structure

```text
LBW-Prediction/
│
├─ README.md                   
├─ LBW_Prediction.R            <- Full R workflow for preprocessing, modeling, evaluation
├─ data/
│   ├─ bangladesh_data.dta    <- Full Bangladesh dataset (preprocessing + train/test split in R)
│   └─ nepal_data.dta         <- Full Nepal dataset (preprocessing + train/test split in R)
├─ figures/
│   ├─ ROC_Curves.png          <- ROC curves for all models
│   ├─ PR_Curves.png           <- Precision-Recall curves
│   ├─ DT_Feature_Importance.png <- Decision Tree feature importance
│   └─ LR_Feature_Importance.png <- Logistic Regression feature importance
├─ tables/
│   └─ Model_Performance.csv   <- Summary of metrics for all models
