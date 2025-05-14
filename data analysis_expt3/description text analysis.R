library(tidyverse)
library(gridExtra)
library(boot)
library(ggpubr)
library(quanteda)
library(quanteda.textstats)
library(topicmodels)
source("../utils/performance-metrics.R")

# # ---- Load the Data ----
data_orig <- readRDS("data_original.RDS")

# # ---- select variables of interest ----
subj_accu <- data_orig %>%
  filter(phase == "test", trialType == "class_response", cycle == 4) %>%
  mutate(cond = factor(condition, labels = c("GEE","GEA", "GCP","CCP")),
         condition = NULL,
         corr = as.logical(corr)) %>%
  filter(cond %in% c("GCP","CCP")) %>%
  select(cond, subjID, cycle, corr) %>%
  group_by(cond, subjID) %>%
  summarize(Prcorr_test = mean(corr)) %>%
  ungroup() %>%
  mutate(Prcorr_bool = if_else(Prcorr_test < median(Prcorr_test),"low","high"),
         Prcorr_bool = factor(Prcorr_bool, levels = c("low","high")))
  
text_description <- data_orig %>%
  filter(trialType == "paired_cat_display") %>%
  mutate(cond = factor(condition, labels = c("GCP","CCP")),
         condition = NULL) %>%
  select(cond, subjID, cycle, trial, starts_with("text")) %>%
  left_join(subj_accu, by = c("subjID")) %>%
  group_by(Prcorr_bool) %>%
  summarize(across(.cols = starts_with("text"),
                   .fn = ~ paste(.x[!is.na(.x) & .x != ""], collapse = ". "),
                   .names = "{.col}"),
            Nsubj = n_distinct(subjID)) %>%
  pivot_longer(cols = starts_with("text"), names_to = "cat", values_to = "text", 
               names_prefix = "text_") %>%
  rowid_to_column("doc_id")

#---------------------------------------------------------
cat_names <- with(data_orig, 
                  sort(unique(cat[cat != ""])))
num_cats <- length(cat_names)

corpus <- corpus(text_description$text, docnames = text_description$doc_id)
lemma_data <- read.delim("https://raw.githubusercontent.com/gesiscss/ptm/refs/heads/master/resources/baseform_en.tsv", 
                         header = FALSE, col.names = c("inflected_form", "lemma"), 
                         sep = "\t", encoding = "UTF-8") %>%
              filter(!is.na(inflected_form))
stopwords <- readLines("https://slcladal.github.io/resources/stopwords_en.txt", encoding = "UTF-8") %>%
  c("rock","stone","type","shape","color", "texture", "pattern", "appearance", 
    "remember", "pretty", "tend", "feature", "generally", cat_names)

set.seed(47404)
corpus_tokens <- corpus %>% 
  tokens(remove_punct = TRUE, remove_numbers = TRUE, remove_symbols = TRUE) %>% 
  tokens_tolower() %>% 
  tokens_replace(lemma_data$inflected_form, lemma_data$lemma, valuetype = "fixed") %>%
  tokens_remove(pattern = stopwords, padding = T)

corpus_collocations <- textstat_collocations(corpus_tokens, min_count = 10) %>% filter(z >= 6)
corpus_tokens <- tokens_compound(corpus_tokens, corpus_collocations)

DTM <- corpus_tokens %>% 
  tokens_remove("") %>%
  dfm() 

# topic modeling
K = 13 
topicModel <- LDA(DTM, K, method="Gibbs", control=list(iter = 5000, verbose = 25))




