library(pROC)

run_roc <- function(data, biomarker, outcome = "Dementia_IMP_2016",
                    case = "Dementia", control = "Normal") {
  
  vars <- c(outcome, biomarker, "PAGE", "GENDER", "RACE", "SCHLYRS")
  df <- data[, vars] %>% na.omit()
  df <- df[df[[outcome]] %in% c(case, control), ]
  df[[outcome]] <- factor(df[[outcome]], levels = c(control, case))
  
  formula <- as.formula(paste(outcome, "~", biomarker, "+ PAGE + GENDER + RACE + SCHLYRS"))
  fit <- glm(formula, data = df, family = "binomial")
  
  pi_hat <- predict(fit, type = "response")
  roc_obj <- roc(response = df[[outcome]], predictor = pi_hat,
                 levels = c(control, case), direction = "<")
  
  cat("\n=============================\n")
  cat("ROC for:", biomarker, "\n")
  cat("=============================\n")
  cat("AUC:", auc(roc_obj), "\n")
  
  best <- coords(roc_obj, "best", ret = c("threshold", "sensitivity", "specificity"))
  print(best)
  
  plot(roc_obj, main = paste("ROC Curve -", biomarker))
  
  return(list(model = fit, roc = roc_obj, auc = auc(roc_obj), best = best))
}
