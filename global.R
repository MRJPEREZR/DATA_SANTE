library(shiny)
library(readxl)
library(tidyverse)
library(tidymodels)

# LOAD DATASET
df0 <- read_excel("./CENSO_DATOS_ABIERTOS_GENERAL_COVID_2020.xlsx", sheet=1)