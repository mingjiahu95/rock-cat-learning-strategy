library(tidyverse)
library(ggpubr)
library(ggridges)
source('util.R')
# library(gridExtra)
# library(magrittr)

# ---- Load the Data ----

data <- readRDS("prolific data.RDS") 

# ---- data cleaning ----------------------------------------------

valid_subj_accu_df <- data %>%
  filter(phase == "test", block %in% 7:9) %>%
  group_by(cond,subj) %>%
  summarize(Pr_corr_test = mean(corr == 1)) %>%
  group_by(cond) %>%
  filter(percent_rank(Pr_corr_test) > .15) %>%
  ungroup()  

data_cleaned <- data %>%
  semi_join(valid_subj_accu_df,by = "subj")%>%
  filter(grepl("SC",cond)) %>%
  mutate(block_set = case_when(
    block %in% 1:3 ~ "1-3",
    block %in% 4:6 ~ "4-6",
    block %in% 7:9 ~ "7-9"),
    block_set = factor(block_set)
  )

# # ---- recommendation following ----
# prop_rec_block <- filter(data_cleaned,cond == "SCR", phase == "train") %>%
#                   group_by(subj, block) %>%
#                   summarize(prop_rec = mean(cat == cat_rec & token == token_rec)) %>%
#                   ungroup() %>%
#                   mutate(block_fct = as.factor(block))
# 
# hist_rec_block <- create_ridge_plot(prop_rec_block,"prop_rec","block_fct",
#                                     "Proportion of Recommendations Followed",
#                                     "Block")
# 
# hist_rec_block <- ggplot(prop_rec_block, aes(x = prop_rec, y = block_fct, group = block)) +
#                   geom_density_ridges2(
#                     color = "black",
#                     fill = "white",
#                     stat = "binline",
#                     binwidth = .2,
#                     scale = 0.9
#                     ) +
#                   geom_text(
#                     stat = "bin",
#                     aes(y = group + after_stat(count/max(count))*0,
#                         label = ifelse(after_stat(count) > 0, after_stat(count), "")),
#                     vjust = -1, size = 3, color = "black", binwidth = .2
#                     ) +
#                   scale_x_continuous(breaks=seq(0,1.00,.2),labels =seq(0,1.00,.2)) +
#                   scale_y_discrete(expand = c(0, 1)) +
#                   xlab("Proportion of recommendations followed") +
#                   ylab ("Block") + 
#                   coord_cartesian(clip = "off") +
#                   theme_bw(base_size = 15) +
#                   theme(panel.grid.minor = element_blank(),
#                         axis.text.x = element_text(vjust = 1))
# 
# ggsave(paste('proportion of recommendation following',".jpg"),plot = hist_rec_block ,path = "figure",width = 12, height = 8)


#---------------------------------------------------------
# check count of recommendation trials per category

rec_cat_test <- data_cleaned %>%
                filter(cond == "SCR", phase == "test", block %in% 1:8) %>%
                group_by(subj, block) %>% 
                nest() %>%
                mutate(stats = map(data, ~ {
                          df <- .x  
                          map_df(unique(df$cat), function(cat_value) {
                                                 compute_dprime(df, cat, resp, cat_value)
                                                 })
                   })) %>%
                unnest(stats) %>%
                group_by(subj, stats_cat) %>%
                arrange(subj, stats_cat, block) %>%
                mutate(dprime_cumsum = compute_exponential_cumsum(block, dprime, lambda = 0.5),
                       rec_val = 1 - dprime_cumsum + 0.125) %>%
                group_by(subj,block) %>%
                mutate(stats_cat = stats_cat,
                       rec_norm = rec_val/sum(rec_val),
                       count_expect = rec_norm*16) %>%
                select(subj,block,stats_cat,H,FA,dprime,dprime_cumsum,rec_norm,count_expect) %>% 
                ungroup() %>%
                mutate(block_train = block + 1,.keep = "unused") %>%
                arrange(subj,block_train,stats_cat)

count_cat_compare <- data_cleaned %>%
                     filter(cond == "SCR", phase == "train", block %in% 2:9) %>%
                     group_by(subj,block,cat_rec) %>% 
                     summarize(count = n()) %>%
                     right_join(rec_cat_test,
                                join_by(subj,cat_rec == stats_cat,block == block_train)) %>%
                     mutate(count = if_else(is.na(count), 0, count),
                            error = abs(count - count_expect),
                            error_size = if_else(error <= 0.5,"small","big"))
