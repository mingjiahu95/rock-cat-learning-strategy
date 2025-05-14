#---------------------------------------------------------
# load libraries and data sets
library(tidyverse)
library(ggpubr)
library(ggridges)
source("util.R")

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

cat_levels = c("Andesite","Basalt","Diorite","Gabbro","Obsidian","Pegmatite","Peridotite","Pumice")
item_coords <- read.csv("rocksmds480.csv") %>%
               filter(cat %in% cat_levels) %>%
               mutate(cat = factor(cat, levels = cat_levels))

#---------------------------------------------------------
# compute the cross entropy between ideal and observed category selection
cat_prop_ideal <- data_cleaned %>%
                  filter(phase == "test", block %in% 1:8) %>%
                  group_by(cond, subj, block) %>% 
                  nest() %>%
                  mutate(stats = map(data, ~ {
                          df <- .x  
                          map_df(unique(df$cat), 
                                  function(cat_value) {
                                    compute_dprime(df, cat, resp, cat_value)
                                  })
                          })
                        ) %>%
                  unnest(stats) %>%
                  group_by(cond, subj, stats_cat) %>%
                  arrange(subj, stats_cat, block) %>%
                  mutate(dprime_cumsum = compute_exponential_cumsum(block, dprime, lambda = 0.5),
                         rec_val = 1 - dprime_cumsum + 0.125) %>%
                  group_by(cond,subj,block) %>%
                  mutate(cat_prop_ide = rec_val/sum(rec_val)) %>%
                  select(subj,block,stats_cat,H,FA,dprime,dprime_cumsum,cat_prop_ide) %>% 
                  ungroup() %>%
                  mutate(block_train = block + 1,.keep = "unused") %>%
                  arrange(cond,subj,block_train,stats_cat)

cat_prop_observed <- data_cleaned %>%
                     filter(phase == "train", block %in% 2:9) %>%
                     group_by(cond,subj,block,cat) %>% 
                     summarize(cat_count = n()) %>%
                     group_by(cond,subj,block) %>%
                     mutate(cat_prop_obs = cat_count/sum(cat_count)) %>%
                     ungroup()

cat_prop_diff <- inner_join(cat_prop_observed, cat_prop_ideal,
                           join_by(cond,subj,cat == stats_cat,block == block_train)) %>%
                 # replace_na(list(cat_count = 0,cat_prop_obs = 0)) %>%
                 # mutate(block_set = case_when(
                 #                      block %in% 2:3 ~ "1-3",
                 #                      block %in% 4:6 ~ "4-6",
                 #                      block %in% 7:9 ~ "7-9"),
                 #        block_set = factor(block_set)
                 #       ) %>%
                 group_by(cond,subj,block) %>% # add block_set
                 summarize(difference = sum(cat_prop_obs*log(cat_prop_obs/cat_prop_ide))) %>%
                 # group_by(cond,subj,block_set) %>%
                 # summarize(difference = mean(difference)) %>%
                 # group_by(cond,block_set) %>%
                 # mutate(cat_strategy_group = if_else(difference >= .3,"NF","F"),
                 #        cat_strategy_group = factor(cat_strategy_group,levels = c("NF","F")),
                 #        .keep = "all") %>%
                 ungroup()
#---------------------------------------------------------
# compile various measures of recommendation following for SC conditions
prop_rec_SCR <- filter(data_cleaned,cond == "SCR", phase == "train") %>%
                group_by(cond, subj, block) %>% #block_set
                summarize(prop_rec_cat = mean(cat == cat_rec),
                          prop_rec_stim = mean(cat == cat_rec & token == token_rec)) %>%
                ungroup() 

# sim_diff_corr <- filter(data_cleaned,phase == "train") %>%
#                  select(cond,subj,block_set,block,phase,trial,cat,token,resp,corr) %>%
#                  left_join(item_coords, by = c("cat","token")) %>%
#                  group_by(cond,subj,block_set,block) %>%
#                  mutate(across(D1:D8, ~ (lead(.x) - .x)^2),
#                         dist = sqrt(D1 + D2 + D3 + D4 + D5 + D6 + D7 + D8),
#                         sim = exp(-0.2*dist)
#                        ) %>%
#                  group_by(cond,subj,block_set) %>%
#                  summarize(sim_corr = mean(sim[corr == 1],na.rm = T),
#                            N_resp_corr = sum(corr == 1),
#                            sim_incorr = mean(sim[corr == 0],,na.rm = T),
#                            N_resp_incorr = sum(corr == 0),
#                            sim_diff = sim_corr - sim_incorr
#                            ) %>%
#                  ungroup() %>%
#                  select(cond,subj,block_set,sim_corr,sim_incorr,sim_diff)

