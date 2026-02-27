# 🌟 Low Birth Weight (LBW) Prediction Using Machine Learning

**Authors:** Mohammad Ohid Ullah, Md Salek Miah  
**Affiliation:** Shahjalal University of Science and Technology (SUST), Department of Statistics  
**Emails:** ohid-sta@sust.edu, saleksta@gmail.com  
**ORCID (Salek Miah):** [0009-0005-5973-461X](https://orcid.org/0009-0005-5973-461X)  
**LinkedIn (Salek Miah):** [https://www.linkedin.com/in/md-salek-miah-b34309329/](https://www.linkedin.com/in/md-salek-miah-b34309329/)  
**Country / Focus:** Bangladesh & Nepal  
**Commit Name:** Final Q1 Journal Submission  

---

## 📌 Project Overview

This repository provides a **complete workflow for predicting Low Birth Weight (LBW)** in newborns using machine learning.  
The workflow is structured for **Q1 journal submission**, with professional figures, tables, and reproducible code.  

**Key Features:**

- Preprocessing of full datasets for Bangladesh and Nepal  
- Handling class imbalance using **SMOTE**  
- Feature selection using **Recursive Feature Elimination (RFE)**  
- Training and hyperparameter tuning of models:
  - Decision Tree (DT)  
  - Random Forest (RF)  
  - Logistic Regression (LR)  
  - Support Vector Machine (SVM)  
  - XGBoost  
- Evaluation metrics: Accuracy, Kappa, Recall/Sensitivity, Specificity, F1-Score, G-Mean, AUC-ROC  
- Feature importance analysis (DT & LR)  
- SHAP / Waterfall plots for interpretability  
- ROC and Precision-Recall curves for visual comparison  

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
