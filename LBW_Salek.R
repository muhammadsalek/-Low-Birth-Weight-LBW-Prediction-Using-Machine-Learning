








####  Required Packages ####

install.packages(c("caret","nnet", "randomForest", "ranger", "mlr3", "data.table", "themis","tidymodels", "shapviz"))





install.packages(c(
  "ggplot2",
  "pROC",
  "precrec",
  "DescTools",
  "ggpubr",
  "iml",
  "DALEX",
  "dplyr",
  "fmsb"
))




install.packages("MLmetrics")













# Load necessary package
if(!require(mice)) install.packages("mice")
library(mice)




install.packages(c("tidyverse","caret","Boruta","smotefamily","randomForest",
                   "rpart","e1071","xgboost","nnet","pROC","mccr"))






# Basic packages
install.packages(c("tidyverse", "mltools", "caret", "MLmetrics", "randomForest", "e1071", "rpart", "rpart.plot", "pROC"))




##### Using Machine Learning Approach #####


#### A. Load Packages ####
packages <- c("haven", "dplyr", "mice", "caret", "neuralnet", "e1071", "kknn",
              "randomForest", "rpart", "MASS", "xgboost", "adabag", "pROC")
install.packages(setdiff(packages, installed.packages()[,1]))
lapply(packages, library, character.only = TRUE)












# Load them
library(tidyverse)
library(caret)
library(MLmetrics)
library(randomForest)
library(e1071)
library(rpart)
library(rpart.plot)
library(pROC)







library(tidyverse)
library(caret)
library(Boruta)
library(smotefamily)       # for SMOTE
library(pROC)       # for AUROC
library(mccr)       # for MCC





library(tidyverse)
library(caret)
library(Boruta)
library(smotefamily)  # for SMOTE
library(randomForest)
library(rpart)
library(e1071)
library(xgboost)
library(nnet)
library(pROC)
library(mccr)



library(haven)
library(tidyverse)
library(caret)
library(Boruta)
library(smotefamily)  # for SMOTE
library(randomForest)
library(rpart)
library(e1071)
library(xgboost)
library(nnet)
library(pROC)
library(mccr)










# ---------------------------
# 1. Import libraries
# ---------------------------

# Data manipulation
library(dplyr)
library(data.table)   # similar to pandas for fast data frame operations
library(tidyr)

# ML preprocessing
library(caret)        # train/test split, preprocessing, cross-validation
library(recipes)      # for preprocessing pipelines
library(mltools)      # for one-hot encoding and other utilities

# Handling missing values
library(mice)         # imputation

# Feature selection
library(Boruta)       # Boruta feature selection

# Oversampling (SMOTE)
library(smotefamily)         # SMOTE implementation

# Machine Learning models
library(randomForest)       # Random Forest
         
library(rpart)              # Decision Tree
library(e1071)              # SVM, Naive Bayes
library(class)              # KNN
library(MASS)               # QDA
library(xgboost)            # XGBoost

# Metrics / evaluation
library(caret)       # accuracy, confusion matrix, F1 score
library(MLmetrics)   # F1_Score, Accuracy, etc.






#  Identifyting Risk Factors of skill Birth Assistance using Machine Learning Approach
# Pipeline :Clean & Impute → Split → Training only (SMOTE → Boruta → CV training) → Test only → Report


####  Load Data ####



data <- read_dta("F:\\Machine learning  Based\\BDHS\\Cross country\\LBW\\Data\\NP_clean.dta")



#### Explore ####



#  Basic Structure
cat("Dimensions:\n")
print(dim(data))

cat("\nVariable Names:\n")
print(names(data))

cat("\nStructure:\n")
str(data)

cat("\nSummary:\n")
summary(data)

#  Missing Values
cat("\nMissing Values Count:\n")
print(colSums(is.na(data)))

cat("\nMissing Values Percentage:\n")
print(round(colSums(is.na(data)) / nrow(data) * 100, 2))

#  Data Type Check
cat("\nVariable Classes:\n")
print(sapply(data, class))








library(dplyr)
library(haven)   # for read_dta
library(caret)   # for preprocessing utilities



df <- data  # rename for convenience


#### 1. Identify categorical columns ####

categorical_cols <- setdiff(colnames(df), "lbw")  # exclude target


#### 2. Convert labelled columns to factors ####

library(forcats)

# Convert all labelled numeric variables to factors using their Stata labels
df[categorical_cols] <- lapply(df[categorical_cols], function(x) {
  if (inherits(x, "labelled")) {
    as.factor(as_factor(x))
  } else {
    as.factor(x)
  }
})


#### 3. Impute missing values (mode / most frequent) ####

mode_impute <- function(x) {
  x[is.na(x)] <- names(sort(table(x), decreasing = TRUE))[1]
  return(x)
}

df[categorical_cols] <- lapply(df[categorical_cols], mode_impute)


#### 4. Encode categorical columns as numeric (0,1,2,...) ####

df[categorical_cols] <- lapply(df[categorical_cols], function(x) as.numeric(x) - 1)

#### 5. Map lbw to 0/1 ####

 #lbw variable is already 0/1 in the dataset
# Just ensure it's numeric
df$lbw <- as.numeric(df$lbw)


#### 6. Final check ####

cat("Preprocessing done!\n")
cat("Columns:", colnames(df), "\n")
cat("LBW value counts:\n")
print(table(df$lbw))



















library(caret)

#### Block 1: Define Outcome & Train-Test Split ####


# Outcome
y <- df$lbw

# Features (all categorical)
X <- df[, setdiff(colnames(df), "lbw")]

# Train-test split (80:20 stratified by lbw)
set.seed(42)
train_index <- createDataPartition(y, p = 0.8, list = FALSE, times = 1)

X_train_cat <- X[train_index, ]
X_test_cat  <- X[-train_index, ]
y_train     <- y[train_index]
y_test      <- y[-train_index]


# Final check

cat("Train shape:", dim(X_train_cat), "\n")
cat("Test shape:", dim(X_test_cat), "\n")

cat("Train LBW counts:\n")
print(table(y_train))

cat("Test LBW counts:\n")
print(table(y_test))
















library(Boruta)
library(randomForest)

# ---------------------------
# Block 2: Boruta Feature Selection
# ---------------------------

# 1️⃣ Ensure all features are numeric (Boruta in R works with numeric/factor)
X_train_numeric <- X_train_cat
X_test_numeric  <- X_test_cat
y_numeric       <- y_train  # already numeric 0/1

# 2️⃣ Initialize Random Forest for Boruta
set.seed(42)
rf_boruta <- randomForest(x = X_train_numeric,
                          y = as.factor(y_numeric),
                          ntree = 500,
                          importance = TRUE,
                          mtry = floor(sqrt(ncol(X_train_numeric))),
                          classwt = c('0' = sum(y_numeric==1)/length(y_numeric),  # balance weights
                                      '1' = sum(y_numeric==0)/length(y_numeric)))

# 3️⃣ Apply Boruta
set.seed(42)
boruta_result <- Boruta(x = X_train_numeric, y = as.factor(y_numeric),
                        doTrace = 2, maxRuns = 100)

# 4️⃣ Confirmed important features
selected_features <- getSelectedAttributes(boruta_result, withTentative = FALSE)
cat("Selected features by Boruta:\n")
print(selected_features)

# 5️⃣ Subset training and testing data to selected features
X_train_cat <- X_train_cat[, selected_features]
X_test_cat  <- X_test_cat[, selected_features]

# Optional: check dimensions
cat("X_train_cat dimensions after Boruta:", dim(X_train_cat), "\n")
cat("X_test_cat dimensions after Boruta:", dim(X_test_cat), "\n")



















library(caret)
library(randomForest)

# ---------------------------
# Block 2: Recursive Feature Elimination (RFE)
# ---------------------------

# 1️⃣ Prepare training data (numeric)
X_train_numeric <- X_train_cat
X_test_numeric  <- X_test_cat
y_numeric       <- as.factor(y_train)  # factor for classification

# 2️⃣ Define control function for RFE
set.seed(42)
ctrl <- rfeControl(functions = rfFuncs,  # Random Forest as estimator
                   method = "cv",       # cross-validation
                   number = 5,          # 5-fold CV
                   verbose = TRUE)

# 3️⃣ Apply RFE
# nFeatures = 20 (adjust as needed)
set.seed(42)
rfe_result <- rfe(x = X_train_numeric,
                  y = y_numeric,
                  sizes = 20,         # number of features to select
                  rfeControl = ctrl)