strategy_measure <- prop_rec_SCR %>%
                    right_join(cat_prop_diff,by = c("cond","subj","block")) %>% #block_set
                    # right_join(sim_diff_corr,by = c("cond","subj","block_set")) %>%
                    rename(cat_dist_discrepancy = difference) 

performance_measure <- filter(data_cleaned, phase == "test") %>%
                       group_by(cond,subj,block) %>%  #block_set
                       summarize(PrCorr_test_block = mean(corr == 1)) 
                       # group_by(cond,subj) %>%  #block_set
                       # mutate(PrCorr_test = mean(PrCorr_test_block))

#---------------------------------------------------------
## visualize the subject distribution for various strategy measures for SCR condition
# category distribution measure
measure_cutoff = 0.8  # cat_dist_discrepancy: 0.2     
metric_var_names <- c("cat_dist_discrepancy","prop_rec_cat","prop_rec_stim") 
metric_figure_names <- c("Category Distribution Divergence","Category Recommendation Proportion",
                         "Item Recommendation Proportion")#"Item Similarity following Correct Response"

for (i in 1:length(metric_var_names)){
  scatterplot_data <- filter(strategy_measure, cond == "SCR") %>% # add cond == "SCN"
    group_by(cond, subj) %>%
    # mutate(avg_measure = mean(!!sym(metric_var_names[i]), na.rm = T)) %>%
    # ungroup() %>%
    # )
    mutate(subject_group = if_else(mean(cat_dist_discrepancy) > measure_cutoff,"F","NF")) %>%
    # summarize(cat_dist_discrepancy = mean(cat_dist_discrepancy),
    #           subject_group = unique(subject_group)
    #           ) %>%
    # mutate(quantile_group = ntile(avg_measure,3),
    #        quantile_group = factor(quantile_group) %>%
    ungroup()
    
  
  p <- ggplot(scatterplot_data, aes(x = !!sym(metric_var_names[i])))+
    geom_histogram(aes(fill = subject_group), # change to quantile group
                   color = "black",
                   position = position_stack(),
                   binwidth = .1) +
    facet_wrap(~ block, nrow = 3) + # change to ~block_set, nrow = 1
    stat_bin(binwidth=.1, geom="text", colour="red", size=3.5,
             aes(label=ifelse(after_stat(count) == 0,"", after_stat(count)), 
                 group=subject_group, y=after_stat(count)), # change to quantile group
             vjust = 1) +
    stat_bin(binwidth=.1, geom="text", colour="black", size=3.5,
             aes(label=ifelse(after_stat(count) == 0,"", after_stat(count)), 
                 y=after_stat(count)),
             vjust = -.5) +
    xlab(metric_figure_names[i]) +
    ylab("Number of Subjects") +
    # ggtitle("Block Number") + # delete condition
    scale_fill_manual(name = "subject group by average", 
                      values = c("cyan","deepskyblue1","blue")) +
    scale_x_continuous(breaks = seq(0,2,.2), limits = c(-.1,1.2)) + 
    scale_y_continuous(breaks = seq(0,60,10),
                       limits = c(0,60),
                       expand = expansion(mult = c(0, .15))
                       ) +
    theme_bw(base_size = 20) +
    theme(panel.grid.minor = element_blank(),
          plot.title = element_text(hjust = 0.5),
          axis.text.x = element_text(hjust = 1.8,vjust = -1.8,angle = 315)
         )
  
  file_name = paste(metric_figure_names[i], "dist_SCR.jpg", sep = "_")
  ggsave(file_name, plot = p ,path = "figure_rec",width = 18, height = 12)
}

#-------------------------------------------------------------------------
# # correlate strategy measure with test performance
# scatterplot_data <- inner_join(strategy_measure, performance_measure,
#                         by = c("cond", "subj","block"))  %>% #block_set
#                     filter(cond == "SCN") %>%
#                     group_by(subj) %>%
#                     reframe(cat_dist_discrepancy = mean(cat_dist_discrepancy),
#                             PrCorr_test = PrCorr_test[block %in% 7:9]) %>%
#                     distinct()
#              
# 
# ggplot(scatterplot_data, aes(x = cat_dist_discrepancy, y = PrCorr_test)) +
#   geom_point(size = 3, color = "blue") +  
#   geom_smooth(method = lm, se = FALSE) + 
#   # facet_wrap(~ block_set) +
#   labs(x = "Category Distribution Measure",
#        y = "Final Test Performance") 
# 
# with(scatterplot_data, cor(cat_dist_discrepancy,PrCorr_test))

