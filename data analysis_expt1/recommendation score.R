library(tidyverse)
library(openxlsx)

# ---- Load the Data ----
setwd("../data")
files = dir(pattern = "revised.txt") #change it for unrevised versions
data = do.call(bind_rows, lapply(files, read.table, fill = T))
data[is.na(data)] <- -1
nrows = sapply(files, function(f) nrow(read.table(f, fill = T)))
setwd("../data analysis")

# ---- define the data types ----
colnames(data) = c("cond","subj","block","phase","trial","cat","token","resp","corr","rt_decision","rt_selection")
data$cond = factor(data$cond,labels = c("random","student_chosen"))
data$subj = as.integer(data$subj)
data$block = as.integer(data$block) 
data$phase = factor(data$phase,labels = c("train","test")) 
data$trial = as.integer(data$trial)
data$cat = factor(data$cat,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
data$resp = factor(data$resp,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice")) 
data$corr = as.integer(data$corr) 

#remove outlier
data = filter(data,!(cond == "student_chosen" & subj %in% c(81,118))) 

#---------------------------------------------------------
# select percentile subjects to be analyzed
subj_accu_df <-  data %>%
                 filter(phase == "test", cond == "student_chosen", block %in% c(7,8,9)) %>%
                 group_by(subj) %>%
                 summarize(Pr_corr_sub = mean(corr == 1)) %>%
                 ungroup() 

percentiles <- quantile(subj_accu_df$Pr_corr_sub, probs = c(0.1, 0.3, 0.5, 0.7, 0.9), type = 3)

subj_selected <- subj_accu_df %>%
                 filter(Pr_corr_sub %in% percentiles) %>%
                 group_by(Pr_corr_sub) %>%
                 slice_sample(n = 1) %>%
                 ungroup() %>%
                 rename(subj_accu = Pr_corr_sub) %>%
                 arrange(subj_accu)
                 
                 
#-------------------------------------------------------------
# compute hit rate and false alarm rates for each category in each block of each subject
apply_exp_weights <- function(block, raw_scores) {
  
  n <- length(block)
  weighted_scores <- numeric(n)
  
  for (i in seq_len(n)) {
    block_weights <- exp(-(block[i] - block[1:i]))
    weighted_scores[i] <- sum(raw_scores[1:i] * block_weights)/sum(block_weights)
  }
  
  return(weighted_scores)
}



perf_stats_by_subj_block_cat <- data %>%
                                filter(phase == "test", cond == "student_chosen", subj %in% subj_selected$subj) %>%
                                group_by(subj,block) %>%
                                reframe(
                                        category = as.factor(levels(cat)),
                                        H = sapply(levels(cat), function(c) sum(cat == c & resp == c) / sum(cat == c)),
                                        FA = sapply(levels(cat), function(c) sum(cat != c & resp == c) / sum(cat != c))
                                       )%>%
                                group_by(subj,category) %>%
                                mutate( 
                                        H_weighted = apply_exp_weights(block,H),
                                        FA_weighted = apply_exp_weights(block,FA)
                                      ) %>%
                                select(-c(H,FA)) %>%
                                left_join(subj_selected,by = "subj") %>%
                                arrange(desc(subj_accu),block,category) %>%
                                ungroup()



perf_stats_wide_format <- perf_stats_by_subj_block_cat %>%
                          group_by(subj_accu,subj) %>%
                          pivot_wider(names_from = block,
                                      names_prefix = "block",
                                      names_sep = ":",
                                      values_from = c(H_weighted,FA_weighted)) %>%
                          ungroup()

# Separate H_weighted and FA_weighted columns
H_cols <- select(perf_stats_wide_format, subj, subj_accu, category, contains("H_weighted"))
FA_cols <- select(perf_stats_wide_format, contains("FA_weighted")) 

# Create a data frame with three empty columns
empty_cols <- data.frame(matrix(NA, nrow=nrow(perf_stats_wide_format), ncol=3))

# Bind the columns together
perf_stats_modified <- bind_cols(H_cols, empty_cols, FA_cols)

# Create a template empty row with the same number of columns
empty_row <- as_tibble(setNames(replicate(ncol(perf_stats_modified), NA, simplify = FALSE), names(perf_stats_modified)))

# Function to insert three empty rows between each group of different subjects
insert_empty_rows <- function(df) {
  df %>%
    group_by(subj_accu,subj) %>%
    summarize(dummy = 1, .groups = 'keep') %>%
    ungroup() %>%
    mutate(empty_rows = list(rep(list(empty_row), 3))) %>%
    select(-dummy) %>%
    unnest(c(empty_rows)) %>%
    bind_rows(df, .) %>%
    arrange(desc(subj_accu)) %>%
    select(-c(subj_accu,empty_rows))
}

# Insert three empty rows between each group of different subjects
perf_stats_final <- insert_empty_rows(perf_stats_modified)

write.xlsx(perf_stats_final, file = "recommendation_score_new.xlsx")
                                
                                
  




  