# 4️⃣ Get selected features
selected_features <- predictors(rfe_result)
cat("Selected features by RFE:\n")
print(selected_features)

# 5️⃣ Subset training and test sets to selected features
X_train_rfe <- X_train_cat[, selected_features, drop = FALSE]
X_test_rfe  <- X_test_cat[, selected_features, drop = FALSE]

# Optional: check dimensions
cat("X_train_rfe dimensions:", dim(X_train_rfe), "\n")
cat("X_test_rfe dimensions:", dim(X_test_rfe), "\n")










library(ggplot2)
library(gridExtra)
library(Boruta)
library(caret)

# ---------------------------
# Boruta plot
# ---------------------------
# Boruta already run as boruta_result
boruta_plot <- plot(boruta_result, las=2, cex.axis=0.7, main="Boruta Feature Importance")

# Note: plot() outputs to current device. To save to ggplot-like, extract importance:
boruta_imp <- attStats(boruta_result)
boruta_imp$Feature <- rownames(boruta_imp)
boruta_df <- boruta_imp[order(-boruta_imp$meanImp), ]
boruta_df$Feature <- factor(boruta_df$Feature, levels = rev(boruta_df$Feature))

p1 <- ggplot(boruta_df, aes(x = Feature, y = meanImp, fill = decision)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  labs(title = "Boruta Feature Importance", y = "Mean Importance") +
  theme_minimal()

# ---------------------------
# RFE plot
# ---------------------------
# rfe_result is your RFE output
rfe_df <- data.frame(Feature = rownames(rfe_result$fit$importance),
                     Importance = rfe_result$fit$importance[, 1])  # MeanDecreaseGini
rfe_df <- rfe_df[order(rfe_df$Importance, decreasing = TRUE), ]
rfe_df$Feature <- factor(rfe_df$Feature, levels = rev(rfe_df$Feature))

p2 <- ggplot(rfe_df[1:20, ], aes(x = Feature, y = Importance)) +
  geom_bar(stat = "identity", fill = "steelblue") +
  coord_flip() +
  labs(title = "RFE Feature Importance ", y = "Importance") +
  theme_minimal()

# ---------------------------
# Arrange side by side
# ---------------------------
library(gridExtra)
grid.arrange(p1, p2, ncol = 2)














library(ggplot2)
library(gridExtra)
library(Boruta)
library(caret)

# ---------------------------
# Boruta data preparation
# ---------------------------
boruta_imp <- attStats(boruta_result)
boruta_imp$Feature <- rownames(boruta_imp)
boruta_df <- boruta_imp[order(boruta_imp$meanImp, decreasing = TRUE), ]
boruta_df$Feature <- factor(boruta_df$Feature, levels = rev(boruta_df$Feature))
boruta_df$decision <- factor(boruta_df$decision, levels = c("Confirmed","Tentative","Rejected"))

p1 <- ggplot(boruta_df, aes(x = Feature, y = meanImp, fill = decision)) +
  geom_bar(stat = "identity") +
  coord_flip() +
  scale_fill_manual(values = c("Confirmed" = "#1b9e77", 
                               "Tentative" = "#d95f02", 
                               "Rejected" = "#7570b3")) +
  labs(title = "Boruta Feature Importance",
       y = "Mean Importance",
       x = NULL,
       fill = "Decision") +
  theme_minimal(base_size = 14) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 11))

# ---------------------------
# RFE data preparation
# ---------------------------
rfe_importance <- rfe_result$fit$importance
rfe_df <- data.frame(Feature = rownames(rfe_importance),
                     Importance = rfe_importance[, 1])
rfe_df <- rfe_df[order(rfe_df$Importance, decreasing = TRUE), ]
rfe_df$Feature <- factor(rfe_df$Feature, levels = rev(rfe_df$Feature))

p2 <- ggplot(rfe_df[1:20, ], aes(x = Feature, y = Importance)) +
  geom_bar(stat = "identity", fill = "#2c7fb8") +
  coord_flip() +
  labs(title = "RFE Feature Importance",
       y = "Importance",
       x = NULL) +
  theme_minimal(base_size = 14) +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank(),
        axis.text.y = element_text(size = 11))

# ---------------------------
# Arrange side by side
# ---------------------------
library(gridExtra)
grid.arrange(p1, p2, ncol = 2)









#### Smotefamily ####

library(smotefamily)
library(dplyr)

# ---------------------------
# Block 4: SMOTE for Training Data (smotefamily)
# ---------------------------

# 1️⃣ Prepare numeric training data
X_train_res <- X_train_rfe %>% mutate_all(as.numeric)  # ensure numeric
y_train_res <- as.numeric(as.character(y_train))       # numeric target

# Combine X and y into a data frame
train_res <- data.frame(X_train_res, lbw = y_train_res)  # <- convert to data frame!

# 2️⃣ Apply SMOTE
# K = 5 is default nearest neighbors
set.seed(42)
smote_out <- SMOTE(X = train_res[, -ncol(train_res)], target = train_res$lbw, K = 5, dup_size = 0)

# 3️⃣ Extract balanced data
train_balanced <- smote_out$data
colnames(train_balanced)[ncol(train_balanced)] <- "lbw"  # rename last column as target

# 4️⃣ Split back into X and y
X_train_res <- train_balanced[, -ncol(train_balanced)]
y_train_res <- train_balanced$lbw

# 5️⃣ Check class balance
cat("Balanced training set dimensions:\n")
print(dim(X_train_res))

cat("LBW counts after SMOTE:\n")
print(table(y_train_res))








#### Smote figure ####
library(ggplot2)
library(dplyr)
library(gridExtra)  # for arranging multiple plots

# ---------------------------
# Data: Prevalence before and after SMOTE
# ---------------------------
pre_smote_counts <- table(y_train)
after_smote_counts <- table(y_train_res)

labels <- c("Normal (0)", "LBW (1)")

# Convert to data frame for ggplot
df_bar <- data.frame(
  Status = rep(c("Before SMOTE", "After SMOTE"), each = 2),
  LBW = rep(labels, 2),
  Count = c(as.numeric(pre_smote_counts), as.numeric(after_smote_counts))
)

# ---------------------------
# 1️⃣ Stacked Bar Chart
# ---------------------------
bar_plot <- ggplot(df_bar, aes(x = Status, y = Count, fill = LBW)) +
  geom_bar(stat = "identity") +
  scale_fill_manual(values = c("skyblue", "lightcoral")) +
  labs(y = "Count", title = "LBW Prevalence: Before vs After SMOTE") +
  theme_minimal(base_size = 14) +
  theme(legend.title = element_blank(),
        plot.title = element_text(face = "bold", hjust = 0.5))

# ---------------------------
# 2️⃣ Pie Charts (Before & After SMOTE)
# ---------------------------
df_pie_before <- data.frame(
  LBW = labels,
  Count = as.numeric(pre_smote_counts)
) %>%
  mutate(Percent = Count / sum(Count) * 100,
         Label = paste0(round(Percent, 1), "%"))

df_pie_after <- data.frame(
  LBW = labels,
  Count = as.numeric(after_smote_counts)
) %>%
  mutate(Percent = Count / sum(Count) * 100,
         Label = paste0(round(Percent, 1), "%"))

