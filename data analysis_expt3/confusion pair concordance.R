library(tidyverse)
library(gridExtra)
library(ggpubr)
library(effsize)

source("../utils/performance-metrics.R")

# # ---- Load the Data ----
data_orig <- readRDS("data_original.RDS")

# # ---- select variables of interest ----
data <- data_orig %>%
  filter(trialType %in% c("class_response", "cat_selection", "paired_cat_display")) %>%
  select(subjID, condition, stimID, cycle, phase, trialType, trial, cat, resp, token, corr, 
         rt, ref_cat_num, paired_cat_num, starts_with("text"), time_obs, time_resp) %>%
  mutate(cond = factor(condition, labels = c("GEE","GEA","GCP","CCP")),
         condition = NULL,
         stimID = as.integer(stimID),
         phase = factor(phase,levels = c("train","test")),
         cat = as.factor(cat),
         resp = as.factor(resp),
         corr = as.logical(corr),
         rt = as.numeric(rt)
  ) 

cat_levels = c("Andesite","Basalt", "Diorite", "Gabbro", 
               "Obsidian", "Pegmatite", "Peridotite", "Pumice")

cat_pairs_full <- expand_grid(cat1 = cat_levels,cat2 = cat_levels) %>%
  filter(cat1 != cat2) %>%
  rowwise() %>%
  mutate(cat_pair = paste(sort(c(cat1, cat2)), collapse = "_")) %>%
  distinct(cat_pair) 

cat_pairs_selected_temp <- data %>%
  filter(cond %in% c("GCP", "CCP"), trialType == "cat_selection") %>%
  select(cond, subjID, cycle, trial, ref_cat_num, paired_cat_num) %>%
  mutate(ref_cat = factor(ref_cat_num,labels = cat_levels),
         paired_cat = factor(paired_cat_num,labels = cat_levels),
         ref_cat_num = NULL,
         paired_cat_num = NULL) %>%
  rowwise() %>%
  mutate(cat_pair = paste(sort(c(ref_cat, paired_cat)), collapse = "_")) %>%
  group_by(cond, subjID, cat_pair) %>%
  summarize(count = n()) 

# frequency of cat pair selections by subject
cat_pairs_selected <- expand_grid(cat_pair = cat_pairs_full$cat_pair, subjID = unique(cat_pairs_selected_temp$subjID)) %>%
  left_join(cat_pairs_selected_temp) %>%
  replace_na(list(count = 0)) %>%
  group_by(subjID) %>%
  mutate(cond = replace_na(cond, unique(na.omit(cond)))) %>%
  arrange(cond, subjID, desc(count)) %>%
  ungroup()

# average number of distinct pairs across subjects by condition
num_distinct_pair_across_subj <- cat_pairs_selected %>%
  group_by(cond, subjID) %>%
  summarize(n_pair = sum(count > 0))

with(num_distinct_pair_across_subj, t.test(n_pair[cond == "CCP"],n_pair[cond == "GCP"], var.equal = T))
with(num_distinct_pair_across_subj, cohen.d(n_pair ~ fct_drop(cond)))


# total number of selections for possible cat pairs across subjects in each condition
count_cat_pair_across_subj <- cat_pairs_selected %>%
  group_by(cond, cat_pair) %>%
  summarize(count = sum(count)) 

# average number of cat pairs selected across subjects by cond
num_cat_pair_by_cond <- cat_pairs_selected %>%
  group_by(cond, cat_pair) %>%
  summarize(mean_count = mean(count)) 
  

#Proportions of participants who observed the unordered cat pairs by cond
num_cat_pair_rep <- num_cat_pair_by_cond %>%
  pivot_wider(names_from = cond, values_from = mean_count, names_glue = "{.value}_{cond}") %>%
  ungroup() %>%
  arrange(desc(mean_count_GCP)) %>%
  slice_head(n = 8) %>%
  pivot_longer(starts_with("mean_count"), names_to = "cond", values_to = "mean_count", names_prefix = "mean_count_") %>%
  mutate(cat_pair = ordered(cat_pair, levels = rev(unique(cat_pair))
         ))

cond_labels <- c("GCP" = "Paired Category Adaptive", "CCP" = "Paired Category Active")
p <- ggplot(data = num_cat_pair_rep,
            mapping = aes(x = cat_pair, y = mean_count, fill = cond)) +
     geom_col(color = "black", 
              width = 0.8, position = "dodge") +
     coord_flip() +
     xlab("") +
     ylab("Mean Frequency of Presentation\nfor Selected Category Pairs") +
     scale_y_continuous(expand = c(0,0), breaks = seq(0,1.6,0.2)) +
     scale_x_discrete() +
     scale_fill_discrete(name = "Condition", labels = cond_labels) +
     theme_pubr(base_size = 30, legend = "bottom") 
ggsave(filename = "figure/Propsubj_cat_pair.png", p, width = 16, height = 8)



#concordance test
library(ConcordanceTest)
concordance_test_df <- cat_pairs_selected %>%
  pivot_wider(names_from = subjID, values_from = count) %>%
  nest_by(cond) %>%
  mutate(data = list({
    data <- data %>% 
      arrange(cat_pair) %>% 
      select(-cat_pair) %>% 
      select(where(~ !all(is.na(.)))) 
    # data.matrix(data)
    as.list(data)
    })
  ) 

with(concordance_test_df, CT_Hypothesis_Test(data[[which(cond == "GCP")]][10:80]))

  
