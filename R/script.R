# LOAD DATASET------------------------------------------------------------------
library(readxl)
library(tidyverse)

df <- read_excel("./Data/CENSO_DATOS_ABIERTOS_GENERAL_COVID_2020.xlsx", sheet=1) %>%
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
library(purrr)

# Convert "NA" (text) to NA (missing value)
# Apply the transformation to all columns
df <- df %>%
  mutate(across(where(is.character), ~ {
    ifelse(. == "NA", NA_character_, .)
  }))

#Convert "No de caso positivo por inicio de síntomas" from char to num
df <- df %>%
  mutate(
    `No de caso positivo por inicio de síntomas` = case_when(
      grepl("^[0-9]+$", `No de caso positivo por inicio de síntomas`) ~  # Verify if the value is a valid number
        as.numeric(`No de caso positivo por inicio de síntomas`),
      TRUE ~ NA_real_  # If is not assign NA
    )
  )

# Special processing for the column "Fecha de la defunción" and "Fecha de última aplicación" due to its format
df <- df %>%
  mutate(
    `Fecha de la defunción` = case_when(
      # Convert numerical values (as "44562") to dates
      grepl("^[0-9]+$", `Fecha de la defunción`) ~ as.character(as.Date(as.numeric(`Fecha de la defunción`), origin = "1899-12-30")),
      # Keep other values as they are (in case there are dates in text format)
      TRUE ~ `Fecha de la defunción`
    ),
    # Convert the column to Date type
    `Fecha de la defunción` = as.Date(`Fecha de la defunción`, format = "%Y-%m-%d"),
    #Same for "Fecha de última aplicación"
    `Fecha de última aplicación` = case_when(
      grepl("^[0-9]+$", `Fecha de última aplicación`) ~ as.character(as.Date(as.numeric(`Fecha de última aplicación`), origin = "1899-12-30")),
      TRUE ~ `Fecha de última aplicación`
    ),
    `Fecha de última aplicación` = as.Date(`Fecha de última aplicación`, format = "%Y-%m-%d")
  )

date_columns <- c(
  "Fecha de inicio de síntomas",
  "Fecha de toma de muestra",
  "Fecha de resultado de laboratorio",
  "Fecha de última aplicación"
)

df <- df %>%
  # Convert dates from mm/dd/yyyy to dd/mm/yyyy
  mutate(across(all_of(date_columns), ~ as.Date(., format = "%m/%d/%Y"))) %>%
  # Categorical encoding
  mutate(across(where(is.character), as.factor))

factor_mapping <- df %>%
  select(where(is.factor)) %>%
  map(~ data.frame(Label = levels(.), Numeric = as.numeric(factor(levels(.)))))

#Creation of new variables

df <- df %>%
  mutate(
    `Dias entre inicio de síntomas y toma de muestra` = as.numeric(
      `Fecha de toma de muestra` - `Fecha de inicio de síntomas`
    ),
    `Dias entre inicio de síntomas y defunción` = as.numeric(
      `Fecha de la defunción` - `Fecha de inicio de síntomas`
    )
  )

# EXPLORING DATA ---------------------------------------------------------------
library(ggplot2)
library(corrplot)

# 1. Identify missing values
missing_data <- df %>%
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

# EXPORTING THE FINAL DATAFRAME TO .CSV ----------------------------------------
write.csv(df, "./Data/data.csv", row.names = FALSE)


