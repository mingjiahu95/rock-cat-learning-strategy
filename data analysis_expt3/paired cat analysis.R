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
         ) %>%
  filter(cond %in% c("GCP", "CCP"))

#---------------------------------------------------------
cat_names <- c("Andesite","Basalt","Diorite","Gabbro", "Obsidian","Pegmatite","Peridotite", "Pumice")
num_cats <- length(cat_names)
# prepare data set
cat_selected_by_subj <- data %>%
  filter(trialType == "cat_selection") %>%
  mutate(ref_cat = factor(ref_cat_num, labels = cat_names),
         paired_cat = factor(paired_cat_num, labels = cat_names),
         ref_cat = as.character(ref_cat),
         paired_cat = as.character(paired_cat)) %>%
  group_by(cond, subjID, cycle) %>%
  summarize(cats_selected = list(unique(c(ref_cat,paired_cat))),
            pairs_selected = list({
              unique_pairs <- unique(data.frame(cat1 = c(ref_cat,paired_cat), 
                                                cat2 = c(paired_cat,ref_cat)
                                                )
                                     )
              split(unique_pairs$cat1, unique_pairs$cat2)
            }),
            ncat_selected = length(cats_selected[[1]])
  )

test_accu_by_subj <- data %>%
  filter(phase == "test", cycle > 0) %>%
  select(cond, subjID, cycle, trial, cat, resp, corr) %>%
  left_join(cat_selected_by_subj, by = c("cond", "subjID", "cycle"))

performance_metrics_df <- test_accu_by_subj %>%
                          rowwise() %>%
                          mutate(cat_char = as.character(cat),
                                 Pr_corr_baseline = 1/num_cats,
                                 Pr_incorr_pair_baseline = length(pairs_selected[[cat_char]])/num_cats,
                                 Pr_incorr_not_pair_baseline = 1 - Pr_corr_baseline - Pr_incorr_pair_baseline,
                                 cat_selected_bool = cat %in% cats_selected,
                                 pair_selected_bool = cat %in% cats_selected &&
                                                      resp %in% pairs_selected[[cat_char]]
                                 ) %>%
                          group_by(cond, subjID, cycle) %>%
                          summarize(N_trial_cat_selected = sum(cat %in% cats_selected[[1]]),
                                    N_trial_cat_unselected = n() - N_trial_cat_selected,
                                    N_trial_corr_cat_selected = sum(corr == TRUE & cat %in% cats_selected[[1]]),
                                    N_trial_corr_cat_unselected = sum(corr == TRUE & !cat %in% cats_selected[[1]]),
                                    Pr_corr_cat_selected = N_trial_corr_cat_selected/N_trial_cat_selected,
                                    Pr_corr_cat_unselected = N_trial_corr_cat_unselected/N_trial_cat_unselected,
                                    # diff_corr_cat_selected = Pr_corr_cat_selected_per_cat - Pr_corr_cat_unselected_per_cat,
                                    
                                    Pr_trial_corr_baseline = mean(Pr_corr_baseline[cat_selected_bool]),
                                    Pr_trial_incorr_pair_baseline = mean(Pr_incorr_pair_baseline[cat_selected_bool]),
                                    Pr_trial_incorr_not_pair_baseline = mean(Pr_incorr_not_pair_baseline[cat_selected_bool]),
                                    Pr_trial_corr = sum(corr & cat_selected_bool)/sum(cat_selected_bool),
                                    Pr_trial_incorr_pair = sum(!corr & pair_selected_bool)/sum(cat_selected_bool),
                                    Pr_trial_incorr_not_pair = 1 - Pr_trial_corr - Pr_trial_incorr_pair
                                    ) 
                          
