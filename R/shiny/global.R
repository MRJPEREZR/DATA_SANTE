# checking if all requirements are satisfied locally

packages <- c("tidyverse", "klaR", "cluster", "Rtsne", "MASS",   
              "dplyr", "tidymodels", "shinyWidgets", "ranger")

missing_packages <- packages[!(packages %in% installed.packages()[,"Package"])]
if(length(missing_packages)) install.packages(missing_packages, dependencies = TRUE)

lapply(packages, library, character.only = TRUE)

library(tidyverse)
library(klaR)
library(cluster)
library(Rtsne)
library(MASS)   
library(dplyr)

library(tidymodels)
library(shinyWidgets)
library(ranger)

# Create constant

SYMPTOMS <- c("Fever" = "Fiebre",
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

COMORBIDITIES <- c("Asthma" = "Asma",
                   "Diabetes" = "Diabetes",
                   "COPD" = "EPOC",
                   "Hypertension" = "Hipertensión",
                   "Immunosuppression" = "Inmunosupresión",
                   "Chronic kidney disease" = "Insuficiencia renal crónica",
                   "Obesity" = "Obesidad",
                   "Heart disease" = "Enfermedad cardiaca",
                   "Smoking" = "Tabaquismo",
                   "Laboratory result" = "Resultado de laboratorio")

COMORBIDITIES1 <- c("Asthma" = "Asma",
                   "Diabetes" = "Diabetes",
                   "COPD" = "EPOC",
                   "Hypertension" = "Hipertensión",
                   "Immunosuppression" = "Inmunosupresión",
                   "Chronic kidney disease" = "Insuficiencia renal crónica",
                   "Obesity" = "Obesidad",
                   "Heart disease" = "Enfermedad cardiaca",
                   "Smoking" = "Tabaquismo")

OTHERS <- c("Sex" = "Sexo",
            "Management type" = "Tipo de manejo",
            "Patients requiring intubation" = "Pacientes que requirieron intubación",
            "Patients admitted to ICU" = "Pacientes que ingresaron a UCI")

# Load Data for clustering
df <- readRDS("dataframe.rds")
df1 <- df %>% select_if(~ !is.numeric(.) & !inherits(., "Date")) # removing numerical variables
df1 <- df1 %>% dplyr::select(-c("Institución tratante", "Unidad notificante", "Municipio de residencia"))

#Load data for prediction
best_rf_model <- readRDS("best_rf_model.rds")

# deploy shinyApp: rsconnect::deployApp('path/to/your/app')
# stop shinyApp: rsconnect::terminateApp("<your app's name>")

