#### 16. LOAD FEATURE SELECTION PACKAGES ####

library(Boruta)
library(randomForest)
library(caret)
library(dplyr)






data <- read_dta("E:\\f drives\\Machine learning based\\LBW\\Data and Codes\\NP_clean.dta")





df <- data  # rename for convenience


####  Identify categorical columns ####

categorical_cols <- setdiff(colnames(df), "lbw")  # exclude target


####  Convert labelled columns to factors ####



library(dplyr)
library(haven)

df <- data

# Identify categorical columns (excluding target)
categorical_cols <- setdiff(names(df), "lbw")

# Convert safely
df[categorical_cols] <- lapply(df[categorical_cols], function(x) {
  if ("haven_labelled" %in% class(x)) {
    # Convert labelled (Stata) to factor using labels
    haven::as_factor(x, levels = "default")
  } else if (is.numeric(x)) {
    # Convert numeric categorical columns to factor
    as.factor(x)
  } else {
    x  # leave factor or character as-is
  }
})

# Check result
sapply(df, class)





#### 3. Impute missing values (mode / most frequent) ####

mode_impute <- function(x) {
  x[is.na(x)] <- names(sort(table(x), decreasing = TRUE))[1]
  return(x)
}

df[categorical_cols] <- lapply(df[categorical_cols], mode_impute)




#### 4. Encode categorical columns as numeric (0,1,2) ####

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










#### 17. CREATE TRAINING DATA FOR FEATURE SELECTION ####

# Feature selection will use TRAINING DATA ONLY

X_train_fs <- X_train_cat


#### 18. REMOVE BIRTH SIZE FROM PRIMARY ANALYSIS ####

# Reviewer concern:
# birth_size is closely related to the LBW outcome
# and may introduce outcome leakage

X_train_fs <- X_train_fs %>%
  dplyr::select(-birth_size)


cat("\nNumber of predictors after removing birth_size:\n")
print(ncol(X_train_fs))

cat("\nPredictors available for feature selection:\n")
print(names(X_train_fs))


#### 19. CONVERT REMAINING NUMERIC CATEGORICAL VARIABLES TO FACTORS ####

# These variables are categorical in the cleaned dataset
# but were imported as numeric

numeric_categorical <- c(
  "mat_edu",
  "toilet",
  "water"
)

for (v in numeric_categorical) {
  
  if (v %in% names(X_train_fs)) {
    
    X_train_fs[[v]] <- factor(
      X_train_fs[[v]]
    )
    
  }
}


#### 20. CHECK VARIABLE CLASSES ####

cat("\nClasses of training predictors before imputation:\n")

print(
  sapply(
    X_train_fs,
    class
  )
)


#### 21. DEFINE MODE FUNCTION ####

get_mode <- function(x) {
  
  x_nonmissing <- x[
    !is.na(x)
  ]
  
  if (length(x_nonmissing) == 0) {
    return(NA)
  }
  
  tab <- table(x_nonmissing)
  
  names(tab)[
    which.max(tab)
  ]
}


#### 22. CALCULATE IMPUTATION VALUES FROM TRAINING DATA ONLY ####

train_modes <- lapply(
  X_train_fs,
  get_mode
)


cat("\nTraining-derived modes:\n")
print(train_modes)


#### 23. IMPUTE MISSING VALUES IN TRAINING DATA ONLY ####

for (v in names(X_train_fs)) {
  
  mode_value <- train_modes[[v]]
  
  
  if (is.factor(X_train_fs[[v]])) {
    
    X_train_fs[[v]][
      is.na(X_train_fs[[v]])
    ] <- mode_value
    
  } else {
    
    X_train_fs[[v]][
      is.na(X_train_fs[[v]])
    ] <- as.numeric(mode_value)
    
  }
}


#### 24. CHECK MISSING VALUES AFTER IMPUTATION ####

cat("\nMissing values after training-only imputation:\n")

print(
  colSums(
    is.na(X_train_fs)
  )
)


cat(
  "\nTotal remaining missing values:",
  sum(is.na(X_train_fs)),
  "\n"
)


#### 25. PREPARE TRAINING OUTCOME ####

y_train_factor <- factor(
  y_train,
  levels = c(0, 1),
  labels = c("Normal", "LBW")
)


cat("\nTraining LBW distribution:\n")

print(
  table(y_train_factor)
)


#### 26. RUN BORUTA ON TRAINING DATA ONLY ####

set.seed(42)

boruta_result <- Boruta(
  x = X_train_fs,
  y = y_train_factor,
  maxRuns = 100,
  doTrace = 2
)


#### 27. CHECK BORUTA RESULTS ####

print(boruta_result)


boruta_stats <- attStats(
  boruta_result
)


boruta_stats <- boruta_stats[
  order(
    boruta_stats$meanImp,
    decreasing = TRUE
  ),
]


cat("\nBoruta feature statistics:\n")

print(
  boruta_stats
)


#### 28. GET CONFIRMED BORUTA FEATURES ####

selected_boruta <- getSelectedAttributes(
  boruta_result,
  withTentative = FALSE
)


cat("\nConfirmed features selected by Boruta:\n")

print(
  selected_boruta
)


cat(
  "\nNumber of confirmed Boruta features:",
  length(selected_boruta),
  "\n"
)


#### 29. CHECK TENTATIVE BORUTA FEATURES ####

tentative_boruta <- names(
  boruta_result$finalDecision[
    boruta_result$finalDecision == "Tentative"
  ]
)


cat("\nTentative Boruta features:\n")

print(
  tentative_boruta
)


#### 30. CREATE BORUTA TRAINING DATA ####

X_train_boruta <- X_train_fs[
  ,
  selected_boruta,
  drop = FALSE
]


cat(
  "\nBoruta training dimensions:",
  dim(X_train_boruta),
  "\n"
)


#### 31. PREPARE INDEPENDENT DATA FOR RFE ####

# IMPORTANT:
# RFE starts again from the full cleaned training predictor set
# It does NOT start from Boruta-selected variables

X_train_rfe_input <- X_train_fs


cat(
  "\nRFE input dimensions:",
  dim(X_train_rfe_input),
  "\n"
)




#### 32. CREATE CLASS-WEIGHTED RFE FUNCTIONS ####

rf_balanced_funcs <- rfFuncs


# Balanced Accuracy for feature selection
rf_balanced_funcs$summary <- function(data, lev = NULL, model = NULL) {
  
  data$obs <- factor(data$obs, levels = lev)
  data$pred <- factor(data$pred, levels = lev)
  
  cm <- caret::confusionMatrix(
    data = data$pred,
    reference = data$obs,
    positive = "LBW"
  )
  
  c(
    BalancedAccuracy = unname(cm$byClass["Balanced Accuracy"]),
    Sensitivity = unname(cm$byClass["Sensitivity"]),
    Specificity = unname(cm$byClass["Specificity"])
  )
}


# Class-weighted Random Forest
# Weights are calculated separately inside each CV training fold
rf_balanced_funcs$fit <- function(x, y, first, last, ...) {
  
  class_counts <- table(y)
  
  class_weights <- length(y) /
    (length(class_counts) * class_counts)
  
  class_weights <- as.numeric(class_weights)
  names(class_weights) <- names(class_counts)
  
  randomForest::randomForest(
    x = x,
    y = y,
    ntree = 500,
    importance = TRUE,
    classwt = class_weights
  )
}


#### 33. CREATE RFE CONTROL ####

set.seed(42)

rfe_ctrl <- rfeControl(
  functions = rf_balanced_funcs,
  method = "cv",
  number = 5,
  verbose = TRUE,
  returnResamp = "final"
)


#### 34. DEFINE RFE FEATURE SET SIZES ####

candidate_sizes <- c(
  5,
  10,
  15,
  20,
  25,
  ncol(X_train_rfe_input)
)

candidate_sizes <- unique(
  candidate_sizes[
    candidate_sizes <= ncol(X_train_rfe_input)
  ]
)

print(candidate_sizes)


#### 35. RE-RUN RFE ON TRAINING DATA ONLY ####

set.seed(42)

rfe_result <- rfe(
  x = X_train_rfe_input,
  y = y_train_factor,
  sizes = candidate_sizes,
  rfeControl = rfe_ctrl,
  metric = "BalancedAccuracy",
  maximize = TRUE
)



#### 36. CHECK RFE RESULTS ####

print(
  rfe_result
)


cat("\nRFE resampling results:\n")

print(
  rfe_result$results
)


#### 37. GET RFE-SELECTED FEATURES ####

selected_rfe <- predictors(
  rfe_result
)


cat("\nSelected features by RFE:\n")

print(
  selected_rfe
)


cat(
  "\nNumber of RFE-selected features:",
  length(selected_rfe),
  "\n"
)


#### 38. CREATE RFE TRAINING DATA ####

X_train_rfe <- X_train_fs[
  ,
  selected_rfe,
  drop = FALSE
]


cat(
  "\nRFE training dimensions:",
  dim(X_train_rfe),
  "\n"
)


#### 39. COMPARE BORUTA AND RFE FEATURES ####

cat("\nFeatures selected by Boruta:\n")

print(
  selected_boruta
)


cat("\nFeatures selected by RFE:\n")

print(
  selected_rfe
)


common_features <- intersect(
  selected_boruta,
  selected_rfe
)


cat("\nFeatures selected by BOTH Boruta and RFE:\n")

print(
  common_features
)


cat(
  "\nNumber of common features:",
  length(common_features),
  "\n"
)






#### 36. CHECK RFE RESULTS ####

print(rfe_result)
print(rfe_result$results)
selected_rfe <- predictors(rfe_result)
print(selected_rfe)








#### UPDATE COMMON FEATURES ####

common_features <- intersect(
  selected_boruta,
  selected_rfe
)

cat("\nFeatures selected by BOTH Boruta and RFE:\n")
print(common_features)

cat(
  "\nNumber of common features:",
  length(common_features),
  "\n"
)



















#### 41. BORUTA FEATURE IMPORTANCE PLOT ####

library(ggplot2)
library(dplyr)
library(stringr)
library(tidyr)
library(Boruta)
library(randomForest)

boruta_imp <- attStats(boruta_result)
boruta_imp$Feature <- rownames(boruta_imp)

boruta_df <- boruta_imp %>%
  filter(decision %in% c("Confirmed", "Tentative")) %>%
  arrange(meanImp) %>%
  mutate(
    Feature_label = gsub("_", " ", Feature),
    Feature_label = str_wrap(Feature_label, width = 18),
    Feature_label = factor(
      Feature_label,
      levels = Feature_label
    ),
    decision = factor(
      decision,
      levels = c("Confirmed", "Tentative")
    )
  )

