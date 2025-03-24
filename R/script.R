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
  "Fecha de resultado de laboratorio"
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

# Identify missing values
missing_data <- df %>%
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
saveRDS(df, file = "./R/shiny/dataframe.rds")

#####################################################################################

# Install necessary packages
install.packages("gganimate")
install.packages("magick")
install.packages("gifski")  # Required for saving animations as GIF

#Necessary libraries

library(readxl)
library(tidyverse)
library(ggplot2)
library(gganimate)
library(magick)
library(gifski)
library(dplyr)
library(tidyr)  # For using pivot_longer

df <- read_csv("./R/shiny/data.csv") #See if could be changed for dataframe.rds
df <- df %>%
  # Categorical encoding
  mutate(across(where(is.character), as.factor))


# List of symptoms
symptoms <- c("Fiebre", "Tos", "Odinofagia", "Disnea", "Irritabilidad", "Diarrea", "Dolor torácico", "Escalofríos", "Cefalea", "Mialgias", "Artralgias", "Ataque al estado general", "Rinorrea", "Polipnea", "Vómito", "Dolor abdminal", "Conjuntivitis", "Cianosis", "Inicio súbito", "Anosmia", "Disgeusia", "Diabetes", "EPOC", "Asma", "Inmunosupresión", "Hipertensión", "VIH/SIDA", "Otra condición", "Enfermedad cardiaca", "Obesidad", "Insuficiencia renal crónica", "Tabaquismo")

# Convert the dataset from wide format to long format
df_long <- df %>%
  pivot_longer(
    cols = all_of(symptoms),  # Select only the symptom columns
    names_to = "Síntoma",
    values_to = "Valor"
  )

#####################################################################################

# Severity grade:

df_long <- df_long %>%
  mutate(Gravedad = case_when(
    Síntoma %in% c("Rinorrea", "Tos", "Odinofagia", "Cefalea", "Conjuntivitis") ~ 1,  # Level 1: Minor symptoms
    Síntoma %in% c("Mialgias", "Artralgias", "Escalofríos", "Diarrea", "Vómito", "Dolor abdminal", "Ataque al estado general", "Anosmia", "Disgeusia") ~ 1,  # Level 2: Moderate symptoms
    Síntoma %in% c("Fiebre", "Irritabilidad", "Polipnea") ~ 2,  # Level 3: Moderately severe symptoms
    Síntoma %in% c("Dolor torácico", "Disnea", "Cianosis") ~ 2,  # Level 4: Severe symptoms
    Síntoma %in% c("Diabetes", "EPOC", "Asma", "Inmunosupresión", "Hipertensión", 
                   "VIH/SIDA", "Enfermedad cardiaca", "Obesidad", "Insuficiencia renal crónica", "Tabaquismo") ~ 3,  #Level 5: Pre-existing medical conditions
    TRUE ~ NA_real_  # Default value for other symptoms
  ))


new_dataset <- df_long %>%
  group_by(`Fecha de inicio de síntomas`, Síntoma, Gravedad) %>%
  summarise(
    total_patients = n(),  # Total patients up to that date
    total_patients_with_symptom = sum(Valor == "SI"),  # Patients with the symptom
    total_patients_with_IRAG = sum(`Diagnóstico probable` == "INFECCION RESPIRATORIA AGUDA GRAVE (IRAG)"),  # Patients with IRAG
    total_patients_with_symptom_and_IRAG = sum(Valor == "SI" & `Diagnóstico probable` == "INFECCION RESPIRATORIA AGUDA GRAVE (IRAG)"),  # Patients with symptom and IRAG
    .groups = 'drop'
  ) %>%
  arrange(`Fecha de inicio de síntomas`) %>%
  group_by(Síntoma) %>%
  mutate(
    # Cumulative frequency of the symptom
    symptom_frequency = cumsum(total_patients_with_symptom) / cumsum(total_patients),
    # Cumulative frequency of the symptom in patients with IRAG
    symptom_frequency_IRAG = ifelse(
      cumsum(total_patients_with_IRAG) == 0,  # If the divisor is 0
      0,  # Return 0
      cumsum(total_patients_with_symptom_and_IRAG) / cumsum(total_patients_with_IRAG)  # Otherwise, calculate the frequency
    )
  ) %>%
  ungroup()

# View the new dataset
head(new_dataset)

# Create the bubble chart
p <- ggplot(new_dataset,
            aes(x = symptom_frequency,          # X axis: Symptom frequency
                y = symptom_frequency_IRAG,       # Y axis: Symptom frequency in IRAG
                size = Gravedad,                 # Bubble size: Symptom severity
                color = Síntoma)) +              # Color: Symptom
  geom_point(alpha = 0.7) +
  scale_size(range = c(3, 15)) +            # Adjust the bubble size range
  theme_bw() +
  labs(title = 'Date: {frame_time}',
       x = 'Symptom Frequency',
       y = 'Symptom Frequency in IRAG',
       size = 'Severity',
       color = 'Symptom') +
  theme(plot.title = element_text(size = 20, hjust = 0.5, color = "steelblue")) +
  transition_time(`Fecha de inicio de síntomas`) +  # Animate by date
  ease_aes('linear')