#-------------------------------------------------------------------------
# learning curves by strategy groups of SCR and SCN
measure_cutoff = 0.8 # change for different metrics
curve_data <- inner_join(strategy_measure, performance_measure,
                               by = c("cond","subj","block"))  %>% #block_set
              group_by(cond,subj) %>%
              mutate(prop_rec_stim = mean(prop_rec_stim),
                     cond_strategy  = case_when(cond == "SCR" & prop_rec_stim > measure_cutoff ~ "SCR_F",
                                                cond == "SCR" & prop_rec_stim <= measure_cutoff ~ "SCR_NF",
                                                cond == "SCN" & prop_rec_stim <= measure_cutoff ~ "SCN_NF") 
                     )%>%
              filter(!is.na(cond_strategy)) %>%
              group_by(cond_strategy, block) %>%
              summarize(Pr_corr = mean(PrCorr_test_block),
                        SEM = sqrt(var(PrCorr_test_block)/length(PrCorr_test_block)),
                        N_subj = n_distinct(subj)) %>%
              ungroup()

N_subj_SCNNF = with(curve_data,unique(N_subj[cond_strategy == "SCN_NF"]))
N_subj_SCRF = with(curve_data,unique(N_subj[cond_strategy == "SCR_F"]))
N_subj_SCRNF = with(curve_data,unique(N_subj[cond_strategy == "SCR_NF"]))

var_names <- c("N_subj_SCN_NF","N_subj_SCR_F","N_subj_SCR_NF")
var_vals <- c(N_subj_SCNNF, N_subj_SCRF, N_subj_SCRNF)
subj_N_info <- paste(paste(var_names, "=", var_vals), collapse = ", ")

p <- ggplot(data = curve_data,
            aes(y = Pr_corr, x = block)) +
  geom_line(aes(group = cond_strategy),linewidth = .7) +
  geom_point(aes(shape = cond_strategy),size = 3) +
  geom_errorbar(aes(ymin = Pr_corr - SEM, ymax = Pr_corr + SEM), width = .1) +
  scale_shape_manual(name = "Condition x Strategy Group", values = c(21,24,16,17)) + #c(24,21)
  xlab("Test Block") +
  ylab ("Proportion Correct") +
  ggtitle(subj_N_info) +  
  scale_x_continuous(breaks = 1:9) +
  scale_y_continuous(limits = c(0.4,0.9)) +
  theme_bw(base_size = 15) +
  theme(panel.grid.minor = element_blank())

ggsave(paste('test learning curves_SCR_without_outlier',".jpg"),plot = p ,path = "figure_new",width = 12, height = 6)

# inspect final test performance by condition and strategy groups
hist_data <- inner_join(strategy_measure, performance_measure,
                         by = c("cond", "subj","block"))  %>% #block_set
             group_by(cond,subj) %>%
             mutate(prop_rec_stim = mean(prop_rec_stim),
                    cond_strategy = case_when(cond == "SCR" & prop_rec_stim > measure_cutoff ~ "SCR_F",
                                              cond == "SCR" & prop_rec_stim <= measure_cutoff ~ "SCR_NF",
                                              cond == "SCN" & prop_rec_stim <= measure_cutoff ~ "SCN_NF") 
                   )%>%
             filter(!is.na(cond_strategy), block %in% 7:9) %>%
             group_by(cond_strategy,subj) %>%
             summarize(PrCorr = mean(PrCorr_test_block)) %>%
             ungroup()

p <- create_ridge_plot(hist_data, "PrCorr","cond_strategy", 0.1, 
                  "Test Accuracy over Blocks 7-9", "Condition x Strategy Group")

ggsave(paste('histogram_SC_without_outlier',".jpg"),plot = p ,path = "figure_new",width = 12, height = 6)

t_test(hist_data,PrCorr ~ cond_strategy, 
       comparisons = list(c("SCR_F","SCR_NF")))

#---------------------------------------------------------
# compare the distributions of proportions of recommendations followed and ideal category selections
prop_rec_block <- filter(data,cond == "SCR", phase == "train") %>%
  left_join(cat_prop_diff,by = "subj") %>%
  group_by(cat_strategy_group, subj, block) %>%
  summarize(prop_rec = mean(cat == cat_rec)) %>%
  ungroup() %>%
  mutate(block_fct = as.factor(block))

ggplot(prop_rec_block, aes(x = prop_rec))+
  geom_histogram(aes(fill = cat_strategy_group),  
                 position = position_stack(),
                 binwidth = .1) +
  facet_wrap(~block_fct,ncol = 1)

create_ridge_plot_stacked(prop_rec_block, "prop_rec","block_fct", "cat_strategy_group", 0.1, 
                                          "Proportion of Recommendations Followed", "Block")                
                 

  