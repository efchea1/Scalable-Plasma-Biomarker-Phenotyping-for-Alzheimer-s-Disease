# Scalable Plasma Biomarker Phenotyping for Alzheimer’s Disease

# Overview
This repository implements a scalable, reproducible framework for plasma biomarker phenotyping in the **Health and Retirement Study (HRS) 2016 Venous Blood Study**. It compares theory‑driven ATN classification with data‑driven phenotypes (k‑means, PCA, VAE) and evaluates cognitive and demographic correlates in a population‑representative cohort. The goal is to advance early detection and heterogeneity modeling in Alzheimer’s disease.

## Key Features
- ATN classification with literature-based cutoffs
- Unsupervised clustering with stability diagnostics (NbClust, bootstrapped Jaccard)
- Variational Autoencoder latent phenotyping
- Survey‑weighted population inference (HRS complex design)
- Full reproducibility with modular R scripts
- Comprehensive sensitivity analyses (cutoffs, k-selection, VAE architecture)

**The workflow integrates:**
* **Theory‑driven classification** using the ATN (Amyloid / Tau / Neurodegeneration) framework
* **Data‑driven unsupervised clustering** with optimal‑K selection
* **Deep learning dimensionality reduction** using a Variational Autoencoder (VAE)
* **Nonlinear visualization** (UMAP, t‑SNE)
* **Cluster stability** via bootstrapped Jaccard indices
* **Survey‑weighted analyses** using HRS sampling weights
* **Sensitivity analyses** across K, ATN cutoffs, and VAE architectures
* **Explainability** using SHAP values for VAE latent dimensions
* **Methodological comparison** across ATN, clustering, PCA, and VAE

The pipeline is designed for **scientific transparency**, **scalability**, and **reviewer‑friendly reproducibility**.

# Repository Structure

| **Folder & File** | **Description** |
|---------------|-------------|
| **AnalysisReport** | Full R Markdown pipeline (`analysis_report.Rmd`) documenting the entire workflow |
| **Archive** | Full R pipelines (`Alzheimer’s Biomarker + ATN + VAE + Omics Pipeline.R`) |
| **R_Folder** | Modular R scripts for each analysis stage (preprocessing, ATN, clustering, VAE, etc.) |
| **Figures** | All exported plots (ROC curves, clustering diagnostics, VAE visualizations, UMAP/t‑SNE, etc.) |
| **Results** | Saved models, latent spaces, training histories, and serialized analysis objects |
| **Tables** | CSV outputs for all statistical tables and summaries |
| **Data** | *(Empty)* - users must obtain HRS data through the official portal; raw HRS data are not included |
| **utils.R** | Shared helper functions used across scripts |
| **README.md** | Project documentation (this file) |

# Running the Pipeline
**Set working directory**
setwd("path/to/repository")

**Load utilities**
source("utils.R")

**Run individual modules**
source("R_Folder/01_data_preparation.R")
source("R_Folder/02_atn_classification.R")
source("R_Folder/03_roc_analysis.R")
source("R_Folder/04_clustering.R")
source("R_Folder/05_vae_training.R")
source("R_Folder/06_method_comparison.R")

**Expected Runtime:**
- Data preparation: 5 minutes
- ATN + ROC analysis: 10 minutes
- Clustering (with NbClust): 15 minutes
- VAE training (50 epochs): 20 minutes
- Sensitivity analyses: 30 minutes
- **Total: ~1.5-2 hours** (Intel i7, 16GB RAM)

## 📊 Analysis Pipeline
### 1. Data Preparation & Quality Control
**Input:** Raw HRS SAS files
**Output:** Clean merged dataset with QC summaries
* Merge biomarker, tracking, and cognition files using HHID_PN
* Derive composite cognition score (0–27)
* Classify cognitive status: Normal / CIND / Dementia
* Generate CONSORT‑style flowchart
* Missingness analysis across biomarkers & demographics

**Key Outputs**
- `tables/sample_flowchart.csv`
- `tables/missing_data_summary.csv`

### 2. ATN Framework Classification

**Method:** Literature-based plasma biomarker cutoffs

**Cutoffs Applied:**
| Biomarker | Threshold | Reference |
|-----------|-----------|-----------|
| Aβ42/40 ratio | < 0.067 | Nakamura et al. 2018 JAMA Neurol (PMID: 29613453) |
| pTau181 | > 2.2 pg/mL | Karikari et al. 2020 Nat Med (PMID: 32123386) |
| NfL | > 20 pg/mL | Mattsson-Carlgren et al. 2021 JAMA Neurol (PMID: 33433581) |

**Output:**
- 8 ATN profiles (A±/T±/N±)
- Distribution tables
- Demographics by ATN group (Table 1)

**Key Files:**
- `tables/atn_cutoff_references.csv`
- `tables/atn_distribution.csv`
- `tables/table1_demographics_by_atn.csv`

### 3. Biomarker Performance (ROC Analysis)

**Models:** Logistic regression adjusted for age, sex, race, education

**Outcome:** Dementia vs. Normal (excluding CIND)

**Validation:**
- Training set: 70% (internal fitting)
- Test set: 30% (held-out evaluation)
- 95% confidence intervals (DeLong method)

**Output:**
- Individual ROC curves with optimal operating points
- AUC comparison table
- Test set performance metrics

**Key Files:**
- `figures/roc_*.png` (4 biomarkers)
- `tables/roc_comparison.csv`
- `tables/test_set_performance.csv`

### 4. Unsupervised Clustering

**Algorithm:** K-means with Lloyd's algorithm