p1 <- ggplot(
  boruta_df,
  aes(
    x = Feature_label,
    y = meanImp,
    fill = decision
  )
) +
  geom_col(
    width = 0.68,
    color = "gray35",
    linewidth = 0.25
  ) +
  coord_flip() +
  scale_fill_manual(
    values = c(
      "Confirmed" = "#2A9D8F",
      "Tentative" = "#E9C46A"
    )
  ) +
  labs(
    title = "Boruta Feature Importance",
    x = NULL,
    y = "Mean Importance",
    fill = "Decision"
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14,
      hjust = 0.5
    ),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    axis.title.x = element_text(
      size = 11,
      face = "bold"
    ),
    legend.position = "top",
    legend.title = element_text(face = "bold"),
    plot.margin = ggplot2::margin(
      t = 10,
      r = 15,
      b = 10,
      l = 15
    )
  )

print(p1)


#### 42. RFE FEATURE IMPORTANCE PLOT ####

rfe_importance <- randomForest::importance(
  rfe_result$fit,
  type = 2
)

if (
  is.matrix(rfe_importance) &&
  "MeanDecreaseGini" %in% colnames(rfe_importance)
) {
  
  rfe_values <- rfe_importance[, "MeanDecreaseGini"]
  
} else if (is.matrix(rfe_importance)) {
  
  rfe_values <- rfe_importance[, 1]
  
} else {
  
  rfe_values <- rfe_importance
}

rfe_df <- data.frame(
  Feature = rownames(rfe_importance),
  Importance = as.numeric(rfe_values)
) %>%
  filter(Feature %in% selected_rfe) %>%
  arrange(Importance) %>%
  mutate(
    Feature_label = gsub("_", " ", Feature),
    Feature_label = str_wrap(Feature_label, width = 18),
    Feature_label = factor(
      Feature_label,
      levels = Feature_label
    )
  )

p2 <- ggplot(
  rfe_df,
  aes(
    x = Feature_label,
    y = Importance
  )
) +
  geom_col(
    width = 0.68,
    fill = "#264653",
    color = "gray35",
    linewidth = 0.25
  ) +
  coord_flip() +
  labs(
    title = "RFE Feature Importance",
    x = NULL,
    y = "Mean Decrease Gini"
  ) +
  theme_classic(base_size = 12) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14,
      hjust = 0.5
    ),
    axis.text.y = element_text(size = 10),
    axis.text.x = element_text(size = 10),
    axis.title.x = element_text(
      size = 11,
      face = "bold"
    ),
    plot.margin = ggplot2::margin(
      t = 10,
      r = 15,
      b = 10,
      l = 15
    )
  )

print(p2)


#### 43. COMMON FEATURES SELECTED BY BORUTA AND RFE ####
#### 43. COMMON FEATURES SELECTED BY BORUTA AND RFE ####

common_features <- intersect(
  selected_boruta,
  selected_rfe
)

cat("\nCommon features selected by Boruta and RFE:\n")
print(common_features)

cat(
  "\nNumber of common features:",
  length(common_features),
  "\n"
)


common_df <- data.frame(
  Feature = common_features
) %>%
  left_join(
    boruta_imp %>%
      dplyr::select(
        Feature,
        Boruta = meanImp
      ),
    by = "Feature"
  ) %>%
  left_join(
    rfe_df %>%
      dplyr::select(
        Feature,
        RFE = Importance
      ),
    by = "Feature"
  ) %>%
  mutate(
    Boruta_normalized =
      100 * Boruta /
      max(Boruta, na.rm = TRUE),
    
    RFE_normalized =
      100 * RFE /
      max(RFE, na.rm = TRUE),
    
    Mean_normalized =
      (
        Boruta_normalized +
          RFE_normalized
      ) / 2
  ) %>%
  arrange(
    Mean_normalized
  )


common_long <- common_df %>%
  dplyr::select(
    Feature,
    Boruta_normalized,
    RFE_normalized
  ) %>%
  tidyr::pivot_longer(
    cols = c(
      Boruta_normalized,
      RFE_normalized
    ),
    names_to = "Method",
    values_to = "Importance"
  ) %>%
  mutate(
    Method = dplyr::recode(
      Method,
      "Boruta_normalized" = "Boruta",
      "RFE_normalized" = "RFE"
    ),
    
    Feature_label = gsub(
      "_",
      " ",
      Feature
    ),
    
    Feature_label = stringr::str_wrap(
      Feature_label,
      width = 18
    )
  )


feature_order <- common_df$Feature

feature_order <- gsub(
  "_",
  " ",
  feature_order
)

feature_order <- stringr::str_wrap(
  feature_order,
  width = 18
)


common_long$Feature_label <- factor(
  common_long$Feature_label,
  levels = feature_order
)


p3 <- ggplot(
  common_long,
  aes(
    x = Feature_label,
    y = Importance,
    fill = Method
  )
) +
  geom_col(
    position = position_dodge(
      width = 0.75
    ),
    width = 0.65,
    color = "gray35",
    linewidth = 0.25
  ) +
  coord_flip() +
  scale_fill_manual(
    values = c(
      "Boruta" = "#2A9D8F",
      "RFE" = "#264653"
    )
  ) +
  labs(
    title = "Common Features Selected by Boruta and RFE",
    x = NULL,
    y = "Normalized Importance (0–100)",
    fill = "Method"
  ) +
  theme_classic(
    base_size = 12
  ) +
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14,
      hjust = 0.5
    ),
    axis.text.y = element_text(
      size = 10
    ),
    axis.text.x = element_text(
      size = 10
    ),
    axis.title.x = element_text(
      size = 11,
      face = "bold"
    ),
    legend.position = "top",
    legend.title = element_text(
      face = "bold"
    ),
    plot.margin = ggplot2::margin(
      t = 10,
      r = 15,
      b = 10,
      l = 15
    )
  )

print(p3)





#### 44. BORUTA AND RFE SIDE-BY-SIDE ####

library(gridExtra)

grid.arrange(
  p1,
  p2,
  ncol = 2,
  widths = c(1, 1)
)











#### 44. PREPARE COMMON FEATURES FOR SMOTE AND MODELING ####

library(caret)
library(recipes)
library(themis)
library(dplyr)
library(ggplot2)
library(gridExtra)


# Use the features selected by BOTH Boruta and RFE

X_train_model <- X_train_cat[
  ,
  common_features,
  drop = FALSE
]

X_test_model <- X_test_cat[
  ,
  common_features,
  drop = FALSE
]


cat("\nCommon features used for modeling:\n")
print(common_features)

cat(
  "\nNumber of common features:",
  length(common_features),
  "\n"
)

cat(
  "\nTraining dimensions:",
  dim(X_train_model),
  "\n"
)

cat(
  "\nTest dimensions:",
  dim(X_test_model),
  "\n"
)


#### 45. CREATE TRAINING AND TEST MODEL DATA ####

train_model <- X_train_model %>%
  mutate(
    lbw = factor(
      y_train,
      levels = c(1, 0),
      labels = c("LBW", "Normal")
    )
  )


test_model <- X_test_model %>%
  mutate(
    lbw = factor(
      y_test,
      levels = c(1, 0),
      labels = c("LBW", "Normal")
    )
  )


cat("\nTraining class distribution before SMOTE:\n")
print(
  table(train_model$lbw)
)

cat("\nTraining class percentages before SMOTE:\n")
print(
  round(
    prop.table(
      table(train_model$lbw)
    ) * 100,
    2
  )
)


cat("\nTest class distribution:\n")
print(
  table(test_model$lbw)
)

cat("\nTest class percentages:\n")
print(
  round(
    prop.table(
      table(test_model$lbw)
    ) * 100,
    2
  )
)


#### 46. CREATE SAFE DUMMY VARIABLE NAMES ####

safe_dummy_names <- function(
    var,
    lvl,
    ordinal = FALSE
) {
  
  safe_lvl <- make.names(
    lvl,
    unique = TRUE
  )
  
  paste(
    var,
    safe_lvl,
    sep = "_"
  )
}


#### 47. CREATE LEAKAGE-SAFE SMOTENC RECIPE ####

smote_recipe <- recipe(
  lbw ~ .,
  data = train_model
) %>%
  
  # Handle possible new factor levels
  step_novel(
    all_nominal_predictors()
  ) %>%
  
  # Mode imputation learned from training/resampling data only
  step_impute_mode(
    all_nominal_predictors()
  ) %>%
  
  # Safety for any numeric predictor
  step_impute_median(
    all_numeric_predictors()
  ) %>%
  
  # Apply SMOTENC before dummy encoding
  # over_ratio = 1 creates approximately equal classes
  # skip = TRUE prevents oversampling of new/test data
  themis::step_smotenc(
    lbw,
    over_ratio = 1,
    neighbors = 5,
    skip = TRUE
  ) %>%
  
  # Convert factors to dummy variables after SMOTENC
  # Custom naming prevents duplicated dummy-variable names
  step_dummy(
    all_nominal_predictors(),
    one_hot = FALSE,
    naming = safe_dummy_names
  ) %>%
  
  # Remove zero-variance predictors
  step_zv(
    all_predictors()
  )


#### 48. CREATE CROSS-VALIDATION CONTROL ####

set.seed(42)

model_control <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 5,
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  savePredictions = "final",
  allowParallel = TRUE
)


#### 49. CREATE SMOTE PREVIEW FOR CHECKING ONLY ####

# IMPORTANT:
# smote_preview is ONLY for checking class balance
# and visualization.
#
# Do NOT use smote_preview directly for final model training.
#
# Final models will use:
# smote_recipe + model_control

set.seed(42)

smote_preview_prep <- prep(
  smote_recipe,
  training = train_model,
  retain = TRUE
)


smote_preview <- juice(
  smote_preview_prep
)


cat("\nClass distribution BEFORE SMOTE:\n")
print(
  table(train_model$lbw)
)


cat("\nClass percentages BEFORE SMOTE:\n")
print(
  round(
    prop.table(
      table(train_model$lbw)
    ) * 100,
    2
  )
)


cat("\nClass distribution AFTER SMOTE:\n")
print(
  table(smote_preview$lbw)
)


cat("\nClass percentages AFTER SMOTE:\n")
print(
  round(
    prop.table(
      table(smote_preview$lbw)
    ) * 100,
    2
  )
)


cat("\nTest data remains untouched:\n")
print(
  table(test_model$lbw)
)


#### 50. PREPARE DATA FOR SMOTE FIGURE ####

pre_smote_counts <- table(
  train_model$lbw
)

after_smote_counts <- table(
  smote_preview$lbw
)


df_before <- data.frame(
  LBW = names(pre_smote_counts),
  Count = as.numeric(pre_smote_counts),
  Status = "Before SMOTE"
)


df_after <- data.frame(
  LBW = names(after_smote_counts),
  Count = as.numeric(after_smote_counts),
  Status = "After SMOTE"
)


