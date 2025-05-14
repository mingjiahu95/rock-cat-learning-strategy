library(tidyverse)
library(ggpubr)
# library(gridExtra)
# library(magrittr)

# ---- Load the Data ----

setwd("../data_expt3")
files <- dir(pattern = "LearnStrategy.*\\.csv$") 
data <- do.call(bind_rows, lapply(files, read.csv, skip = 1,nrows = 289))
setwd("../data analysis_expt3")

# ---- data cleaning ----
data_cleaned <- select(data, participant,condition, block, phase, trial, cat, token, row, col, resp, corr, t_select, t_resp) %>%
                rename(subj = participant,cond = condition) %>%
                filter(!is.na(trial) & !is.na(subj)) #give the unnamed participant a subject number

data_cleaned$cond = factor(data_cleaned$cond,levels = c("TCN","TCR","SCN", "SCR"))
data_cleaned$phase = factor(data_cleaned$phase,labels = c("train","test"))
data_cleaned$cat = factor(data_cleaned$cat,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
data_cleaned$resp = factor(data_cleaned$resp,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
# data_cleaned$subj = as.factor(data_cleaned$subj)
# data_cleaned$block = as.factor(data_cleaned$block)

#---------------------------------------------------------
# count number of recommended categories

dprime_cat_test <- data_cleaned %>%
                   filter(cond %in% c("SCR","SCN"), phase == "test", block != 9) %>%
                   group_by(cond, subj, block) %>% # add subj and block for different levels
                   nest() %>%
                   mutate(stats = map(data, ~ {
                          df <- .x  
                          map_df(unique(df$cat), function(cat_value) {
                                                 compute_dprime(df, 'cat', 'resp', cat_value)
                                                 })
                   })) %>%
                   unnest(stats) %>%
                   group_by(cond, subj, stats_cat) %>%
                   arrange(cond, subj, stats_cat, block) %>%
                   mutate(dprime_cumsum = compute_exponential_cumsum(block, dprime, lambda = 1)) %>%
                   select(cond,subj,block,stats_cat,H,FA,dprime_cumsum) %>% # add subj and block for different levels
                   ungroup() %>%
                   mutate(block_train = block + 1,
                          cat = stats_cat,.keep = "unused") %>%
                   arrange(cond,subj,block_train,cat)

prop_selection_top3 <- data_cleaned %>%
                       filter(cond %in% c("SCR","SCN"), phase == "train", block %in% 2:9) %>%
                       group_by(cond,subj,block,cat) %>% # add subj and block for different levels
                       summarize(cat_count = n()) %>%
                       left_join(dprime_cat_test,
                                 join_by(cond,subj,cat, block == block_train)) %>% # add subj and block for different levels
                       group_by(cond,subj,block) %>% # add block for different levels
                       arrange(dprime_cumsum,H,desc(FA),cat,.by_group = TRUE) %>%
                       summarize(prop_select_block = sum(head(cat_count,3))/sum(cat_count)) %>%
                       group_by(cond,subj) %>%
                       summarize(prop_select_subj = mean(prop_select_block)) %>%
                       group_by(cond) %>%
                       mutate(prop_select_group = if_else(prop_select_subj > median(prop_select_subj),2,1),
                              prop_select_group = as.factor(prop_select_group)) %>%
                       ungroup()

learning_curve_subj_df <- data_cleaned %>%
                          filter(cond == "SCR", phase == "test", block %in% 7:9) %>% ##choose SCN or SCR
                          group_by(subj) %>%
                          summarize(PropCorr = mean(corr)) %>%
                          left_join(prop_selection_top3)
                       
learning_curve_ref_df <- data_cleaned %>%
                         filter(cond == "TCN", phase == "test", block %in% 7:9) %>%
                         group_by(subj) %>%
                         summarize(PropCorr_sub = mean(corr))

t.test(learning_curve_ref_df$PropCorr_sub,
       learning_curve_subj_df$PropCorr[learning_curve_subj_df$prop_select_group == 2])

# p <- ggplot(learning_curve_subj_df, aes(x = block,
#                                         y = PropCorr,
#                                         group = subj,
#                                         alpha = prop_select)) +
#      geom_line() +
#      scale_x_continuous(1:9) +
#      labs(title = "Individual learning curve",
#          x = "Block",
#          y = "Proportion Correct") +
#      theme_pubr()

test_accu_by_group <- learning_curve_subj_df %>%
                      # filter(block %in% 7:9) %>% 
                      group_by(prop_select_group,subj) %>%
                      summarize(PropCorr_sub = mean(PropCorr)) %>%
                      group_by(prop_select_group) %>%
                      summarize(PropCorr = mean(PropCorr_sub),
                                PropCorr_SE = sd(PropCorr_sub)/sqrt(n())
                                ) 
test_accu_ref <- learning_curve_ref_df %>%
                 # filter(block %in% 7:9) %>%
                 summarize(PropCorr = mean(PropCorr_sub))

p <- ggplot(test_accu_by_group,aes(x = prop_select_group,
                                   y = PropCorr)) +
     geom_col(width = .5, fill = "white", color = "black") +
     geom_errorbar(aes(ymin = PropCorr - PropCorr_SE,
                       ymax = PropCorr + PropCorr_SE),
                   width = .3) +
     geom_hline(data = test_accu_ref,
                mapping = aes(yintercept = PropCorr),
                linetype = "dashed") +
     scale_x_discrete(labels = c("other","difficult")) +
     ylim(0,1) +
     labs(title = "test accuracy median split",
          x = "Category Selection Strategy",
          y = "Proportion Correct") +
     theme_pubr(base_size = 15)
                      

ggsave(paste('top3_lambda1_PropSelect_SCR',".jpg"),plot = p ,path = "figure/block weight",width = 10, height = 10)