#-------------------------data visualization----------------------
# compare the number of incorrect trials where the trained category pairs are confused
# by conditions and cycles
resp_cat_selected_data <- performance_metrics_df %>%
  gather(key = "resp_type", value = "Pr_resp", Pr_trial_corr, Pr_trial_incorr_pair,Pr_trial_incorr_not_pair,
         factor_key = TRUE) %>%
  mutate(resp_type = recode_factor(resp_type,
                                   'Pr_trial_corr' = 'correct',
                                   'Pr_trial_incorr_pair' = 'incorrect-paired',
                                   'Pr_trial_incorr_not_pair' = 'incorrect-not-paired')) %>%
  select(cond, subjID, cycle, resp_type, Pr_resp)

n_cycle = n_distinct(cat_selection_data$cycle)
resp_cat_selected_baseline <- performance_metrics_df %>%
  gather(key = "resp_type", value = "Pr_resp", Pr_trial_corr_baseline, Pr_trial_incorr_pair_baseline,Pr_trial_incorr_not_pair_baseline,
         factor_key = TRUE) %>%
  mutate(resp_type = recode_factor(resp_type,
                                   'Pr_trial_corr_baseline' = 'correct',
                                   'Pr_trial_incorr_pair_baseline' = 'incorrect-paired',
                                   'Pr_trial_incorr_not_pair_baseline' = 'incorrect-not-paired')) %>%
  group_by(cond, cycle, resp_type) %>%
  summarize(Pr_resp = mean(Pr_resp)) %>%
  arrange(cond, cycle, desc(resp_type)) %>%
  mutate(Pr_resp_cum = cumsum(Pr_resp),
         x_pos = as.integer(resp_type) - 0.9/2 + 0.9/n_cycle * (cycle - 1),
         xend_pos = x_pos + 0.9/n_cycle)

resp_cat_selected_stats <- resp_cat_selected_data %>%
  group_by(cond, cycle, resp_type) %>%
  summarize(
    Pr_resp_mean = median(Pr_resp),
    Pr_resp_mean_ci = list(boot.ci(boot(
      Pr_resp,
      function(x, i) {median(x[i])},
      R = 5000, ncpus = 8), type = "basic")$basic[4:5])
  ) %>%
  rowwise() %>%
  mutate(
    Pr_resp_mean_ci_lower = Pr_resp_mean_ci[1],
    Pr_resp_mean_ci_upper = Pr_resp_mean_ci[2]
    )

light_colors <- c(
  "correct" = "#F69898",          # light red
  "incorrect-paired" = "#98F698", # light green
  "incorrect-not-paired" = "#9898F6" # light blue
)

# Define fill colors as darker shades of the above hues
dark_colors <- c(
  "correct" = "#C20000",          # darker red
  "incorrect-paired" = "#00C200", # darker green
  "incorrect-not-paired" = "#0000C2" # darker blue
)

# stacked bar plots
# p <- ggplot(resp_cat_selected_stats, aes(x = cycle, y = Pr_resp_mean, fill = resp_type, color = resp_type)) +
#      geom_col(position = "stack", width = 0.5) +
#      geom_segment(data = resp_cat_selected_baseline, 
#                   aes(x = cycle - 0.25, 
#                       xend = cycle + 0.25, 
#                       y = Pr_resp_cum, 
#                       yend = Pr_resp_cum),
#                linetype = "dashed") +
#      scale_fill_manual(values = light_colors, limits = names(light_colors)) +
#      scale_color_manual(values = dark_colors, limits = names(dark_colors)) +
#      facet_wrap(~cond)

# dodged bar plots
facet_labels <- c("GCP" = "Category Pair Given", "CCP" = "Catergory Pair Chosen")