df_bar <- bind_rows(
  df_before,
  df_after
) %>%
  group_by(Status) %>%
  mutate(
    Percent = Count / sum(Count) * 100,
    
    Label = paste0(
      Count,
      "\n(",
      round(Percent, 1),
      "%)"
    )
  ) %>%
  ungroup()


df_bar$Status <- factor(
  df_bar$Status,
  levels = c(
    "Before SMOTE",
    "After SMOTE"
  )
)


df_bar$LBW <- factor(
  df_bar$LBW,
  levels = c(
    "Normal",
    "LBW"
  )
)


#### 51. SMOTE BAR FIGURE ####

bar_plot <- ggplot(
  df_bar,
  aes(
    x = Status,
    y = Count,
    fill = LBW
  )
) +
  
  geom_col(
    position = position_dodge(
      width = 0.75
    ),
    width = 0.65,
    color = "white"
  ) +
  
  geom_text(
    aes(
      label = Label
    ),
    position = position_dodge(
      width = 0.75
    ),
    vjust = -0.35,
    size = 4.3,
    fontface = "bold"
  ) +
  
  scale_fill_manual(
    values = c(
      "Normal" = "#80B3FF",
      "LBW" = "#FF9999"
    )
  ) +
  
  labs(
    title = "Class Distribution Before and After SMOTE",
    x = NULL,
    y = "Number of Observations",
    fill = "Birth Weight Status"
  ) +
  
  expand_limits(
    y = max(df_bar$Count) * 1.12
  ) +
  
  theme_classic(
    base_size = 13
  ) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      hjust = 0.5,
      size = 15
    ),
    
    axis.title.y = element_text(
      face = "bold"
    ),
    
    axis.text = element_text(
      size = 11
    ),
    
    legend.position = "top",
    
    legend.title = element_text(
      face = "bold"
    )
  )


print(bar_plot)


#### 52. SMOTE PIE FIGURES ####

create_pie <- function(
    counts,
    title
) {
  
  pie_df <- data.frame(
    LBW = names(counts),
    Count = as.numeric(counts)
  ) %>%
    
    mutate(
      Percent = Count / sum(Count) * 100,
      
      Label = paste0(
        round(Percent, 1),
        "%"
      )
    )
  
  
  pie_df$LBW <- factor(
    pie_df$LBW,
    levels = c(
      "Normal",
      "LBW"
    )
  )
  
  
  ggplot(
    pie_df,
    aes(
      x = "",
      y = Count,
      fill = LBW
    )
  ) +
    
    geom_col(
      width = 1,
      color = "white"
    ) +
    
    coord_polar(
      theta = "y"
    ) +
    
    geom_text(
      aes(
        label = Label
      ),
      position = position_stack(
        vjust = 0.5
      ),
      size = 5,
      fontface = "bold"
    ) +
    
    scale_fill_manual(
      values = c(
        "Normal" = "#80B3FF",
        "LBW" = "#FF9999"
      )
    ) +
    
    labs(
      title = title,
      fill = "Birth Weight Status"
    ) +
    
    theme_void() +
    
    theme(
      plot.title = element_text(
        face = "bold",
        hjust = 0.5,
        size = 14
      )
    )
}


pie_before <- create_pie(
  pre_smote_counts,
  "Before SMOTE"
)


pie_after <- create_pie(
  after_smote_counts,
  "After SMOTE"
)


gridExtra::grid.arrange(
  pie_before,
  pie_after,
  ncol = 2
)











#### 53. MACHINE LEARNING MODELS WITHOUT SURVEY WEIGHTS ####

library(caret)
library(recipes)
library(themis)
library(pROC)
library(dplyr)
library(tidyr)
library(ggplot2)
library(randomForest)
library(rpart)
library(kernlab)
library(xgboost)


# IMPORTANT:
# This section intentionally fits UNWEIGHTED predictive ML models.
# DHS survey weights should be used separately for prevalence,
# descriptive statistics, and geographic inequality estimates.
#
# Modeling uses:
# - 8 common Boruta + RFE predictors
# - training data only for model development
# - SMOTENC inside CV through the recipe
# - untouched original test data for final evaluation


#### 54. CHECK TRAINING AND TEST OUTCOMES ####

train_model$lbw <- factor(
  train_model$lbw,
  levels = c("LBW", "Normal")
)

test_model$lbw <- factor(
  test_model$lbw,
  levels = c("LBW", "Normal")
)


cat("\nTraining outcome:\n")
print(table(train_model$lbw))

cat("\nTest outcome:\n")
print(table(test_model$lbw))


#### 55. CREATE FINAL MODELING RECIPE ####

# Start from the previously created leakage-safe SMOTENC recipe.
# Add normalization after dummy encoding.
#
# Scaling is particularly important for SVM.
# Tree-based models are not adversely affected by linear scaling.

model_recipe <- smote_recipe %>%
  step_normalize(
    all_numeric_predictors()
  )


#### 56. DETERMINE FINAL NUMBER OF MODEL PREDICTORS ####

# Only used to construct a valid RF mtry grid.
# No test data are used here.

set.seed(42)

recipe_preview <- prep(
  model_recipe,
  training = train_model,
  retain = TRUE
)

recipe_preview_data <- juice(
  recipe_preview
)

number_model_predictors <- ncol(
  recipe_preview_data
) - 1


cat(
  "\nNumber of predictors after preprocessing:",
  number_model_predictors,
  "\n"
)


#### 57. CREATE IDENTICAL REPEATED CV FOLDS FOR ALL MODELS ####

set.seed(42)

cv_index <- createMultiFolds(
  train_model$lbw,
  k = 5,
  times = 5
)


cv_index_out <- lapply(
  cv_index,
  function(x) {
    setdiff(
      seq_len(nrow(train_model)),
      x
    )
  }
)


#### 58. CREATE REPRODUCIBLE SEEDS ####

set.seed(42)

cv_seeds <- vector(
  mode = "list",
  length = length(cv_index) + 1
)


for (i in seq_along(cv_index)) {
  
  cv_seeds[[i]] <- sample.int(
    1000000,
    100
  )
}


cv_seeds[[length(cv_index) + 1]] <- sample.int(
  1000000,
  1
)


#### 59. CREATE MODEL TRAINING CONTROL ####

model_control_final <- trainControl(
  method = "repeatedcv",
  number = 5,
  repeats = 5,
  
  index = cv_index,
  indexOut = cv_index_out,
  
  classProbs = TRUE,
  summaryFunction = twoClassSummary,
  
  savePredictions = "final",
  returnResamp = "final",
  
  selectionFunction = "best",
  
  seeds = cv_seeds,
  
  allowParallel = TRUE
)


#### 60. DECISION TREE TUNING GRID ####

dt_grid <- expand.grid(
  cp = c(
    0.001,
    0.005,
    0.010,
    0.020,
    0.050
  )
)


#### 61. RANDOM FOREST TUNING GRID ####

rf_candidates <- c(
  2,
  4,
  6,
  8,
  10,
  12
)


rf_candidates <- unique(
  pmin(
    rf_candidates,
    number_model_predictors
  )
)


rf_candidates <- rf_candidates[
  rf_candidates >= 1
]


rf_grid <- expand.grid(
  mtry = rf_candidates
)


cat("\nRandom Forest mtry grid:\n")
print(rf_grid)


#### 62. SVM RADIAL TUNING GRID ####

svm_grid <- expand.grid(
  
  sigma = c(
    0.005,
    0.010,
    0.020,
    0.050
  ),
  
  C = c(
    0.5,
    1,
    2,
    4
  )
)


#### 63. XGBOOST TUNING GRID ####

# All combinations are evaluated ONLY through training CV.
# Test-set performance is NOT used for tuning.

xgb_grid <- expand.grid(
  
  nrounds = c(
    100,
    200
  ),
  
  max_depth = c(
    2,
    4
  ),
  
  eta = c(
    0.03,
    0.10
  ),
  
  gamma = 0,
  
  colsample_bytree = 0.80,
  
  min_child_weight = c(
    1,
    5
  ),
  
  subsample = 0.80
)


cat(
  "\nNumber of XGBoost tuning combinations:",
  nrow(xgb_grid),
  "\n"
)


#### 64. TRAIN LOGISTIC REGRESSION ####

cat("\nTraining Logistic Regression...\n")

set.seed(42)

fit_lr <- caret::train(
  model_recipe,
  data = train_model,
  
  method = "glm",
  
  family = binomial(),
  
  metric = "ROC",
  
  trControl = model_control_final
)


#### 65. TRAIN DECISION TREE ####

cat("\nTraining Decision Tree...\n")

set.seed(42)

fit_dt <- caret::train(
  model_recipe,
  data = train_model,
  
  method = "rpart",
  
  tuneGrid = dt_grid,
  
  metric = "ROC",
  
  trControl = model_control_final
)


#### 66. TRAIN RANDOM FOREST ####

cat("\nTraining Random Forest...\n")

set.seed(42)

fit_rf <- caret::train(
  model_recipe,
  data = train_model,
  
  method = "rf",
  
  tuneGrid = rf_grid,
  
  metric = "ROC",
  
  ntree = 1000,
  
  importance = TRUE,
  
  trControl = model_control_final
)


#### 67. TRAIN SUPPORT VECTOR MACHINE ####

cat("\nTraining Support Vector Machine...\n")

set.seed(42)

fit_svm <- caret::train(
  model_recipe,
  data = train_model,
  
  method = "svmRadial",
  
  tuneGrid = svm_grid,
  
  metric = "ROC",
  
  trControl = model_control_final
)


#### 68. TRAIN XGBOOST ####

cat("\nTraining XGBoost...\n")

set.seed(42)

fit_xgb <- caret::train(
  model_recipe,
  data = train_model,
  
  method = "xgbTree",
  
  tuneGrid = xgb_grid,
  
  metric = "ROC",
  
  trControl = model_control_final,
  
  verbose = FALSE
)


#### 69. STORE ALL FITTED MODELS ####

model_fits <- list(
  
  LogisticRegression = fit_lr,
  
  DecisionTree = fit_dt,
  
  RandomForest = fit_rf,
  
  SVM = fit_svm,
  
  XGBoost = fit_xgb
)


#### 70. DISPLAY BEST HYPERPARAMETERS ####

cat("\nLOGISTIC REGRESSION:\n")
print(fit_lr$bestTune)

cat("\nDECISION TREE BEST TUNE:\n")
print(fit_dt$bestTune)

cat("\nRANDOM FOREST BEST TUNE:\n")
print(fit_rf$bestTune)

cat("\nSVM BEST TUNE:\n")
print(fit_svm$bestTune)

cat("\nXGBOOST BEST TUNE:\n")
print(fit_xgb$bestTune)


#### 71. CREATE TEST PREDICTOR DATA ####

# Remove outcome from newdata.
# This remains the ORIGINAL non-SMOTE test set.

