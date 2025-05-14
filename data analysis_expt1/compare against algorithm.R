library(tidyverse)
library(ggpubr)
source("../utils/performance-metrics.R")

# ---- Load the Data ----
epsilon <- 1e-6
df <- readRDS("data.RDS") %>%
      filter(version == "after") %>%
      select(cond, subj, block, phase, cat, resp, corr) %>%
      mutate(
          subj = factor(subj),
          cond = recode_factor(cond,
                              "random" = "GEE" , "student_chosen" = "CE"),
          block_set = case_match(block, 1:3 ~ 1,4:6 ~ 2,7:9 ~ 3)
      ) %>%
      filter(!(cond == "CE" & subj %in% c(81,118))) 


# ---- algorithm-based trial counts per category ----
expect_cat_count_train <- df %>%
  filter(phase == "test", block %in% 1:8) %>%
  group_by(cond,subj,block) %>% 
  nest() %>%
  mutate(stats = map(data, ~ {
    df <- .x  
    map_df(unique(df$cat), function(cat_value) {
      compute_dprime(df, "cat", "resp", cat_value)
    })
  })) %>%
  unnest(stats) %>%
  group_by(cond, subj, stats_cat) %>%
  arrange(cond, subj, stats_cat, block) %>%
  mutate(dprime_cumsum = compute_exponential_cumsum(block, dprime, lambda = 0.5),
         rec_val = 1 - dprime_cumsum + 0.125) %>%
  group_by(cond, subj, block) %>%
  mutate(stats_cat = stats_cat,
         rec_norm = rec_val/sum(rec_val),
         count_expect = rec_norm*16) %>%
  select(block,stats_cat,count_expect) %>% 
  ungroup() %>%
  mutate(block_train = block + 1,.keep = "unused") %>%
  arrange(cond, subj, block_train, stats_cat)

count_cat_compare <- df %>%
  filter(phase == "train", block %in% 2:9) %>%
  group_by(cond, subj, block, cat) %>% 
  summarize(count = n()) %>%
  right_join(expect_cat_count_train,
             join_by(cond, subj, cat == stats_cat, block == block_train)) %>%
  mutate(count = if_else(is.na(count),0,count))

algorithm_match_score_by_subj <- count_cat_compare %>%
  mutate(count_diff = abs(count - count_expect)) %>%
  group_by(cond, subj, block) %>%
  summarize(block_score = sum(count_diff)) %>%
  group_by(cond, subj) %>%
  summarize(mismatch_score = mean(block_score)) %>%
  group_by(cond) %>%
  mutate(algorithm_match_flag = if_else(mismatch_score <= median(mismatch_score),"low","high")) %>%
  ungroup()
  
df_plot_finalAccu_mismatch <- df %>%
  filter(block_set == 3) %>%
  group_by(cond, subj) %>%
  summarize(Pr_corr_final = mean(corr)) %>%
  left_join(algorithm_match_score_by_subj,by = c("cond","subj"))

p <- ggplot(df_plot_finalAccu_mismatch, mapping = aes(x = mismatch_score, y = Pr_corr_final, color = cond)) +
     geom_point()
                      


