# LOADING DATA -----------------------------------------------------------------
library(tidyverse)

df <- readRDS(file = "./R/shiny/dataframe.rds")
df1 <- df %>% select(-where(~ is.numeric(.) | inherits(., "Date"))) # removing numerical variables
df1 <- df1 %>% select(-"Institución tratante", -"Unidad notificante", -"Municipio de residencia")

missing_data <- df1 %>%
  summarise(across(everything(), ~ mean(is.na(.)) * 100)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Percentage") %>%
  arrange(desc(Missing_Percentage))

df2 <- df1 %>% select(-"Vacuna contra COVID19", -"Marca", -"Ocupación")
mean(is.na(df2))

# K-MODES CLUSTERING -----------------------------------------------------------
library(klaR)
set.seed(123)
modes = 3
df2 <- as.data.frame(df2)
kmodes_model <- kmodes(df2, modes = modes, iter.max = 200)
df2$kmodes_cluster <- kmodes_model$cluster

# COMPARING USING SILHOUETTE SCORE
library(cluster) 
gower_dist <- daisy(df2, metric = "gower")
kmodes_sil <- silhouette(df2$kmodes_cluster, gower_dist)
kmodes_sil_score <- mean(kmodes_sil[, modes]) # Higher is better (closer to 1)

print(paste("k-modes Silhouette Score:", kmodes_sil_score))
