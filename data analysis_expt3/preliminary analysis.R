library(tidyverse)
library(gridExtra)
library(ggpubr)
library(boot)
source("../utils/performance-metrics.R")

# # ---- Load the Data ----
setwd("../data_expt3")
files1 = dir(path = "CCP", pattern = ".csv$",full.names = TRUE)
files2 = dir(path = "GCP", pattern = ".csv$",full.names = TRUE)
files3 = dir(path = "GEA", pattern = ".csv$",full.names = TRUE)
files4 = dir(path = "GEE", pattern = ".csv$",full.names = TRUE)
files_mod = dir(path = "data_mod", pattern = ".csv$",full.names = TRUE)
files_extra = dir(path = "extra subjects", pattern = ".csv$",full.names = TRUE)
files = c(files1,files2,files3,files4,files_mod,files_extra) #files_extra
data <- do.call(bind_rows,
                lapply(files, read.csv, fill = T,
                       colClasses = c(webaudio = "character",
                                      webcam = "character",
                                      mobile = "character",
                                      fullscreen = "character",
                                      microphone = "character",
                                      success = "character",
                                      timeout = "character",
                                      corr = "character",
                                      ref_cat_num = "character",
                                      paired_cat_num = "character"
                                      )
                       )
                )
data[is.na(data)] <- NA
setwd("../data analysis_expt3")
saveRDS(data, "data_full.RDS")
data_full <- readRDS("data_full.RDS")

# # ---- select variables of interest ----
data <- data_full %>%
  filter(trialType %in% c("class_response", "cat_selection", "paired_cat_display")) %>%
  select(subjID, condition, stimID, cycle, phase, trial, cat, resp, token, corr, 
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

#---------------------------------------------------------
# test learning curves

learning_curve_df <- data %>%
  filter(phase == "test") %>% 
  group_by(cond,subjID,cycle) %>%
  summarize(Pr_corr = mean(corr)) %>%
  group_by(cond,cycle) %>%
  summarize(Prcorr_mean = mean(Pr_corr),
            # Prcorr_ci = list({
            #   boot_samples <- boot(Pr_corr, 
            #                        function(x,i){median(x[i])}, 
            #                        R=5000, ncpus=8)
            #   boot.ci(boot_samples, type = "basic")$basic[4:5]
            #   }),            
            N_subj = n_distinct(subjID)) %>%
  ungroup()

cond_labels <- c("GEE" = "Given Example\nEven\n", "GEA" = "Given Example\nAdapted\n",
                 "GCP" = "Given Category\nPaired\n", "CCP" = "Choose Category\nPaired\n")
p <- ggplot(data = learning_curve_df,
           aes(y=Prcorr_mean, x=cycle, color = cond)) +
  geom_line(aes(group = cond), linewidth = .7) +
  geom_point(aes(shape = cond),size = 3) +
  # geom_errorbar(aes(ymin = Prcorr_ci_lower, ymax = Prcorr_ci_upper), width = .1) +
  scale_color_manual(values = c("GEE" = "red", "GEA" = "gray", "GCP" = "red","CCP" = "gray")) +
  scale_shape_manual(name = "Condition", values = c(1,2,3,4), labels = cond_labels) +
  # scale_linetype_manual(name = "Condition", values = c("solid","dashed","dotted","dotdash"), labels = cond_labels) + 
  xlab("Learning Cycle") +
  ylab ("Mean Test Accuracy") +
  scale_x_continuous(breaks = 0:4) +
  scale_y_continuous(limits = c(0,1)) +
  theme_pubr(base_size = 36, legend = "none") +
  theme(legend.text = element_text(hjust = 0.5)) + 
  guides(color = "none")


ggsave(paste('test learning curves_demo',".jpg"),plot = p ,path = "../data analysis_expt3/figure",width = 12, height = 9)

#---------------------------------------------------------
# subject_level accuracy distribution
accudist_test_lastCycle <- data %>%
  filter(phase == "test", cycle >= 3) %>%
  group_by(cond,subjID) %>%
  summarize(N_corr = sum(corr)) %>%
  ungroup() %>%
  arrange(cond,N_corr)

# facet_labels <- c("random" = paste0("random ","(N = ",N_subj_R, ")"),
#                   "student_chosen" = paste0("student chosen ","(N = ",N_subj_SC, ")"))

# p_test <- ggplot(data = accudist_test_df,
#                   aes(x=Pr_corr_sub)) +
#           geom_histogram(color = "black",fill = 'white',binwidth = .05) +
#           stat_bin(aes(y=after_stat(count), label=after_stat(count)), geom="text", vjust=-.5,binwidth = .05) +
#           xlab("Classification Accuracy") +
#           ylab ("Number of Subjects") +
#           scale_x_continuous(breaks=seq(.25,1.00,.05),labels =seq(.25,1.00,.05)) +
#           facet_wrap(~cond, labeller = as_labeller(facet_labels)) +
#           theme_bw(base_size = 15) +
#           theme(panel.grid.minor = element_blank())

p <- create_ridge_plot(accudist_test_lastCycle,
                       "N_corr", "cond",1,
                       "Test Accuracy in cycle 4", "Condition")

ggsave(paste('accuracy distribution_test',".jpg"),plot = p ,path = "../data analysis_expt3/figure",width = 16, height = 8)
#-------------------------------------------------------------
# confusion matrix for test phase
trial_count_by_subj_cat <- filter(data,phase == "test") %>%
                           group_by(cond,subjID,cat) %>%
                           summarize(N_trials_cat = n()) %>%
                           ungroup()


confusion_mat_incomplete <- filter(data,phase == "test") %>%
                            group_by(cond,subjID,cat,resp) %>%
                            summarize(count_resp_subj = n()) %>%
                            left_join(trial_count_by_subj_cat, by = c("cond","subjID","cat")) %>%
                            mutate(prop_resp_subj = count_resp_subj/N_trials_cat) %>%
                            group_by(cond,cat,resp) %>%
                            summarize(prop_resp = mean(prop_resp_subj)) %>%
                            ungroup()
                            
                            

var_allcomb <- expand.grid(cond = levels(confusion_mat_incomplete$cond),
                           resp = levels(confusion_mat_incomplete$resp), cat = levels(confusion_mat_incomplete$cat)) %>%
               filter(resp != "", cat != "")

confusion_mat_complete <- var_allcomb %>%
                          left_join(confusion_mat_incomplete, by = c("cond","resp", "cat")) %>%
                          replace_na(list(prop_resp = 0))


p <- ggplot(data = confusion_mat_complete, aes(x = resp, y = cat, fill = prop_resp)) + 
     geom_tile() + 
     geom_text(aes(label = ifelse(prop_resp > .15, round(prop_resp,3), '')), color = "white") +
     scale_fill_gradient(name = "Response Proportion", low = "white", high = "black") + 
     ggtitle("Category Response Matrix") +
     xlab("Response") +
     ylab ("Category") +
     facet_wrap(~cond) +
     theme_bw(base_size = 18) +
     theme(axis.text.x = element_text(angle = 335, hjust = .7, vjust = -1.5),
           axis.ticks.length.x = unit(0.5, "cm"))

ggsave(paste("confusion matrix revised",".jpg"),plot = p ,path = "../figure",width = 12, height = 6)

#-------------------------------------------------------------
# item classification accuracy table
class_table_R <- filter(data,cond == "random",block %in% c(7,8,9),phase == "test") %>%
                 group_by(cat,token) %>%
                 summarize(Pr_corr = mean(corr == 1)) %>%
                 ungroup()

class_table_SC <- filter(data,cond == "student_chosen",block %in% c(7,8,9),phase == "test") %>%
                  group_by(cat,token) %>%
                  summarize(Pr_corr = mean(corr == 1)) %>%
                  ungroup()

write.csv(class_table_R,file = "Item Classification Accuracy_R.csv")
write.csv(class_table_SC,file = "Item Classification Accuracy_SC.csv")

#-------------------------------------------------------------
# read in rock layout data
setwd("../data/TrainStim")
files = dir(pattern = ".txt") 
train_stim_vars = do.call(bind_rows, lapply(files, read.table))
nrows = sapply(files, function(f) nrow(read.table(f)) )
setwd("../../data analysis")

colnames(train_stim_vars) <- c("subj","cat","token")# add "cond" for future
train_stim_vars <- mutate(train_stim_vars,across(c(everything(),-cat),as.integer))
train_stim_vars$cat <- factor(train_stim_vars$cat,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))                           

