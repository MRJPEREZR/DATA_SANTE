# DATA SANTE FINAL PROJECT
Final Project "Data Santé" Course.

# Table of contents
- [Introduction](#introduction)
- [Business undestanding](#business-undestanding)
- [Data understanding](#data-understanding)
- [Data Preparation](#data-preparation)
- [Modeling](#modeling)
- [Evaluation](#evaluation)
- [Deployment](#deployment)

# Introduction

Data science project following the CRISP methodology.

# Business undestanding

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

Describe our whole work cleaning and transforming variables to prepare our dataset to train models.

## Transforming NA char values to real NA missing values

## Fixing date values to variables of interesting.

## Creating new varibles of interesting

| Column                                          | Data type original -> transformed   |
|-------------------------------------------------|-------------------------------------|
| Días entre inicio de síntomas y toma de muestra | num                                 |
| Días entre inicio de síntomas y defunción       | num                                 |

## Categorical values mapping

Each column was transformed as factor. So, [here](Docs/LabelsForCategoricalVariables.md), you can see the mapping between each label factor and its respective number id.

# Modeling

# Evaluation

# Deployment
