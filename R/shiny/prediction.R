# 5. Example Use Cases
# 
# Here are some example prediction tasks based on your dataset:
#   Predict ICU Admission
# 
# Target Variable: "Pacientes que ingresaron a UCI"
# 
# Features: Symptoms (e.g., "Disnea", "Fiebre"), comorbidities (e.g., "Diabetes", "Hipertensión"), demographics (e.g., "Edad", "Sexo").
# 
# Predict Mortality
# 
# Target Variable: "Estatus del paciente" (e.g., alive vs. deceased).
# 
# Features: Symptoms, comorbidities, time between symptom onset and testing ("Dias entre inicio de síntomas y toma de muestra").
# 
# Predict Pneumonia Diagnosis
# 
# Target Variable: "Diagnóstico clínico de Neumonía"
# 
# Features: Symptoms (e.g., "Tos", "Dolor torácico"), comorbidities, demographics.
# 
# Predict Time-to-Death
# 
# Target Variable: "Dias entre inicio de síntomas y defunción"
# 
# Features: Symptoms, comorbidities, demographics, and time-based features.

# LOADING DATA -----------------------------------------------------------------
library(tidyverse)

df <- readRDS(file = "./R/shiny/dataframe.rds")

# "Dias entre inicio de síntomas y defunción": Predict survival time.

symptoms <- c("Fiebre", "Tos", "Odinofagia", "Disnea", "Irritabilidad",
              "Diarrea", "Dolor torácico", "Escalofríos", "Cefalea", "Mialgias",
              "Artralgias", "Ataque al estado general", "Rinorrea", "Polipnea",
              "Vómito", "Dolor abdminal", "Conjuntivitis", "Cianosis",
              "Inicio súbito", "Anosmia", "Disgeusia")

comorbidities <- c("Diabetes", "Hipertensión", "Obesidad", "Enfermedad cardiaca", "Insuficiencia renal crónica", "Tabaquismo")

demographics <- c("Edad", "Sexo")

time_based <- c("Dias entre inicio de síntomas y toma de muestra")

all_attr <- c(symptoms, comorbidities, demographics, time_based)

symptoms_demographics_time <- c(symptoms, demographics, time_based)

comorbidities_demographics_time <- c(comorbidities, demographics, time_based)

df1 <- df %>%
  filter(!is.na(`Fecha de la defunción`)) %>%  # Filter rows where Fecha de la defunción is not NA
  dplyr::select(all_of(all_attr)) %>%
  as.data.frame()
mean(is.na(df1)) # be sure there is no NA values

df2 <- df %>%
  filter(!is.na(`Fecha de la defunción`)) %>%  # Filter rows where Fecha de la defunción is not NA
  dplyr::select(all_of(symptoms_demographics_time)) %>%
  as.data.frame()

df3 <- df %>%
  filter(!is.na(`Fecha de la defunción`)) %>%  # Filter rows where Fecha de la defunción is not NA
  dplyr::select(all_of(comorbidities_demographics_time)) %>%
  as.data.frame()