pie_before <- ggplot(df_pie_before, aes(x = "", y = Count, fill = LBW)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  geom_text(aes(label = Label), position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = c("skyblue", "lightcoral")) +
  labs(title = "Before SMOTE") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none")

pie_after <- ggplot(df_pie_after, aes(x = "", y = Count, fill = LBW)) +
  geom_bar(stat = "identity", width = 1) +
  coord_polar(theta = "y") +
  geom_text(aes(label = Label), position = position_stack(vjust = 0.5)) +
  scale_fill_manual(values = c("skyblue", "lightcoral")) +
  labs(title = "After SMOTE") +
  theme_void() +
  theme(plot.title = element_text(face = "bold", hjust = 0.5),
        legend.position = "none")

# Arrange side by side
pie_plot <- grid.arrange(pie_before, pie_after, ncol = 2)









library(ggplot2)
library(dplyr)
library(gridExtra)

# ---------------------------
# Data: Prevalence before and after SMOTE
# ---------------------------
pre_smote_counts <- table(y_train)
after_smote_counts <- table(y_train_res)

labels <- c("Normal (0)", "LBW (1)")

# Convert to data frame for ggplot
df_bar <- data.frame(
  Status = rep(c("Before SMOTE", "After SMOTE"), each = 2),
  LBW = rep(labels, 2),
  Count = c(as.numeric(pre_smote_counts), as.numeric(after_smote_counts))
)

# Calculate percentages for stacked bar labels
df_bar <- df_bar %>%
  group_by(Status) %>%
  mutate(Percent = Count / sum(Count) * 100,
         Label = paste0(round(Percent, 1), "%")) %>%
  ungroup()

# ---------------------------
# 1️⃣ Stacked Bar Chart
# ---------------------------
bar_plot <- ggplot(df_bar, aes(x = Status, y = Count, fill = LBW)) +
  geom_bar(stat = "identity", color = "white", width = 0.6) +
  geom_text(aes(label = Label), position = position_stack(vjust = 0.5),
            size = 5, fontface = "bold", color = "black") +
  scale_fill_manual(values = c("#80B3FF", "#FF9999")) +
  labs(y = "Number of Participants", x = "",
       title = "LBW Prevalence Before vs After SMOTE") +
  theme_minimal(base_size = 14) +
  theme(
    legend.title = element_blank(),
    plot.title = element_text(face = "bold", hjust = 0.5, size = 16),
    axis.text = element_text(face = "bold", size = 12),
    axis.title.y = element_text(face = "bold", size = 14)
  )

# ---------------------------
# 2️⃣ Pie Charts (Before & After SMOTE)
# ---------------------------
create_pie <- function(counts, title){
  df <- data.frame(
    LBW = labels,
    Count = as.numeric(counts)
  ) %>%
    mutate(Percent = Count / sum(Count) * 100,
           Label = paste0(round(Percent, 1), "%"))
  
  ggplot(df, aes(x = "", y = Count, fill = LBW)) +
    geom_bar(stat = "identity", width = 1, color = "white") +
    coord_polar(theta = "y") +
    geom_text(aes(label = Label), position = position_stack(vjust = 0.5),
              size = 5, fontface = "bold", color = "black") +
    scale_fill_manual(values = c("#80B3FF", "#FF9999")) +
    labs(title = title) +
    theme_void() +
    theme(plot.title = element_text(face = "bold", hjust = 0.5, size = 14),
          legend.position = "none")
}

pie_before <- create_pie(pre_smote_counts, "Before SMOTE")
pie_after <- create_pie(after_smote_counts, "After SMOTE")

# Arrange side by side
pie_plot <- grid.arrange(pie_before, pie_after, ncol = 2)






# ---------------------------
# Safe factor levels
# ---------------------------


y_test_model  <- factor(ifelse(y_test == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))


X_test_model <- X_test_rfe  # keep original RFE-selected test set
y_test_model <- y_test       # original test labels


# ---------------------------
# Use SMOTE-balanced training set
# ---------------------------
X_train_model <- X_train_res      # SMOTE-balanced training features
y_train_model <- y_train_res      # SMOTE-balanced training labels

X_test_model  <- X_test_rfe       # original test features
y_test_model  <- y_test           # original test labels












#### Model Training - FINAL STABLE VERSION (No Hyperparameter Tuning) ####

library(caret)
library(pROC)
library(xgboost)
library(e1071)
library(randomForest)
library(rpart)
library(dplyr)

# ---------------------------
# Prepare Data
# ---------------------------

X_train_model <- X_train_res
y_train_model <- factor(ifelse(y_train_res == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

X_test_model  <- X_test_rfe
y_test_model  <- factor(ifelse(y_test == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

train_data <- cbind(X_train_model, lbw = y_train_model)

# ---------------------------
# TrainControl for caret models
# ---------------------------
ctrl <- trainControl(
  method = "cv",
  number = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE
)

# ---------------------------
# caret Models
# ---------------------------
model_list <- list(
  "DecisionTree" = "rpart",
  "RandomForest" = "rf",
  "LogisticRegression" = "glm",
  "SVM" = "svmRadial"
)

results <- list()

for (name in names(model_list)) {
  
  cat("\nTraining", name, "...\n")
  
  set.seed(42)
  fit <- train(
    lbw ~ .,
    data = train_data,
    method = model_list[[name]],
    trControl = ctrl,
    metric = "ROC"
  )
  
  pred_prob <- predict(fit, X_test_model, type = "prob")
  y_prob <- pred_prob[, "LBW"]
  
  y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                   levels = c("Normal","LBW"))
  
  acc  <- mean(y_pred == y_test_model)
  rec  <- caret::sensitivity(y_pred, y_test_model, positive="LBW")
  spec <- caret::specificity(y_pred, y_test_model, negative="Normal")
  f1   <- 2 * rec * spec / (rec + spec)
  auc  <- pROC::auc(pROC::roc(y_test_model, y_prob))
  
  results[[name]] <- data.frame(
    Model = name,
    Accuracy = round(acc,3),
    F1_Score = round(f1,3),
    Recall   = round(rec,3),
    AUC_ROC  = round(as.numeric(auc),3)
  )
}

# ---------------------------
# XGBoost (xgb.train version)
# ---------------------------
cat("\nTraining XGBoost...\n")

y_train_numeric <- ifelse(y_train_model=="LBW", 1, 0)
y_test_numeric  <- ifelse(y_test_model=="LBW", 1, 0)

dtrain <- xgb.DMatrix(data = as.matrix(X_train_model), label = y_train_numeric)
dtest  <- xgb.DMatrix(data = as.matrix(X_test_model), label = y_test_numeric)

params <- list(
  objective = "binary:logistic",
  eval_metric = "auc"
)

set.seed(42)
xgb_fit <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100,
  verbose = 0
)

y_prob <- predict(xgb_fit, dtest)
y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                 levels = c("Normal","LBW"))

acc  <- mean(y_pred == y_test_model)
rec  <- caret::sensitivity(y_pred, y_test_model, positive="LBW")
spec <- caret::specificity(y_pred, y_test_model, negative="Normal")
f1   <- 2 * rec * spec / (rec + spec)
auc  <- pROC::auc(pROC::roc(y_test_model, y_prob))

results[["XGBoost"]] <- data.frame(
  Model = "XGBoost",
  Accuracy = round(acc,3),
  F1_Score = round(f1,3),
  Recall   = round(rec,3),
  AUC_ROC  = round(as.numeric(auc),3)
)

# ---------------------------
# Final Results
# ---------------------------
results_df <- do.call(rbind, results)
print(results_df)












#### Model Training - FINAL STABLE VERSION (No Hyperparameter Tuning) ####

library(caret)
library(pROC)
library(xgboost)
library(e1071)
library(randomForest)
library(rpart)
library(dplyr)

# ---------------------------
# Prepare Data
# ---------------------------

X_train_model <- X_train_res
y_train_model <- factor(ifelse(y_train_res == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

X_test_model  <- X_test_rfe
y_test_model  <- factor(ifelse(y_test == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

train_data <- cbind(X_train_model, lbw = y_train_model)

# ---------------------------
# TrainControl for caret models
# ---------------------------
ctrl <- trainControl(
  method = "cv",
  number = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE
)

# ---------------------------
# caret Models
# ---------------------------
model_list <- list(
  "DecisionTree" = "rpart",
  "RandomForest" = "rf",
  "LogisticRegression" = "glm",
  "SVM" = "svmRadial"
)

results <- list()

for (name in names(model_list)) {
  
  cat("\nTraining", name, "...\n")
  
  set.seed(42)
  fit <- train(
    lbw ~ .,
    data = train_data,
    method = model_list[[name]],
    trControl = ctrl,
    metric = "ROC"
  )
  
  pred_prob <- predict(fit, X_test_model, type = "prob")
  y_prob <- pred_prob[, "LBW"]
  
  y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                   levels = c("Normal","LBW"))
  
  # Confusion matrix
  cm <- confusionMatrix(y_pred, y_test_model, positive = "LBW")
  
  # Metrics
  acc  <- cm$overall["Accuracy"]
  kappa <- cm$overall["Kappa"]
  rec  <- cm$byClass["Sensitivity"]
  spec <- cm$byClass["Specificity"]
  f1   <- 2 * rec * spec / (rec + spec)
  gmean <- sqrt(as.numeric(rec) * as.numeric(spec))
  
  # Manual MCC
  TP <- cm$table["LBW","LBW"]
  TN <- cm$table["Normal","Normal"]
  FP <- cm$table["LBW","Normal"]
  FN <- cm$table["Normal","LBW"]
  mcc <- (TP*TN - FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN))
  
  auc  <- pROC::auc(pROC::roc(y_test_model, y_prob))
  
  results[[name]] <- data.frame(
    Model = name,
    Accuracy = round(as.numeric(acc),3),
    Kappa = round(as.numeric(kappa),3),
    F1_Score = round(as.numeric(f1),3),
    Recall   = round(as.numeric(rec),3),
    Specificity = round(as.numeric(spec),3),
    GMean = round(as.numeric(gmean),3),
    MCC = round(as.numeric(mcc),3),
    AUC_ROC  = round(as.numeric(auc),3),
    Confusion_Matrix = paste(cm$table)
  )
}

# ---------------------------
# XGBoost (xgb.train version)
# ---------------------------
cat("\nTraining XGBoost...\n")

y_train_numeric <- ifelse(y_train_model=="LBW", 1, 0)
y_test_numeric  <- ifelse(y_test_model=="LBW", 1, 0)

dtrain <- xgb.DMatrix(data = as.matrix(X_train_model), label = y_train_numeric)
dtest  <- xgb.DMatrix(data = as.matrix(X_test_model), label = y_test_numeric)

params <- list(
  objective = "binary:logistic",
  eval_metric = "auc"
)

set.seed(42)
xgb_fit <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100,
  verbose = 0
)

y_prob <- predict(xgb_fit, dtest)
y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                 levels = c("Normal","LBW"))

cm <- confusionMatrix(y_pred, y_test_model, positive = "LBW")

acc  <- cm$overall["Accuracy"]
kappa <- cm$overall["Kappa"]
rec  <- cm$byClass["Sensitivity"]
spec <- cm$byClass["Specificity"]
f1   <- 2 * rec * spec / (rec + spec)
gmean <- sqrt(as.numeric(rec) * as.numeric(spec))
TP <- cm$table["LBW","LBW"]
TN <- cm$table["Normal","Normal"]
FP <- cm$table["LBW","Normal"]
FN <- cm$table["Normal","LBW"]
mcc <- (TP*TN - FP*FN)/sqrt((TP+FP)*(TP+FN)*(TN+FP)*(TN+FN))
auc  <- pROC::auc(pROC::roc(y_test_model, y_prob))

results[["XGBoost"]] <- data.frame(
  Model = "XGBoost",
  Accuracy = round(as.numeric(acc),3),
  Kappa = round(as.numeric(kappa),3),
  F1_Score = round(as.numeric(f1),3),
  Recall   = round(as.numeric(rec),3),
  Specificity = round(as.numeric(spec),3),
  GMean = round(as.numeric(gmean),3),
  MCC = round(as.numeric(mcc),3),
  AUC_ROC  = round(as.numeric(auc),3),
  Confusion_Matrix = paste(cm$table)
)

# ---------------------------
# Final Results
# ---------------------------
results_df <- do.call(rbind, results)
print(results_df)





















#### Model Training - FINAL STABLE VERSION (No Hyperparameter Tuning) ####

library(caret)
library(pROC)
library(xgboost)
library(e1071)
library(randomForest)
library(rpart)
library(dplyr)

# ---------------------------
# Prepare Data
# ---------------------------

X_train_model <- X_train_res
y_train_model <- factor(ifelse(y_train_res == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

X_test_model  <- X_test_rfe
y_test_model  <- factor(ifelse(y_test == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

train_data <- cbind(X_train_model, lbw = y_train_model)

# ---------------------------
# TrainControl for caret models
# ---------------------------
ctrl <- trainControl(
  method = "cv",
  number = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE
)

# ---------------------------
# caret Models
# ---------------------------
model_list <- list(
  "DecisionTree" = "rpart",
  "RandomForest" = "rf",
  "LogisticRegression" = "glm",
  "SVM" = "svmRadial"
)

results <- list()

for (name in names(model_list)) {
  
  cat("\nTraining", name, "...\n")
  
  set.seed(42)
  fit <- train(
    lbw ~ .,
    data = train_data,
    method = model_list[[name]],
    trControl = ctrl,
    metric = "ROC"
  )
  
  pred_prob <- predict(fit, X_test_model, type = "prob")
  y_prob <- pred_prob[, "LBW"]
  
  y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                   levels = c("Normal","LBW"))
  
  # Confusion matrix
  cm <- confusionMatrix(y_pred, y_test_model, positive="LBW")
  
  # Metrics
  acc  <- cm$overall["Accuracy"]
  kappa <- cm$overall["Kappa"]
  rec  <- cm$byClass["Sensitivity"]
  spec <- cm$byClass["Specificity"]
  f1   <- 2 * rec * spec / (rec + spec)
  gmean <- sqrt(as.numeric(rec) * as.numeric(spec))
  
  results[[name]] <- data.frame(
    Model = name,
    Accuracy = round(as.numeric(acc),3),
    Kappa = round(as.numeric(kappa),3),
    Sensitivity = round(as.numeric(rec),3),
    Specificity = round(as.numeric(spec),3),
    F1_Score = round(as.numeric(f1),3),
    GMean = round(as.numeric(gmean),3),
    TP = cm$table["LBW","LBW"],
    TN = cm$table["Normal","Normal"],
    FP = cm$table["LBW","Normal"],
    FN = cm$table["Normal","LBW"],
    AUC_ROC  = round(as.numeric(pROC::auc(pROC::roc(y_test_model, y_prob))),3)
  )
}

# ---------------------------
# XGBoost (xgb.train version)
# ---------------------------
cat("\nTraining XGBoost...\n")

y_train_numeric <- ifelse(y_train_model=="LBW", 1, 0)
y_test_numeric  <- ifelse(y_test_model=="LBW", 1, 0)

dtrain <- xgb.DMatrix(data = as.matrix(X_train_model), label = y_train_numeric)
dtest  <- xgb.DMatrix(data = as.matrix(X_test_model), label = y_test_numeric)

params <- list(
  objective = "binary:logistic",
  eval_metric = "auc"
)

set.seed(42)
xgb_fit <- xgb.train(
  params = params,
  data = dtrain,
  nrounds = 100,
  verbose = 0
)

y_prob <- predict(xgb_fit, dtest)
y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                 levels = c("Normal","LBW"))

cm <- confusionMatrix(y_pred, y_test_model, positive="LBW")

acc  <- cm$overall["Accuracy"]
kappa <- cm$overall["Kappa"]
rec  <- cm$byClass["Sensitivity"]
spec <- cm$byClass["Specificity"]
f1   <- 2 * rec * spec / (rec + spec)
gmean <- sqrt(as.numeric(rec) * as.numeric(spec))

results[["XGBoost"]] <- data.frame(
  Model = "XGBoost",
  Accuracy = round(as.numeric(acc),3),
  Kappa = round(as.numeric(kappa),3),
  Sensitivity = round(as.numeric(rec),3),
  Specificity = round(as.numeric(spec),3),
  F1_Score = round(as.numeric(f1),3),
  GMean = round(as.numeric(gmean),3),
  TP = cm$table["LBW","LBW"],
  TN = cm$table["Normal","Normal"],
  FP = cm$table["LBW","Normal"],
  FN = cm$table["Normal","LBW"],
  AUC_ROC  = round(as.numeric(pROC::auc(pROC::roc(y_test_model, y_prob))),3)
)

# ---------------------------
# Final Results
# ---------------------------
results_df <- do.call(rbind, results)
print(results_df)











#### Model Training - FINAL STABLE VERSION WITH HYPERPARAMETER TUNING ####

library(caret)
library(pROC)
library(xgboost)
library(e1071)
library(randomForest)
library(rpart)
library(dplyr)

# ---------------------------
# Prepare Data
# ---------------------------

X_train_model <- X_train_res
y_train_model <- factor(ifelse(y_train_res == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

X_test_model  <- X_test_rfe
y_test_model  <- factor(ifelse(y_test == 1, "LBW", "Normal"),
                        levels = c("Normal","LBW"))

train_data <- cbind(X_train_model, lbw = y_train_model)

# ---------------------------
# TrainControl for caret models (5-fold CV + ROC)
# ---------------------------
ctrl <- trainControl(
  method = "cv",
  number = 5,
  summaryFunction = twoClassSummary,
  classProbs = TRUE,
  search = "grid"
)

# ---------------------------
# Hyperparameter grids
# ---------------------------
tune_grids <- list(
  DecisionTree = expand.grid(cp = seq(0.001, 0.05, by=0.01)),
  RandomForest = expand.grid(mtry = seq(1, ncol(X_train_model), by = 2)),
  LogisticRegression = NULL,  # no tuning grid for glm
  SVM = expand.grid(C = 2^(-1:2), sigma = 2^(-2:1))
)

# ---------------------------
# caret Models with hyperparameter tuning
# ---------------------------
model_list <- list(
  "DecisionTree" = "rpart",
  "RandomForest" = "rf",
  "LogisticRegression" = "glm",
  "SVM" = "svmRadial"
)

results <- list()

for (name in names(model_list)) {
  
  cat("\nTraining", name, "with hyperparameter tuning...\n")
  
  set.seed(42)
  fit <- train(
    lbw ~ .,
    data = train_data,
    method = model_list[[name]],
    trControl = ctrl,
    tuneGrid = tune_grids[[name]],
    metric = "ROC"
  )
  
  pred_prob <- predict(fit, X_test_model, type = "prob")
  y_prob <- pred_prob[, "LBW"]
  
  y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                   levels = c("Normal","LBW"))
  
  # Confusion matrix
  cm <- confusionMatrix(y_pred, y_test_model, positive="LBW")
  
  # Metrics
  acc  <- cm$overall["Accuracy"]
  kappa <- cm$overall["Kappa"]
  rec  <- cm$byClass["Sensitivity"]
  spec <- cm$byClass["Specificity"]
  f1   <- 2 * rec * spec / (rec + spec)
  gmean <- sqrt(as.numeric(rec) * as.numeric(spec))
  
  results[[name]] <- data.frame(
    Model = name,
    Accuracy = round(as.numeric(acc),3),
    Kappa = round(as.numeric(kappa),3),
    Sensitivity = round(as.numeric(rec),3),
    Specificity = round(as.numeric(spec),3),
    F1_Score = round(as.numeric(f1),3),
    GMean = round(as.numeric(gmean),3),
    TP = cm$table["LBW","LBW"],
    TN = cm$table["Normal","Normal"],
    FP = cm$table["LBW","Normal"],
    FN = cm$table["Normal","LBW"],
    AUC_ROC  = round(as.numeric(pROC::auc(pROC::roc(y_test_model, y_prob))),3)
  )
}

# ---------------------------
# XGBoost (xgb.train with manual tuning grid)
# ---------------------------
cat("\nTraining XGBoost with hyperparameter tuning...\n")

y_train_numeric <- ifelse(y_train_model=="LBW", 1, 0)
y_test_numeric  <- ifelse(y_test_model=="LBW", 1, 0)

dtrain <- xgb.DMatrix(data = as.matrix(X_train_model), label = y_train_numeric)
dtest  <- xgb.DMatrix(data = as.matrix(X_test_model), label = y_test_numeric)

# Define simple manual grid for XGBoost
xgb_grid <- expand.grid(
  eta = c(0.01, 0.1, 0.3),
  max_depth = c(3, 6, 9),
  gamma = c(0, 1),
  colsample_bytree = c(0.6, 0.8, 1),
  min_child_weight = c(1, 5),
  subsample = c(0.7, 1)
)

best_auc <- 0
best_model <- NULL

for(i in 1:nrow(xgb_grid)) {
  params <- list(
    objective = "binary:logistic",
    eval_metric = "auc",
    eta = xgb_grid$eta[i],
    max_depth = xgb_grid$max_depth[i],
    gamma = xgb_grid$gamma[i],
    colsample_bytree = xgb_grid$colsample_bytree[i],
    min_child_weight = xgb_grid$min_child_weight[i],
    subsample = xgb_grid$subsample[i]
  )
  
  set.seed(42)
  xgb_fit <- xgb.train(
    params = params,
    data = dtrain,
    nrounds = 100,
    verbose = 0
  )
  
  y_prob <- predict(xgb_fit, dtest)
  auc <- as.numeric(pROC::auc(pROC::roc(y_test_model, y_prob)))
  
  if(auc > best_auc){
    best_auc <- auc
    best_model <- xgb_fit
    best_y_prob <- y_prob
  }
}

y_pred <- factor(ifelse(best_y_prob > 0.5, "LBW", "Normal"),
                 levels = c("Normal","LBW"))

cm <- confusionMatrix(y_pred, y_test_model, positive="LBW")

acc  <- cm$overall["Accuracy"]
kappa <- cm$overall["Kappa"]
rec  <- cm$byClass["Sensitivity"]
spec <- cm$byClass["Specificity"]
f1   <- 2 * rec * spec / (rec + spec)
gmean <- sqrt(as.numeric(rec) * as.numeric(spec))

results[["XGBoost"]] <- data.frame(
  Model = "XGBoost",
  Accuracy = round(as.numeric(acc),3),
  Kappa = round(as.numeric(kappa),3),
  Sensitivity = round(as.numeric(rec),3),
  Specificity = round(as.numeric(spec),3),
  F1_Score = round(as.numeric(f1),3),
  GMean = round(as.numeric(gmean),3),
  TP = cm$table["LBW","LBW"],
  TN = cm$table["Normal","Normal"],
  FP = cm$table["LBW","Normal"],
  FN = cm$table["Normal","LBW"],
  AUC_ROC  = round(as.numeric(best_auc),3)
)

# ---------------------------
# Final Results
# ---------------------------
results_df <- do.call(rbind, results)
print(results_df)















# ---------------------------
# Round numeric columns to 2 decimals
# ---------------------------
results_df_rounded <- results_df
results_df_rounded[,2:5] <- round(results_df_rounded[,2:5], 2)

# ---------------------------
# Save to CSV
# ---------------------------
output_path <- "F:/Machine learning  Based/BDHS/Cross country/LBW/R Programmings/Tables/LBW_Model_Results.csv"
write.csv(results_df_rounded, file = output_path, row.names = FALSE)

cat("Results saved to:", output_path, "\n")












#### Figure ####
library(ggplot2)
library(pROC)
library(caret)
library(PRROC)
library(gridExtra)  # for side-by-side plots













# Create separate list for trained caret models
fits <- list()

for (name in names(model_list)) {
  
  cat("\nTraining", name, "with hyperparameter tuning...\n")
  
  set.seed(42)
  fit <- train(
    lbw ~ .,
    data = train_data,
    method = model_list[[name]],
    trControl = ctrl,
    tuneGrid = tune_grids[[name]],
    metric = "ROC"
  )
  
  # Save the trained model
  fits[[name]] <- fit
  
  # Predictions and metrics code here (same as before)
  pred_prob <- predict(fit, X_test_model, type="prob")
  y_prob <- pred_prob[, "LBW"]
  
  y_pred <- factor(ifelse(y_prob > 0.5, "LBW", "Normal"),
                   levels = c("Normal","LBW"))
  
  cm <- confusionMatrix(y_pred, y_test_model, positive="LBW")
  acc  <- cm$overall["Accuracy"]
  kappa <- cm$overall["Kappa"]
  rec  <- cm$byClass["Sensitivity"]
  spec <- cm$byClass["Specificity"]
  f1   <- 2 * rec * spec / (rec + spec)
  gmean <- sqrt(as.numeric(rec) * as.numeric(spec))
  
  results[[name]] <- data.frame(
    Model = name,
    Accuracy = round(as.numeric(acc),3),
    Kappa = round(as.numeric(kappa),3),
    Sensitivity = round(as.numeric(rec),3),
    Specificity = round(as.numeric(spec),3),
    F1_Score = round(as.numeric(f1),3),
    GMean = round(as.numeric(gmean),3),
    TP = cm$table["LBW","LBW"],
    TN = cm$table["Normal","Normal"],
    FP = cm$table["LBW","Normal"],
    FN = cm$table["Normal","LBW"],
    AUC_ROC  = round(as.numeric(pROC::auc(pROC::roc(y_test_model, y_prob))),3)
  )
}






library(pROC)
library(PRROC)
library(ggplot2)
library(gridExtra)

# Collect predicted probabilities
model_preds <- list(
  "DecisionTree" = predict(fits$DecisionTree, X_test_model, type="prob")[, "LBW"],
  "RandomForest" = predict(fits$RandomForest, X_test_model, type="prob")[, "LBW"],
  "LogisticRegression" = predict(fits$LogisticRegression, X_test_model, type="prob")[, "LBW"],
  "SVM" = predict(fits$SVM, X_test_model, type="prob")[, "LBW"],
  "XGBoost" = best_y_prob
)

# ROC curves
roc_list <- lapply(names(model_preds), function(name){
  roc_obj <- roc(y_test_model, model_preds[[name]], levels=c("Normal","LBW"), direction="<")
  data.frame(FPR = 1 - roc_obj$specificities,
             TPR = roc_obj$sensitivities,
             Model = name)
})

roc_df <- do.call(rbind, roc_list)

roc_plot <- ggplot(roc_df, aes(x=FPR, y=TPR, color=Model)) +
  geom_line(size=1) +
  geom_abline(linetype="dashed") +
  labs(title="ROC Curves", x="1 - Specificity", y="Sensitivity") +
  theme_minimal()

# Precision-Recall curves
pr_list <- lapply(names(model_preds), function(name){
  fg <- model_preds[[name]][y_test_model=="LBW"]
  bg <- model_preds[[name]][y_test_model=="Normal"]
  pr <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve=TRUE)
  data.frame(Recall = pr$curve[,1],
             Precision = pr$curve[,2],
             Model = name)
})

pr_df <- do.call(rbind, pr_list)

pr_plot <- ggplot(pr_df, aes(x=Recall, y=Precision, color=Model)) +
  geom_line(size=1) +
  labs(title="Precision-Recall Curves", x="Recall", y="Precision") +
  theme_minimal()

# Side-by-side
grid.arrange(roc_plot, pr_plot, ncol=2)











#### ROC + Precision Recall ####
library(pROC)
library(PRROC)
library(ggplot2)
library(gridExtra)
library(viridis)   # nice color palettes

# ---------------------------
# Collect predicted probabilities
# ---------------------------
model_preds <- list(
  "DecisionTree" = predict(fits$DecisionTree, X_test_model, type="prob")[, "LBW"],
  "RandomForest" = predict(fits$RandomForest, X_test_model, type="prob")[, "LBW"],
  "LogisticRegression" = predict(fits$LogisticRegression, X_test_model, type="prob")[, "LBW"],
  "SVM" = predict(fits$SVM, X_test_model, type="prob")[, "LBW"],
  "XGBoost" = best_y_prob
)

# ---------------------------
# ROC Curves
# ---------------------------
roc_list <- lapply(names(model_preds), function(name){
  roc_obj <- roc(y_test_model, model_preds[[name]], levels=c("Normal","LBW"), direction="<")
  data.frame(FPR = 1 - roc_obj$specificities,
             TPR = roc_obj$sensitivities,
             Model = name)
})

roc_df <- do.call(rbind, roc_list)

roc_plot <- ggplot(roc_df, aes(x=FPR, y=TPR, color=Model)) +
  geom_line(size=1.2) +
  geom_abline(linetype="dashed", color="gray70") +
  scale_color_viridis(discrete = TRUE, option="D") +
  labs(title="ROC Curves", x="False Positive Rate (1 - Specificity)", y="True Positive Rate (Sensitivity)") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face="bold", size=16, hjust=0.5),
    legend.position = "bottom",
    legend.title = element_blank()
  )

# ---------------------------
# Precision-Recall Curves
# ---------------------------
pr_list <- lapply(names(model_preds), function(name){
  fg <- model_preds[[name]][y_test_model=="LBW"]
  bg <- model_preds[[name]][y_test_model=="Normal"]
  pr <- pr.curve(scores.class0 = fg, scores.class1 = bg, curve=TRUE)
  data.frame(Recall = pr$curve[,1],
             Precision = pr$curve[,2],
             Model = name)
})

pr_df <- do.call(rbind, pr_list)

pr_plot <- ggplot(pr_df, aes(x=Recall, y=Precision, color=Model)) +
  geom_line(size=1.2) +
  scale_color_viridis(discrete = TRUE, option="D") +
  labs(title="Precision-Recall Curves", x="Recall (Sensitivity)", y="Precision") +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face="bold", size=16, hjust=0.5),
    legend.position = "bottom",
    legend.title = element_blank()
  )

