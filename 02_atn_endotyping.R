library(dplyr)

load("data/final_preprocessed.RData")

# ---- Log-transform Biomarkers ----
final <- final %>%
  mutate(
    log_NfL = log(NfL),
    log_GFAP = log(GFAP),
    log_AB42_40_ratio = log(AB42_40_ratio),
    log_pTau181_recode = log(pTau181_recode)
  )

# ---- A/T/N Endotypes ----
A_cut <- median(final$log_AB42_40_ratio, na.rm = TRUE)
T_cut <- median(final$log_pTau181_recode, na.rm = TRUE)
N_cut <- median(final$log_NfL, na.rm = TRUE)

final <- final %>%
  mutate(
    A = ifelse(log_AB42_40_ratio < A_cut, "A+", "A-"),
    T = ifelse(log_pTau181_recode > T_cut, "T+", "T-"),
    N = ifelse(log_NfL > N_cut, "N+", "N-"),
    ATN = paste(A, T, N, sep = "/")
  )

print(table(final$ATN))

save(final, file = "C:/Users/emman/OneDrive/Desktop/Sithara_Work/AD_ATN/final_atn.RData")
