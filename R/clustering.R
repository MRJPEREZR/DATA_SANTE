# LOADING DATA -----------------------------------------------------------------
library(tidyverse)

df <- readRDS(file = "./R/shiny/dataframe.rds")
df1 <- df %>% select_if(~ !is.numeric(.) & !inherits(., "Date")) # removing numerical variables
df1 <- df1 %>% dplyr::select(-c("Institución tratante", "Unidad notificante", "Municipio de residencia"))

missing_data <- df1 %>%
  summarise(across(everything(), ~ mean(is.na(.)) * 100)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Percentage") %>%
  arrange(desc(Missing_Percentage))

df2 <- df1 %>% dplyr::select(-c("Vacuna contra COVID19", -"Marca", -"Ocupación", -"Estatus del paciente", -"Diagnóstico probable"))
mean(is.na(df2)) # be sure there is no NA values

# K-MODES CLUSTERING -----------------------------------------------------------

# k-modes
library(klaR)
library(cluster)
set.seed(123)

symptom_vars <-  c("Fever" = "Fiebre",
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

modes = 2

df2_filtred <- df2 %>%
  dplyr::select(all_of(symptom_vars)) %>%
  head(1000) %>%  # Taking a subset for clustering
  as.data.frame()
df2_filtred_age <- df2_filtred %>%
  mutate(Edad = df$`Edad`[0:1000])

gower_dist_kmodes <- daisy(df2_filtred, metric = "gower")
gower_dist_pam <- daisy(df2_filtred_age, metric = "gower")


kmodes_model <- kmodes(df2_filtred, modes = modes, iter.max = 200)
df2_filtred$kmodes_cluster <- kmodes_model$cluster

# PAM
pam_model <- pam(gower_dist_pam, k = modes)
df2_filtred_age$pam_cluster <- pam_model$clustering

# COMPARING USING SILHOUETTE SCORE ---------------------------------------------

kmodes_sil <- silhouette(df2_filtred$kmodes_cluster, gower_dist_kmodes)
kmodes_sil_score <- mean(kmodes_sil[, 3])  # Higher is better (closer to 1)

pam_sil <- silhouette(df2_filtred_age$pam_cluster, gower_dist_pam)
pam_sil_score <- mean(pam_sil[, 3])  # Higher is better

print(paste("k-modes Silhouette Score:", kmodes_sil_score))
print(paste("pam Silhouette Score:", pam_sil_score))

# PLOTING CLUSTER --------------------------------------------------------------
library(Rtsne)

# k-modes
tsne_obj <- Rtsne(gower_dist_kmodes, perplexity = 30) # Perform t-SNE (for dimensionality reduction)

tsne_data <- data.frame(tsne_obj$Y, cluster = as.factor(df2_filtred$kmodes_cluster)) # Convert to data frame

library(ggplot2)
ggplot(tsne_data, aes(x = X1, y = X2, color = cluster)) +
  geom_point(size = 2) +
  theme_minimal() +
  ggtitle("Clusters Visualization (t-SNE)")

#pam
tsne_obj <- Rtsne(gower_dist_pam, perplexity = 30) 

tsne_data <- data.frame(tsne_obj$Y, cluster = as.factor(df2_filtred_age$pam_cluster)) # Convert to data frame

library(ggplot2)
ggplot(tsne_data, aes(x = X1, y = X2, color = cluster)) +
  geom_point(size = 2) +
  theme_minimal() +
  ggtitle("Clusters Visualization (t-SNE)")

# ANALYSING CLUSTER ------------------------------------------------------------
cluster_summary <- df2_filtred %>%
  group_by(kmodes_cluster) %>%
  summarise(across(where(is.factor), ~ names(which.max(table(.x)))))

cluster_summary_long <- cluster_summary %>%
  pivot_longer(-kmodes_cluster, names_to = "Variable", values_to = "Most_Common_Category")

print(cluster_summary_long)

ggplot(cluster_summary_long, aes(x = as.factor(kmodes_cluster), fill = Most_Common_Category)) +
  geom_bar(position = "dodge") +  # Adjust position as needed
  facet_wrap(~ Variable) +  # Create separate charts for each variable
  theme_minimal() +
  labs(title = "Most Frequent Categories per Cluster",
       x = "Cluster",
       y = "Count",
       fill = "Most Common Category")

# Step 1: Join df2_filtered with cluster_summary to compare rows
df2_filtred_with_modes <- df2_filtred %>%
  left_join(cluster_summary, by = "kmodes_cluster")

matches <- df2_filtred_with_modes %>%
  rowwise() %>%  # Ensures row-by-row comparison
  mutate(Matches_Mode = all(c_across(-kmodes_cluster) == 
                              cluster_summary[cluster_summary$kmodes_cluster == kmodes_cluster, -1])) %>%
  ungroup() %>%
  group_by(kmodes_cluster) %>%
  summarise(Count_Mode_Vector = sum(Matches_Mode), Total = n(), .groups = "drop") %>%
  mutate(Percentage = (Count_Mode_Vector / Total) * 100)

## FURTHER ANALISYS ------------------------------------------------------------
feature_importance <- df2_filtred %>%
  pivot_longer(-kmodes_cluster, names_to = "feature") %>%
  count(kmodes_cluster, feature, value) %>%
  group_by(kmodes_cluster, feature) %>%
  mutate(prop = n / sum(n)) %>%
  group_by(feature) %>%
  summarise(
    importance = sd(prop),  # Measures how differently features behave across clusters
    .groups = "drop"
  ) %>%
  arrange(desc(importance))
feature_importance # Higher importance values indicate features that vary most between clusters (key discriminators).

ggplot(feature_importance, aes(x = reorder(feature, importance), y = importance)) +
  geom_col() +
  coord_flip() +
  labs(title = "Cluster-Discriminating Features", x = "Feature", y = "Importance (SD of Proportions)")

library(broom)
chi_squared_results <- df2_filtred %>%
  dplyr::select(-kmodes_cluster) %>%
  map(~ tidy(chisq.test(.x, df2_filtred$kmodes_cluster))) %>%
  bind_rows(.id = "feature") %>%
  arrange(p.value)

chi_squared_results # Low p-values (<0.05) indicate features significantly associated with cluster assignment.