# ---------------------------
# Side-by-side display
# ---------------------------
grid.arrange(roc_plot, pr_plot, ncol=2)













#### Feature Importance ####
library(ggplot2)
library(dplyr)

# ---------------------------
# Decision Tree Feature Importance
# ---------------------------
dt_imp <- varImp(fits$DecisionTree)$importance
dt_imp$Feature <- rownames(dt_imp)
dt_imp <- dt_imp %>% arrange(desc(Overall))

dt_plot <- ggplot(dt_imp, aes(x=reorder(Feature, Overall), y=Overall)) +
  geom_col(fill="#66c2a5") +
  coord_flip() +
  labs(title="Decision Tree Feature Importance",
       x="Features", y="Importance") +
  theme_minimal(base_size=14) +
  theme(plot.title = element_text(face="bold", size=16, hjust=0.5))

# ---------------------------
# Logistic Regression Feature Importance (Absolute Coefficients)
# ---------------------------
lr_coef <- coef(fits$LogisticRegression$finalModel)
lr_imp <- data.frame(Feature = names(lr_coef)[-1],
                     Importance = abs(lr_coef[-1]))
lr_imp <- lr_imp %>% arrange(desc(Importance))

lr_plot <- ggplot(lr_imp, aes(x=reorder(Feature, Importance), y=Importance)) +
  geom_col(fill="#fc8d62") +
  coord_flip() +
  labs(title="Logistic Regression Feature Importance (|Coefficient|)",
       x="Features", y="Absolute Coefficient") +
  theme_minimal(base_size=14) +
  theme(plot.title = element_text(face="bold", size=16, hjust=0.5))

