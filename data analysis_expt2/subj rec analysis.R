#---------------------------------------------------------
# load libraries and data sets
library(tidyverse)
library(ggpubr)
library(ggridges)
library(effsize)
library(RColorBrewer)
source("../utils/performance-metrics.R")

data <- readRDS("prolific data.RDS") 
# ---- data cleaning ----------------------------------------------

data <- data %>%
  filter(cond %in% c("CE", "CEA", "GEA")) %>%
  mutate(block_set = case_when(
            block %in% 1:3 ~ 1,
            block %in% 4:6 ~ 2,
            block %in% 7:9 ~ 3),
         block_set = factor(block_set))

cat_levels = c("Andesite","Basalt","Diorite","Gabbro","Obsidian","Pegmatite","Peridotite","Pumice")

#---------------------------------------------------------
# compute the cross entropy between ideal and observed category selection
cat_prop_ideal <- data %>%
                  filter(phase == "test", block %in% 1:8) %>%
                  group_by(cond, subj, block) %>% 
                  group_modify(~ {
                    df_group <- .x
                    cat_levels <- unique(df_group$cat)
                    map_dfr(.x = cat_levels, 
                            .f = ~ compute_OPScore(df_group, "cat", "resp", .x))
                  }) %>%
                  mutate(OPS_block = OPS, .keep = "unused") %>%
                  group_by(cond,subj,stats_cat) %>%
                  arrange(cond,subj,stats_cat,block) %>%
                  mutate(OPS_cumsum = compute_exponential_cumsum(block, OPS_block, lambda = 0.5),
                         rec_val = 1 - OPS_cumsum + 0.125) %>%
                  group_by(cond,subj,block) %>%
                  mutate(cat_prop_ideal = rec_val/sum(rec_val)) %>%
                  select(block,stats_cat,H,FA,cat_prop_ideal) %>% 
                  arrange(block) %>%
                  mutate(cat_prop_desc = desc(cat_prop_ideal),
                         FA_desc = desc(FA),
                         cat_rank_tie = min_rank(pick(cat_prop_desc,H,FA_desc))
                         ) %>%
                  group_by(cat_rank_tie, .add = TRUE) %>%
                  mutate(cat_rank = cat_rank_tie + sample(n()) - 1) %>%
                  filter(cat_rank <= 3) %>%
                  mutate(block_train = block + 1,.keep = "unused") %>%
                  ungroup()

cat_prop_observed <- data %>%
                     filter(phase == "train", block %in% 2:9) %>%
                     # group_by(cond,subj,block_set,block,cat) %>% 
                     group_by(cond,subj,block,cat) %>% 
                     summarize(count_per_cat = n()) %>%
                     # group_by(cond,subj,block_set,block) %>%
                     group_by(cond,subj,block) %>%
                     mutate(cat_prop_obs = count_per_cat/sum(count_per_cat)) %>%
                     ungroup()

cat_prop_top3 <- right_join(cat_prop_observed, cat_prop_ideal,
                            join_by(cond,subj,cat == stats_cat,block == block_train)) %>%
                 replace_na(list(cat_prop_obs = 0)) %>%
                 mutate(block_set = case_when(
                                        block %in% 1:3 ~ 1,
                                        block %in% 4:6 ~ 2,
                                        block %in% 7:9 ~ 3),
                        block_set = factor(block_set)
                        ) %>%
                 group_by(cond,subj,block_set,block) %>%
                 summarize(prop_cats_obs = sum(cat_prop_obs),
                           prop_cats_ideal = sum(cat_prop_ideal)) %>%
                 ungroup()
#---------------------------------------------------------
#visualize distribution of proprotions of recommendations followed
cat_rec_prop_top3_CEA <- data %>%
  filter(phase == "train", block %in% 2:9, cond  == "CEA") %>%
  group_by(subj,block,cat_rec) %>%
  summarize(resp_rec_match = sum(cat == cat_rec),
            rec_count = n(),
            resp_rec_prop_cat = resp_rec_match/rec_count) %>%
  right_join(filter(cat_prop_ideal, cond == "CEA"),
             join_by(subj,cat_rec == stats_cat,block == block_train)) %>%
  replace_na(list(cat_prop_obs = 0)) %>%
  group_by(subj) %>%
  summarize(prop_resp_rec = mean(resp_rec_prop_cat)) %>%
  ungroup() 

p <- ggplot(data = cat_rec_prop_top3_CEA,
            mapping = aes(x = prop_resp_rec)) +
  geom_histogram(binwidth = 0.05, fill = "white", color = "black") +
  geom_text(stat = "bin", binwidth = 0.05,
            aes(label = after_stat(count), y = after_stat(count) + 1), size = 6) +
  scale_x_continuous(breaks = seq(0, 1, 0.05)) +
  xlab("Proportion of Recommendations followed\nin Selecting Worse Performing Categories") +
  ylab("Number of Participants") +
  theme_pubr(base_size = 30) +
  theme(axis.text.x = element_text(size = 20, angle = 315, vjust = -.5))

