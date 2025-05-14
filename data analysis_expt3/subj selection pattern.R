library(tidyverse)
library(gridExtra)
library(boot)
library(ggpubr)
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
  

load("prior_info.Rdata")
prior_data <- prior_df %>%
  mutate(ref_cat = ref,
         pair_cat = pair,
         .keep = "unused") %>%
  group_by(ref_cat) %>%
  mutate(CS_prior = similarity/sum(similarity),
         CS_prior = if_else(ref_cat == pair_cat, NA, CS_prior),
         .keep = "used") %>%
  select(-similarity) 

pred_cat_test <- data %>%
  filter(cond %in% c("GCP", "CCP"), phase == "test", cycle %in% 0:3) %>%
  group_by(cond,subjID,cycle) %>% 
  group_modify(~ {
    df_group <- .x
    cat_levels <- unique(df_group$cat)
    pmap_dfr(.l = expand.grid(cat_levels, cat_levels, stringsAsFactors = FALSE), 
             .f = ~ compute_classScore(df_group, "cat", "resp", ..1, ..2)
            )
    }) %>%
  group_by(cond, subjID, ref_cat, pair_cat) %>%
  left_join(prior_data, by = c("ref_cat","pair_cat")) %>%
  mutate(HS_cumsum = compute_exponential_cumsum(cycle, HS, 0.5),
         CS_cumsum = compute_exponential_cumsum(cycle, CS, 0.5, unique(CS_prior)),
         CS_cumsum = if_else(is.na(CS_cumsum),CS_prior,CS_cumsum),
         DS = 1 - HS_cumsum + 1/8) %>%
  group_by(cond, subjID, cycle, pair_cat) %>%
  mutate(ref_cat_prop = DS/sum(DS, na.rm = T)) %>%
  group_by(cond, subjID, cycle, ref_cat) %>%
  mutate(paired_cat_prop = CS_cumsum/sum(CS_cumsum, na.rm = T),
         cat_pair_prop = ref_cat_prop * paired_cat_prop,
         cycle_train = cycle + 1) %>%
  select(-c(CS_prior,HS_cumsum, CS_cumsum, DS, HS, CS)) %>%
  ungroup() %>%
  nest(.by = c(cond, subjID, cycle_train), .key = "pairs_score") 

cat_levels = c("Andesite","Basalt", "Diorite", "Gabbro", 
               "Obsidian", "Pegmatite", "Peridotite", "Pumice")
cat_pair_select_compare <- data %>%
  filter(cond %in% c("GCP", "CCP"), trialType == "cat_selection") %>%
  select(cond, subjID, cycle, trial, ref_cat_num, paired_cat_num) %>%
  mutate(ref_cat = factor(ref_cat_num,labels = cat_levels),
         paired_cat = factor(paired_cat_num,labels = cat_levels),
         .keep = "unused") %>%
  nest(.by = c(cond, subjID, cycle), .key = "pairs_selected") %>%
  left_join(pred_cat_test, by = join_by(cond, subjID, cycle == cycle_train)) %>%
  rowwise() %>%
  mutate(sym_pair_data = list(symmetrize_cat_pairs(pairs_score) %>%
                            arrange(desc(cat_pair_prop))),
         count_pair_match = {
           pairs_ideal = paste(sym_pair_data$ref_cat_sym[1:3],sym_pair_data$pair_cat_sym[1:3], sep = "_")
           cat_pair_match = mapply(function (ref, pair){
                                    cat_pair_sym = paste(sort(c(ref, pair)),collapse = "_")
                                    cat_pair_sym %in% pairs_ideal
                                    }, 
                                   pairs_selected$ref_cat, pairs_selected$paired_cat, SIMPLIFY = T)
           sum(cat_pair_match)
         },
         diff_prop_pair = {
           
            cat_pair_prob_ideal = sym_pair_data$cat_pair_prop[1:3]
            
            cat_pair_prob_select = mapply(function (ref, pair){
                                          cat_pair_sym = sort(c(ref, pair))
                                          with(sym_pair_data, 
                                               cat_pair_prop[ref_cat_sym == cat_pair_sym[1] & pair_cat_sym == cat_pair_sym[2]])
                                          }, 
                                          pairs_selected$ref_cat, pairs_selected$paired_cat, SIMPLIFY = T)
            cat_pair_prob_select = sort(cat_pair_prob_select, decreasing = T)
            sum(cat_pair_prob_ideal - cat_pair_prob_select)
         })

