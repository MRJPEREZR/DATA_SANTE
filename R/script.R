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
         - `Semana epidemiológica de resultados positivos`,
         - `Fecha de última aplicación`)
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

# Special processing for the column "Fecha de la defunción" due to its format
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
  )

date_columns <- c(
  "Fecha de inicio de síntomas",
  "Fecha de toma de muestra",
  # "Fecha de resultado de laboratorio"
)

df <- df %>%
  # Convert dates from mm/dd/yyyy to dd/mm/yyyy
  mutate(across(all_of(date_columns), ~ as.Date(., format = "%m/%d/%Y"))) %>%
  # Categorical encoding
  mutate(across(where(is.character), as.factor))

# factor_mapping <- df %>%
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

# EXPLORING DATA ---------------------------------------------------------------
library(ggplot2)
library(corrplot)

# Identify missing values
missing_data <- df1 %>%
  summarise(across(everything(), ~ mean(is.na(.)) * 100)) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Percentage") %>%
  arrange(desc(Missing_Percentage))

print("Columns with missing values:")
print(missing_data)

# Identify constant columns (only one unique value)
constant_columns <- df %>%
  summarise(across(everything(), ~ n_distinct(.))) %>%
  pivot_longer(everything(), names_to = "Variable", values_to = "Unique_Values") %>%
  filter(Unique_Values == 1)

print("Columns with a single unique value (potentially useless):")
print(constant_columns)

# Check for duplicate rows
duplicate_rows <- df[duplicated(df), ]
print(paste("Number of duplicate rows:", nrow(duplicate_rows)))

# Data type verification
print("Data Types:")
print(str(df))

# Identify numeric columns and check distribution
numeric_cols <- df %>% select(where(is.numeric))
summary(numeric_cols)

#Checking if they are dates out of range
# Define the date range
start_date <- as.Date("2021-12-01")
end_date <- as.Date("2022-06-30")

# Function to check if all dates in a column are within the range
check_date_range <- function(column) {
  all(column >= start_date & column <= end_date, na.rm = TRUE)
}

# Apply the function to all Date columns
date_columns <- df %>% select(where(is.Date))

results <- sapply(date_columns, check_date_range)

# Show results only if any column is FALSE
if (any(results == FALSE)) {
  print(results)
} else {
  print("All Date columns are within the specified range.")
}


#Histogram for numerical columns

#Edad

ggplot(df, aes(x = `Edad`)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "black") +
  labs(
    title = "",
    x = "Age",
    y = "Frequence"
  ) +
  theme_minimal()


# Filter and remove rows where age is greater than or equal to 100
df <- df %>% filter(Edad < 100)

#We visualize again the histogram

ggplot(df, aes(x = `Edad`)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "black") +
  labs(
    title = "",
    x = "Age",
    y = "Frequence"
  ) +
  theme_minimal()

#Days between symptom onset and death

ggplot(df, aes(x = `Dias entre inicio de síntomas y defunción`)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "black") +
  labs(
    title = "",
    x = "Days between symptom onset and death",
    y = "Frequence"
  ) +
  theme_minimal()

#Days between symptom onset and laboratory sample collection

ggplot(df, aes(x = `Dias entre inicio de síntomas y toma de muestra`)) +
  geom_histogram(binwidth = 5, fill = "steelblue", color = "black") +
  labs(
    title = "",
    x = "Days between symptom onset and lab sample collection",
    y = "Frequence"
  ) +
  theme_minimal()

#Violin visualization
#scale = "count" makes the area of each violin proportional to the number of patients treated by the institution.
ggplot(df, aes(x = `Institución tratante`, y = `Dias entre inicio de síntomas y toma de muestra`)) +
  geom_violin(aes(fill = `Institución tratante`), scale = "count", alpha = 0.5) +
  geom_boxplot(width = 0.1, fill = "orange", color = "black") +
  labs(
    title = "Violin plots normalized",
    x = "Institution",
    y = "Days between symptom onset and lab sample collection"
  ) +
  theme_minimal() +
  theme(legend.position = "none")

# EXPORTING THE FINAL DATAFRAME TO .CSV ----------------------------------------
write.csv(df, "./R/shiny/data.csv", row.names = FALSE)