# ---------------------------
# Display side-by-side
# ---------------------------
library(gridExtra)
grid.arrange(dt_plot, lr_plot, ncol=2)







library(ggplot2)
library(dplyr)
library(gridExtra)

# ---------------------------
# Decision Tree Feature Importance
# ---------------------------
dt_imp <- varImp(fits$DecisionTree)$importance
dt_imp$Feature <- rownames(dt_imp)
dt_imp <- dt_imp %>% arrange(desc(Overall))

dt_plot <- ggplot(dt_imp, aes(x=reorder(Feature, Overall), y=Overall, fill=Overall)) +
  geom_col(color="black", width=0.7) +
  scale_fill_gradient(low="#b2df8a", high="#33a02c") +
  coord_flip() +
  labs(title="Decision Tree Feature Importance",
       x="Features", y="Importance") +
  theme_minimal(base_size=14) +
  theme(
    plot.title = element_text(face="bold", size=16, hjust=0.5, color="#1b4332"),
    axis.title = element_text(face="bold"),
    axis.text = element_text(color="#1b4332"),
    legend.position = "none",
    panel.grid.major.y = element_line(color="#d9d9d9"),
    panel.grid.minor = element_blank()
  )

# ---------------------------
# Logistic Regression Feature Importance
# ---------------------------
lr_coef <- coef(fits$LogisticRegression$finalModel)
lr_imp <- data.frame(Feature = names(lr_coef)[-1],
                     Importance = abs(lr_coef[-1]))