test_predictors <- test_model[
  ,
  setdiff(
    names(test_model),
    "lbw"
  ),
  drop = FALSE
]


#### 72. DEFINE SAFE DIVISION FUNCTION ####

safe_divide <- function(
    numerator,
    denominator
) {
  
  if (
    is.na(denominator) ||
    denominator == 0
  ) {
    
    return(NA_real_)
    
  }
  
  numerator / denominator
}


#### 73. DEFINE AVERAGE PRECISION FUNCTION ####

average_precision <- function(
    actual,
    probability
) {
  
  ordering <- order(
    probability,
    decreasing = TRUE
  )
  
  actual_sorted <- actual[
    ordering
  ]
  
  cumulative_true_positive <- cumsum(
    actual_sorted == 1
  )
  
  precision_at_rank <-
    cumulative_true_positive /
    seq_along(actual_sorted)
  
  positive_positions <- which(
    actual_sorted == 1
  )
  
  if (
    length(positive_positions) == 0
  ) {
    
    return(NA_real_)
    
  }
  
  mean(
    precision_at_rank[
      positive_positions
    ]
  )
}


#### 74. DEFINE FAST AUC FUNCTION ####

fast_auc <- function(
    actual,
    probability
) {
  
  n_positive <- sum(
    actual == 1
  )
  
  n_negative <- sum(
    actual == 0
  )
  
  
  if (
    n_positive == 0 ||
    n_negative == 0
  ) {
    
    return(NA_real_)
    
  }
  
  
  probability_ranks <- rank(
    probability,
    ties.method = "average"
  )
  
  
  (
    sum(
      probability_ranks[
        actual == 1
      ]
    ) -
      n_positive *
      (n_positive + 1) / 2
  ) /
    (
      n_positive *
        n_negative
    )
}


#### 75. DEFINE PERFORMANCE METRIC FUNCTION ####

calculate_metrics <- function(
    actual,
    probability,
    threshold = 0.50
) {
  
  probability <- pmin(
    pmax(
      probability,
      1e-6
    ),
    1 - 1e-6
  )
  
  
  predicted <- ifelse(
    probability >= threshold,
    1,
    0
  )
  
  
  TP <- sum(
    predicted == 1 &
      actual == 1
  )
  
  TN <- sum(
    predicted == 0 &
      actual == 0
  )
  
  FP <- sum(
    predicted == 1 &
      actual == 0
  )
  
  FN <- sum(
    predicted == 0 &
      actual == 1
  )
  
  
  N <- length(actual)
  
  
  accuracy <- safe_divide(
    TP + TN,
    N
  )
  
  
  sensitivity <- safe_divide(
    TP,
    TP + FN
  )
  
  
  specificity <- safe_divide(
    TN,
    TN + FP
  )
  
  
  precision <- safe_divide(
    TP,
    TP + FP
  )
  
  
  npv <- safe_divide(
    TN,
    TN + FN
  )
  
  
  f1_score <- safe_divide(
    2 * precision * sensitivity,
    precision + sensitivity
  )
  
  
  balanced_accuracy <- mean(
    c(
      sensitivity,
      specificity
    ),
    na.rm = TRUE
  )
  
  
  gmean <- sqrt(
    sensitivity *
      specificity
  )
  
  
  youden_j <-
    sensitivity +
    specificity -
    1
  
  
  mcc_denominator <- sqrt(
    (TP + FP) *
      (TP + FN) *
      (TN + FP) *
      (TN + FN)
  )
  
  
  mcc <- ifelse(
    mcc_denominator == 0,
    NA_real_,
    (
      TP * TN -
        FP * FN
    ) /
      mcc_denominator
  )
  
  
  observed_positive <- safe_divide(
    TP + FN,
    N
  )
  
  observed_negative <- safe_divide(
    TN + FP,
    N
  )
  
  predicted_positive <- safe_divide(
    TP + FP,
    N
  )
  
  predicted_negative <- safe_divide(
    TN + FN,
    N
  )
  
  
  expected_accuracy <-
    observed_positive *
    predicted_positive +
    observed_negative *
    predicted_negative
  
  
  kappa <- ifelse(
    is.na(expected_accuracy) ||
      expected_accuracy == 1,
    NA_real_,
    (
      accuracy -
        expected_accuracy
    ) /
      (
        1 -
          expected_accuracy
      )
  )
  
  
  auc_roc <- fast_auc(
    actual,
    probability
  )
  
  
  avg_precision <- average_precision(
    actual,
    probability
  )
  
  
  brier_score <- mean(
    (
      actual -
        probability
    )^2
  )
  
  
  log_loss <- -mean(
    actual *
      log(probability) +
      (
        1 - actual
      ) *
      log(
        1 - probability
      )
  )
  
  
  linear_predictor <- qlogis(
    probability
  )
  
  
  calibration_intercept <- tryCatch(
    {
      
      calibration_intercept_model <- glm(
        actual ~ 1 +
          offset(linear_predictor),
        family = binomial()
      )
      
      as.numeric(
        coef(
          calibration_intercept_model
        )[1]
      )
      
    },
    error = function(e) {
      NA_real_
    }
  )
  
  
  calibration_slope <- tryCatch(
    {
      
      calibration_slope_model <- glm(
        actual ~ linear_predictor,
        family = binomial()
      )
      
      as.numeric(
        coef(
          calibration_slope_model
        )[2]
      )
      
    },
    error = function(e) {
      NA_real_
    }
  )
  
  
  c(
    
    Accuracy = accuracy,
    
    Sensitivity = sensitivity,
    
    Specificity = specificity,
    
    Precision_PPV = precision,
    
    NPV = npv,
    
    F1_Score = f1_score,
    
    Balanced_Accuracy =
      balanced_accuracy,
    
    GMean = gmean,
    
    MCC = mcc,
    
    Kappa = kappa,
    
    Youden_J = youden_j,
    
    AUC_ROC = auc_roc,
    
    Average_Precision =
      avg_precision,
    
    Brier_Score =
      brier_score,
    
    Log_Loss =
      log_loss,
    
    Calibration_Intercept =
      calibration_intercept,
    
    Calibration_Slope =
      calibration_slope
  )
}


#### 76. DEFINE CONFUSION MATRIX COUNT FUNCTION ####

calculate_confusion_counts <- function(
    actual,
    probability,
    threshold = 0.50
) {
  
  predicted <- ifelse(
    probability >= threshold,
    1,
    0
  )
  
  
  c(
    
    TP = sum(
      predicted == 1 &
        actual == 1
    ),
    
    TN = sum(
      predicted == 0 &
        actual == 0
    ),
    
    FP = sum(
      predicted == 1 &
        actual == 0
    ),
    
    FN = sum(
      predicted == 0 &
        actual == 1
    )
  )
}


#### 77. DEFINE STRATIFIED BOOTSTRAP 95% CI FUNCTION ####

bootstrap_metric_ci <- function(
    actual,
    probability,
    threshold = 0.50,
    B = 2000,
    seed = 2026
) {
  
  positive_indices <- which(
    actual == 1
  )
  
  negative_indices <- which(
    actual == 0
  )
  
  
  point_metrics <- calculate_metrics(
    actual,
    probability,
    threshold
  )
  
  
  set.seed(seed)
  
  
  bootstrap_results <- matrix(
    NA_real_,
    nrow = B,
    ncol = length(
      point_metrics
    )
  )
  
  
  colnames(
    bootstrap_results
  ) <- names(
    point_metrics
  )
  
  
  for (
    b in seq_len(B)
  ) {
    
    bootstrap_positive <- sample(
      positive_indices,
      size = length(
        positive_indices
      ),
      replace = TRUE
    )
    
    
    bootstrap_negative <- sample(
      negative_indices,
      size = length(
        negative_indices
      ),
      replace = TRUE
    )
    
    
    bootstrap_indices <- c(
      bootstrap_positive,
      bootstrap_negative
    )
    
    
    bootstrap_results[
      b,
    ] <- calculate_metrics(
      
      actual[
        bootstrap_indices
      ],
      
      probability[
        bootstrap_indices
      ],
      
      threshold
    )
  }
  
  
  safe_ci <- function(x) {
    
    x <- x[
      is.finite(x)
    ]
    
    
    if (
      length(x) == 0
    ) {
      
      return(
        c(
          NA_real_,
          NA_real_
        )
      )
      
    }
    
    
    as.numeric(
      quantile(
        x,
        probs = c(
          0.025,
          0.975
        ),
        na.rm = TRUE
      )
    )
  }
  
  
  ci_matrix <- t(
    apply(
      bootstrap_results,
      2,
      safe_ci
    )
  )
  
  
  colnames(
    ci_matrix
  ) <- c(
    "Lower_95CI",
    "Upper_95CI"
  )
  
  
  list(
    
    point = point_metrics,
    
    ci = ci_matrix,
    
    bootstrap = bootstrap_results
  )
}









#### 78. NUMBER OF BOOTSTRAP REPLICATES ####

BOOT_B <- 2000


#### 79. EVALUATE EACH MODEL ON UNTOUCHED TEST DATA ####

evaluation_results <- list()
prediction_results <- list()
confusion_results <- list()


# Convert true test outcome to numeric:
# 1 = LBW
# 0 = Normal
actual_test_numeric <- ifelse(
  test_model$lbw == "LBW",
  1,
  0
)


# Final check
stopifnot(
  length(actual_test_numeric) == nrow(test_predictors)
)