ggsave(filename = "figure/prop_rec_followed.png", p, width = 15, height = 8)

#---------------------------------------------------------
#check proportions of cat selections in the worse performing categories
# between condition
accu_df <- data %>%
  filter(phase == "test", block %in% 1:3) %>% 
  group_by(cond, subj) %>%
  summarize(Prcorr = mean(corr))

cat_select_prop <- cat_prop_top3 %>%
  arrange(cond, subj) %>%
  inner_join(accu_df, by = c("cond","subj")) %>%
  group_by(cond, subj) %>%
  summarize(prop_cats_obs = mean(prop_cats_obs),
            prop_cats_ideal = mean(prop_cats_ideal)) %>%
  inner_join(accu_df, by = c("cond", "subj")) %>%
  ungroup()


save(cat_select_prop, file = "cat_select_prop.Rdata")
load("cat_select_prop.Rdata")

# block_set_labels <- c(`1` = "blocks 1-3", `2` = "blocks 4-6", `3` = "blocks 7-9")
cond_labels <- c("CE" = "Choose\nExample", "CEA" = "Choose\nExample Adaptive")
color_palette <- colorRampPalette(c("black","lightgray"))(length(unique(cat_select_prop$subj)))
cat_select_prop_wide <- cat_select_prop %>%
  filter(cond %in% c("CE", "CEA")) %>%
  mutate(subj_offset = rep(runif(243,-.3,.3)))
cat_select_prop_data <- cat_select_prop_wide %>%
  rename(Observed = prop_cats_obs,
         Recommended = prop_cats_ideal) %>%
  pivot_longer(cols = c(Observed, Recommended), 
               names_to = "data_type", values_to = "prop_cats") %>%
  arrange(subj, data_type) 
cat_select_prop_stats <- cat_select_prop %>%
  filter(cond %in% c("CE", "CEA")) %>%
  group_by(cond) %>%
  summarize(prop_cats_obs_mean = mean(prop_cats_obs),
            prop_cats_obs_SEM = sd(prop_cats_obs)/sqrt(n()))
p <- ggplot(filter(cat_select_prop_data, cond %in% c("CE", "CEA"))) +
  geom_segment(data = cat_select_prop_wide,
               mapping = aes(x = as.numeric(cond) + subj_offset, xend = as.numeric(cond) + subj_offset,
                             y = prop_cats_obs, yend = prop_cats_ideal),
               alpha = 0.3) +
  geom_point(aes(x = as.numeric(cond) + subj_offset, 
                 y = prop_cats, shape = data_type), 
             size = 1.3) +
  geom_col(data = cat_select_prop_stats,
           mapping = aes(x = cond, y = prop_cats_obs_mean),
           fill = NA, color = "black", width = 0.8) + 
  geom_errorbar(data = cat_select_prop_stats,
               mapping = aes(x = cond, y = prop_cats_obs_mean, 
                             ymin = prop_cats_obs_mean - 2.96*prop_cats_obs_SEM,
                             ymax = prop_cats_obs_mean + 2.96*prop_cats_obs_SEM),
               width = 0.3, alpha = 0.5) +
  geom_segment(mapping = aes(x = as.numeric(cond) - 0.4, xend = as.numeric(cond) + 0.4),
               y = 3/8, yend = 3/8, linetype = "dashed") +
  scale_x_discrete(labels = cond_labels) +
  scale_shape_manual(name = "", values = c("Observed" = 16, "Recommended" = 1)) +
  # scale_alpha_manual(name = "", values = c("Observed" = 0.6, "Recommended" = 1)) +
  scale_color_manual(values = color_palette) +
  xlab("Condition") +
  ylab("Proportion of Worse Performing\nCategories Selected") +
  # facet_grid(~ block_set, labeller = labeller(block_set = block_set_labels)) +
  theme_pubr(base_size = 30) +
  guides(color = "none", shape = guide_legend(override.aes = list(size = 6))) 
ggsave(filename = "figure/cat_select_top3_CECEA.png", p, width = 15, height = 8)

# between accuracy groups for each condition
# cat_select_prop_stats <- cat_select_prop %>%
#   group_by(cond) %>%
#   summarize(prop_cats_median = median(prop_cats)) %>%
#   ungroup()