lr_imp <- lr_imp %>% arrange(desc(Importance))

lr_plot <- ggplot(lr_imp, aes(x=reorder(Feature, Importance), y=Importance, fill=Importance)) +
  geom_col(color="black", width=0.7) +
  scale_fill_gradient(low="#fdbb84", high="#e34a33") +
  coord_flip() +
  labs(title="Logistic Regression Feature Importance (|Coefficient|)",
       x="Features", y="Absolute Coefficient") +
  theme_minimal(base_size=14) +
  theme(
    plot.title = element_text(face="bold", size=16, hjust=0.5, color="#7f0000"),
    axis.title = element_text(face="bold"),
    axis.text = element_text(color="#7f0000"),
    legend.position = "none",
    panel.grid.major.y = element_line(color="#d9d9d9"),
    panel.grid.minor = element_blank()
  )

# ---------------------------
# Display side-by-side
# ---------------------------
grid.arrange(dt_plot, lr_plot, ncol=2)








library(ggplot2)
library(dplyr)
library(gridExtra)

# ---------------------------
# Decision Tree Feature Importance
# ---------------------------
dt_imp <- varImp(fits$DecisionTree)$importance
dt_imp$Feature <- rownames(dt_imp)
dt_imp <- dt_imp %>% arrange(desc(Overall))