for (model_name in names(model_fits)) {
  
  cat(
    "\nEvaluating",
    model_name,
    "on untouched test data...\n"
  )
  
  
  #### GET CURRENT MODEL ####
  
  current_model <- model_fits[[model_name]]
  
  
  #### PREDICT LBW PROBABILITY ON UNTOUCHED TEST DATA ####
  
  predicted_probability <- predict(
    current_model,
    newdata = test_predictors,
    type = "prob"
  )[, "LBW"]
  
  
  predicted_probability <- as.numeric(
    predicted_probability
  )
  
  
  # Safety check
  if (
    length(predicted_probability) !=
    length(actual_test_numeric)
  ) {
    
    stop(
      paste(
        "Prediction length mismatch for model:",
        model_name
      )
    )
  }
  
  
  if (anyNA(predicted_probability)) {
    
    stop(
      paste(
        "Missing predicted probabilities detected for model:",
        model_name
      )
    )
  }
  
  
  #### PERFORMANCE METRICS + BOOTSTRAP 95% CI ####
  
  current_evaluation <- bootstrap_metric_ci(
    actual = actual_test_numeric,
    probability = predicted_probability,
    threshold = 0.50,
    B = BOOT_B,
    seed = 2026
  )
  
  
  point_metrics <- current_evaluation$point
  ci_metrics <- current_evaluation$ci
  
  
  #### ROC-AUC + DELONG 95% CI ####
  
  roc_object <- pROC::roc(
    response = actual_test_numeric,
    predictor = predicted_probability,
    levels = c(0, 1),
    direction = "<",
    quiet = TRUE
  )
  
  
  auc_delong_ci <- tryCatch(
    
    as.numeric(
      pROC::ci.auc(
        roc_object,
        conf.level = 0.95,
        method = "delong"
      )
    ),
    
    error = function(e) {
      
      c(
        NA_real_,
        NA_real_,
        NA_real_
      )
    }
  )
  
  
  # Replace bootstrap AUC CI with DeLong AUC CI
  if (
    "AUC_ROC" %in% rownames(ci_metrics)
  ) {
    
    ci_metrics[
      "AUC_ROC",
      "Lower_95CI"
    ] <- auc_delong_ci[1]
    
    
    ci_metrics[
      "AUC_ROC",
      "Upper_95CI"
    ] <- auc_delong_ci[3]
  }
  
  
  #### SAVE PERFORMANCE RESULTS ####
  
  evaluation_results[[model_name]] <- data.frame(
    
    Model = model_name,
    
    Metric = names(point_metrics),
    
    Estimate = as.numeric(
      point_metrics
    ),
    
    Lower_95CI = as.numeric(
      ci_metrics[
        names(point_metrics),
        "Lower_95CI"
      ]
    ),
    
    Upper_95CI = as.numeric(
      ci_metrics[
        names(point_metrics),
        "Upper_95CI"
      ]
    ),
    
    row.names = NULL
  )
  
  
  #### CONFUSION MATRIX COUNTS ####
  
  confusion_counts <- calculate_confusion_counts(
    actual = actual_test_numeric,
    probability = predicted_probability,
    threshold = 0.50
  )
  
  
  confusion_results[[model_name]] <- data.frame(
    
    Model = model_name,
    
    TP = as.numeric(
      confusion_counts["TP"]
    ),
    
    TN = as.numeric(
      confusion_counts["TN"]
    ),
    
    FP = as.numeric(
      confusion_counts["FP"]
    ),
    
    FN = as.numeric(
      confusion_counts["FN"]
    ),
    
    row.names = NULL
  )
  
  
  #### SAVE INDIVIDUAL-LEVEL PREDICTIONS ####
  
  prediction_results[[model_name]] <- data.frame(
    
    Model = model_name,
    
    Actual = actual_test_numeric,
    
    Probability = predicted_probability,
    
    Predicted_Class = ifelse(
      predicted_probability >= 0.50,
      "LBW",
      "Normal"
    )
  )
  
  
  cat(
    "Completed:",
    model_name,
    "\n"
  )
}




#### 80. COMBINE NUMERIC PERFORMANCE RESULTS ####

results_long <- bind_rows(
  evaluation_results
)


results_long <- results_long %>%
  mutate(
    
    Estimate =
      round(
        Estimate,
        4
      ),
    
    Lower_95CI =
      round(
        Lower_95CI,
        4
      ),
    
    Upper_95CI =
      round(
        Upper_95CI,
        4
      )
  )


cat(
  "\nComplete performance results with 95% CI:\n"
)

print(
  results_long
)


#### 81. FORMAT RESULTS AS JOURNAL TABLE ####

results_journal <- results_long %>%
  
  mutate(
    
    Estimate_95CI = paste0(
      
      sprintf(
        "%.3f",
        Estimate
      ),
      
      " (",
      
      sprintf(
        "%.3f",
        Lower_95CI
      ),
      
      "–",
      
      sprintf(
        "%.3f",
        Upper_95CI
      ),
      
      ")"
    )
  ) %>%
  
  dplyr::select(
    
    Model,
    
    Metric,
    
    Estimate_95CI
  ) %>%
  
  tidyr::pivot_wider(
    
    names_from =
      Metric,
    
    values_from =
      Estimate_95CI
  )


cat(
  "\nJournal-ready performance table:\n"
)

print(
  results_journal,
  width = Inf
)


#### 82. CONFUSION MATRIX COUNTS ####

confusion_table <- bind_rows(
  confusion_results
)


cat(
  "\nConfusion matrix counts at threshold = 0.50:\n"
)

print(
  confusion_table
)



#### 83. SAVE JOURNAL TABLES ####

output_path <- "E:\\f drives\\Machine learning based\\LBW\\Updated Analysis\\Nepal\\Table"

# Create folder if it does not exist
if (!dir.exists(output_path)) {
  dir.create(
    output_path,
    recursive = TRUE
  )
}


# Save journal-ready performance table
write.csv(
  results_journal,
  file = file.path(
    output_path,
    "Nepal_Model_Performance_95CI.csv"
  ),
  row.names = FALSE
)


# Save confusion matrix counts
write.csv(
  confusion_table,
  file = file.path(
    output_path,
    "Nepal_Confusion_Matrix_Counts.csv"
  ),
  row.names = FALSE
)


cat(
  "\nFiles successfully saved in:\n",
  output_path,
  "\n"
)



#### 83. CREATE CALIBRATION DATA ####

prediction_data <- dplyr::bind_rows(
  prediction_results
)


calibration_data <- prediction_data %>%
  
  dplyr::group_by(
    Model
  ) %>%
  
  dplyr::mutate(
    
    Calibration_Group = dplyr::ntile(
      Probability,
      10
    )
  ) %>%
  
  dplyr::group_by(
    Model,
    Calibration_Group
  ) %>%
  
  dplyr::summarise(
    
    Mean_Predicted_Risk = mean(
      Probability,
      na.rm = TRUE
    ),
    
    Observed_LBW = mean(
      Actual,
      na.rm = TRUE
    ),
    
    N = dplyr::n(),
    
    .groups = "drop"
  )


cat("\nCalibration data:\n")

print(
  calibration_data
)


#### 84. CALIBRATION PLOTS ####

calibration_plot <- ggplot2::ggplot(
  
  calibration_data,
  
  ggplot2::aes(
    x = Mean_Predicted_Risk,
    y = Observed_LBW
  )
  
) +
  
  ggplot2::geom_abline(
    intercept = 0,
    slope = 1,
    linetype = "dashed",
    linewidth = 0.6,
    color = "gray40"
  ) +
  
  ggplot2::geom_line(
    ggplot2::aes(
      group = 1
    ),
    linewidth = 0.8
  ) +
  
  ggplot2::geom_point(
    size = 2.5
  ) +
  
  ggplot2::facet_wrap(
    ~ Model,
    ncol = 3
  ) +
  
  ggplot2::coord_equal(
    xlim = c(0, 1),
    ylim = c(0, 1)
  ) +
  
  ggplot2::labs(
    title = "Calibration of Low Birth Weight Prediction Models",
    x = "Mean Predicted Probability",
    y = "Observed LBW Proportion"
  ) +
  
  ggplot2::theme_classic(
    base_size = 12
  ) +
  
  ggplot2::theme(
    
    plot.title = ggplot2::element_text(
      face = "bold",
      hjust = 0.5,
      size = 14
    ),
    
    strip.text = ggplot2::element_text(
      face = "bold",
      size = 10
    ),
    
    axis.title = ggplot2::element_text(
      face = "bold"
    ),
    
    axis.text = ggplot2::element_text(
      size = 10
    )
  )


print(
  calibration_plot
)






#### 84. STYLISH CALIBRATION PLOTS ####

model_colors <- c(
  "LogisticRegression" = "#0072B2",
  "DecisionTree"       = "#D55E00",
  "RandomForest"       = "#009E73",
  "SVM"                = "#CC79A7",
  "XGBoost"            = "#E69F00"
)


calibration_plot <- ggplot2::ggplot(
  calibration_data,
  ggplot2::aes(
    x = Mean_Predicted_Risk,
    y = Observed_LBW,
    color = Model
  )
) +
  
  # Perfect calibration reference line
  ggplot2::geom_abline(
    intercept = 0,
    slope = 1,
    linetype = "dashed",
    linewidth = 0.8,
    color = "gray40"
  ) +
  
  # Calibration curve
  ggplot2::geom_line(
    ggplot2::aes(group = Model),
    linewidth = 1.2,
    alpha = 0.90
  ) +
  
  # Calibration points
  ggplot2::geom_point(
    ggplot2::aes(fill = Model),
    shape = 21,
    size = 3.8,
    stroke = 0.8,
    color = "white"
  ) +
  
  # Separate panel for each model
  ggplot2::facet_wrap(
    ~ Model,
    ncol = 3
  ) +
  
  # Professional model colors
  ggplot2::scale_color_manual(
    values = model_colors
  ) +
  
  ggplot2::scale_fill_manual(
    values = model_colors
  ) +
  
  # Probability scale
  ggplot2::scale_x_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = scales::label_number(
      accuracy = 0.1
    )
  ) +
  
  ggplot2::scale_y_continuous(
    limits = c(0, 1),
    breaks = seq(0, 1, by = 0.2),
    labels = scales::label_number(
      accuracy = 0.1
    )
  ) +
  
  ggplot2::coord_equal() +
  
  ggplot2::labs(
    title = "Calibration of Low Birth Weight Prediction Models",
    subtitle = "Observed versus predicted probabilities in the independent test set",
    x = "Mean Predicted Probability",
    y = "Observed LBW Proportion"
  ) +
  
  ggplot2::theme_minimal(
    base_size = 12
  ) +
  
  ggplot2::theme(
    
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 16,
      hjust = 0.5
    ),
    
    plot.subtitle = ggplot2::element_text(
      size = 11,
      hjust = 0.5,
      color = "gray35",
      margin = ggplot2::margin(
        b = 12
      )
    ),
    
    strip.text = ggplot2::element_text(
      face = "bold",
      size = 11
    ),
    
    strip.background = ggplot2::element_rect(
      fill = "gray95",
      color = "gray75",
      linewidth = 0.5
    ),
    
    axis.title = ggplot2::element_text(
      face = "bold",
      size = 11
    ),
    
    axis.text = ggplot2::element_text(
      size = 9,
      color = "black"
    ),
    
    panel.grid.major = ggplot2::element_line(
      color = "gray88",
      linewidth = 0.4
    ),
    
    panel.grid.minor = ggplot2::element_blank(),
    
    panel.border = ggplot2::element_rect(
      color = "gray50",
      fill = NA,
      linewidth = 0.6
    ),
    
    legend.position = "none",
    
    plot.margin = ggplot2::margin(
      t = 15,
      r = 15,
      b = 15,
      l = 15
    )
  )


print(calibration_plot)


#### 85. EXTRACT CALIBRATION METRICS ONLY ####

calibration_metrics <- results_long %>%
  
  filter(
    
    Metric %in% c(
      
      "Brier_Score",
      
      "Log_Loss",
      
      "Calibration_Intercept",
      
      "Calibration_Slope"
    )
  )


