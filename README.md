# Scalable Plasma Biomarker Phenotyping for Alzheimer’s Disease
**Integrative ATN Framework * Unsupervised Clustering * Deep Learning (VAE) * Stability & Sensitivity Analyses**

# Overview

This repository provides a **comprehensive, reproducible analysis pipeline** for characterizing Alzheimer's disease (AD) heterogeneity using plasma biomarkers from the **Health and Retirement Study (HRS) 2016 Venous Blood Study**. The workflow integrates:

* **Theory-driven classification** using the ATN (Amyloid/Tau/Neurodegeneration) framework
* **Data-driven unsupervised clustering** (k-means with optimal k selection)
* **Deep learning dimensionality reduction** (Variational Autoencoder)
* **Comprehensive validation** (ROC analysis, bootstrap stability, sensitivity analyses)
* **Methodological comparison** of classification approaches

# Set working directory
setwd("path/to/repository")

# Load utilities
source("utils.R")

# Run individual modules
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
**Output:** Merged analytical dataset with QC metrics

- Merge tracking, biomarker, and cognitive data by `HHID_PN`
- Derive composite cognitive scores (0-27 scale)
- Classify cognitive status: Normal (>11), CIND (7-11), Dementia (≤6)
- Generate CONSORT flowchart documenting exclusions
- Assess missingness patterns

**Key Files:**
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
- Mean silhouette width
- Bootstrap stability (50 iterations, 80% subsampling)
- Dunn index, connectivity metrics

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

**Training:**
- 50 epochs with early stopping (patience=10)
- Learning rate reduction on plateau
- Batch size: 32

**Validation:**
- Reconstruction quality
- Latent space cluster separation (silhouette)
- Correlation with original biomarkers
- Comparison to PCA (variance explained)

**Key Files:**
- `results/encoder_model.h5`
- `results/decoder_model.h5`
- `results/vae_latent.RData`
- `figures/vae_latent_space.png`
- `figures/vae_training_curves.png`
- `figures/pca_vs_vae_comparison.png`

### 7. Sensitivity Analyses

**Tests Conducted:**
1. **Alternative ATN cutoffs:** Quartile-based thresholds
2. **VAE architectures:** Latent dimensions (2, 3, 4, 5)
3. **Clustering solutions:** k±1 comparison
4. **Missing data patterns:** Relationship with demographics/outcomes

**Key Files:**
- `tables/sensitivity_analyses_summary.csv`
- `tables/sensitivity_atn_cutoffs_crosstab.csv`

### 8. Comprehensive Method Comparison

**Compared Approaches:**
1. ATN Framework (theory-driven)
2. K-means Clustering (data-driven, unsupervised)
3. VAE Latent Space (data-driven, deep learning)
4. PCA (data-driven, linear)

**Evaluation Criteria:**
- Number of groups/dimensions
- Cluster quality (silhouette)
- Variance explained
- Cognitive association
- Interpretability
- Advantages/limitations

**Key Files:**
- `tables/method_comparison_comprehensive.csv`
- `tables/method_agreement_matrix.csv`

## 📈 Key Results Summary

**Sample Characteristics:**
- N = [Your N] participants from HRS 2016 VBS
- Complete biomarker data: [N with 4 biomarkers]
- Age: Mean ± SD
- Female: [%]

**Primary Findings:**
1. **ATN-Cluster Agreement:** ARI = [value], NMI = [value]
   - Interpretation: [Moderate/Low] alignment
2. **Best Predictive Biomarker:** [NfL/GFAP/etc.] (AUC = [value])
3. **Optimal Clusters:** k = [4-5] with silhouette = [value]
4. **Clustering Stability:** Mean bootstrap ARI = [value]
5. **VAE vs PCA:** VAE [outperforms/underperforms] in cluster separation

**Statistical Significance:**
- All p-values corrected for multiple comparisons (Benjamini-Hochberg)
- Biomarkers differ significantly across clusters (all p < 0.05)
- Cognition associated with both ATN (p = [value]) and clusters (p = [value])

## 📝 Publications & Citations

**Preprint:** [Link pending]  
**Published:** [Journal name, DOI pending]

**If you use this code, please cite:**

Chea, E.F. (2024). Scalable Plasma Biomarker Phenotyping for Alzheimer's Disease: 
Integrative ATN Framework, Unsupervised Clustering, and Deep Learning Approaches. 
GitHub repository: [Scalable Plasma Biomarker Phenotyping for Alzheimer's Disease: Integrative ATN Framework, Unsupervised Clustering, and Deep Learning Approaches](https://github.com/efchea1/Scalable-Plasma-Biomarker-Phenotyping-for-Alzheimer-s-Disease)

### Transcriptomics integration (scaffolded)
   - The repository includes commented code illustrating how transcriptomic data could be integrated using DESeq2 to relate ATN/latent structure to gene expression.
   - This section is intentionally scaffolded and not executed for this project.

### Running the Analysis
**Full Pipeline**
**Open in RStudio**
file.edit("AnalysisReport/analysis_report.Rmd")

# Knit document (Ctrl+Shift+K) or:
rmarkdown::render("AnalysisReport/analysis_report.Rmd")

### 1. Required R Packages

# Core data manipulation
install.packages(c("dplyr", "tidyr", "haven", "readr"))

# Visualization
install.packages(c("ggplot2", "corrplot", "pheatmap", "GGally", 
                   "factoextra", "ggdendro", "gridExtra", "reshape2"))

# Statistical analysis
install.packages(c("pROC", "nnet", "cluster", "mclust", 
                   "NbClust", "aricode", "naniar"))

# Deep learning
install.packages(c("keras", "tensorflow"))

# Bioconductor (for potential omics integration)
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")
BiocManager::install("DESeq2")

```r
if (!requireNamespace("BiocManager", quietly = TRUE))
  install.packages("BiocManager")
BiocManager::install("DESeq2")