dt_plot <- ggplot(dt_imp, aes(x=reorder(Feature, Overall), y=Overall, fill=Overall)) +
  geom_col(color="black", width=0.7) +
  scale_fill_gradient(low="#b2df8a", high="#33a02c") +
  coord_flip() +
  labs(title="Decision Tree Feature Importance",
       x="Features", y="Importance") +
  theme_minimal(base_size=14) +
  theme(
    plot.title = element_text(face="bold", size=16, hjust=0.5, color="#1b4332"),
    axis.title = element_text(face="bold"),
    axis.text = element_text(color="#1b4332"),
    legend.position = "none",
    panel.grid.major.y = element_line(color="#d9d9d9"),
    panel.grid.minor = element_blank()
  )

# ---------------------------
# Logistic Regression Feature Importance
# ---------------------------
lr_coef <- coef(fits$LogisticRegression$finalModel)
lr_imp <- data.frame(Feature = names(lr_coef)[-1],
                     Importance = abs(lr_coef[-1]))
lr_imp <- lr_imp %>% arrange(desc(Importance))

lr_plot <- ggplot(lr_imp, aes(x=reorder(Feature, Importance), y=Importance, fill=Importance)) +
  geom_col(color="black", width=0.7) +
  scale_fill_gradient(low="#fdbb84", high="#e34a33") +
  coord_flip() +
  labs(title="Logistic Regression Feature Importance (|Coefficient|)",
       x="Features", y="Absolute Coefficient") +
  theme_minimal(base_size=14) +
  theme(
    plot.title = element_text(face="bold", size=16, hjust=0.5, color="#7f0000"),
    axis.title = element_text(face="bold"),
    axis.text = element_text(color="#7f0000"),
    legend.position = "none",
    panel.grid.major.y = element_line(color="#d9d9d9"),
    panel.grid.minor = element_blank()
  )

# ---------------------------
# Display side-by-side
# ---------------------------
grid.arrange(dt_plot, lr_plot, ncol=2)
















# ===============================
# SHAP & Waterfall (DT + LR)
# ===============================

library(iml)
library(ggplot2)
library(dplyr)
library(gridExtra)

set.seed(123)

# ---------------------------
# 1️⃣ Decision Tree - Monte Carlo SHAP (20 samples)
# ---------------------------

# Wrap Decision Tree
dt_predictor <- Predictor$new(
  model = fits$DecisionTree$finalModel,
  data  = X_train_model,
  y     = y_train_model,
  type  = "prob"
)

# Monte Carlo SHAP (20 simulations)
dt_shap_mc <- Shapley$new(
  dt_predictor,
  x.interest = X_test_model[1, ],
  sample.size = 20   # Monte Carlo 20
)

# Global approximation (mean |phi|)
dt_global <- FeatureImp$new(
  dt_predictor,
  loss = "ce"
)

# Plot Monte Carlo SHAP values (bar)
plot(dt_shap_mc) + 
  ggtitle("Decision Tree - Local SHAP (Monte Carlo 20)")

# Waterfall-like plot (local)
dt_shap_df <- dt_shap_mc$results
dt_shap_df <- dt_shap_df %>% arrange(phi)

ggplot(dt_shap_df, aes(x=reorder(feature, phi), y=phi, fill=phi)) +
  geom_col() +
  coord_flip() +
  labs(title="Decision Tree - SHAP Waterfall (Local)",
       x="Feature", y="SHAP value") +
  theme_minimal()








# ===============================
# Nature Communications Style
# Decision Tree - Local SHAP Waterfall
# ===============================

library(ggplot2)
library(dplyr)
library(scales)

dt_shap_df <- dt_shap_df %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

ggplot(dt_shap_df,
       aes(x = reorder(feature, phi),
           y = phi,
           fill = direction)) +
  
  geom_col(width = 0.7, color = "black", size = 0.25) +
  
  coord_flip() +
  
  scale_fill_manual(values = c(
    "Positive impact" = "#d73027",   # bright red
    "Negative impact" = "#4575b4"    # bright blue
  )) +
  
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  
  labs(
    title = "Decision Tree Model – Local SHAP Explanation",
    x = "Features",
    y = "SHAP value (impact on prediction)",
    fill = NULL
  ) +
  
  theme_classic(base_size = 14) +
  
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(color = "black"),
    legend.position = "top",
    legend.text = element_text(size = 11),
    panel.grid.major.y = element_blank(),
    panel.grid.major.x = element_line(color = "grey85", size = 0.3),
    axis.line = element_line(color = "black")
  )













# ===============================
# Ultra-Clean Bright Style
# Decision Tree - Local SHAP Waterfall
# ===============================

library(ggplot2)
library(dplyr)
library(scales)

dt_shap_df <- dt_shap_df %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

ggplot(dt_shap_df,
       aes(x = reorder(feature, phi),
           y = phi,
           fill = direction)) +
  
  geom_col(width = 0.6, color = NA, radius = unit(3, "pt")) +   # soft edges
  
  coord_flip() +
  
  scale_fill_manual(values = c(
    "Positive impact" = "#fc8d59",   # lighter bright red
    "Negative impact" = "#91bfdb"    # lighter bright blue
  )) +
  
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  
  labs(
    title = "Decision Tree – Local SHAP Explanation",
    x = "Features",
    y = "SHAP value (impact on prediction)",
    fill = NULL
  ) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey30"),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(color = "grey20", size = 12),
    legend.position = "top",
    legend.text = element_text(size = 12),
    panel.grid.major.x = element_line(color = "grey90", size = 0.3),
    panel.grid.major.y = element_blank(),
    axis.line = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )






#### LR ####


lr_predictor <- Predictor$new(
  model = fits$LogisticRegression$finalModel,
  data  = X_train_model,
  y     = y_train_model,
  type  = "response"   # <-- change here
)



# Example: compute feature importance globally
lr_global <- FeatureImp$new(
  lr_predictor,
  loss = "ce"   # cross-entropy loss for classification
)

plot(lr_global) +
  ggtitle("Logistic Regression - Global Feature Importance (SHAP approximation)")





lr_shap_local <- Shapley$new(
  lr_predictor,
  x.interest = X_test_model[1, ],   # single observation
  sample.size = 100
)

ggplot(lr_shap_local$results %>% arrange(phi),
       aes(x = reorder(feature, phi), y = phi, fill = phi > 0)) +
  geom_col(width = 0.6) +
  coord_flip() +
  labs(title="Logistic Regression - Local SHAP Waterfall",
       x="Feature", y="SHAP value") +
  theme_minimal()




library(ggplot2)
library(dplyr)
library(scales)

# Prepare dataframe
lr_shap_df <- lr_shap_local$results %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

# Plot
ggplot(lr_shap_df, aes(x = reorder(feature, phi), y = phi, fill = direction)) +
  
  geom_col(width = 0.6, color = NA) +   # clean bars, no border
  
  coord_flip() +
  
  scale_fill_manual(values = c(
    "Positive impact" = "#fc8d59",   # bright soft red
    "Negative impact" = "#91bfdb"    # bright soft blue
  )) +
  
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  
  labs(
    title = "Logistic Regression – Local SHAP Waterfall",
    subtitle = "Single observation explanation",
    x = "Features",
    y = "SHAP value (impact on probability)",
    fill = NULL
  ) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey30"),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(color = "grey20", size = 12),
    legend.position = "top",
    legend.text = element_text(size = 12),
    panel.grid.major.x = element_line(color = "grey90", size = 0.3),
    panel.grid.major.y = element_blank(),
    axis.line = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )



# ---------------------------
# 3️⃣ Logistic Regression - Local Waterfall
# ---------------------------

lr_shap_local <- Shapley$new(
  lr_predictor,
  x.interest = X_test_model[1, ],
  sample.size = 100
)

lr_shap_df <- lr_shap_local$results %>% arrange(phi)

ggplot(lr_shap_df, aes(x=reorder(feature, phi), y=phi, fill=phi)) +
  geom_col() +
  coord_flip() +
  labs(title="Logistic Regression - SHAP Waterfall (Local)",
       x="Feature", y="SHAP value") +
  theme_minimal()










library(ggplot2)
library(dplyr)
library(scales)

# Prepare dataframe
lr_shap_df <- lr_shap_local$results %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

