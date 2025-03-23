library(shiny)
ui <- fluidPage(
  titlePanel("Clustering Analysis"),
  sidebarLayout(
    sidebarPanel(
      numericInput("clusters", "Number of Clusters", value = 2, min = 2, max = 10),
      actionButton("analyze", "Run Analysis")
    ),
    mainPanel(
      tabsetPanel(
        tabPanel("Silhouette Scores", verbatimTextOutput("silScores")),
        tabPanel("Cluster Visualization", plotOutput("tsnePlot")),
        tabPanel("Cluster Summary", tableOutput("clusterSummary"))
      )
    )
  )
)