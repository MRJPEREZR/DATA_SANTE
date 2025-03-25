library(tidyverse)
library(klaR)
library(cluster)
library(Rtsne)
library(MASS)   
library(dplyr)

library(tidymodels)
library(shinyWidgets)

# Create constant
SYMPTOMS <- c("Fiebre", "Tos", "Disnea", "Dolor torácico", "Escalofríos", "Cefalea", "Mialgias",
              "Artralgias", "Ataque al estado general", "Rinorrea", "Polipnea", 
              "Cianosis", "Inicio súbito")

COMORBIDITIES <- c("Asma", "Diabetes", "EPOC", "Hipertensión", "Inmunosupresión", "Insuficiencia renal crónica", "Obesidad", 
                   "Enfermedad cardiaca", "Tabaquismo", "Resultado de laboratorio")

OTHERS <- c("Sexo", "Tipo de manejo", "Pacientes que requirieron intubación", "Pacientes que ingresaron a UCI")

# Load Data for clustering
df <- readRDS("dataframe.rds")
df1 <- df %>% select_if(~ !is.numeric(.) & !inherits(., "Date")) # removing numerical variables
df1 <- df1 %>% dplyr::select(-c("Institución tratante", "Unidad notificante", "Municipio de residencia"))

#Load data for prediction
best_rf_model <- readRDS("best_rf_model.rds")


