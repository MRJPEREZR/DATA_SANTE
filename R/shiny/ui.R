library(shiny)

ui <- fluidPage(
  titlePanel("Clustering & Prediction Analysis"),
  
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        condition = "input.tabs == 'Clustering'",
        numericInput("clusters", "Number of Clusters", value = 2, min = 2, max = 10),
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