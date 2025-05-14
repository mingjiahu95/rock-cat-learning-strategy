library(tidyverse)
library(ggpubr)
library(ggridges)
library(jsonlite)
source('util.R')


# ---- Load the Data ----

data_GEA <- read.csv("GEA_test.csv",stringsAsFactors = TRUE) %>%
            filter(trialType == "class_response") %>%
            select(cycle, phase, resp, cat, token, corr)

# data <- read.csv("exptData_subj-67100e5eaa639.csv",stringsAsFactors = TRUE) %>%
#         filter(trialType == "class_response") %>%
#         select(cycle, phase, resp, cat, token, corr)


#---------------------------------------------------------
# check count of recommendation trials per category
pred_cat_test <- data_GEA %>%
                 filter(phase == "test", cycle %in% 0:3) %>%
                 group_by(cycle) %>% 
                 nest() %>%
                 mutate(stats = map(data, ~ {
                           df <- .x  
                           map_df(unique(df$cat), function(cat_value) {
                                                 compute_dprime(df, cat, resp, cat_value)
                                             })
                                })) %>%
                 unnest(stats) %>%
                 group_by(stats_cat) %>%
                 arrange(stats_cat, cycle) %>%
                 mutate(dprime_cumsum = compute_exponential_cumsum(cycle, dprime, lambda = 0.5),
                        rec_val = 1 - dprime_cumsum + 0.125) %>%
                 group_by(cycle) %>%
                 mutate(stats_cat = stats_cat,
                       rec_norm = rec_val/sum(rec_val),
                       count_expect = rec_norm*48) %>%
                 select(cycle,stats_cat,H,FA,dprime,dprime_cumsum,rec_norm,count_expect) %>% 
                 ungroup() %>%
                 mutate(cycle_train = cycle + 1,.keep = "unused") %>%
                 arrange(cycle_train,stats_cat)

count_cat_compare <- data_GEA %>%
                     filter(phase == "train", cycle %in% 1:4) %>%
                     group_by(cycle,cat) %>% 
                     summarize(count = n()) %>%
                     right_join(pred_cat_test,
                                join_by(cat == stats_cat,cycle == cycle_train)) %>%
                     mutate(count = if_else(is.na(count), 0, count),
                            error = abs(count - count_expect),
                            error_size = if_else(error <= 0.5,"small","big"),
                            DF_cycle = 1 - dprime + 1/8,
                            CDF = 1 - dprime_cumsum + 1/8)

# resp_list <- data %>%
#   filter(phase == "test") %>%
#   group_by(cycle) %>%
#   summarize(resp_list = list(resp), .groups = 'drop') %>%
#   pull(resp_list)
# 
# toJSON(resp_list,pretty = TRUE)
