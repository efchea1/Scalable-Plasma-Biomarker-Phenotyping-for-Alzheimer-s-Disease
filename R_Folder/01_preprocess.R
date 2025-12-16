# ---- Libraries ----
library(dplyr)
library(tidyr)
library(haven)
library(readr)

set.seed(123)

# ---- Load HRS Biomarker + Cognition Data ----
trk2020 <- read_sas("trk2020tr_r.sas7bdat")
neurobiomarker <- read_sas("neurobiomarker_sithara.sas7bdat")
cogimp <- read_sas("cogimp9220a_r.sas7bdat")

# ---- Preprocess ----
trk2020_sub <- trk2020 %>%
  select(HHID, PN, GENDER, HISPANIC, RACE, PAGE, PVBSWGTR, SECU, STRATUM, SCHLYRS) %>%
  distinct() %>%
  mutate(HHID_PN = paste0(HHID, "_", PN))

neurobiomarker <- neurobiomarker %>%
  mutate(HHID_PN = paste0(HHID, "_", PN))

cogimp_sub <- cogimp %>%
  mutate(HHID_PN = paste0(HHID, "_", PN)) %>%
  select(HHID_PN, R13IMRC, R13DLRC, R13SER7, R13BWC20) %>%
  na.omit() %>%
  mutate(
    Dementia_Score_Imputed_2016 = R13IMRC + R13DLRC + R13SER7 + R13BWC20,
    Dementia_IMP_2016 = case_when(
      Dementia_Score_Imputed_2016 <= 6 ~ "Dementia",
      Dementia_Score_Imputed_2016 <= 11 ~ "CIND",
      TRUE ~ "Normal"
    )
  )

# ---- Merge All Data ----
final <- neurobiomarker %>%
  inner_join(trk2020_sub, by = "HHID_PN") %>%
  inner_join(cogimp_sub, by = "HHID_PN")

save(final, file = "data/final_preprocessed.RData")
