## Code is obtained from Diarmuids r script 'clustering.R'
## Including saving the data with the cluster number included
## Using this to run regression models on the data split into each cluster.

setwd("/scratch/prj/ukirtc_rtd/ML-AI/D/2023-ca4021-bradyd-35-mcdaida-3")

#install.packages('reticulate')
library("reticulate")
library(dplyr)
#py_install("pandas")
# On Windows 10 I was asked to install conda (package manager), which I did.

#py_install("pickle") # Not sure this line is needed - pickle may be built-in

source_python("r/read_pickle.py")
df_pheno <- read_pickle_file("data/proc/pheno_eng.pkl")



# Removing all post-transplant and redundant variables
df_pheno <- select(
  df_pheno, 
  -c(# Post transplant variables
    GraftSurvivalDays, GraftCensored, eGFR1Year, eGFR5Year,
    # Redundant Variables
    RecId, DonId, HasDiabetes, OnDialysis, HLAMismatches, ColdIschemiaTime,
    RecSex_num, DonSex_num, PrimaryRenalDisease_num, GraftType_num, 
    DonAge_sqrd, RecAge_sqrd, AgeDifference_sqrd, HLAMismatches_sqrd, 
    HLAMismatches_bin, DonPC1, DonPC2, RecPC2, DonPC3, RecPC3,
    DoneGFRDeltaPRS, ReceGFRDeltaPRS, DonPKDPRS, RecPKDPRS, 
    DonAlbuminuriaPRS, RecAlbuminuriaPRS, DonIAPRS, RecIAPRS, 
    DonKVPRS, RecKVPRS, RecStrokePRS, ReceGFRPRS, DonHAKVPRS,
    SexMismatch, Month, Day, Season, Season_num, GraftDate
  )
)

df_pheno_num <- select(
  df_pheno, 
  c(
    RecAge, DonAge, RecPC1, RecHypertensionPRS, DonHypertensionPRS, 
    DoneGFRPRS, DonStrokePRS, RecHAKVPRS, AgeDifference, Year, DonAge_X_RecAge
  )
)
df_pheno_cat <- select(
  df_pheno,
  c(
    RecSex, DonSex, GraftNo, PrimaryRenalDisease, GraftType, DonType
  )
)

# View the subset of data
head(df_pheno_num)
head(df_pheno_cat)

# View the dimension of each, this is a check before running kamila
dim(df_pheno_num)
dim(df_pheno_cat)

# Check for NAs in df_pheno_num
colSums(is.na(df_pheno_num))
any(is.na(df_pheno_num)) # False

# Check for NAs in df_pheno_cat
colSums(is.na(df_pheno_cat))
any(is.na(df_pheno_cat)) # False

# Checking dimnames
colnames(df_pheno_num)
colnames(df_pheno_cat)

# Adding empty columns to match dataframe sizes
num_cols_to_add <- 4  # Number of empty columns to add
df_pheno_cat <- cbind(df_pheno_cat, matrix(nrow = nrow(df_pheno_cat), ncol = num_cols_to_add))


# View the dimension of each, this is a check before running kamila
dim(df_pheno_num)
dim(df_pheno_cat)

head(df_pheno_num)
head(df_pheno_cat)


# import mclust
#install.packages('mclust')
library(mclust)

help(Mclust)

# Fit the model with the best BIC score
# VEI 2
# 
model <- Mclust(df_pheno, modelNames='VEE')

# Print the model output
summary(model) # Produces poor results

# Fit Mclust models with different covariance structures and numbers of components
models <- list()
models[[1]] <- Mclust(df_pheno, G=1:5, modelNames="EEE")
models[[2]] <- Mclust(df_pheno, G=1:5, modelNames="VVV")
models[[3]] <- Mclust(df_pheno, G=1:5, modelNames="VVI")
models[[4]] <- Mclust(df_pheno, G=1:5, modelNames="VII")

# Print summary of BIC and ICL for each model
for (num in c(1,2,3,4)) {
  print(summary(models[[num]]))
}

# install ggplot2
install.packages("ggplot2")
library(ggplot2)
library(mclust)

# Fit Mclust VII model with 5 components to df_pheno
model <- Mclust(df_pheno, G = 5, modelNames = "VII")

# Get cluster labels
labels <- model$classification

# Add cluster labels to df_pheno
df_pheno$cluster <- as.factor(labels)

# Plot clusters
ggplot(df_pheno, aes(x = DonAge, y = RecAge, color = cluster)) +
  geom_point() +
  labs(title = "Mclust VII (spherical, varying volume) model with 5 components") +
  theme_bw()

source_python("r/read_pickle.py")
save_pickle_file(df_pheno, file='../../A/2023-ca4021-bradyd-35-mcdaida-3/data/proc/pheno_clust.pkl')
##saveRDS(df_pheno, file='../../A/2023-ca4021-bradyd-35-mcdaida-3/data/proc/pheno_clust.pkl')
