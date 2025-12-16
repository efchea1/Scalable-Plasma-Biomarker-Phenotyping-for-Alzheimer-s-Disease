library(dplyr)
source("C:/Users/emman/OneDrive/Desktop/Sithara_Work/AD_ATN/utils.R")

load("C:/Users/emman/OneDrive/Desktop/Sithara_Work/AD_ATN/final_atn.RData")

biomarkers <- c("log_NfL", "log_GFAP", "log_AB42_40_ratio", "log_pTau181_recode")

roc_results <- lapply(biomarkers, function(b) run_roc(final, b))
names(roc_results) <- biomarkers

save(roc_results, file = "C:/Users/emman/OneDrive/Desktop/Sithara_Work/AD_ATN/roc_results.RData")
