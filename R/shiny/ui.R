# UI ---------------------------------------------------------------------------
ui <- fluidPage(
  titlePanel("Clustering Analysis Dashboard"),
  
  sidebarLayout(
    sidebarPanel(
      selectInput("method", "Clustering Method", 
                  choices = c("K-Means", "Hierarchical Clustering")),
      numericInput("clusters", "Number of Clusters", value = 3, min = 2, max = 10),
      actionButton("run", "Run Clustering")
    ),
    
    mainPanel(
      tabsetPanel(
        tabPanel("Clustering Plot", plotOutput("clusterPlot")),
        tabPanel("Cluster Summary", verbatimTextOutput("clusterSummary"))
      )
    )
  )
)