# Target Variable: "Diagnostico" : "ENFERMEDAD TIPO INFLUENZA (ETI)", "INFECCION RESPIRATORIA AGUDA GRAVE (IRAG)"
set.seed(123)
# LOADING DATA -----------------------------------------------------------------
library(tidyverse)
library(recipes) # recipe
library(themis)  # For SMOTE

df <- readRDS(file = "./R/shiny/dataframe.rds")

target <- c("target")

symptoms <- c("Fever" = "Fiebre",
              "Cough" = "Tos",
              "Shortness of breath" = "Disnea",
              "Chest pain" = "Dolor torácico",
              "Chills" = "Escalofríos",
              "Headache" = "Cefalea",
              "Muscle pain" = "Mialgias",
              "Joint pain" = "Artralgias",
              "General malaise" = "Ataque al estado general",
              "Runny nose" = "Rinorrea",
              "Rapid breathing" = "Polipnea",
              "Cyanosis" = "Cianosis",
              "Sudden onset" = "Inicio súbito")

comorbidities <- c("Asthma" = "Asma",
                   "Diabetes" = "Diabetes",
                   "COPD" = "EPOC",
                   "Hypertension" = "Hipertensión",
                   "Immunosuppression" = "Inmunosupresión",
                   "Chronic kidney disease" = "Insuficiencia renal crónica",
                   "Obesity" = "Obesidad",
                   "Heart disease" = "Enfermedad cardiaca",
                   "Smoking" = "Tabaquismo",
                   "Laboratory result" = "Resultado de laboratorio")

demographics <- c("Age" = "Edad", "Sex" = "Sexo")

all_attr <- c(symptoms, comorbidities, demographics, target)

df <- df %>%
  rename(target = `Diagnóstico probable`) %>%
  filter(
    `Resultado de laboratorio` != "Pendiente"  # Remove "Pendiente" records
  ) %>%
  filter(
    if_all(
      c("Fiebre", "Disnea", "Dolor torácico", "Escalofríos", "Cefalea", "Mialgias",
        "Artralgias", "Ataque al estado general", "Rinorrea", "Polipnea", 
        "Cianosis", "Inicio súbito",
        "Asma", "Diabetes", "EPOC", "Hipertensión", "Inmunosupresión", "Insuficiencia renal crónica", "Obesidad", 
        "Enfermedad cardiaca", "Tabaquismo"),
      ~ . != "SE IGNORA"
    )  # Remove rows where ANY of these columns are "SE IGNORA"
  )

class1 <- df %>%
  filter(target == "ENFERMEDAD TIPO INFLUENZA (ETI)") %>%
  slice_sample(n = 5000)  # Adjust size for faster computation

class2 <- df %>%
  filter(target == "INFECCION RESPIRATORIA AGUDA GRAVE (IRAG)")


# defining different version of dataset to train the models
df_filtered <- bind_rows(class1, class2) %>%
  sample_frac(1)  # Shuffle all rows
  
df1 <- df_filtered %>%
  dplyr::select(all_of(all_attr)) %>%
  as.data.frame()
mean(is.na(df1)) # be sure there is no NA values

# Recipe
recipe_prep <- recipe(target ~ ., data=df1) %>%
  step_dummy(all_nominal_predictors(), -target) %>% 
  step_zv(all_predictors()) %>%  # Remove zero-variance predictors
  step_smote(target, over_ratio = 1) # Balance minority class

# DEFINING CLASSIFICATION MODELS -----------------------------------------------
library(tidymodels)
library(kernlab) # SVM support
library(kknn)    # KNN

rf <- rand_forest() %>% set_engine("ranger", importance = "permutation") %>% set_mode("classification")
xgb <- boost_tree() %>% set_engine("xgboost") %>% set_mode("classification")
svm <- svm_poly() %>% set_engine("kernlab") %>% set_mode("classification")
knn <- nearest_neighbor() %>% set_engine("kknn") %>% set_mode("classification")
mlp <- mlp() %>% set_engine("nnet") %>% set_mode("classification") # Multi Layer Perceptron

# Store models in a list
models <- list(rf, xgb, svm, knn, mlp)

# Step 4: Create a 5-fold cross-validation
cv_folds <- vfold_cv(df1, v = 5)

# Step 5: Create workflow set
wf_set <- workflow_set(
  preproc = list(recipe_prep),
  models = models
)

# FIT MODELS WITH CROSS VALIDATION ---------------------------------------------
results <- wf_set %>%
  workflow_map("fit_resamples", resamples = cv_folds, metrics = metric_set(roc_auc, accuracy, precision, recall, f_meas)) # ensures that the recipe (recipe_prep) is applied separately for each fold.

# Step 7: Visualize and compare results
autoplot(results)
collect_metrics(results)

# Collect all metrics from resampled results
metrics_summary <- collect_metrics(results)

# Print all available metrics
print(metrics_summary, n = Inf)

avg_metrics_wflow <- metrics_summary %>%
  group_by(wflow_id, .metric) %>%  # Group by workflow ID and metric type
  summarise(avg_value = mean(mean), .groups = "drop") %>%  # Compute the mean of the metric
  pivot_wider(names_from = .metric, values_from = avg_value)  # Reshape to have metrics as columns

# View results
print(avg_metrics_wflow)

# FINAL STEP: EXTRACT THE BEST MODEL -------------------------------------------

# Extract the best model (recipe_rand_forest) based on metrics
best_rf_model <- extract_workflow(wf_set, id = "recipe_rand_forest")
final_rf_model <- best_rf_model %>% fit(df1)

print(final_rf_model$trained)
saveRDS(final_rf_model, "./R/shiny/best_rf_model.rds")

# predictions <- predict(final_rf_model, new_data) # to predict new data
# predictions_prob <- predict(final_rf_model, new_data, type = "prob") # get the probability

# FURTHER ANALYSYS -------------------------------------------------------------

library(stringr)

# Step 1: Clean dummy variable names
importance_clean <- importance %>%
  mutate(
    Parent_Variable = str_replace(Variable, "_SI$|_.*$", ""),  # Remove suffixes
    Parent_Variable = str_replace(Parent_Variable, "Laboratory result", "Resultado de laboratorio")  # Optional: revert translations
  )

# Step 2: Sum importance by parent variable
aggregated_importance <- importance_clean %>%
  group_by(Parent_Variable) %>%
  summarise(Total_Importance = sum(Importance), .groups = "drop") %>%
  arrange(desc(Total_Importance))

# View cleaned results
print(aggregated_importance, n = Inf)

aggregated_importance %>%
  slice_max(Total_Importance, n = 15) %>%
  mutate(Parent_Variable = fct_reorder(Parent_Variable, Total_Importance)) %>%
  ggplot(aes(x = Total_Importance, y = Parent_Variable, fill = Total_Importance)) +
  geom_col() +
  scale_fill_viridis_c() +
  labs(
    title = "Random Forest Feature Importance (Aggregated)",
    subtitle = "Top predictors for COVID/Influenza classification",
    x = "Importance Score",
    y = ""
  ) +
  theme_minimal()


