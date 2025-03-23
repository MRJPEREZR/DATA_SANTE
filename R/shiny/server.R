library(shiny)
server <- function(input, output) {
  filtered_data <- reactive({
    df1
  })
  
  output$missingTable <- renderTable({
    df1 %>% summarise(across(everything(), ~ mean(is.na(.)) * 100)) %>%
      pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Percentage") %>%
      arrange(desc(Missing_Percentage))
  })
  
  analysis <- eventReactive(input$analyze, {
    df2 <- df1 %>% dplyr::select(-c("Vacuna contra COVID19", -"Marca", -"Ocupación", -"Estatus del paciente", -"Diagnóstico probable"))
    df2_filtred <- as.data.frame(df2[0:1000,6:38])
    df2_filtred_age <- df2_filtred %>% mutate(Edad = df$`Edad`[0:1000])
    
    gower_dist_kmodes <- daisy(df2_filtred, metric = "gower")
    gower_dist_pam <- daisy(df2_filtred_age, metric = "gower")
    
    kmodes_model <- kmodes(df2_filtred, modes = input$clusters, iter.max = 200)
    df2_filtred$kmodes_cluster <- kmodes_model$cluster
    
    pam_model <- pam(gower_dist_pam, k = input$clusters)
    df2_filtred_age$pam_cluster <- pam_model$clustering
    
    kmodes_sil <- silhouette(df2_filtred$kmodes_cluster, gower_dist_kmodes)
    pam_sil <- silhouette(df2_filtred_age$pam_cluster, gower_dist_pam)
    
    list(
      kmodes_score = mean(kmodes_sil[, 3]),
      pam_score = mean(pam_sil[, 3]),
      df2_filtred = df2_filtred,
      df2_filtred_age = df2_filtred_age,
      gower_dist_kmodes = gower_dist_kmodes,
      gower_dist_pam = gower_dist_pam
    )
  })
  
  output$silScores <- renderPrint({
    res <- analysis()
    cat("k-modes Silhouette Score:", res$kmodes_score, "\n")
    cat("PAM Silhouette Score:", res$pam_score)
  })
  
  output$tsnePlot <- renderPlot({
    res <- analysis()
    tsne_obj <- Rtsne(res$gower_dist_kmodes, perplexity = 30)
    tsne_data <- data.frame(tsne_obj$Y, cluster = as.factor(res$df2_filtred$kmodes_cluster))
    ggplot(tsne_data, aes(x = X1, y = X2, color = cluster)) +
      geom_point(size = 2) + theme_minimal() + ggtitle("Clusters Visualization (t-SNE)")
  })
  
  cluster_summary_reactive <- reactive({
    res <- analysis()
    res$df2_filtred %>%
      group_by(kmodes_cluster) %>%
      summarise(across(where(is.factor), ~ names(which.max(table(.x)))))
  })
  
  output$clusterSummary <- renderTable({
    cluster_summary_reactive()  # Use the reactive function
  })
  
  output$matches <- renderTable({
    res <- analysis()
    cluster_summary <- cluster_summary_reactive()  # Get stored cluster_summary
    df2_filtred <- res$df2_filtred
    
    # Ensure cluster_summary is not NULL before proceeding
    if (is.null(cluster_summary) || nrow(cluster_summary) == 0) {
      return(data.frame(Message = "No cluster summary available"))
    }
    
    df2_filtred_with_modes <- df2_filtred %>%
      left_join(cluster_summary, by = "kmodes_cluster")
    
    matches <- df2_filtred_with_modes %>%
      rowwise() %>%
      mutate(Matches_Mode = identical(
        c_across(-kmodes_cluster),
        cluster_summary[cluster_summary$kmodes_cluster == kmodes_cluster, -1]
      )) %>%
      ungroup() %>%
      group_by(kmodes_cluster) %>%
      summarise(
        Count_Mode_Vector = sum(Matches_Mode, na.rm = TRUE),
        Total = n(),
        Percentage = (Count_Mode_Vector / Total) * 100,
        .groups = "drop"
      )
    
    return(matches)  # Ensure output is returned
  })
  
}