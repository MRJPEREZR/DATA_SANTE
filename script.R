# LOAD DATASET------------------------------------------------------------------
library(readxl)
library(tidyverse)
df <- read_excel("./CENSO_DATOS_ABIERTOS_GENERAL_COVID_2020.xlsx", sheet=1) %>%
  # Remove variables that are not useful for our objective
  select(-`Toma de muestra en el ESTADO`, 
         -`Procedencia`, 
         -`Fecha de llegada al Estado`, 
         -`REFUERZO`, 
         -`FECHA REFUERZO`, 
         -`VARIANTE`, 
         -`INFLUENZA`,
         - `Estatus día previo`,
         - `Periodo mínimo de incubación (2 días)`,
         - `Periodo máximo de incubación (7 días)`,
         - `Fecha estimada de Alta Sanitaria`,
         - `Semana epidemiológica de defunciones positivas`,
         - `Semana epidemiológica de resultados positivos`)
# CHANGING COLUMNS DATA TYPES --------------------------------------------------
library(dplyr)
library(lubridate)

date_columns <- c(
  "Fecha de inicio de síntomas",
  "Fecha de toma de muestra",
  "Fecha de resultado de laboratorio",
  "Fecha de última aplicación"
)

# Convert dates from mm/dd/yyyy to dd/mm/yyyy
df <- df %>%
  mutate(across(all_of(date_columns), ~ as.Date(., format = "%m/%d/%Y")))

# Special processing for the column "Fecha de la defunción" due to its format
df <- df %>%
  mutate(
    `Fecha de la defunción` = case_when(
      # Convert "NA" (text) to NA (missing value)
      `Fecha de la defunción` == "NA" ~ NA_character_,
      # Convert numerical values (as "44562") to dates
      grepl("^[0-9]+$", `Fecha de la defunción`) ~ as.character(as.Date(as.numeric(`Fecha de la defunción`), origin = "1899-12-30")),
      # Keep other values as they are (in case there are dates in text format)
      TRUE ~ `Fecha de la defunción`
    ),
    # Convert the column to Date type
    `Fecha de la defunción` = as.Date(`Fecha de la defunción`, format = "%Y-%m-%d")
  )

df <- df %>%
  mutate(across(where(is.character), as.factor))

# EXPLORING DATA ---------------------------------------------------------------
library(ggplot2)
library(corrplot)

# 1. Identify missing values
missing_data <- df1 %>%
  summarise(across(everything(), ~ mean(is.na(.)) * 100)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Percentage") %>%
  arrange(desc(Missing_Percentage))

print("Columns with missing values:")
print(missing_data)

# 2. Identify constant columns (only one unique value)
constant_columns <- df %>%
  summarise(across(everything(), ~ n_distinct(.))) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Unique_Values") %>%
  filter(Unique_Values == 1)

print("Columns with a single unique value (potentially useless):")
print(constant_columns)

# 3. Data type verification
print("Data Types:")
print(str(df))

# 4. Identify numeric columns and check distribution
numeric_cols <- df %>% select(where(is.numeric))
summary(numeric_cols)

# 5. Detect outliers using boxplots
df %>%
  select(where(is.numeric)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Value") %>%
  ggplot(aes(x = Variable, y = Value)) +
  geom_boxplot() +
  coord_flip() +
  theme_minimal() +
  labs(title = "Outlier Detection via Boxplots")

# 6. Correlation Analysis (for numeric variables)
corr_matrix <- cor(numeric_cols, use = "complete.obs")
corrplot(corr_matrix, method = "color", type = "lower", tl.cex = 0.7)

# 7. Check for duplicate rows
duplicate_rows <- df[duplicated(df), ]
print(paste("Number of duplicate rows:", nrow(duplicate_rows)))

filtered_data <- df1 %>%
  filter(`Estatus del paciente` == "Defunción", !is.na(`Fecha de la defunción`)) %>%
  select(`Fecha de la defunción`)




