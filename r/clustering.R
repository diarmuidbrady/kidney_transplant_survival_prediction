setwd("/scratch/prj/ukirtc_rtd/ML-AI/D/2023-ca4021-bradyd-35-mcdaida-3")

#install.packages('reticulate')
library("reticulate")
library(dplyr)
#py_install("pandas")
# On Windows 10 I was asked to install conda (package manager), which I did.

#py_install("pickle") # Not sure this line is needed - pickle may be built-in

source_python("r/read_pickle.py")
df_pheno <- read_pickle_file("data/proc/pheno_eng.pkl")

<<<<<<< HEAD
df_pheno
=======
colnames(df_pheno)

df_pheno_clust <- subset(df_pheno, select=-c(index, eGFR1Year, eGFR5Year, GraftSurvivalDays))

# import mclust
#install.packages('mclust')
library(mclust)

models = c()

for (i in 2:10) {
  models[[i]] <- Mclust(df_pheno_clust, G=i)
  print(summary(models[[i]]))
  print(models[[i]]$BIC)
}

library(ggplot2)

# Create a data frame of BIC values for each number of clusters
bic_df <- data.frame(num_clusters = 2:10, bic = sapply(models[2:10], function(x) x$bic))

# Create a ggplot object and add a scatterplot of BIC values
ggplot(bic_df, aes(x = num_clusters, y = bic)) +
  geom_point() +
  labs(x = "Number of clusters", y = "BIC value") +
  ggtitle("BIC values for different numbers of clusters")

# Create a data frame of BIC values for each number of clusters
df_log <- data.frame(NumClusters = 2:10, LogLikelihood = sapply(models[2:10], function(x) x$loglik))
>>>>>>> mclust

# Create a ggplot object and add a scatterplot of BIC values
ggplot(df_log, aes(x = NumClusters, y = LogLikelihood)) +
  geom_point() +
  labs(x = "Number of clusters", y = "Log Likelihood") +
  ggtitle("Log Likelihood for different numbers of clusters")


best <- models[[3]]


df_pheno$MClustClusters <- as.factor(best$classification)

#####################################################################

<<<<<<< HEAD
# install ggplot2
#install.packages("ggplot2")
library(ggplot2)
library(mclust)
=======
# TSNE
>>>>>>> mclust

#####################################################################

#install.packages("Rtsne")
library(Rtsne)

# Split the data into training and validation sets
set.seed(123)
train_indices <- sample(nrow(df_pheno), size = 0.8 * nrow(df_pheno))
train_data <- df_pheno[train_indices, -ncol(df_pheno)]
valid_data <- df_pheno[-train_indices, -ncol(df_pheno)]

# Define a range of perplexity values to try
perplexity_range <- seq(5,100,5)

# Initialize a list to store the KL divergences for each perplexity value
kl_divs <- vector("list", length(perplexity_range))

# Compute the KL divergence for each perplexity value on the validation set
for (i in seq_along(perplexity_range)) {
  cur_perplexity <- perplexity_range[i]
  print(cur_perplexity)
  tsne_embedding <- Rtsne(train_data, dims = 2, perplexity = cur_perplexity, verbose = TRUE)
  high_dim_dist <- colSums(as.matrix(dist(train_data, method = "euclidean"))^2)
  low_dim_dist <- colSums(as.matrix(dist(tsne_embedding$Y))^2)
  kl_divs[[i]] <- sum((high_dim_dist / sum(high_dim_dist)) * log((high_dim_dist / sum(high_dim_dist)) / (low_dim_dist / sum(low_dim_dist))))
}

# Choose the perplexity value with the lowest KL divergence
best_perplexity <- perplexity_range[which.min(kl_divs)]

<<<<<<< HEAD
#install.packages("Rtsne")
library(Rtsne)

# Split the data into training and validation sets
set.seed(123)
train_indices <- sample(nrow(df_pheno), size = 0.8 * nrow(df_pheno))
train_data <- df_pheno[train_indices, -ncol(df_pheno)]
valid_data <- df_pheno[-train_indices, -ncol(df_pheno)]

# Define a range of perplexity values to try
perplexity_range <- seq(5,100,5)

# Initialize a list to store the KL divergences for each perplexity value
kl_divs <- vector("list", length(perplexity_range))

