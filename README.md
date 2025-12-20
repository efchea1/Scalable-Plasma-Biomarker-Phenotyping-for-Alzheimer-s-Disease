# Scalable Plasma Biomarker Phenotyping for Alzheimer's Disease: Integrative ATN Framework, Unsupervised Clustering, and Deep Learning Approaches

# Overview

This repository provides a **comprehensive, reproducible analysis pipeline** for characterizing Alzheimer's disease (AD) heterogeneity using plasma biomarkers from the **Health and Retirement Study (HRS) 2016 Venous Blood Study**. The workflow integrates:

* **Theory-driven classification** using the ATN (Amyloid/Tau/Neurodegeneration) framework
* **Data-driven unsupervised clustering** (k-means with optimal k selection)
* **Deep learning dimensionality reduction** (Variational Autoencoder)
* **Comprehensive validation** (ROC analysis, bootstrap stability, sensitivity analyses)
* **Methodological comparison** of classification approaches

---

## Repository structure

- **AnalysisReport**  
  Contains the main R Markdown analysis (`analysis_report.Rmd`) and rendered outputs (e.g., `html`), documenting the full pipeline from data preprocessing to VAE-based latent representation.

- **Archive**  
  Legacy for the full R scripts for reference.

- **Data**  
  Placeholder for input data (HRS biomarker, cognition, and related files).  
  **Note:** Raw HRS data are restricted and are **not** stored in this repository. Users must obtain appropriate access and place data files here following the expected filenames and structure described below.

- **Figures**  
  Exported plots, including:
  - ROC curves for individual biomarkers  
  - Clustering diagnostics (elbow plot, cluster assignments, cluster centroids)  
  - VAE latent space by ATN endotype  
  - VAE training curves (loss, reconstruction loss, KL divergence, learning rate)

- **Models**  
  Saved Keras/TensorFlow model objects, such as:
  - `encoder_model.h5`  
  - `decoder_model.h5`

- **R_Folder**  
  Modular R scripts implementing each analysis stage (e.g., preprocessing, ATN derivation, ROC modeling, clustering, and VAE).

- **Results**  
  Serialized results objects used by the analysis and for downstream interpretation, including:
  - Cluster assignments and summaries  
  - VAE latent coordinates (`vae_latent.RData`)  
  - Training histories (`vae_training_history.RData`)

- **utils.R**  
  Helper functions used across scripts (e.g., utility plotting, shared preprocessing routines).

---

## Analysis overview

The pipeline proceeds in the following stages (see `AnalysisReport/analysis_report.Rmd` and scripts in `R_Folder/`):

1. **Data loading and preprocessing**
   - Import HRS biomarker (`neurobiomarker`), tracking (`trk2020`), and cognition (`cogimp`) data.
   - Construct participant IDs (`HHID_PN`) and merge datasets into a unified `final` data frame.
   - Derive cognitive status (`Normal`, `CIND`, `Dementia`) based on imputed scores.

2. **Biomarker transformation and ATN endotyping**
   - Log-transform key plasma biomarkers:
     - NfL, GFAP, AB42_40_ratio, pTau181_recode.
   - Define A/T/N endotypes using median-based thresholds and construct composite `ATN` labels (e.g., `A-/T-/N-`, `A+/T+/N+`).

3. **Biomarker performance via ROC analysis**
   - Fit covariate-adjusted logistic regression models predicting dementia status.
   - Generate ROC curves and compute:
     - AUC
     - Sensitivity/specificity at optimal thresholds
   - Export ROC plots for each biomarker to `Figures/`.

4. **Unsupervised clustering of biomarker profiles**
   - Scale plasma biomarker values and perform:
     - Elbow method for optimal K
     - K-means clustering (e.g., K = 5)
   - Merge cluster assignments back into `final`.
   - Examine cluster–ATN and cluster–dementia cross-tabs.
   - Visualize:
     - Cluster scatter plot
     - Cluster centroids (mean biomarker levels) in `Figures/`.

5. **Variational autoencoder (VAE) modeling**
   - Train a VAE on scaled biomarker profiles using a custom training loop:
     - Reconstruction loss (squared error)
     - KL divergence for latent regularization
   - Track and save:
     - Total loss, reconstruction loss, KL loss, learning rate across epochs.
   - Extract and save 2D latent coordinates (`z1`, `z2`) and link them to ATN endotypes.
   - Visualize:
     - Latent space colored by ATN (biologically interpretable embedding).
     - Training curves for transparency and stability assessment.

6. **Transcriptomics integration (scaffolded)**
   - The repository includes commented code illustrating how transcriptomic data could be integrated using DESeq2 to relate ATN/latent structure to gene expression.
   - This section is intentionally scaffolded and not executed for this project.

---

## How to run the analysis

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