# Clean, bright, stylish SHAP waterfall
ggplot(lr_shap_df, aes(x = reorder(feature, phi), y = phi, fill = direction)) +
  
  geom_col(width = 0.6, alpha = 0.9, color = NA) +   # soft bright bars
  
  coord_flip(expand = TRUE) +
  
  scale_fill_manual(values = c(
    "Positive impact" = "#f8766d",   # brighter red
    "Negative impact" = "#00b0f6"    # brighter blue
  )) +
  
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  
  labs(
    title = "Logistic Regression – Local SHAP Waterfall",
    x = "Features",
    y = "SHAP value (impact on probability)",
    fill = NULL
  ) +
  
  theme_minimal(base_size = 14) +
  
  theme(
    plot.title = element_text(face = "bold", size = 18, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5, color = "grey35"),
    axis.title = element_text(face = "bold", size = 14),
    axis.text = element_text(color = "grey25", size = 12),
    axis.ticks = element_blank(),
    legend.position = "top",
    legend.text = element_text(size = 12),
    panel.grid.major.x = element_line(color = "grey90", size = 0.3),
    panel.grid.major.y = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )








library(ggplot2)
library(dplyr)
library(scales)
library(gridExtra)

# ---------------------------
# 1️⃣ Prepare Decision Tree SHAP df
# ---------------------------
dt_shap_df <- dt_shap_df %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

dt_plot <- ggplot(dt_shap_df, aes(x = reorder(feature, phi), y = phi, fill = direction)) +
  geom_col(width = 0.6, alpha = 0.9, color = NA) +  # clean bars
  coord_flip(expand = TRUE) +
  scale_fill_manual(values = c("Positive impact" = "#fc8d59", "Negative impact" = "#91bfdb")) +
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  labs(title = "Decision Tree – Local SHAP Waterfall",
       x = "Features", y = "SHAP value", fill = NULL) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(color = "grey25", size = 12),
    axis.ticks = element_blank(),
    legend.position = "top",
    legend.text = element_text(size = 12),
    panel.grid.major.x = element_line(color = "grey90", size = 0.3),
    panel.grid.major.y = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )

# ---------------------------
# 2️⃣ Prepare Logistic Regression SHAP df
# ---------------------------
lr_shap_df <- lr_shap_local$results %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

lr_plot <- ggplot(lr_shap_df, aes(x = reorder(feature, phi), y = phi, fill = direction)) +
  geom_col(width = 0.6, alpha = 0.9, color = NA) +
  coord_flip(expand = TRUE) +
  scale_fill_manual(values = c("Positive impact" = "#f8766d", "Negative impact" = "#00b0f6")) +
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  labs(title = "Logistic Regression – Local SHAP Waterfall",
       x = "Features", y = "SHAP value", fill = NULL) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(color = "grey25", size = 12),
    axis.ticks = element_blank(),
    legend.position = "top",
    legend.text = element_text(size = 12),
    panel.grid.major.x = element_line(color = "grey90", size = 0.3),
    panel.grid.major.y = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )

# ---------------------------
# 3️⃣ Display side-by-side
# ---------------------------
grid.arrange(dt_plot, lr_plot, ncol = 2)






library(ggplot2)
library(dplyr)
library(scales)
library(gridExtra)

# ---------------------------
# 1️⃣ Decision Tree SHAP df
# ---------------------------
dt_shap_df <- dt_shap_df %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

dt_plot <- ggplot(dt_shap_df, aes(x = reorder(feature, phi), y = phi, fill = direction)) +
  geom_col(width = 0.6, alpha = 0.95, color = NA) +
  coord_flip(expand = TRUE) +
  scale_fill_manual(values = c(
    "Positive impact" = "#e41a1c",   # Nature bright red
    "Negative impact" = "#377eb8"    # Nature bright blue
  )) +
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  labs(title = "Decision Tree – Local SHAP Waterfall",
       x = "Features", y = "SHAP value", fill = NULL) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(color = "grey20", size = 12),
    axis.ticks = element_blank(),
    legend.position = "top",
    legend.text = element_text(size = 12),
    panel.grid.major.x = element_line(color = "grey90", size = 0.3),
    panel.grid.major.y = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )

# ---------------------------
# 2️⃣ Logistic Regression SHAP df
# ---------------------------
lr_shap_df <- lr_shap_local$results %>%
  arrange(phi) %>%
  mutate(direction = ifelse(phi > 0, "Positive impact", "Negative impact"))

lr_plot <- ggplot(lr_shap_df, aes(x = reorder(feature, phi), y = phi, fill = direction)) +
  geom_col(width = 0.6, alpha = 0.95, color = NA) +
  coord_flip(expand = TRUE) +
  scale_fill_manual(values = c(
    "Positive impact" = "#ff7f00",   # Nature orange
    "Negative impact" = "#4daf4a"    # Nature green
  )) +
  scale_y_continuous(labels = number_format(accuracy = 0.01)) +
  labs(title = "Logistic Regression – Local SHAP Waterfall",
       x = "Features", y = "SHAP value", fill = NULL) +
  theme_minimal(base_size = 14) +
  theme(
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    axis.title = element_text(face = "bold"),
    axis.text = element_text(color = "grey20", size = 12),
    axis.ticks = element_blank(),
    legend.position = "top",
    legend.text = element_text(size = 12),
    panel.grid.major.x = element_line(color = "grey90", size = 0.3),
    panel.grid.major.y = element_blank(),
    panel.background = element_rect(fill = "white", color = NA),
    plot.background = element_rect(fill = "white", color = NA)
  )

# ---------------------------
# 3️⃣ Display side-by-side
# ---------------------------
grid.arrange(dt_plot, lr_plot, ncol = 2)


















# Predicted labels
y_pred_DT <- factor(ifelse(predict(fits$DecisionTree, X_test_model)=="LBW","LBW","Normal"), levels=c("Normal","LBW"))
y_pred_LR <- factor(ifelse(predict(fits$LogisticRegression, X_test_model)=="LBW","LBW","Normal"), levels=c("Normal","LBW"))

# Confusion table for McNemar test
mc_table <- table(y_pred_DT, y_pred_LR)

# McNemar's test
mcnemar_test <- mcnemar.test(table(y_pred_DT==y_test_model, y_pred_LR==y_test_model))
print(mcnemar_test)







names(fits)



library(xgboost)
# assuming X_train_model numeric matrix and y_train_model numeric 0/1
dtrain <- xgb.DMatrix(data = as.matrix(X_train_model), label = as.numeric(y_train_model)-1)
params <- list(objective = "binary:logistic", eval_metric = "logloss")
fits$XGBoost <- xgb.train(params = params, data = dtrain, nrounds = 100)



y_pred_XGB <- factor(ifelse(predict(fits$XGBoost, as.matrix(X_test_model)) > 0.5, "LBW", "Normal"),
                     levels = c("Normal","LBW"))







# ---------------------------
# 1️⃣ Combine predictions for all models
# ---------------------------
pred_list <- list(
  "Decision Tree"       = factor(ifelse(predict(fits$DecisionTree, X_test_model)=="LBW","LBW","Normal"), levels=c("Normal","LBW")),
  "Random Forest"       = factor(ifelse(predict(fits$RandomForest, X_test_model)=="LBW","LBW","Normal"), levels=c("Normal","LBW")),
  "Logistic Regression" = factor(ifelse(predict(fits$LogisticRegression, X_test_model)=="LBW","LBW","Normal"), levels=c("Normal","LBW")),
  "SVM"                 = factor(ifelse(predict(fits$SVM, X_test_model)=="LBW","LBW","Normal"), levels=c("Normal","LBW")),
  "XGBoost"             = factor(ifelse(predict(fits$XGBoost, as.matrix(X_test_model)) > 0.5, "LBW", "Normal"), levels=c("Normal","LBW"))
)

# ---------------------------
# 2️⃣ Pairwise McNemar’s test
# ---------------------------
model_names <- names(pred_list)
results <- data.frame(Model1=character(), Model2=character(),
                      Chi2=numeric(), df=numeric(), p_value=numeric(),
                      stringsAsFactors = FALSE)

for(i in 1:(length(model_names)-1)){
  for(j in (i+1):length(model_names)){
    test <- mcnemar.test(table(pred_list[[model_names[i]]] == y_test_model,
                               pred_list[[model_names[j]]] == y_test_model))
    results <- rbind(results, data.frame(
      Model1 = model_names[i],
      Model2 = model_names[j],
      Chi2 = round(test$statistic,2),
      df = test$parameter,
      p_value = round(test$p.value,3)
    ))
  }
}

# ---------------------------
# 3️⃣ APA-style table ready for Word
# ---------------------------
results