#-------------------------------------------------------------
# token sampling table by subjects
sampling_table <- filter(data,cond == "student_chosen",phase == "train") %>%
  group_by(subj,cat,token) %>%
  summarize(token_count = n()) %>%
  ungroup() %>%
  left_join(train_stim_vars,.,by = c("subj","cat","token")) %>% # add "cond" for future
  replace_na(list(token_count = 0))
  
write.csv(sampling_table, file = "Item Sampling Pattern.csv")

num_token_by_subj <- sampling_table %>%
  filter(token_count > 3) %>%
  group_by(subj) %>%
  summarize(num_token = n()) %>%
  ungroup() %>%
  arrange(-num_token)

break_vals = min(num_token_by_subj$num_token):max(num_token_by_subj$num_token)
ggplot(num_token_by_subj, aes(x = num_token)) +
  geom_histogram() +
  scale_x_continuous(name = "Number of tokens sampled more than chance",breaks = break_vals)

#------check if tokens are oversampled in a block-------------------------------
# token sampling table by subjects
num_token_oversample_block <- filter(data,cond == "student_chosen",phase == "train") %>%
  mutate(block = factor(block)) %>%
  group_by(subj,block,cat,token) %>%
  summarize(token_count = n()) %>%
  filter(token_count > 1) %>%
  group_by(subj,block) %>%
  summarize(num_token = n()) %>%
  ungroup() 

# break_vals = min(num_token_oversample_block$num_token):max(num_token_oversample_block$num_token)
# ggplot(num_token_oversample_block, aes(x = num_token)) +
#   geom_histogram() +
#   facet_wrap(~block)
#   scale_x_continuous(name = "Number of tokens repeatedly sampled",breaks = break_vals)
  