# facet_labels <- c(`1` = "blocks 1-3", `2` = "blocks 4-6", `3` = "blocks 7-9")
# p <- filter(cat_select_prop, cond != "GEA") %>%
#   ggplot(aes(x = accu_grp, y = prop_cats)) +
#   geom_jitter(width = 0.05, size = 0.8) +
#   geom_boxplot(fill = NA, outliers = FALSE,
#                color = "black", width = 0.6) + 
#   geom_segment(mapping = aes(x = as.numeric(accu_grp) - 0.3, xend = as.numeric(accu_grp) + 0.3),
#                y = 3/8, yend = 3/8, linetype = "dashed") +
#   xlab("Condition") +
#   ylab("Proportion of Difficult Categories Selected") +
#   facet_grid(~ cond) +
#   theme_pubr(base_size = 30)
ggsave(filename = "figure/cat_select_top3_accu_group.png", p, width = 15, height = 8)

#---------------------------------------------------------
#statistical tests comparing the mean proportions of difficult categories selected
#across conditions and accuracy groups

load("cat_select_prop.Rdata")
# cat_select_prop <- cat_select_prop %>%
#   group_by(cond,subj) %>%
#   summarize(Prcorr = mean(Prcorr),
#             prop_cats = prop_cats_cum[block_set == 3])%>%
#   group_by(cond) %>%
#   filter(percent_rank(Prcorr) > 0.05, percent_rank(Prcorr) < 0.95) %>%
#   mutate(accu_grp = if_else(Prcorr > median(Prcorr), "high", "low"))

# correlation between selecion proportion and final test accuracy
cond_labels <- c("CE" = "Choose\nExample", "CEA" = "Choose\nExample Adaptive")
p <- ggplot(data = filter(cat_select_prop, cond != "GEA"),
            mapping = aes(x = prop_cats_obs, y = Prcorr)) +
  geom_smooth(method = "lm", se = F, color = "gray", alpha = 0.5) +
  geom_vline(color = "gray", xintercept = with(cat_select_prop, 
                                               mean(prop_cats_ideal[cond == "GEA"])),
             linetype = "dashed") +
  geom_point(size = 2, shape = 1) +
  xlab("Proportion of Worse Performing\nCategories Selected") +
  ylab("Final Test Accuracy") +
  scale_x_continuous(breaks = seq(0,1,0.1), limits = c(0, 1)) +
  scale_y_continuous(breaks = seq(0,1,0.1), limits = c(0, 1)) +
  coord_equal() +
  facet_wrap(~ cond, labeller = labeller(cond = cond_labels)) +
  theme_pubr(base_size = 20) 
with(filter(cat_select_prop, cond == "CE"),
     cor.test(prop_cats_obs, Prcorr))
with(filter(cat_select_prop, cond == "CEA"),
     cor.test(prop_cats_obs, Prcorr))
ggsave(filename = "figure/PropDiffvsPrC.png", p, width = 16, height = 8)



#between conditions
summary_stats <- cat_select_prop %>%
  group_by(cond) %>%
  summarize(mean = mean(prop_cats_obs),
            sd = sd(prop_cats_obs),
            nsubj = n())
cat_select_prop_longer <- cat_select_prop %>%
  pivot_longer(cols = starts_with("prop_cats"), 
               names_to = "data_type", values_to = "prop_cats", names_prefix = "prop_cats_")

with(filter(cat_select_prop, cond == "CE"),
     t.test(prop_cats_obs, prop_cats_ideal, paired = T, var.equal = T))

with(filter(cat_select_prop_longer, cond == "CE"),
     cohen.d(prop_cats, data_type, paired = T, subject = subj))

with(filter(cat_select_prop, cond == "CEA"),
     t.test(prop_cats_obs, prop_cats_ideal, paired = T, var.equal = T))

with(filter(cat_select_prop_longer, cond == "CEA"),
     cohen.d(prop_cats, data_type, paired = T, subject = subj))

with(cat_select_prop,
     t.test(prop_cats_obs[cond == "CEA"], prop_cats_obs[cond == "CE"], var.equal = T))

with(filter(cat_select_prop_longer, cond %in% c("CE","CEA")),
     cohen.d(prop_cats, data_type))

with(filter(cat_select_prop,cond == "CEA"),
     cor.test(prop_cats_obs, Prcorr, var.equal = T))

#between accuracy groups
# summary_stats <- cat_select_prop %>%
#   group_by(cond, accu_grp) %>%
#   summarize(median = median(prop_cats),
#             MAD = mad(prop_cats),
#             nsubj = n())
# 
# with(filter(cat_select_prop,cond == "CE"),
#      wilcox.test(prop_cats[accu_grp == "high"], prop_cats[accu_grp == "low"]))
# 
# with(filter(cat_select_prop,cond == "CE"),
#      cliff.delta(prop_cats[accu_grp == "high"], prop_cats[accu_grp == "low"]))
# 
# with(filter(cat_select_prop,cond == "CEA"),
#      wilcox.test(prop_cats[accu_grp == "high"], prop_cats[accu_grp == "low"]))
# 
# with(filter(cat_select_prop,cond == "CEA"),
#      cliff.delta(prop_cats[accu_grp == "high"], prop_cats[accu_grp == "low"]))
#   