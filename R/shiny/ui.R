library(shiny)

ui <- fluidPage(
  titlePanel("Clustering & Prediction Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        condition = "input.tabs == 'Clustering'",
        numericInput("clusters", "Number of Clusters", value = 2, min = 2, max = 10),
        radioButtons("symptomSelection", "Select Symptoms:",
                     choices = c("All Symptoms" = "all", "Custom Selection" = "custom"),
                     selected = "all"),
        
        conditionalPanel(
          condition = "input.symptomSelection == 'custom'",
          checkboxGroupInput("selectedSymptoms", "Select Symptoms for Clustering:",
                             choices = c("Fiebre", "Tos", "Odinofagia", "Disnea", "Irritabilidad",
                                         "Diarrea", "Dolor torácico", "Escalofríos", "Cefalea", "Mialgias",
                                         "Artralgias", "Ataque al estado general", "Rinorrea", "Polipnea",
                                         "Vómito", "Dolor abdominal", "Conjuntivitis", "Cianosis",
                                         "Inicio súbito", "Anosmia", "Disgeusia"),
                             selected = c("Fiebre", "Tos", "Odinofagia", "Disnea", "Irritabilidad", 
                                          "Diarrea", "Dolor torácico", "Escalofríos", "Cefalea", "Mialgias"))
        ),
        actionButton("analyze", "Run Analysis")
      ),
      
      conditionalPanel(
        condition = "input.tabs == 'Prediction Methods'",
        selectInput("predictionMethod", "Select Prediction Method", 
                    choices = c("Method 1", "Method 2")),
        actionButton("predict", "Run Prediction")
      )
    ),
    
    mainPanel(
      tabsetPanel(
        id = "tabs",  # Add an id to the tabsetPanel
        tabPanel("Clustering",  # Main Page for Clustering
                 tabsetPanel(
                   tabPanel("Cluster Visualization", plotOutput("tsnePlot")),
                   tabPanel("Silhouette Scores", verbatimTextOutput("silScores")),
                   tabPanel("Cluster Summary", tableOutput("clusterSummary")),
                   tabPanel("Matches", tableOutput("matches"))
                 )
        ),
        
        tabPanel("Prediction Methods",  # New Main Page for Predictions
                 tabsetPanel(
                   tabPanel("Method 1", verbatimTextOutput("predictionMethod1")),
                   tabPanel("Method 2", verbatimTextOutput("predictionMethod2")),
                   tabPanel("Comparison", tableOutput("predictionComparison"))
                 )
        )
      )
    )
  )
)