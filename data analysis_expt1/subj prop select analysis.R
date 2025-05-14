#---------------------------------------------------------
# load libraries and data sets
library(tidyverse)
library(ggpubr)
library(ggridges)
source("../utils/performance-metrics.R")

data <- readRDS("data.RDS") 
# ---- data cleaning ----------------------------------------------

data <- data %>%
  mutate(cond = factor(cond, labels = c("GEE","CE"))) %>%
  # filter(cond == "CE") %>%
  mutate(block_set = case_when(
            block %in% 1:3 ~ 1,
            block %in% 4:6 ~ 2,
            block %in% 7:9 ~ 3),
         block_set = factor(block_set))

cat_levels = c("Andesite","Basalt","Diorite","Gabbro","Obsidian","Pegmatite","Peridotite","Pumice")

#---------------------------------------------------------
# proportions of diff cat selected defined on subj level
cat_prcorr <- data %>%
  filter(phase == "test") %>%
  group_by(version, cond, subj, cat) %>%
  summarize(Prcorr_mean = mean(corr)) %>%
  group_by(version, cond, subj) %>%
  mutate(
    Prcorr_jitter = Prcorr_mean + runif(n(), 0, 1e-8),  
    rank_cat = min_rank(Prcorr_jitter)  
  ) %>%
  select(version, cond, subj, cat, rank_cat)

prop_select_subj <- data %>%
  left_join(cat_prcorr, by = c("version", "cond", "subj", "cat")) %>%
  group_by(version, cond, subj) %>%
  summarize(
    n_rank_cat = n_distinct(rank_cat),
    n_trial_train = sum(phase == "train"),
    n_trial_train_diff = sum(phase == "train" & rank_cat <= 3),
    prop_select_diff = n_trial_train_diff / n_trial_train,
    PrCorr_final = mean(corr[phase == "test" & block_set == 3])
  )

prop_subj <- prop_select_subj %>%
  filter(cond == "CE") %>%
  group_by(version) %>%
  summarize(prop_subj_diff = sum(prop_select_diff > 0.375)/n())

with(filter(prop_select_subj, version == "before"),
            t.test(prop_select_diff[cond == "CE"], prop_select_diff[cond == "GEE"])
)

with(filter(prop_select_subj, cond == "CE"),
     t.test(prop_select_diff[version == "after"], prop_select_diff[version == "before"])
)

with(filter(prop_select_subj, version == "after", cond == "CE"),
     cor.test(prop_select_diff, PrCorr_final)
)

# compute the top 3 most difficult categories for each subject
# cat_prop_ideal <- data %>%
#                   filter(phase == "test", block %in% 1:8) %>%
#                   group_by(version, cond, subj, block) %>% 
#                   group_modify(~ {
#                     df_group <- .x
#                     cat_levels <- unique(df_group$cat)
#                     map_dfr(.x = cat_levels, 
#                             .f = ~ compute_OPScore(df_group, "cat", "resp", .x))
#                   }) %>%
#                   mutate(OPS_block = OPS, .keep = "unused") %>%
#                   group_by(cond,subj,stats_cat) %>%
#                   arrange(cond,subj,stats_cat,block) %>%
#                   mutate(OPS_cumsum = compute_exponential_cumsum(block, OPS_block, lambda = 0.5),
#                          rec_val = 1 - OPS_cumsum + 0.125) %>%
#                   group_by(version, cond,subj,block) %>%
#                   mutate(cat_prop_ideal = rec_val/sum(rec_val)) %>%
#                   select(block,stats_cat,H,FA,cat_prop_ideal) %>% 
#                   arrange(block) %>%
#                   mutate(cat_prop_desc = desc(cat_prop_ideal),
#                          FA_desc = desc(FA),
#                          cat_rank_tie = min_rank(pick(cat_prop_desc,H,FA_desc))
#                          ) %>%
#                   group_by(cat_rank_tie, .add = TRUE) %>%
#                   mutate(cat_rank = cat_rank_tie + sample(n()) - 1) %>%
#                   filter(cat_rank <= 3) %>%
#                   mutate(block_train = block + 1,.keep = "unused") %>%
#                   ungroup()

prop_select_diff_cat <- data %>%
                        filter(phase == "train", cond == "CE") %>%
                        group_by(version,cond,subj,cat) %>% 
                        mutate(PrCorr_cat = mean(corr)) %>%
                        group_by(version,cond,subj) %>%
                        summarize(diff_rank = dense_rank(PrCorr_cat),
                                  prop_select_diff = sum(diff_rank >= 7)/n(),
                                  PrCorr_final = mean(PrCorr_cat[block >= 7])) 
                        

#---------------------------------------------------------
#inspect correlation between cat selection pattern and test performance
accu_df <- data %>%
  filter(phase == "test", block %in% 2:9) %>%
  group_by(version, cond, subj, block_set) %>%
  summarize(Prcorr = mean(corr))
cat_select_prop <- cat_prop_top3 %>%
  arrange(version, cond, subj, block_set) %>%
  group_by(version, cond, subj, block_set) %>%
  summarize(prop_cats_blockset = mean(prop_cats)) %>%
  inner_join(accu_df, by = c("version","cond","subj", "block_set")) %>%
  group_by(version, cond, subj) %>%
  mutate(block_set = block_set,
         prop_cats_cum = cummean(prop_cats_blockset),
         prop_cats_cum_blockset3 = prop_cats_cum[block_set == 3],
         .keep = "unused") %>%
  group_by(version, cond)  %>% 
  mutate(prop_cats_group = if_else(prop_cats_cum_blockset3 < median(prop_cats_cum_blockset3),
                                   "lower","upper"),
         .keep = "unused")

save(cat_select_prop, file = "cat_select_prop_CE.Rdata")

p <- cat_select_prop %>%
     filter(block_set == 3, version == "before") %>%
     ggplot(aes(x = prop_cats_cum, y = Prcorr)) +
            geom_point() +
            geom_smooth(method = "lm", se = FALSE) + 
            theme_pubr(base_size = 20) +
            scale_x_continuous(limits = c(0.2,0.8), breaks = seq(0.2,0.8,0.1)) +
            scale_y_continuous(limits = c(0.2,1), breaks = seq(0.2,1,0.1)) +
            xlab("Cumulative Proportions of difficult Categories Selected") +
            ylab("Percent Correct")
ggsave(filename = "figure/prop_cat_select_vs_test_accu_before.png", p, width = 8, height = 8)

# check correlation coefficients
output = numeric()
for (version_val in c("before","after")){
  for (cond_val in c("CE")){
    for (block_set_val in 3){
      temp <- with(filter(cat_select_prop, cond == cond_val, block_set == block_set_val, version == version_val),
                   cor(prop_cats_cum, Prcorr))
      output <- c(output, paste(version_val, cond_val, block_set_val, temp))
    }
  }
}
print(output)

  