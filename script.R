install.packages("DataExplorer")


library(shiny)
library(readxl)
library(tidyverse)
library(tidymodels)

# LOAD DATASET
df <- read_excel("./CENSO_DATOS_ABIERTOS_GENERAL_COVID_2020.xlsx", sheet=1)

# Load necessary libraries
library(tidyverse)
library(DataExplorer)
library(ggplot2)
library(corrplot)

# Check data structure
glimpse(df)

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



# Load necessary libraries
library(dplyr)

# Remove variables that are not useful for our objective
df_removed <- df %>%
  select(-`Toma de muestra en el ESTADO`, 
         -`Procedencia`, 
         -`Fecha de llegada al Estado`, 
         -`REFUERZO`, 
         -`FECHA REFUERZO`, 
         -`VARIANTE`, 
         -`INFLUENZA`)

# Verify that the variables have been removed
names(df_removed)

# Load necessary libraries
library(dplyr)
library(lubridate)  # For date manipulation

# List of date columns to transform
date_columns <- c(
  "Fecha de inicio de síntomas",
  "Periodo mínimo de incubación (2 días)",
  "Periodo máximo de incubación (7 días)",
  "Fecha estimada de Alta Sanitaria",
  "Fecha de toma de muestra",
  "Fecha de resultado de laboratorio",
  "Fecha de la defunción",
  "Fecha de última aplicación"
)

# Convert dates from mm/dd/yyyy to dd/mm/yyyy
df1 <- df_removed %>%
  mutate(across(all_of(date_columns), ~ format(as.Date(., format = "%m/%d/%Y"), "%d/%m/%Y")))

# Verify the transformation
head(df1 %>% select(all_of(date_columns)))

# Convert character columns to Date type (format dd/mm/yyyy)
df1 <- df1 %>%
  mutate(across(all_of(date_columns), ~ as.Date(., format = "%d/%m/%Y")))

# Verify the transformation
str(df1 %>% select(all_of(date_columns)))



