setwd("/scratch/prj/ukirtc_rtd/ML-AI/D/2023-ca4021-bradyd-35-mcdaida-3")

#install.packages('reticulate')
library("reticulate")
library(dplyr)
#py_install("pandas")
# On Windows 10 I was asked to install conda (package manager), which I did.

#py_install("pickle") # Not sure this line is needed - pickle may be built-in

source_python("r/read_pickle.py")
df_pheno <- read_pickle_file("data/interim/pheno_r.pkl")

head(df_pheno)

# Features are determined using EDA from notebook '01_EDA.ipynb'
features <- c(
  'RecAge', 'DonAge', 'RecSex', 'DonSex', 'RecPC1', 
  'RecHypertensionPRS', 'DonHypertensionPRS', 
  'DoneGFRPRS', 'DonStrokePRS', 'RecHAKVPRS', 
  'HLAMismatches', 'ColdIschemiaTime', 'GraftNo', 
  'PrimaryRenalDisease', 'IntracranialHaemorrhage'
  )

head(select(df_pheno, features))

# install.packages('mice')
library(mice)

# install.packages('rpart')
library(rpart)

library(stats)

# install.packages('nortest')
library('nortest')

# Impute the missing data using the mice package with CART method
imp <- mice(select(df_pheno, features), method = "cart")

# Extract the imputed data for the HLAMismatches variable
imp <- complete(imp)

# Test the distribution of the original and imputed data using the Kolmogorov-Smirnov test
ks.test(df_pheno$HLAMismatches, imp$HLAMismatches)
ks.test(df_pheno$ColdIschemiaTime, imp$ColdIschemiaTime)

# Test the normality of the original and imputed data using the Shapiro-Wilk test
# All significant differences and therefore not normal
shapiro.test(df_pheno$HLAMismatches)
shapiro.test(imp$HLAMismatches)
shapiro.test(df_pheno$ColdIschemiaTime)
shapiro.test(imp$ColdIschemiaTime)

# Test the goodness of fit of the original and imputed data to the normal distribution using the Anderson-Darling test
# All significant differences and therefore not normal
ad.test(df_pheno$HLAMismatches)
ad.test(imp$HLAMismatches)
ad.test(df_pheno$ColdIschemiaTime)
ad.test(imp$ColdIschemiaTime)

table(df_pheno$PrimaryRenalDisease)
table(imp$PrimaryRenalDisease)

# Run a chi-squared test to check for differences between the imputed values and the observed values
# The p-value is statistically significant, it appears that PrimaryRenalDisease is a very challenging variable to predict
# Perhaps, it is best to extract the top 10 values and set them as binary variables
chisq.test(imp$PrimaryRenalDisease, df_pheno$PrimaryRenalDisease)

# create a column indicating the source of each value
df_pheno$source <- "original"
imp$source <- "imputed"

cols <- c("HLAMismatches", "PrimaryRenalDisease", "ColdIschemiaTime", "source")

# combine the dataframes using rbind
df_combined <- rbind(select(df_pheno, cols), select(imp, cols))

head(df_combined)

library(ggplot2)

# create a bar plot of HLAMismatches, split by the source variable
ggplot(df_combined, aes(x=as.factor(HLAMismatches), fill=source)) + 
  geom_bar(position="dodge") +
  scale_fill_manual(values=c("blue", "red"), name="Source") +
  labs(title="HLAMismatches", x="Number of Mismatches", y="Frequency") +
  scale_x_discrete(limits=factor(seq(0,6)))

ggsave("reports/figures/imp/HLAMismatches.png", plot=last_plot(), width=6, height=4, dpi=300)

# create a density plot of ColdIschemiaTime, split by the source variable
ggplot(df_combined, aes(x=ColdIschemiaTime, fill=source)) + 
  geom_density(alpha=0.5) +
  scale_fill_manual(values=c("blue", "red"), name="Source") +
  labs(title="ColdIschemiaTime", x="Cold Ischemia Time (minutes)", y="Density") +
  xlim(0, max(df_combined$ColdIschemiaTime))

ggsave("reports/figures/imp/ColdIschemiaTime.png", plot=last_plot(), width=6, height=4, dpi=300)

ggplot(df_combined, aes(x=PrimaryRenalDisease, fill=source)) +
  geom_bar(position="dodge", alpha=0.8) +
  scale_fill_manual(values=c("blue", "red"), name="Source") +
  labs(title="Primary Renal Disease", x="Primary Renal Disease", y="Count") +
  theme(axis.text.x = element_text(angle = 0, hjust = 1, vjust=0.5))

ggsave("reports/figures/imp/PrimaryRenalDisease.png", plot=last_plot(), width=6, height=4, dpi=300)

df_pheno[cols[1:3]] <- imp[cols[1:3]]

save_pickle_file(df_pheno, file='data/proc/pheno_imp.pkl')
