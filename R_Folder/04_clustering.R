library(dplyr)
library(factoextra)
library(cluster)
library(reshape2)
library(ggplot2)

load("C:/Users/emman/OneDrive/Desktop/Sithara_Work/AD_ATN/final_atn.RData")

df_clust <- final %>%
  select(HHID_PN, NfL, GFAP, AB42_40_ratio, pTau181_recode) %>%
  na.omit()

df_clust <- as.data.frame(df_clust)
rownames(df_clust) <- df_clust$HHID_PN

df_clust_scaled <- scale(df_clust[, -1])

fviz_nbclust(df_clust_scaled, kmeans, method = "wss")

pca <- prcomp(df_clust_scaled)
print(summary(pca))

set.seed(123)
km <- kmeans(df_clust_scaled, centers = 5, nstart = 25)

fviz_cluster(km, data = df_clust_scaled)

df_clust$Cluster <- factor(km$cluster)

final <- final %>%
  left_join(df_clust[, c("HHID_PN", "Cluster")], by = "HHID_PN")

cluster_profiles <- aggregate(df_clust[, -c(1,6)],
                              by = list(Cluster = df_clust$Cluster), FUN = mean)

centroids_melt <- melt(cluster_profiles, id.vars = "Cluster")

ggplot(centroids_melt, aes(x = variable, y = value, fill = Cluster)) +
  geom_bar(stat = "identity", position = "dodge") +
  theme_minimal()

save(final, df_clust_scaled, km, cluster_profiles,
     file = "C:/Users/emman/OneDrive/Desktop/Sithara_Work/AD_ATN/final_clustered.RData")