cat(
  "\nCalibration metrics with 95% CI:\n"
)

print(
  calibration_metrics
)


#### 86. EXTRACT DISCRIMINATION METRICS ONLY ####

discrimination_metrics <- results_long %>%
  
  filter(
    
    Metric %in% c(
      
      "AUC_ROC",
      
      "Average_Precision",
      
      "Sensitivity",
      
      "Specificity",
      
      "Precision_PPV",
      
      "NPV",
      
      "F1_Score",
      
      "Balanced_Accuracy",
      
      "GMean",
      
      "MCC"
    )
  )


cat(
  "\nDiscrimination metrics with 95% CI:\n"
)

print(
  discrimination_metrics
)


#### 87. CREATE COMPACT PRIMARY PERFORMANCE TABLE ####

primary_metrics <- c(
  
  "Accuracy",
  
  "Sensitivity",
  
  "Specificity",
  
  "Precision_PPV",
  
  "F1_Score",
  
  "Balanced_Accuracy",
  
  "GMean",
  
  "MCC",
  
  "AUC_ROC",
  
  "Average_Precision",
  
  "Brier_Score",
  
  "Calibration_Intercept",
  
  "Calibration_Slope"
)


primary_results <- results_long %>%
  
  filter(
    Metric %in%
      primary_metrics
  ) %>%
  
  mutate(
    
    Estimate_95CI = paste0(
      
      sprintf(
        "%.3f",
        Estimate
      ),
      
      " (",
      
      sprintf(
        "%.3f",
        Lower_95CI
      ),
      
      "–",
      
      sprintf(
        "%.3f",
        Upper_95CI
      ),
      
      ")"
    )
  ) %>%
  
  dplyr::select(
    
    Model,
    
    Metric,
    
    Estimate_95CI
  ) %>%
  
  tidyr::pivot_wider(
    
    names_from =
      Metric,
    
    values_from =
      Estimate_95CI
  )


cat(
  "\nPRIMARY MODEL PERFORMANCE TABLE:\n"
)

print(
  primary_results,
  width = Inf
)






#### 90. SAVE APA-STYLE MODEL PERFORMANCE TABLES TO MS WORD ####

library(dplyr)
library(tidyr)
library(gtsummary)
library(flextable)
library(officer)

# Compact journal-style gtsummary theme
gtsummary::theme_gtsummary_compact()


#### OUTPUT PATH ####

output_path <- paste0(
  "E:\\f drives\\Machine learning based\\LBW\\Updated Analysis\\",
  "Nepal\\Table"
)

if (!dir.exists(output_path)) {
  dir.create(
    output_path,
    recursive = TRUE
  )
}


#### 91. FORMAT FUNCTION FOR ESTIMATE WITH 95% CI ####

format_ci <- function(est, low, high) {
  
  paste0(
    sprintf("%.3f", est),
    " (",
    sprintf("%.3f", low),
    "–",
    sprintf("%.3f", high),
    ")"
  )
}


#### 92. CALIBRATION TABLE DATA ####

calibration_word <- results_long %>%
  
  dplyr::filter(
    Metric %in% c(
      "Brier_Score",
      "Log_Loss",
      "Calibration_Intercept",
      "Calibration_Slope"
    )
  ) %>%
  
  dplyr::mutate(
    
    Metric = dplyr::recode(
      Metric,
      "Brier_Score" = "Brier score",
      "Log_Loss" = "Log loss",
      "Calibration_Intercept" = "Calibration intercept",
      "Calibration_Slope" = "Calibration slope"
    ),
    
    Value = format_ci(
      Estimate,
      Lower_95CI,
      Upper_95CI
    )
  ) %>%
  
  dplyr::select(
    Model,
    Metric,
    Value
  ) %>%
  
  tidyr::pivot_wider(
    names_from = Metric,
    values_from = Value
  )


#### 93. DISCRIMINATION TABLE DATA ####

discrimination_word <- results_long %>%
  
  dplyr::filter(
    Metric %in% c(
      "AUC_ROC",
      "Average_Precision",
      "Sensitivity",
      "Specificity",
      "Precision_PPV",
      "NPV",
      "F1_Score",
      "Balanced_Accuracy",
      "GMean"
    )
  ) %>%
  
  dplyr::mutate(
    
    Metric = dplyr::recode(
      Metric,
      "AUC_ROC" = "ROC-AUC",
      "Average_Precision" = "Average precision",
      "Sensitivity" = "Sensitivity",
      "Specificity" = "Specificity",
      "Precision_PPV" = "PPV",
      "NPV" = "NPV",
      "F1_Score" = "F1 score",
      "Balanced_Accuracy" = "Balanced accuracy",
      "GMean" = "G-mean"
    ),
    
    Value = format_ci(
      Estimate,
      Lower_95CI,
      Upper_95CI
    )
  ) %>%
  
  dplyr::select(
    Model,
    Metric,
    Value
  ) %>%
  
  tidyr::pivot_wider(
    names_from = Metric,
    values_from = Value
  )


#### 94. PRIMARY PERFORMANCE TABLE DATA ####

primary_metrics <- c(
  "Accuracy",
  "Sensitivity",
  "Specificity",
  "Precision_PPV",
  "F1_Score",
  "Balanced_Accuracy",
  "GMean",
  "AUC_ROC",
  "Average_Precision",
  "Brier_Score",
  "Calibration_Intercept",
  "Calibration_Slope"
)


primary_word <- results_long %>%
  
  dplyr::filter(
    Metric %in% primary_metrics
  ) %>%
  
  dplyr::mutate(
    
    Metric = dplyr::recode(
      Metric,
      "Accuracy" = "Accuracy",
      "Sensitivity" = "Sensitivity",
      "Specificity" = "Specificity",
      "Precision_PPV" = "PPV",
      "F1_Score" = "F1 score",
      "Balanced_Accuracy" = "Balanced accuracy",
      "GMean" = "G-mean",
      "AUC_ROC" = "ROC-AUC",
      "Average_Precision" = "Average precision",
      "Brier_Score" = "Brier score",
      "Calibration_Intercept" = "Calibration intercept",
      "Calibration_Slope" = "Calibration slope"
    ),
    
    Value = format_ci(
      Estimate,
      Lower_95CI,
      Upper_95CI
    )
  ) %>%
  
  dplyr::select(
    Model,
    Metric,
    Value
  ) %>%
  
  tidyr::pivot_wider(
    names_from = Metric,
    values_from = Value
  )


#### 95. CLEAN MODEL NAMES ####

clean_model_names <- function(data) {
  
  data %>%
    dplyr::mutate(
      Model = dplyr::recode(
        Model,
        "LogisticRegression" = "Logistic regression",
        "DecisionTree" = "Decision tree",
        "RandomForest" = "Random forest",
        "SVM" = "Support vector machine",
        "XGBoost" = "XGBoost"
      )
    )
}


calibration_word <- clean_model_names(
  calibration_word
)

discrimination_word <- clean_model_names(
  discrimination_word
)

primary_word <- clean_model_names(
  primary_word
)


#### 96. APA FLEXTABLE FUNCTION ####

apa_flextable <- function(data) {
  
  ft <- flextable::flextable(
    data
  )
  
  # Font
  ft <- flextable::font(
    ft,
    fontname = "Times New Roman",
    part = "all"
  )
  
  ft <- flextable::fontsize(
    ft,
    size = 10,
    part = "all"
  )
  
  
  # Bold header
  ft <- flextable::bold(
    ft,
    part = "header",
    bold = TRUE
  )
  
  
  # Header alignment
  ft <- flextable::align(
    ft,
    align = "center",
    part = "header"
  )
  
  
  # First column left aligned
  ft <- flextable::align(
    ft,
    j = 1,
    align = "left",
    part = "body"
  )
  
  
  # Remaining columns centered
  if (ncol(data) > 1) {
    
    ft <- flextable::align(
      ft,
      j = 2:ncol(data),
      align = "center",
      part = "body"
    )
  }
  
  
  # APA-style borders:
  # remove all borders first
  ft <- flextable::border_remove(
    ft
  )
  
  
  black_border <- officer::fp_border(
    color = "black",
    width = 1
  )
  
  
  thin_border <- officer::fp_border(
    color = "black",
    width = 0.5
  )
  
  
  # Top line
  ft <- flextable::hline_top(
    ft,
    border = black_border,
    part = "header"
  )
  
  
  # Line below header
  ft <- flextable::hline_bottom(
    ft,
    border = thin_border,
    part = "header"
  )
  
  
  # Bottom line
  ft <- flextable::hline_bottom(
    ft,
    border = black_border,
    part = "body"
  )
  
  
  # White background
  ft <- flextable::bg(
    ft,
    bg = "white",
    part = "all"
  )
  
  
  # Padding
  ft <- flextable::padding(
    ft,
    padding.top = 4,
    padding.bottom = 4,
    padding.left = 4,
    padding.right = 4,
    part = "all"
  )
  
  
  # Autofit
  ft <- flextable::autofit(
    ft
  )
  
  
  # Prevent rows splitting across pages
  ft <- flextable::set_table_properties(
    ft,
    layout = "autofit",
    opts_word = list(
      split = FALSE,
      repeat_headers = TRUE
    )
  )
  
  
  return(ft)
}


#### 97. CREATE APA TABLES ####

ft_calibration <- apa_flextable(
  calibration_word
)

ft_discrimination <- apa_flextable(
  discrimination_word
)

ft_primary <- apa_flextable(
  primary_word
)


#### 98. CREATE WORD DOCUMENT ####

doc <- officer::read_docx()


#### TABLE 1 ####

doc <- officer::body_add_par(
  doc,
  "Table 1",
  style = "Normal"
)

doc <- officer::body_add_par(
  doc,
  "Calibration Performance of Machine-Learning Models for Low Birth Weight Prediction in Bangladesh",
  style = "Normal"
)

doc <- flextable::body_add_flextable(
  doc,
  value = ft_calibration
)

doc <- officer::body_add_par(
  doc,
  paste0(
    "Note. Values are estimates with 95% confidence intervals in parentheses. ",
    "For calibration, an intercept of 0 and a slope of 1 indicate ideal calibration. ",
    "Lower Brier scores and log-loss values indicate better probabilistic performance."
  ),
  style = "Normal"
)


#### PAGE BREAK ####

doc <- officer::body_add_break(
  doc
)


#### TABLE 2 ####

doc <- officer::body_add_par(
  doc,
  "Table 2",
  style = "Normal"
)

doc <- officer::body_add_par(
  doc,
  "Discrimination and Classification Performance of Machine-Learning Models",
  style = "Normal"
)

doc <- flextable::body_add_flextable(
  doc,
  value = ft_discrimination
)

