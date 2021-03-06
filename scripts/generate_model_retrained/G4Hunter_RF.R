# Train an RF model based on G4Hunter scores (G4Hunter RF) on active G4 dataset
# Made by Vincent ROCHER (05/10/20)
library(ranger)
library(tidyverse)
#Load dataset (already splited)
# Data generated by scripts/data_generation/quadron_features_for_quadron_retrained.R
G4Hunter.train <- readRDS("rds/G4Hunter_scores_Peaks_BG4_G4seq_HaCaT_GSE76688_hg19_201b_Ctrl_gkmSVM_0.8_42_Sequence_train.rds")
G4Hunter.train <- G4Hunter.train %>% dplyr::select(-seq) %>% mutate(Y = as.factor(Y)) %>% as.data.frame()
colnames(G4Hunter.train) <- c(paste("G4HunterScore",colnames(G4Hunter.train)[-12],sep="_"),"Y")
# set seed for reproductibility 
set.seed(1337)

## Grow a forest 
RangerBG4 <- ranger( formula= Y~., data= G4Hunter.train,
                     importance = "permutation",probability = T)
saveRDS(RangerBG4,"rds/G4Hunter_retrained_ranger_Peaks_BG4_G4seq_HaCaT_GSE76688_hg19_201b_Ctrl_gkmSVM_0.8_42_Sequence_train.rds")
# make prediction and get AUC
library(pROC)
G4Hunter.test <- readRDS("rds/G4Hunter_scores_Peaks_BG4_G4seq_HaCaT_GSE76688_hg19_201b_Ctrl_gkmSVM_0.8_42_Sequence_test.rds")
G4Hunter.test <- G4Hunter.test %>% dplyr::select(-seq) %>% mutate(Y = as.factor(Y))%>% as.data.frame()
colnames(G4Hunter.test) <- c(paste("G4HunterScore",colnames(G4Hunter.test)[-12],sep="_"),"Y")
Test.Pred <- predict(RangerBG4, G4Hunter.test)
rocRFall <- roc(as.factor( G4Hunter.test$Y),Test.Pred$predictions[,2],ci=T)
aucRF <- pROC::auc(rocRFall)