# Compute the KL divergence for each perplexity value on the validation set
for (i in seq_along(perplexity_range)) {
  cur_perplexity <- perplexity_range[i]
  print(cur_perplexity)
  tsne_embedding <- Rtsne(train_data, dims = 2, perplexity = cur_perplexity, verbose = TRUE)
  high_dim_dist <- colSums(as.matrix(dist(train_data, method = "euclidean"))^2)
  low_dim_dist <- colSums(as.matrix(dist(tsne_embedding$Y))^2)
  kl_divs[[i]] <- sum((high_dim_dist / sum(high_dim_dist)) * log((high_dim_dist / sum(high_dim_dist)) / (low_dim_dist / sum(low_dim_dist))))
}

# Choose the perplexity value with the lowest KL divergence
best_perplexity <- perplexity_range[which.min(kl_divs)]

=======
>>>>>>> mclust
# Compute the final t-SNE embedding with the best perplexity value on the full dataset
final_embedding <- Rtsne(df_pheno[, -ncol(df_pheno)], dims = 2, perplexity = 100, verbose = TRUE)

# Add cluster labels to t-SNE embedding
tsne_df <- data.frame(final_embedding$Y, cluster = as.factor(labels))

head(tsne_df)

# Plot t-SNE embedding with cluster labels
ggplot(tsne_df, aes(x = X1, y = X2, color = cluster)) +
  geom_point() +
  labs(title = "t-SNE embedding with cluster labels") +
  theme_bw()

#########################################################

# KAMILA

#########################################################

colnames(df_pheno)
# Load KAMILA and dplyr
#install.packages('kamila')
#install.packages('dplyr')
library(kamila)
library(dplyr)


<<<<<<< HEAD
df_pheno_num <- select(
  df_pheno, 
  c(
    RecAge, DonAge, RecPC1, RecHypertensionPRS, DonHypertensionPRS, 
    DoneGFRPRS, DonStrokePRS, RecHAKVPRS, Year, ColdIschemiaTime, GraftNo
  )
)
df_pheno_cat <- select(
  df_pheno,
  c(
    RecSex, DonSex, SexMismatch, 
    IntracranialHaemorrhage
  )
)

# Adding empty columns to match dataframe sizes
num_cols_to_add <- 7  # Number of empty columns to add
df_pheno_cat <- cbind(df_pheno_cat, matrix(nrow = nrow(df_pheno_cat), ncol = num_cols_to_add))


# View the dimension of each, this is a check before running kamila
dim(df_pheno_num)
dim(df_pheno_cat)

head(df_pheno_num)
head(df_pheno_cat)

str(df_pheno_num)
=======
df_pheno_num <- df_pheno %>%
  select(RecAge, DonAge, RecPC1, RecHypertensionPRS, DonHypertensionPRS, 
    DoneGFRPRS, DonStrokePRS, RecHAKVPRS, Year, ColdIschemiaTime, GraftNo) %>%
  mutate(across(everything(), as.numeric))

df_pheno_cat <- df_pheno %>%
  select(RecSex, DonSex, SexMismatch, IntracranialHaemorrhage) %>%
  mutate(across(everything(), as.factor))

df_pheno_con <- df_pheno %>%
  select(RecAge, DonAge, RecPC1, RecHypertensionPRS) %>%
  mutate(across(everything(), as.numeric))

# View the dimension of each, this is a check before running kamila
dim(df_pheno_con)
dim(df_pheno_cat)

head(df_pheno_con)
head(df_pheno_cat)

str(df_pheno_con)
>>>>>>> mclust
str(df_pheno_cat)

# Perform KAMILA clustering
set.seed(123) # Set seed for reproducibility
<<<<<<< HEAD
kamila_model <- kamila(conVar=df_pheno_num, catFactor=df_pheno_cat, numClust=3) # Set number of clusters to 3
=======

kamila_model <- kamila(conVar=df_pheno_con, catFactor=df_pheno_cat, 
                       numClust=2:10, numInit=10,
                       calcNumClust = "ps", numPredStrCvRun = 10, predStrThresh = 0.5
                       ) # Running Cross Validation 10 times for 2 to 10 clusters


>>>>>>> mclust
#help(kamila)
print(kamila_model)



# View cluster assignments
cluster_assignments <- kamila_model$clusters

df_pheno$KamilaClusters <- as.factor(kamila_model$finalMemb)

df_pheno <- subset(df_pheno, select=-c(index))

colnames(df_pheno)

#####################################################################

# Exporting 

#####################################################################

save_pickle_file(df_pheno, "data/proc/pheno_cluster.pkl")

