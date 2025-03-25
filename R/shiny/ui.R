library(shiny)

symptoms <- SYMPTOMS
comorbidities <- COMORBIDITIES
comorbidities1 <- COMORBIDITIES1
others <- OTHERS

ui <- fluidPage(
  titlePanel("Clustering & Prediction Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        condition = "input.tabs == 'Clustering'",
        numericInput("clusters", "Number of Clusters", value = 2, min = 2, max = 10),
        radioButtons("symptomSelection", "Select Symptoms:",
                     choices = c("All Symptoms" = "all", "Custom Selection" = "custom", "None" = "none"),
                     selected = "all"),
        radioButtons("attributeSelection", "Select other attributes:",
                     choices = c("All Attributes" = "all", "Custom Selection" = "custom", "None" = "none"),
                     selected = "none"),
        radioButtons("comorbiditySelection", "Select other attributes:",
                     choices = c("All Comorbidities" = "all", "Custom Selection" = "custom", "None" = "none"),
                     selected = "none"),
        
        conditionalPanel(
          condition = "input.symptomSelection == 'custom'",
          checkboxGroupInput("selectedSymptoms", "Select Symptoms for Clustering:",
                             choices = symptoms,
                             selected = c("Fiebre", "Tos", "Disnea", "Rinorrea", "Polipnea", "Cianosis"))
        ),
        conditionalPanel(
          condition = "input.comorbiditySelection == 'custom'",
          checkboxGroupInput("selectedComorbidities", "Select comorbidities for Clustering:",
                             choices = comorbidities,
                             selected = c("Asma", "Tabaquismo"))
        ),
        conditionalPanel(
          condition = "input.attributeSelection == 'custom'",
          checkboxGroupInput("selectedAttributes", "Select attributes for Clustering:",
                             choices = others,
                             selected = c("Sexo"))
        ),
        actionButton("analyze", "Run Analysis")
      ),
      
      conditionalPanel(
        condition = "input.tabs == 'Respiratory Disease Prediction'",
        h4("Patient Information"),
        numericInput("Edad", "Age (Years)", value = 30, min = 0, max = 100),
        radioButtons("Sexo", "Sex", 
                     choices = c("Male" = "M", "Female" = "F")),
        
        h4("Symptoms"),
        awesomeCheckboxGroup("symptoms", "Select Symptoms:",
                             choices = symptoms,
                             selected = c("Fiebre", "Tos", "Disnea")),
        
        h4("Comorbidities"),
        awesomeCheckboxGroup("comorbidities", "Select Comorbidities:",
                             choices = comorbidities1,
                             selected = c("Asma", "Tabaquismo")),
        
        radioButtons("lab_result", "Laboratory Result:",
                     choices = c("Positive" = "SARS-COV-2",
                                 "Negative" = "Negativo")),
        
        actionButton("predict", "Predict Diagnosis", class = "btn-primary")
      )
    ),
    
    mainPanel(
      tabsetPanel(
        id = "tabs",
        tabPanel("Clustering",
                 tabsetPanel(
                   tabPanel("Cluster Visualization", plotOutput("tsnePlot")),
                   tabPanel("Silhouette Scores", verbatimTextOutput("silScores")),
                   tabPanel("Cluster Summary", tableOutput("clusterSummary")),
                   tabPanel("Matches", tableOutput("matches"))
                 )
        ),
        
        tabPanel("Respiratory Disease Prediction",
                 tabsetPanel(
                   tabPanel("Diagnosis Prediction",
                            h3("Prediction Results"),
                            wellPanel(
                              h4("Diagnosis Probability:"),
                              verbatimTextOutput("prediction"),
                              plotOutput("prob_plot")
                            ),
                            br(),
                            h4("Interpretation:"),
                            p("This tool predicts the probability of two respiratory conditions:"),
                            tags$ul(
                              tags$li(tags$strong("ETI (Influenza-like Illness)")),
                              tags$li(tags$strong("IRAG (Severe Acute Respiratory Infection)"))
                            )
                   )
                 )
        )
      )
    )
  )
)