# Show the animation
animate(p, nframes = 250, fps = 5, width = 800, height = 600)

anim_save("animation.gif", animation = last_animation())

##################################################################################
library(ggplot2)
library(dplyr)
library(plotly)
library(htmlwidgets)

# Create interactive plot for the last day

# Filter data for the last day
last_day <- new_dataset %>%
  filter(`Fecha de inicio de síntomas` == max(`Fecha de inicio de síntomas`))

# Create the static plot with ggplot2
p_last_day <- ggplot(last_day,
                     aes(x = symptom_frequency,          
                         y = symptom_frequency_IRAG,    
                         size = Gravedad,                
                         color = Síntoma,                
                         text = paste("Symptom:", Síntoma, "<br>",  
                                      "Frequency:", round(symptom_frequency, 2), "<br>",
                                      "Frequency in IRAG:", round(symptom_frequency_IRAG, 2), "<br>",
                                      "Severity:", Gravedad))) + 
  geom_point(alpha = 0.7) +
  scale_size(range = c(3, 15)) +            
  theme_bw() +
  labs(title = paste("Last day:", max(last_day$`Fecha de inicio de síntomas`)),
       x = 'Symptom Frequency',
       y = 'Symptom Frequency in IRAG',
       size = 'Severity',
       color = 'Symptom') +
  theme(plot.title = element_text(size = 20, hjust = 0.5, color = "steelblue"))

# Convert ggplot2 plot to plotly with the ability to select symptoms interactively
p_interactive <- ggplotly(p_last_day, tooltip = "text") %>%
  layout(
    legend = list(
      title = list(text = 'Symptoms'),
      itemsizing = 'constant',
      traceorder = 'reversed'
    ),
    xaxis = list(title = 'Symptom Frequency'),
    yaxis = list(title = 'Symptom Frequency in IRAG')
  )

# Show the interactive plot
p_interactive

# Save the interactive plot as an HTML file
saveWidget(p_interactive, file = "interactive_plot.html")

##########################################################################################
# Daily frequency instead of cumulative frequency

# Calculate daily frequencies
new_dataset_daily <- df_long %>%
  group_by(`Fecha de inicio de síntomas`, Síntoma, Gravedad) %>%
  summarise(
    total_patients = n(),  # Total patients that day
    total_patients_with_symptom = sum(Valor == "SI"),  # Patients with the symptom that day
    total_patients_with_IRAG = sum(`Diagnóstico probable` == "INFECCION RESPIRATORIA AGUDA GRAVE (IRAG)"),  # Patients with IRAG that day
    total_patients_with_symptom_and_IRAG = sum(Valor == "SI" & `Diagnóstico probable` == "INFECCION RESPIRATORIA AGUDA GRAVE (IRAG)"),  # Patients with symptom and IRAG that day
    .groups = 'drop'
  ) %>%
  mutate(
    # Daily frequency of the symptom
    daily_symptom_frequency = total_patients_with_symptom / total_patients,
    # Daily frequency of the symptom in patients with IRAG
    daily_symptom_frequency_IRAG = ifelse(
      total_patients_with_IRAG == 0,  # If there are no patients with IRAG that day
      0,  # Return 0
      total_patients_with_symptom_and_IRAG / total_patients_with_IRAG  # Otherwise, calculate the frequency
    )
  )

# Create the animated plot
p_animated <- ggplot(new_dataset_daily,
                     aes(x = daily_symptom_frequency,          # X axis: Daily symptom frequency
                         y = daily_symptom_frequency_IRAG,    # Y axis: Daily symptom frequency in IRAG
                         size = Gravedad,                       # Bubble size: Symptom severity
                         color = Síntoma)) +                    # Color: Symptom
  geom_point(alpha = 0.7) +
  scale_size(range = c(3, 15)) +            # Adjust the bubble size range
  theme_bw() +
  labs(title = 'Date: {frame_time}',
       x = 'Daily Symptom Frequency',
       y = 'Daily Symptom Frequency in IRAG',
       size = 'Severity',
       color = 'Symptom') +
  theme(plot.title = element_text(size = 20, hjust = 0.5, color = "steelblue")) +
  transition_time(`Fecha de inicio de síntomas`) +  # Animate by date
  ease_aes('linear')

# Show the animation
animate(p_animated, nframes = 400, fps = 5, width = 800, height = 600)

anim_save("daily_animation.gif", animation = last_animation())

###################################################################################