#inspect correlation between cat selection pattern and test performance
accu_df <- data %>%
  filter(phase == "test", cond == "CCP") %>%
  group_by(subjID, cycle) %>%
  summarize(Prcorr = mean(corr))
cat_pair_select_subj_cycle <- cat_pair_select_compare %>%
  filter(cond == "CCP") %>%
  group_by(subjID) %>%
  mutate(diff_prop_pairs = cummean(diff_prop_pair),
         count_pair_match = cumsum(count_pair_match)) %>%
  inner_join(accu_df, by = c("subjID", "cycle")) %>%
  ungroup() 
save(cat_pair_select_subj_cycle, file = "cat_pair_select_CCP.Rdata")
load("cat_pair_select_CCP.Rdata")

# visualization
## scatter plot for accuracy across cycle
p <- ggplot(filter(cat_pair_select_subj_cycle, cycle == 4), 
            aes(x = count_pair_match, y = Prcorr)) +
  geom_jitter(width = 0.1) +
  geom_smooth(method = "lm", se = F, color = "gray", alpha = 0.8) +
  # facet_wrap(~cycle, labeller = "label_both") +
  scale_x_continuous(breaks = 0:9) +
  xlab("Number of Category Pairs Selected\nMatching Adaptive System") +
  ylab("Final Test Accuracy") +
  theme_pubr(base_size = 30)
  ggsave(paste('Cat_PairvsTest_Accu',".jpg"),plot = p ,path = "figure",width = 12, height = 12)
 
output = c()
for (cycle_val in unique(data$cycle)) {
  for (cond_val in "CCP"){
    cor_coef = filter(cat_pair_select_subj_cycle, cond == cond_val, cycle == cycle_val) %>%
               with(cor.test(count_pair_match, Prcorr, method = "spearman"))
    output = c(output, cycle_val, cor_coef)
  }
} 
print(output)


## learning curves
# cat_pair_select_subj <- cat_pair_select_subj_cycle %>%
#   select(cond, subjID, count_pair_group) %>%
#   distinct()
# learning_curve_CCP <- data %>%
#   filter(cond == "CCP", phase == "test", trialType == "class_response") %>%
#   group_by(cond, subjID, cycle) %>%
#   summarize(Prcorr = mean(corr)) %>%
#   left_join(cat_pair_select_subj, by = c("cond", "subjID")) %>%
#   group_by(cond, cycle, count_pair_group) %>%
#   summarize(Prcorr_median = median(Prcorr))
# learning_curves_other <- data %>%
#   filter(cond != "CCP", phase == "test", trialType == "class_response") %>%
#   group_by(cond, subjID, cycle) %>%
#   summarize(Prcorr = mean(corr)) %>%
#   group_by(cond, cycle) %>%
#   summarize(Prcorr_median = median(Prcorr))
  
# p <- ggplot(data = learning_curves_other,
#             aes(y=Prcorr_median, x=cycle)) +
#   geom_line(aes(linetype = cond),linewidth = .7) +
#   geom_point(aes(shape = cond),size = 3) +
#   geom_line(data = learning_curve_CCP, aes(color = count_pair_group)) +
#   scale_shape_manual(name = "Condition", values = c(1,2,3,4)) +
#   scale_linetype_manual(name = "Condition", values = c("dashed","dotted","dotdash")) + 
#   xlab("Cycle") +
#   ylab ("Proportion Correct") +
#   labs(color = "CCP\nalgorithm pair matching\nmedian group") +
#   scale_x_continuous(breaks = 0:4) +
#   scale_y_continuous(limits = c(0,1)) +
#   theme_bw(base_size = 15) +
#   theme(panel.grid.minor = element_blank())
# ggsave(paste('annotated learning curves',".jpg"),plot = p ,path = "figure",width = 8, height = 6)