doc <- officer::body_add_par(
  doc,
  paste0(
    "Note. Values are estimates with 95% confidence intervals in parentheses. ",
    "PPV = positive predictive value; NPV = negative predictive value; ",
    "ROC-AUC = area under the receiver operating characteristic curve. ",
    "ROC-AUC confidence intervals were obtained using the DeLong method; ",
    "other confidence intervals were obtained using bootstrap resampling."
  ),
  style = "Normal"
)


#### PAGE BREAK ####

doc <- officer::body_add_break(
  doc
)


#### TABLE 3 ####

doc <- officer::body_add_par(
  doc,
  "Table 3",
  style = "Normal"
)

doc <- officer::body_add_par(
  doc,
  "Primary Performance Metrics of Machine-Learning Models for Low Birth Weight Prediction",
  style = "Normal"
)

doc <- flextable::body_add_flextable(
  doc,
  value = ft_primary
)

doc <- officer::body_add_par(
  doc,
  paste0(
    "Note. Values are estimates with 95% confidence intervals in parentheses. ",
    "All performance measures were calculated using the untouched test dataset ",
    "at a classification threshold of 0.50."
  ),
  style = "Normal"
)

#### 99. SAVE WORD DOCUMENT ####

output_path <- "E:\\f drives\\Machine learning based\\LBW\\Updated Analysis\\Nepal\\Table"

word_file <- file.path(
  output_path,
  "Nepal_ML_APA_Performance_Tables.docx"
)

print(
  doc,
  target = word_file
)

cat(
  "\nAPA-style Word document saved successfully:\n",
  word_file,
  "\n"
)






















#### 88. DISPLAY FINAL BEST TUNING PARAMETERS ####

cat("\nFinal hyperparameter settings:\n")


for (model_name in names(model_fits)) {
  
  cat(
    "\n",
    model_name,
    ":\n",
    sep = ""
  )
  
  current_model <- model_fits[[model_name]]
  
  
  if (
    !is.null(current_model$bestTune) &&
    ncol(current_model$bestTune) > 0
  ) {
    
    print(
      current_model$bestTune
    )
    
  } else {
    
    cat(
      "No hyperparameter tuning required.\n"
    )
  }
}


#### 89. SESSION INFORMATION FOR REPRODUCIBILITY ####

cat(
  "\nR SESSION INFORMATION:\n"
)

print(
  sessionInfo()
)
























#### 90. SHAP AND LIME EXPLAINABILITY FOR BEST RANDOM FOREST MODEL ####

library(fastshap)
library(shapviz)
library(lime)
library(ggplot2)
library(dplyr)
library(scales)
library(grid)
library(patchwork)


#### 91. DEFINE BEST MODEL ####

best_model <- fit_rf

best_model_name <- "Random Forest"


cat(
  "\nBest model selected for explainability analysis:\n"
)

print(
  best_model_name
)


cat(
  "\nOptimal tuning parameter:\n"
)

print(
  best_model$bestTune
)


#### 92. PREPARE ORIGINAL TRAINING AND UNTOUCHED TEST PREDICTORS ####

# IMPORTANT:
# SHAP background = original training data without SMOTE
# SHAP evaluation = untouched test data without SMOTE

X_shap_train <- base::as.data.frame(
  X_train_model
)

X_shap_test <- base::as.data.frame(
  X_test_model
)


# Ensure same column order
X_shap_test <- X_shap_test[
  ,
  names(X_shap_train),
  drop = FALSE
]


cat(
  "\nTraining predictors dimensions:\n"
)

print(
  dim(X_shap_train)
)


cat(
  "\nTest predictors dimensions:\n"
)

print(
  dim(X_shap_test)
)


cat(
  "\nPredictors used for SHAP/LIME:\n"
)

print(
  names(X_shap_train)
)


cat(
  "\nClass of SHAP training data:\n"
)

print(
  class(X_shap_train)
)


cat(
  "\nClass of SHAP test data:\n"
)

print(
  class(X_shap_test)
)


#### SAFETY CHECKS ####

stopifnot(
  identical(
    names(X_shap_train),
    names(X_shap_test)
  )
)

stopifnot(
  identical(
    class(X_shap_train),
    class(X_shap_test)
  )
)


n_shap_features <- ncol(
  X_shap_test
)


#### 93. CREATE PREDICTION WRAPPER FOR SHAP ####

pred_wrapper <- function(
    object,
    newdata
) {
  
  newdata <- base::as.data.frame(
    newdata
  )
  
  
  pred <- predict(
    object,
    newdata = newdata,
    type = "prob"
  )
  
  
  if (!"LBW" %in% colnames(pred)) {
    
    stop(
      "LBW probability column was not found in model predictions."
    )
  }
  
  
  as.numeric(
    pred[, "LBW"]
  )
}


#### 94. CHECK RANDOM FOREST PREDICTIONS ####

test_lbw_probability <- pred_wrapper(
  best_model,
  X_shap_test
)


cat(
  "\nPredicted LBW probability summary:\n"
)

print(
  summary(
    test_lbw_probability
  )
)


cat(
  "\nNumber of test predictions:\n"
)

print(
  length(
    test_lbw_probability
  )
)


stopifnot(
  length(test_lbw_probability) ==
    nrow(X_shap_test)
)


#### 95. CALCULATE SHAP VALUES ON UNTOUCHED TEST SET ####

set.seed(42)


shap_values <- fastshap::explain(
  
  object = best_model,
  
  # Original non-SMOTE training data
  X = X_shap_train,
  
  # Completely untouched test data
  newdata = X_shap_test,
  
  pred_wrapper = pred_wrapper,
  
  nsim = 200,
  
  adjust = TRUE
)


shap_values <- as.matrix(
  shap_values
)


cat(
  "\nSHAP values calculated successfully.\n"
)


cat(
  "\nSHAP matrix dimensions:\n"
)

print(
  dim(shap_values)
)


#### 96. CREATE SHAPVIZ OBJECT ####

baseline_probability <- mean(
  
  pred_wrapper(
    best_model,
    X_shap_train
  ),
  
  na.rm = TRUE
)


cat(
  "\nSHAP baseline probability:\n"
)

print(
  baseline_probability
)


shap_object <- shapviz::shapviz(
  
  shap_values,
  
  X = X_shap_test,
  
  baseline = baseline_probability
)


#### 97. HIGH-IMPACT SHAP BEESWARM PLOT ####

shap_beeswarm <- shapviz::sv_importance(
  
  shap_object,
  
  kind = "beeswarm",
  
  max_display = n_shap_features
  
) +
  
  ggplot2::scale_color_gradientn(
    
    colours = c(
      "#003CFF",
      "#00BFFF",
      "#00E5FF",
      "#F4F000",
      "#FF8C00",
      "#FF1744",
      "#C000FF"
    ),
    
    values = scales::rescale(
      c(
        0.00,
        0.15,
        0.30,
        0.50,
        0.70,
        0.85,
        1.00
      )
    ),
    
    name = "Feature value",
    
    guide = ggplot2::guide_colorbar(
      title.position = "top",
      title.hjust = 0.5,
      barwidth = grid::unit(
        0.45,
        "cm"
      ),
      barheight = grid::unit(
        5,
        "cm"
      ),
      frame.colour = "black",
      frame.linewidth = 0.5,
      ticks.colour = "black"
    )
  ) +
  
  ggplot2::geom_vline(
    xintercept = 0,
    linetype = "dashed",
    linewidth = 0.75,
    color = "#303030",
    alpha = 0.85
  ) +
  
  ggplot2::labs(
    
    title = "SHAP Feature Effects for Low Birth Weight Prediction",
    
    x = "SHAP value",
    
    y = NULL
  ) +
  
  ggplot2::theme_minimal(
    base_size = 14
  ) +
  
  ggplot2::theme(
    
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 11,
      hjust = 0.5,
      color = "#111111",
      margin = ggplot2::margin(
        b = 11
      )
    ),
    
    axis.title.x = ggplot2::element_text(
      face = "bold",
      size = 13.5,
      color = "#111111",
      margin = ggplot2::margin(
        t = 10
      )
    ),
    
    axis.text.x = ggplot2::element_text(
      size = 11,
      color = "#222222"
    ),
    
    axis.text.y = ggplot2::element_text(
      size = 11.5,
      face = "bold",
      color = "#111111",
      margin = ggplot2::margin(
        r = 8
      )
    ),
    
    axis.ticks.x = ggplot2::element_line(
      color = "#333333",
      linewidth = 0.55
    ),
    
    axis.ticks.y = ggplot2::element_blank(),
    
    panel.grid.major.x = ggplot2::element_line(
      color = "#DCDCDC",
      linewidth = 0.45
    ),
    
    panel.grid.major.y = ggplot2::element_line(
      color = "#F0F0F0",
      linewidth = 0.40
    ),
    
    panel.grid.minor = ggplot2::element_blank(),
    
    legend.position = "right",
    
    legend.title = ggplot2::element_text(
      face = "bold",
      size = 11.5,
      color = "#111111"
    ),
    
    legend.text = ggplot2::element_text(
      size = 10,
      color = "#333333"
    ),
    
    panel.background = ggplot2::element_rect(
      fill = "#FFFFFF",
      color = NA
    ),
    
    plot.background = ggplot2::element_rect(
      fill = "#FFFFFF",
      color = NA
    ),
    
    panel.border = ggplot2::element_rect(
      fill = NA,
      color = "#202020",
      linewidth = 0.75
    ),
    
    plot.margin = ggplot2::margin(
      t = 18,
      r = 20,
      b = 15,
      l = 15
    )
  )


print(
  shap_beeswarm
)


#### 98. SHAP GLOBAL FEATURE IMPORTANCE PLOT ####

shap_importance <- shapviz::sv_importance(
  
  shap_object,
  
  kind = "bar",
  
  max_display = n_shap_features
  
) +
  
  ggplot2::labs(
    
    title = "Global SHAP Feature Importance",
    
    x = "Mean absolute SHAP value",
    
    y = NULL
  ) +
  
  ggplot2::theme_minimal(
    base_size = 14
  ) +
  
  ggplot2::theme(
    
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 11,
      hjust = 0.5,
      color = "#111111",
      margin = ggplot2::margin(
        b = 11
      )
    ),
    
    axis.title.x = ggplot2::element_text(
      face = "bold",
      size = 11,
      color = "#111111"
    ),
    
    axis.text.x = ggplot2::element_text(
      size = 10.5,
      color = "#222222"
    ),
    
    axis.text.y = ggplot2::element_text(
      size = 11,
      face = "bold",
      color = "#111111"
    ),
    
    axis.ticks = ggplot2::element_line(
      color = "#333333",
      linewidth = 0.5
    ),
    
    panel.grid.major.x = ggplot2::element_line(
      color = "#DCDCDC",
      linewidth = 0.45
    ),
    
    panel.grid.major.y = ggplot2::element_line(
      color = "#F0F0F0",
      linewidth = 0.35
    ),
    
    panel.grid.minor = ggplot2::element_blank(),
    
    panel.border = ggplot2::element_rect(
      fill = NA,
      color = "#202020",
      linewidth = 0.7
    ),
    
    plot.background = ggplot2::element_rect(
      fill = "white",
      color = NA
    ),
    
    panel.background = ggplot2::element_rect(
      fill = "white",
      color = NA
    )
  )


