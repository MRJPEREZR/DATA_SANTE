# SERVER -----------------------------------------------------------------------
server <- function(input, output) {
  
  # Reactive expression to perform clustering
  clusters <- eventReactive(input$run, {
    df <- data
    df <- na.omit(df)  # Remove missing values
    
    # Select numeric columns for clustering
    numeric_cols <- df %>% select_if(is.numeric)
    
    if (input$method == "K-Means") {
      kmeans(numeric_cols, centers = input$clusters)
    } else {
      hclust(dist(numeric_cols), method = "ward.D2")
    }
  })
  
  # Output clustering plot
  output$clusterPlot <- renderPlot({
    if (input$method == "K-Means") {
      # Get cluster assignments
      cluster_results <- clusters()
      df <- data %>% select_if(is.numeric) %>% na.omit()
      df$cluster <- as.factor(cluster_results$cluster)
      
      # Plot using ggplot2
      ggplot(df, aes(x = df[, 1], y = df[, 2], color = cluster)) +
        geom_point(size = 3) +
        labs(title = "K-Means Clustering",
             x = colnames(df)[1],
             y = colnames(df)[2],
             color = "Cluster") +
        theme_minimal()
    } else {
      # Plot dendrogram for hierarchical clustering
      plot(clusters())
      rect.hclust(clusters(), k = input$clusters, border = "red")
    }
  })
  
  # Output cluster summary
  output$clusterSummary <- renderPrint({
    if (input$method == "K-Means") {
      clusters()$centers
    } else {
      cutree(clusters(), k = input$clusters)
    }
  })
}