# DATA SANTE FINAL PROJECT

We collected the data from an official source provided by the Mexican government [Censo General de Casos de Enfermedad Respiratoria Viral en Colima](https://datos.gob.mx/busca/dataset/censo-general-de-casos-de-enfermedad-respiratoria-viral-estudiados-en-la-entidad-de-colima).
Our goal is to analyze this dataset by applying clustering and machine learning algorithms. 
Specifically, we aim to develop a predictive model for clinical diagnosis (Influenza-Like Illness or Severe Acute Respiratory Infection).

The final result is an app available to visit here: [https://jperezr.shinyapps.io/datasante_imt/](https://jperezr.shinyapps.io/datasante_imt/)

![Shiny App](Docs/shinyApp.gif)

# Table of contents
- [How to run it ?](#how-to-running-it-?)
- [Introduction](#introduction)
- [Business undestanding](#business-undestanding)
- [Data understanding](#data-understanding)
- [Data Preparation](#data-preparation)
- [Modeling](#modeling)
- [Evaluation](#evaluation)
- [Deployment](#deployment)
- [Summary](#summary)

# How to run it ?

It's simple!, first install R, shiny (see more [here])(https://shiny.posit.co/)), and execute the following commands:
```
git clone https://github.com/MRJPEREZR/DATA_SANTE.git
cd DATA_SANTE/R/shiny
R
shiny::RunApp()
```

# Introduction

This is a project that follows the CRISP-DM (Cross-industry standard process for data mining) methodology. 
In a nutshell, we clean and filter the data to get a proper data frame without missing values to be able to fit supervised and unsupervised learning algorithms.
To explain with more details, next section illustrates each CRIPS-DM steps:

# Business understanding

The dataset provides valuable insights into the incidence of acute respiratory diseases, such as Influenza-Like Illness (ILI) and Severe Acute Respiratory Infection (SARI), within the state of Colima, Mexico, during the year 2020. This is a critical public health concern, as respiratory infections have been one of the leading causes of illness in the region. By analyzing this data, we aim to help healthcare professionals and local authorities better understand patterns and trends in these diseases.

From a business perspective, this analysis can contribute to:

- Improved Resource Allocation: Understanding the severity and distribution of cases can help local health services better allocate resources such as medical personnel, equipment, and medicines.

- Public Health Strategies: Insights derived from predictive models can assist in designing more effective public health interventions, helping prevent the spread of infections.

- Policy Decision Support: The analysis can provide valuable data to inform governmental policies regarding healthcare funding, vaccination campaigns, and other preventive measures.

- Enhancing Healthcare Response: By developing predictive models for clinical diagnosis and discharge times, we can support healthcare providers in managing patient flow more efficiently, improving both the quality of care and patient outcomes.

In this context, applying clustering and machine learning techniques will not only help in improving disease diagnosis and medical discharge predictions but also in providing actionable insights for better healthcare management and planning.

# Data understanding

## Profiling report
[Here](https://mrjperezr.github.io/DATA_SANTE/Docs/profiling_report.html) you can find a profiling report generated with python to take a quick look to the initial dataset state.

## Column name and data type list

| Column                                          | Data type original -> transformed|
|-------------------------------------------------|-----------------------------|
| No de caso positivo por inicio de síntomas      | num                         |
| No consecutivo por inicio de síntomas           | num                         |
| Institución tratante                            | chr -> Factor 8 levels      |
| Unidad notificante                              | chr -> Factor 128 levels    |
| Municipio de residencia                         | chr  -> Factor 111 levels   |
| Edad                                            | num                         |
| Sexo                                            | chr -> Factor 2 levels      |
| Fecha de inicio de síntomas                     | date                        |
| Fecha de toma de muestra                        | date                        |
| Tipo de manejo                                  | chr -> Factor 2 levels      |
| Estatus del paciente                            | chr -> Factor 8 levels      |
| Fecha de la defunción                           | date                        |
| Fecha de resultado de laboratorio               | date                        |
| Resultado de laboratorio                        | chr -> Factor 3 levels      |
| Pacientes que requirieron intubación            | chr -> Factor 2 levels      |
| Pacientes que ingresaron a UCI                  | chr -> Factor 2 levels      |
| Diagnóstico clínico de Neumonía                 | chr -> Factor 2 levels      |
| Diagnóstico probable                            | chr -> Factor 2 levels      |
| Fiebre                                          | chr -> Factor 3 levels      |
| Tos                                             | chr -> Factor 2 levels      |
| Odinofagia                                      | chr -> Factor 3 levels      |
| Disnea                                          | chr -> Factor 3 levels      |
| Irritabilidad                                   | chr -> Factor 3 levels      |
| Diarrea                                         | chr -> Factor 3 levels      |
| Dolor torácico                                  | chr -> Factor 3 levels      |
| Escalofríos                                     | chr -> Factor 3 levels      |
| Cefalea                                         | chr -> Factor 3 levels      |
| Mialgias                                        | chr -> Factor 3 levels      |
| Artralgias                                      | chr -> Factor 3 levels      |
| Ataque al estado general                        | chr -> Factor 3 levels      |
| Rinorrea                                        | chr -> Factor 3 levels      |
| Polipnea                                        | chr -> Factor 3 levels      |
| Vómito                                          | chr -> Factor 3 levels      |
| Dolor abdominal                                 | chr -> Factor 3 levels      |
| Conjuntivitis                                   | chr -> Factor 3 levels      |
| Cianosis                                        | chr -> Factor 3 levels      |
| Inicio súbito                                   | chr -> Factor 3 levels      |
| Anosmia                                         | chr -> Factor 3 levels      |
| Disgeusia                                       | chr -> Factor 3 levels      |
| Diabetes                                        | chr -> Factor 3 levels      |
| EPOC                                            | chr -> Factor 3 levels      |
| Asma                                            | chr -> Factor 3 levels      |
| Inmunosupresión                                 | chr -> Factor 3 levels      |
| Hipertensión                                    | chr -> Factor 3 levels      |
| VIH/SIDA                                        | chr -> Factor 3 levels      |
| Otra condición                                  | chr -> Factor 3 levels      |
| Enfermedad cardiaca                             | chr -> Factor 3 levels      |
| Obesidad                                        | chr -> Factor 3 levels      |
| Insuficiencia renal crónica                     | chr -> Factor 3 levels      |
| Tabaquismo                                      | chr -> Factor 3 levels      |
| Vacuna contra COVID19                           | chr -> Factor 3 levels      |
| Marca                                           | chr -> Factor 11 levels     |
| Ocupación                                       | chr -> Factor 18 levels     |


## Description of dataset's categorical columns used. 

| **Español** | **English** | **Français** | **Description** |
|-------------|------------|--------------|----------------|
| Institución tratante | Treating Institution | Institution traitante | The healthcare facility providing medical care. |
| Unidad notificante | Reporting Unit | Unité de notification | The entity responsible for reporting the case. |
| Municipio de residencia | Municipality of Residence | Municipalité de résidence | The city or town where the patient lives. |
| Sexo | Sex | Sexe | The biological sex of the patient (Male/Female). |
| Tipo de manejo | Type of Management | Type de prise en charge | The method of patient care (e.g., outpatient, hospitalized). |
| Estatus del paciente | Patient Status | Statut du patient | The current condition of the patient (e.g., recovered, deceased). |
| Resultado de laboratorio | Laboratory Result | Résultat de laboratoire | The outcome of diagnostic tests (e.g., positive/negative). |
| Pacientes que requirieron intubación | Patients Requiring Intubation | Patients nécessitant une intubation | Patients who needed mechanical ventilation. |
| Pacientes que ingresaron a UCI | Patients Admitted to ICU | Patients admis en soins intensifs | Patients who were transferred to an Intensive Care Unit. |
| Diagnóstico clínico de Neumonía | Clinical Diagnosis of Pneumonia | Diagnostic clinique de pneumonie | Diagnosis based on medical examination and symptoms. |
| Diagnóstico probable | Probable Diagnosis | Diagnostic probable | A preliminary medical diagnosis before confirmation. |
| Fiebre | Fever | Fièvre | Elevated body temperature, common in infections. |
| Tos | Cough | Toux | A reflex to clear the airways, common in respiratory infections. |
| Odinofagia | Sore Throat | Maux de gorge | Pain or discomfort in the throat when swallowing. |
| Disnea | Shortness of Breath | Dyspnée | Difficulty in breathing or breathlessness. |
| Irritabilidad | Irritability | Irritabilité | Increased sensitivity or agitation, common in illness. |
| Diarrea | Diarrhea | Diarrhée | Frequent, loose, or watery bowel movements. |
| Dolor torácico | Chest Pain | Douleur thoracique | Pain in the chest area, may indicate respiratory or cardiac issues. |
| Escalofríos | Chills | Frissons | Shivering due to cold or fever. |
| Cefalea | Headache | Céphalée | Pain or discomfort in the head. |
| Mialgias | Muscle Pain | Myalgies | General muscle aches, common in viral infections. |
| Artralgias | Joint Pain | Arthralgies | Pain in the joints, common in inflammatory diseases. |
| Ataque al estado general | General Malaise | Malaise général | A general feeling of discomfort or weakness. |
| Rinorrea | Runny Nose | Rhinorrhée | Excess nasal mucus discharge. |
| Polipnea | Rapid Breathing | Polypnée | Abnormally fast breathing rate. |
| Vómito | Vomiting | Vomissement | Expelling stomach contents through the mouth. |
| Dolor abdominal | Abdominal Pain | Douleur abdominale | Pain in the stomach or belly area. |
| Conjuntivitis | Conjunctivitis | Conjonctivite | Inflammation of the eye's conjunctiva (pink eye). |
| Cianosis | Cyanosis | Cyanose | Bluish skin due to lack of oxygen in the blood. |
| Inicio súbito | Sudden Onset | Début soudain | Symptoms that appear suddenly. |
| Anosmia | Loss of Smell (Anosmia) | Perte d'odorat (Anosmie) | The inability to detect odors. |
| Disgeusia | Loss of Taste (Dysgeusia) | Perte du goût (Dysgueusie) | A distortion or loss of the sense of taste. |
| Diabetes | Diabetes | Diabète | A chronic condition affecting blood sugar levels. |
| EPOC | COPD (Chronic Obstructive Pulmonary Disease) | BPCO (Bronchopneumopathie chronique obstructive) | A chronic lung disease that causes airflow blockage. |
| Asma | Asthma | Asthme | A condition causing breathing difficulties due to airway narrowing. |
| Inmunosupresión | Immunosuppression | Immunosuppression | A weakened immune system, increasing infection risk. |
| Hipertensión | Hypertension | Hypertension | High blood pressure, a risk factor for heart disease. |
| VIH/SIDA | HIV/AIDS | VIH/SIDA | A viral infection that weakens the immune system. |
| Otra condición | Other Condition | Autre condition | Any additional medical condition not listed. |
| Enfermedad cardiaca | Heart Disease | Maladie cardiaque | A broad term for conditions affecting the heart. |
| Obesidad | Obesity | Obésité | Excessive body weight, increasing health risks. |
| Insuficiencia renal crónica | Chronic Kidney Disease | Insuffisance rénale chronique | Long-term kidney damage affecting function. |
| Tabaquismo | Smoking | Tabagisme | Tobacco use, a risk factor for respiratory diseases. |
| Vacuna contra COVID19 | COVID-19 Vaccine | Vaccin contre la COVID-19 | Whether the patient received a COVID-19 vaccine. |
| Marca | Vaccine Brand | Marque du vaccin | The brand of the administered COVID-19 vaccine. |
| Ocupación | Occupation | Profession | The patient’s job or profession. |

# Data Preparation

After, understanding the meaning of each column, it is time to prepare it according to our interest.

## Handling Missing Values

- Converts all text "NA" values to proper R missing values (NA).

- Applies this transformation to all character columns.

## Numeric Conversion

- Specifically converts case numbers from character to numeric.

- Uses regex to verify valid numbers before conversion.

- Sets invalid entries to NA.

## Date Handling

- Handles Excel numeric date format (days since 1899-12-30).

- Converts numeric dates to proper Date format.

- Preserves existing properly formatted dates.

- Processes other date columns from mm/dd/yyyy format.

- Uses lubridate for consistent date handling.

## Categorical encoding

- Converts all character columns to factors.

- Creates a mapping table showing how factor levels were converted to numeric values **[here](Docs/LabelsForCategoricalVariables.md)**.

- Useful for understanding the encoding scheme later.

## Feature Groups

- Symptoms: 13 clinical symptoms like fever, cough, dyspnea.

- Comorbidities: 10 pre-existing conditions like diabetes, hypertension.

- Demographics: Age and sex.

## Data Filtering

- Removes records with pending lab results.

- Excludes rows where any symptom/comorbidity is marked "SE IGNORA" (unknown).

## Data Export

- Saves cleaned data in two formats:

- CSV for general use

- RDS (R's native format) preserving factor levels and data types

# Modeling

## Clustering Methods

### k-modes Clustering

- Uses kmodes() function from klaR package.

- Configured for 2 clusters (modes = 2).

- Uses Gower distance metric (daisy() with metric="gower") suitable for mixed data.

- Stores cluster assignments in new column kmodes_cluster.

### PAM Clustering

- Uses pam() function from cluster package.

- Also uses Gower distance.

- Includes age information in addition to symptoms.

- Stores cluster assignments in pam_cluster.

## Prediction methods

### Class Balancing

- Subsampling 5000 ETI cases (for computational efficiency).

- Keeping all IRAG cases.

- Shuffling the combined dataset.

### Feature Engineering

- Dummy Encoding: Converts categorical predictors to numeric.

- Zero-Variance Removal: Eliminates constant predictors.

- SMOTE: Applies synthetic minority oversampling to balance classes.

### Model Definitions

1. Random Forest (rand_forest()).

2. XGBoost (boost_tree()).

3. SVM with Polynomial Kernel (svm_poly()).

4. k-Nearest Neighbors (nearest_neighbor()).

5. Multilayer Perceptron (mlp())

### Cross-Validation Setup

Creates 5-fold cross-validation splits.

### Workflow Management

- Combines preprocessing recipe with each model

- Enables consistent preprocessing across models

# Evaluation

## Clustering

### Metrics

Silhouette Scores:

- Calculates silhouette scores for both methods.

- k-modes score indicates how well patients fit their assigned symptom clusters.

- PAM score evaluates clustering considering both symptoms and age.

- Higher scores (closer to 1) indicate better cluster separation.

### Visualization
t-SNE Plots:

- Uses Rtsne for dimensionality reduction.

- Creates 2D visualizations of high-dimensional clustering results.

- Color-codes points by cluster assignment.

- Generates separate plots for k-modes and PAM results.

Mode Matching Analysis:

- Calculates what percentage of patients exactly match their cluster's mode vector.

- Provides measure of how "pure" or well-defined the clusters are.

## Machine learning

### Performance Metrics

- ROC AUC.

- Accuracy.

- Precision.

- Recall.

- F1-score.

### Model Selection

- Identifies top-performing model (Random Forest in this case).

- Trains final model on full dataset.


# Deployment

- The trained model was saved for future predictions [best_rf_model](R/shiny/best_rf_model.rds) .  

- Shiny application ready for deployment [shiny](R/shiny).

# Summary

# Parallel Comparison: Clustering vs. Prediction

## Modeling

| Aspect              | Clustering Approach                          | Prediction Approach                          |
|---------------------|---------------------------------------------|---------------------------------------------|
| **Purpose**         | Identify patient subgroups                  | Classify respiratory diseases               |
| **Methods**         | • k-modes (categorical)<br>• PAM (mixed)    | • Random Forest<br>• XGBoost<br>• SVM<br>• KNN<br>• MLP |
| **Data Prep**       | • Filter "SE IGNORA"<br>• Select symptoms   | • SMOTE oversampling<br>• Dummy encoding<br>• Remove zero-variance |
| **Key Features**    | Symptom patterns + Age (PAM)                | Symptoms + Comorbidities + Demographics     |
| **Output**          | Cluster assignments                         | Classification probabilities                |

## Evaluation

| Aspect              | Clustering Approach                          | Prediction Approach                          |
|---------------------|---------------------------------------------|---------------------------------------------|
| **Metrics**         | • Silhouette score<br>• Cluster purity      | • ROC AUC<br>• Accuracy/Precision/Recall/F1 |
| **Visualization**   | t-SNE plots colored by cluster              | Metrics comparison plots                    |
| **Analysis Focus**  | Separation quality and clinical patterns    | Model performance and feature importance    |
| **Final Output**    | Patient subgroups with characteristic patterns | Trained classifier for new predictions     |

## Key Differences

| Characteristic      | Clustering                     | Prediction                     |
|---------------------|-------------------------------|-------------------------------|
| **Primary Goal**    | Discover patterns             | Assign classes                |
| **Data Needs**      | Unlabeled data                | Labeled training data         |
| **Validation**      | Internal metrics (silhouette) | Holdout testing               |
| **Output Type**     | Groups/labels                 | Probabilities                 |
| **Best Use Case**   | Exploratory analysis          | Diagnostic support            |