print(
  shap_importance
)


#### 99. SHAP BEESWARM AND GLOBAL IMPORTANCE SIDE BY SIDE ####

combined_shap_plot <- shap_beeswarm +
  shap_importance +
  patchwork::plot_layout(
    ncol = 2,
    widths = c(
      1.45,
      1
    )
  )


print(
  combined_shap_plot
)


#### 100. SELECT HIGH-RISK TEST OBSERVATION ####

# Select untouched Nepal test observation
# with highest predicted LBW probability

waterfall_case <- which.max(
  test_lbw_probability
)


cat(
  "\nObservation selected for local explanation:\n"
)

print(
  waterfall_case
)


cat(
  "\nPredicted LBW probability:\n"
)

print(
  test_lbw_probability[
    waterfall_case
  ]
)


cat(
  "\nObserved outcome:\n"
)

print(
  test_model$lbw[
    waterfall_case
  ]
)


cat(
  "\nPredictor values for selected observation:\n"
)

print(
  X_shap_test[
    waterfall_case,
    ,
    drop = FALSE
  ]
)


#### 101. HIGH-IMPACT SHAP WATERFALL PLOT ####

shap_waterfall <- shapviz::sv_waterfall(
  
  shap_object,
  
  row_id = waterfall_case,
  
  max_display = n_shap_features
  
) +
  
  ggplot2::labs(
    
    title = "SHAP Waterfall Plot for a High-Risk LBW Prediction",
    
    subtitle = paste0(
      "Predicted LBW probability = ",
      sprintf(
        "%.3f",
        test_lbw_probability[
          waterfall_case
        ]
      )
    ),
    
    x = "Contribution to predicted LBW risk",
    
    y = NULL
  ) +
  
  ggplot2::theme_minimal(
    base_size = 14
  ) +
  
  ggplot2::theme(
    
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 17,
      hjust = 0.5,
      color = "#111111",
      margin = ggplot2::margin(
        b = 6
      )
    ),
    
    plot.subtitle = ggplot2::element_text(
      face = "bold",
      size = 12,
      hjust = 0.5,
      color = "#555555",
      margin = ggplot2::margin(
        b = 14
      )
    ),
    
    axis.title.x = ggplot2::element_text(
      face = "bold",
      size = 12.5,
      color = "#111111",
      margin = ggplot2::margin(
        t = 10
      )
    ),
    
    axis.text.x = ggplot2::element_text(
      size = 10.5,
      color = "#222222"
    ),
    
    axis.text.y = ggplot2::element_text(
      size = 11.5,
      face = "bold",
      color = "#111111",
      margin = ggplot2::margin(
        r = 7
      )
    ),
    
    panel.grid.major.x = ggplot2::element_line(
      color = "#D9D9D9",
      linewidth = 0.45
    ),
    
    panel.grid.major.y = ggplot2::element_blank(),
    
    panel.grid.minor = ggplot2::element_blank(),
    
    axis.ticks.x = ggplot2::element_line(
      color = "#333333",
      linewidth = 0.5
    ),
    
    axis.ticks.y = ggplot2::element_blank(),
    
    panel.border = ggplot2::element_rect(
      fill = NA,
      color = "#222222",
      linewidth = 0.75
    ),
    
    panel.background = ggplot2::element_rect(
      fill = "#FFFFFF",
      color = NA
    ),
    
    plot.background = ggplot2::element_rect(
      fill = "#FFFFFF",
      color = NA
    ),
    
    legend.position = "none",
    
    plot.margin = ggplot2::margin(
      t = 16,
      r = 18,
      b = 15,
      l = 18
    )
  )


print(
  shap_waterfall
)


#### 102. PREPARE LIME EXPLAINER FOR RANDOM FOREST ####

model_type.train <- function(
    x,
    ...
) {
  
  return(
    "classification"
  )
}


predict_model.train <- function(
    x,
    newdata,
    type,
    ...
) {
  
  newdata <- base::as.data.frame(
    newdata
  )
  
  
  prediction <- predict(
    x,
    newdata = newdata,
    type = "prob"
  )
  
  
  prediction <- base::as.data.frame(
    prediction
  )
  
  
  return(
    prediction
  )
}


set.seed(42)


lime_explainer <- lime::lime(
  
  x = X_shap_train,
  
  model = best_model,
  
  bin_continuous = TRUE,
  
  n_bins = 4
)


#### 103. SELECT SAME UNTOUCHED TEST CASE FOR LIME ####

lime_case <- X_shap_test[
  waterfall_case,
  ,
  drop = FALSE
]


lime_case <- base::as.data.frame(
  lime_case
)


cat(
  "\nLIME case selected:\n"
)

print(
  lime_case
)


#### 104. GENERATE LIME LOCAL EXPLANATION ####

set.seed(42)


lime_explanation <- lime::explain(
  
  x = lime_case,
  
  explainer = lime_explainer,
  
  labels = "LBW",
  
  n_features = n_shap_features,
  
  n_permutations = 5000,
  
  kernel_width = 0.75,
  
  feature_select = "highest_weights"
)


cat(
  "\nLIME explanation:\n"
)

print(
  lime_explanation
)


#### 105. HIGH-IMPACT LIME FEATURE CONTRIBUTION PLOT ####

lime_feature_plot <- lime::plot_features(
  
  lime_explanation,
  
  ncol = 1
  
) +
  
  ggplot2::scale_fill_manual(
    
    values = c(
      "#00A6FF",
      "#FF3B5C"
    )
  ) +
  
  ggplot2::labs(
    
    title = "LIME Feature Contributions to LBW Prediction",
    
    subtitle = paste0(
      "Predicted LBW probability = ",
      sprintf(
        "%.3f",
        test_lbw_probability[
          waterfall_case
        ]
      )
    ),
    
    x = "Contribution to predicted LBW risk",
    
    y = NULL,
    
    fill = NULL
  ) +
  
  ggplot2::theme_minimal(
    base_size = 14
  ) +
  
  ggplot2::theme(
    
    plot.title = ggplot2::element_text(
      face = "bold",
      size = 18,
      hjust = 0.5,
      color = "#111111",
      margin = ggplot2::margin(
        b = 5
      )
    ),
    
    plot.subtitle = ggplot2::element_text(
      face = "bold",
      size = 12,
      hjust = 0.5,
      color = "#555555",
      margin = ggplot2::margin(
        b = 15
      )
    ),
    
    axis.title.x = ggplot2::element_text(
      face = "bold",
      size = 12.5,
      color = "#111111",
      margin = ggplot2::margin(
        t = 10
      )
    ),
    
    axis.text.x = ggplot2::element_text(
      size = 10.5,
      color = "#222222"
    ),
    
    axis.text.y = ggplot2::element_text(
      face = "bold",
      size = 11.5,
      color = "#111111",
      margin = ggplot2::margin(
        r = 8
      )
    ),
    
    axis.ticks.x = ggplot2::element_line(
      color = "#333333",
      linewidth = 0.5
    ),
    
    axis.ticks.y = ggplot2::element_blank(),
    
    panel.grid.major.x = ggplot2::element_line(
      color = "#DCDCDC",
      linewidth = 0.45
    ),
    
    panel.grid.major.y = ggplot2::element_blank(),
    
    panel.grid.minor = ggplot2::element_blank(),
    
    panel.border = ggplot2::element_rect(
      fill = NA,
      color = "#202020",
      linewidth = 0.75
    ),
    
    panel.background = ggplot2::element_rect(
      fill = "#FFFFFF",
      color = NA
    ),
    
    plot.background = ggplot2::element_rect(
      fill = "#FFFFFF",
      color = NA
    ),
    
    legend.position = "bottom",
    
    legend.title = ggplot2::element_blank(),
    
    legend.text = ggplot2::element_text(
      face = "bold",
      size = 10.5,
      color = "#222222"
    ),
    
    legend.key.width = grid::unit(
      1.3,
      "cm"
    ),
    
    strip.text = ggplot2::element_text(
      face = "bold",
      size = 11.5,
      color = "#111111"
    ),
    
    strip.background = ggplot2::element_rect(
      fill = "#F4F6F8",
      color = "#D0D0D0",
      linewidth = 0.5
    ),
    
    plot.margin = ggplot2::margin(
      t = 18,
      r = 22,
      b = 16,
      l = 20
    )
  )


print(
  lime_feature_plot
)


#### 106. CHECK LIME OUTPUT ####

cat(
  "\nLIME rows:\n"
)

print(
  nrow(
    lime_explanation
  )
)


cat(
  "\nLIME columns:\n"
)

print(
  names(
    lime_explanation
  )
)


cat(
  "\nLIME class:\n"
)

print(
  class(
    lime_explanation
  )
)


#### 107. CREATE NEPAL FIGURE OUTPUT FOLDER ####

figure_path <- paste0(
  "E:\\f drives\\Machine learning based\\LBW\\Updated Analysis\\",
  "Nepal\\Figure"
)


if (!dir.exists(figure_path)) {
  
  dir.create(
    figure_path,
    recursive = TRUE
  )
}


#### 108. SAVE COMBINED SHAP FIGURE ####

ggplot2::ggsave(
  
  filename = file.path(
    figure_path,
    "Nepal_SHAP_RandomForest_Combined.tiff"
  ),
  
  plot = combined_shap_plot,
  
  width = 13,
  height = 6.5,
  units = "in",
  
  dpi = 600,
  
  compression = "lzw",
  
  bg = "white"
)


#### 109. SAVE SHAP WATERFALL FIGURE ####

ggplot2::ggsave(
  
  filename = file.path(
    figure_path,
    "Nepal_SHAP_Waterfall_RandomForest.tiff"
  ),
  
  plot = shap_waterfall,
  
  width = 8.5,
  height = 6.5,
  units = "in",
  
  dpi = 600,
  
  compression = "lzw",
  
  bg = "white"
)


#### 110. SAVE LIME FIGURE ####

ggplot2::ggsave(
  
  filename = file.path(
    figure_path,
    "Nepal_LIME_RandomForest.tiff"
  ),
  
  plot = lime_feature_plot,
  
  width = 8.5,
  height = 6.5,
  units = "in",
  
  dpi = 600,
  
  compression = "lzw",
  
  bg = "white"
)


cat(
  "\nAll Nepal Random Forest explainability figures saved successfully in:\n",
  figure_path,
  "\n"
)




