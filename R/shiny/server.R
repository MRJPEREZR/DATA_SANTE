library(shiny)
server <- function(input, output) {
  
  symptoms <- SYMPTOMS
  comorbidities <- COMORBIDITIES
  others <- OTHERS
  
  # CLUSTERING -----------------------------------------------------------------
  filtered_data <- reactive({
    df1
  })
  
  output$missingTable <- renderTable({
    df1 %>% summarise(across(everything(), ~ mean(is.na(.)) * 100)) %>%
      pivot_longer(everything(), names_to = "Variable", values_to = "Missing_Percentage") %>%
      arrange(desc(Missing_Percentage))
  })
  
  analysis <- eventReactive(input$analyze, {
    # Get symptoms based on user selection
    symptom_vars <- if (input$symptomSelection == "all") {
      symptoms
    } else if (input$symptomSelection == "custom") {
      input$selectedSymptoms  # User-selected symptoms
    } else if (input$symptomSelection == "none") {
      NULL # No symptoms
    }
    
    # Get comorbidities based on user selection
    comorbidity_vars <- if (input$comorbiditySelection == "all") {
      comorbidities
    } else if (input$comorbiditySelection == "custom") {
      input$selectedComorbidities  # User-selected comorbidities
    }else if (input$comorbiditySelection == "none") {
      NULL
    }
    
    # Get other attributes based on user selection
    attribute_vars <- if (input$attributeSelection == "all") {
      others
    } else if (input$attributeSelection == "custom") {
      input$selectedAttributes  # User-selected attributes
    } else if (input$attributeSelection == "none") {
      NULL  # No additional attributes
    }
    
    # Combine symptom and attribute selections
    selected_vars <- c(symptom_vars, comorbidity_vars, attribute_vars)
    
    df2_filtred <- df1 %>%
      dplyr::select(all_of(selected_vars)) %>%
      head(1000) %>%  # Taking a subset for clustering
      as.data.frame()
    
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
    
    # Compute t-SNE for k-modes
    tsne_kmodes <- Rtsne(res$gower_dist_kmodes, perplexity = 30)
    tsne_data_kmodes <- data.frame(
      X1 = tsne_kmodes$Y[,1], 
      X2 = tsne_kmodes$Y[,2], 
      cluster = as.factor(res$df2_filtred$kmodes_cluster),
      method = "k-modes"
    )
    
    # Compute t-SNE for PAM
    tsne_pam <- Rtsne(res$gower_dist_pam, perplexity = 30)
    tsne_data_pam <- data.frame(
      X1 = tsne_pam$Y[,1], 
      X2 = tsne_pam$Y[,2], 
      cluster = as.factor(res$df2_filtred_age$pam_cluster),
      method = "PAM"
    )
    
    # Combine both datasets
    tsne_data <- bind_rows(tsne_data_kmodes, tsne_data_pam)
    
    # Plot using facet_wrap to compare both methods
    ggplot(tsne_data, aes(x = X1, y = X2, color = cluster)) +
      geom_point(size = 2) +
      facet_wrap(~ method) +  # This separates plots by clustering method
      theme_minimal() +
      ggtitle("t-SNE Clustering Visualization: k-modes vs. PAM")
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
      mutate(Matches_Mode = all(c_across(-kmodes_cluster) == 
                                  cluster_summary[cluster_summary$kmodes_cluster == kmodes_cluster, -1])) %>%
      ungroup() %>%
      group_by(kmodes_cluster) %>%
      summarise(Count_Mode_Vector = sum(Matches_Mode), Total = n(), .groups = "drop") %>%
      mutate(Percentage = (Count_Mode_Vector / Total) * 100)
    
    return(matches)  # Ensure output is returned
  })
  
  # PREDICTION -----------------------------------------------------------------
  user_data <- reactive({
    req(input$symptoms, input$comorbidities)
    
    symptom_cols <- setNames(rep("NO", length(symptoms)), symptoms)
    symptom_cols[input$symptoms] <- "SI"
    
    comorbidity_cols <- setNames(rep("NO", length(comorbidities)), comorbidities)
    comorbidity_cols[input$comorbidities] <- "SI"
    
    # Create the data frame
    data.frame(
      Age = input$Edad,
      Sex = input$Sexo,
      Fever = symptom_cols["Fiebre"],
      Cough = symptom_cols["Tos"],
      `Shortness of breath` = symptom_cols["Disnea"],
      `Runny nose` = symptom_cols["Rinorrea"],
      `Rapid breathing` = symptom_cols["Polipnea"],
      Cyanosis = symptom_cols["Cianosis"],
      `Chest pain` = symptom_cols["Dolor torácico"],
      Chills = symptom_cols["Escalofríos"],
      Headache = symptom_cols["Cefalea"],
      `Muscle pain` = symptom_cols["Mialgias"],
      `Joint pain` = symptom_cols["Artralgias"],
      `General malaise` = symptom_cols["Ataque al estado general"],
      `Sudden onset` = symptom_cols["Inicio súbito"],
      COPD = comorbidity_cols["EPOC"],
      Asthma = comorbidity_cols["Asma"],
      Immunosuppression = comorbidity_cols["Inmunosupresión"],
      Hypertension = comorbidity_cols["Hipertensión"],
      Diabetes = comorbidity_cols["Diabetes"],
      `Heart disease` = comorbidity_cols["Enfermedad cardiaca"],
      Obesity = comorbidity_cols["Obesidad"],
      Smoking = comorbidity_cols["Tabaquismo"],
      `Chronic kidney disease` = comorbidity_cols["Insuficiencia renal crónica"],
      `Laboratory result` = input$lab_result,
      check.names = FALSE
    )
  })
  
  # Make predictions when the predict button is clicked
  prediction <- eventReactive(input$predict, {
    req(best_rf_model)
    new_data <- user_data()
    
    # Get both class probabilities and predicted class
    prob_pred <- predict(best_rf_model, new_data, type = "prob")
    class_pred <- predict(best_rf_model, new_data, type = "class")
    
    list(probabilities = prob_pred, class = class_pred)
  })
  
  # Display prediction results
  output$prediction <- renderPrint({
    pred <- prediction()
    cat("Predicted Diagnosis:", as.character(pred$class$.pred_class), "\n\n")
    cat("Probabilities:\n")
    print(pred$probabilities)
  })
  
  # Plot probabilities
  output$prob_plot <- renderPlot({
    pred <- prediction()
    probs <- pred$probabilities %>%
      pivot_longer(cols = everything(), names_to = "Diagnosis", values_to = "Probability")
    
    ggplot(probs, aes(x = Diagnosis, y = Probability, fill = Diagnosis)) +
      geom_bar(stat = "identity") +
      scale_fill_manual(values = c("#E69F00", "#56B4E9")) +
      labs(title = "Diagnosis Probability Distribution",
           y = "Probability") +
      theme_minimal() +
      theme(legend.position = "none") +
      scale_y_continuous(limits = c(0, 1))
  })
}