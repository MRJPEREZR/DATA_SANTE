library(tidyverse)
library(klaR)
library(cluster)
library(Rtsne)

# Load Data
df <- readRDS("dataframe.rds")
df1 <- df %>% select_if(~ !is.numeric(.) & !inherits(., "Date")) # removing numerical variables
df1 <- df1 %>% dplyr::select(-c("Institución tratante", "Unidad notificante", "Municipio de residencia"))