**Optimal K Selection:**
1. **Elbow method** (within-cluster sum of squares)
2. **Silhouette analysis** (cluster cohesion/separation)
3. **NbClust consensus** (30+ validation indices)

**Validation:**
- Silhouette width
- Bootstrap stability (Jaccard index)
- Dunn index & connectivity
- Cluster centroids heatmap
- Biomarker distributions by cluster

**Cluster Characterization:**
- Demographics, biomarker profiles, cognitive status
- ATN profile composition by cluster
- Post-hoc pairwise comparisons (Wilcoxon + BH correction)

**Key Files:**
- `figures/elbow_plot.png`
- `figures/nbclust_recommendation.png`
- `figures/cluster_plot_pca.png`
- `tables/table2_cluster_profiles.csv`
- `tables/clustering_stability.csv`

### 5. ATN-Cluster Alignment

**Metrics:**
- **Adjusted Rand Index (ARI):** Agreement adjusted for chance
- **Normalized Mutual Information (NMI):** Shared information content
- **Chi-square test:** Independence test with simulated p-values

**Visualization:**
- Contingency heatmap
- Stacked bar charts (ATN composition by cluster)

**Key Files:**
- `tables/atn_cluster_alignment.csv`
- `figures/atn_cluster_heatmap.png`

### 6. Variational Autoencoder (VAE)

**Architecture:**

Input (4D) → Dense(64) → Latent(2D) → Dense(64) → Output(4D)
              ↓
         z_mean, z_log_var → Sampling → Decoder

**Loss Function:**

Total Loss = Reconstruction Loss (MSE) + KL Divergence

**Training**
- 50 epochs
- Early stopping (patience = 10)
- Reduce‑LR‑on‑plateau
- Batch size = 32

**Explainability**
- **SHAP values** for latent dimensions
(Python via reticulate; optional)

**Validation**
- Reconstruction loss
- KL divergence
- Latent space silhouette
- Correlation with biomarkers
- PCA vs VAE comparison

**Files**
- `results/encoder_model.h5`
- `results/decoder_model.h5`
- `results/latent_representations.RData`
- `figures/vae_training_curves.png`
- `figures/pca_vs_vae_comparison.png`
- `figures/vae_latent_correlations.png`

### 7. Nonlinear Visualization (UMAP + t‑SNE)
**Purpose:** Reveal nonlinear structure in biomarker space

**Methods:**
- UMAP (default parameters)
- t‑SNE (perplexity = 30)

**Files**
- `figures/umap_clusters.png`
- `figures/tsne_clusters.png`

### 8. Sensitivity Analyses

**Tests Conducted:**
* Silhouette across K = 2–8
* Alternative ATN cutoffs (quartiles)
* VAE latent dimensions = 2, 3, 4, 5
* Missingness vs demographics
* Cluster robustness under resampling

**Key Files:**
- `tables/sensitivity_k_values.csv`
- `figures/sensitivity_k_values.png`
- `tables/sensitivity_vae_architectures.csv`

### 9. Survey‑Weighted Analyses (HRS PVBSWGTR)

**Design:**  
`svydesign(ids = SECU, strata = STRATUM, weights = PVBSWGTR)`

**Outputs**
* Weighted mean age by ATN
* Weighted cognition by ATN

**Files**
- `tables/weighted_age_by_atn.csv`
- `tables/weighted_cognition_by_atn.csv`

### 10. Comprehensive Method Comparison

**Methods Compared**
1. ATN Framework
2. K‑means Clustering
3. VAE Latent Space
4. PCA

**Criteria**
* Number of groups
* Silhouette
* Variance explained
* Cognitive association
* Interpretability
* Advantages & limitations

**Files**
- `tables/method_comparison_comprehensive.csv`

## 📝 Publications & Citations

**Preprint:** [Link pending]  
**Published:** [Journal name, DOI pending]

## Future Work
- External validation in ADNI, AIBL, and NACC
- Equity and transportability analyses across demographic subgroups
- Survey‑weighted clustering and latent modeling
- Integration with transcriptomics or proteomics datasets
- Longitudinal modeling of cognitive decline using HRS follow-up waves

## How to Cite
If you use this code or framework in your research, please cite this repository:

Chea, E.F. (2024). Scalable Plasma Biomarker Phenotyping for Alzheimer's Disease: 
Integrative ATN Framework, Unsupervised Clustering, and Deep Learning Approaches. 
GitHub repository: [Scalable Plasma Biomarker Phenotyping for Alzheimer's Disease: Integrative ATN Framework, Unsupervised Clustering, and Deep Learning Approaches](https://github.com/efchea1/Scalable-Plasma-Biomarker-Phenotyping-for-Alzheimer-s-Disease)

### Transcriptomics integration (scaffolded)
* The repository includes commented code demonstrating how **DESeq2** could be used to integrate transcriptomic data with ATN or VAE latent structure.
* This section is **not executed** in the current analysis.

### Running the Analysis
**Full Pipeline**
**Open in RStudio**
file.edit("AnalysisReport/analysis_report.Rmd")

# Knit document (Ctrl+Shift+K) or:
rmarkdown::render("AnalysisReport/analysis_report.Rmd")

### 1. Required R Packages

install.packages(c(
  "dplyr","tidyr","haven","readr","ggplot2","corrplot","pheatmap",
  "GGally","factoextra","ggdendro","gridExtra","reshape2","pROC",
  "nnet","cluster","mclust","NbClust","aricode","naniar","fpc",
  "umap","Rtsne","survey"
))

# Deep learning
install.packages(c("keras","tensorflow"))

# Bioconductor
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("DESeq2")

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("DESeq2")