p <- ggplot(resp_cat_selected_data, aes(x = resp_type, y = Pr_resp, 
                                         color = resp_type, group = cycle)) +
     geom_col(data = resp_cat_selected_stats, 
              mapping = aes(y = Pr_resp_mean),
              position = position_dodge(width = 0.9), 
              width = 0.9, fill = "white") +
     geom_errorbar(data = resp_cat_selected_stats,
                   mapping = aes(y = Pr_resp_mean, ymax = Pr_resp_mean_ci_upper, ymin = Pr_resp_mean_ci_lower),
                   position = position_dodge(width = 0.9), width = 0.5) +
     geom_point(position = position_jitterdodge(jitter.width = 0.4, dodge.width = 0.9), size = 0.6) +
     geom_segment(data = resp_cat_selected_baseline,
                  mapping = aes(x = x_pos, xend = xend_pos, 
                                yend = Pr_resp),
                  linetype = "solid", linewidth = 0.8, color = "black") +
     scale_color_manual(values = dark_colors, limits = names(dark_colors)) +
     # scale_y_continuous(breaks = round(seq(0,1,length.out = 7),3)) +
     facet_wrap(~cond, labeller = as_labeller(facet_labels)) +
     geom_text(data = resp_cat_selected_baseline, 
               mapping = aes(x = (x_pos + xend_pos)/2, label = cycle),
               y = -0.02,  # Adjust y-position as needed
               color = "black", size = 4) +
     xlab("Response Type x Cycle") +
     ylab("Proportion of Response") +
     guides(color = "none") +
     theme_pubr() +
     theme(strip.text = element_text(size = 14))

ggsave("Pr_corr_cat_selection.png", plot = p , path = "figure/paired cat",width = 9, height = 6)

# compare the proportions of correct responses for selected and unselected categories
# by conditions and cycles
cat_selection_data <- performance_metrics_df %>%
  gather(key = "cat_type", value = "Pr_corr", Pr_corr_cat_selected, Pr_corr_cat_unselected,
         factor_key = TRUE) %>%
  mutate(cat_type = recode_factor(cat_type,
                                    'Pr_corr_cat_selected' = 'cat-selected',
                                    'Pr_corr_cat_unselected' = 'cat-unselected')) %>%
  select(cond, subjID, cycle, cat_type, Pr_corr) 

n_cycle = n_distinct(cat_selection_data$cycle)
cat_selection_stats <- cat_selection_data %>%
  group_by(cond, cycle, cat_type) %>%
  summarize(
    Pr_corr_median = median(Pr_corr),
    Pr_corr_median_ci = list(boot.ci(boot(
      Pr_corr,
      function(x, i) {median(x[i])},
      R = 5000, ncpus = 8), type = "basic")$basic[4:5])) %>%
  rowwise() %>%
  mutate(
    Pr_corr_median_ci_lower = Pr_corr_median_ci[1],
    Pr_corr_median_ci_upper = Pr_corr_median_ci[2],
    cat_type_int = as.integer(cat_type),
    x_pos = as.integer(cat_type) - 0.9/2 + 0.9/n_cycle * (cycle - 1),
    xend_pos = x_pos + 0.9/n_cycle)

p <- ggplot(cat_selection_data, aes(x = cat_type, y = Pr_corr, 
                                    color = cat_type, group = cycle)
            ) +
     geom_col(data = cat_selection_stats, mapping = aes(y = Pr_corr_median),
              position = position_dodge(width = 0.9), 
              width = 0.9, color = "black", fill = "white") +
     geom_errorbar(data = cat_selection_stats, mapping = aes(y = Pr_corr_median,
                                                            ymax = Pr_corr_median_ci_upper,
                                                            ymin = Pr_corr_median_ci_lower),
                   position = position_dodge(width = 0.9), 
                   width = 0.4, color = "black") +
     geom_point(position = position_jitterdodge(jitter.width = 0.3, dodge.width = 0.9), size = 1) +
     geom_text(data = cat_selection_stats, 
               mapping = aes(x = (x_pos + xend_pos)/2, label = cycle),
               y = -0.02,  # Adjust y-position as needed
               color = "black", size = 4) +
     facet_wrap(~cond, labeller = as_labeller(facet_labels)) +
     xlab("Category Type x Cycle") +
     ylab("Proportion of Correct Response") +
     guides(color = "none") +
     theme_pubr() +
     theme(strip.text = element_text(size = 14))

ggsave("Pr_resp_cat_selected.png", plot = p , path = "figure/paired cat",width = 9, height = 6)



