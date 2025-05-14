library(tidyverse)
library(gridExtra)
library(magrittr)
library(ggpubr)
source("../utils/performance-metrics.R")

# # ---- Load the Data ----
# setwd("../data")
# files = dir(pattern = ".txt$") #revised.txt$
# data = do.call(bind_rows, lapply(files, read.table, fill = T))
# data[is.na(data)] <- NA
# nrows = sapply(files, function(f) nrow(read.table(f, fill = T)))
# setwd("../data analysis")
# 
# # ---- define the data types ----
# colnames(data) = c("cond","subj","block","phase","trial","cat","token","resp","corr","rt_decision","rt_selection")
# file_version_idx = ifelse(grepl("revised",files),2,1)
# data$version = factor(rep(file_version_idx,each = nrows),labels = c("before","after"))
# data$cond = factor(data$cond,labels = c("random","student_chosen"))
# data$subj = as.integer(data$subj)
# data$block = as.integer(data$block)
# data$phase = factor(data$phase,labels = c("train","test"))
# data$trial = as.integer(data$trial)
# data$cat = factor(data$cat,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
# data$resp = factor(data$resp,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
# data$corr = as.integer(data$corr)
# 
# #remove outlier
# data = filter(data,!(cond == "student_chosen" & subj %in% c(81,118)))

data <- readRDS("data.RDS")
#---------------------------------------------------------
# test learning curve
learning_curve_df <- data %>%
  filter(phase == "test") %>% #
  mutate(cond = factor(cond, labels = c("GEE", "CE"))) %>%
  group_by(version,cond,subj,block) %>%
  summarize(Pr_corr_sub = mean(corr)) %>%
  ungroup() %>%
  group_by(version,cond,block) %>%
  summarize(Pr_corr_mean = mean(Pr_corr_sub),
            N_subj = n_distinct(subj))

# N_subj_R <- unique(learning_curve_df$N_subj[learning_curve_df$cond == "GEE"])
# N_subj_SC <- unique(learning_curve_df$N_subj[learning_curve_df$cond == "CE"])

cond_labels <- c("GEE" = "Given Example Even", "CE" = "Choose Example")
version_labels <- c("before" = "Expt 1a", "after" = "Expt 1b")
p <- ggplot(data = filter(learning_curve_df, version == "after"),
           aes(y=Pr_corr_mean, x=block)) +
  geom_line(aes(linetype = cond),linewidth = .7) +
  geom_point(aes(shape = cond),size = 3) +
  # geom_errorbar(aes(ymin = Pr_corr - SEM, ymax = Pr_corr + SEM), width = .1) +
  scale_shape_manual(name = "Condition", values = c(1,2,3), labels = cond_labels) +
  scale_linetype_manual(name = "Condition", values = c("solid","dashed","dotted"), labels = cond_labels) + #only two values are used
  xlab("Block") +
  ylab ("Mean Test Accuracy") +
  # facet_grid(~version, labeller = labeller(version = version_labels)) +
  # ggtitle(paste0("N_subj_R = ",N_subj_R,", ","N_subj_SC = ", N_subj_SC)) +
  scale_x_continuous(breaks = 1:10) +
  scale_y_continuous(limits = c(0,1)) +
  theme_pubr(base_size = 36, legend = "right") +
  theme(legend.text = element_text(hjust = 0.5),
        legend.position = "none")



ggsave(paste('test learning curve after',".jpg"),plot = p ,path = "figure",width = 12, height = 9)
#---------------------------------------------------------
cond_labels <- c("GEE" = "Given Example Even", "CE" = "Choose Example")
version_labels <- c("before" = "Expt 1a", "after" = "Expt 1b")
# selection proportions across categories for training
training_prop_select_df <- data %>%
  filter(phase == "train") %>% 
  group_by(version,cond) %>%
  mutate(n_trial = n()) %>%
  group_by(version,cond,cat) %>%
  summarize(prop_cat = n()/n_trial[1]) %>%
  ungroup() 

p <- ggplot(training_prop_select_df,
            aes(x = cat, y = prop_cat, fill = cond)) +
  geom_col(position = "dodge") +
  scale_fill_manual(name = "Condition", values = c("#F8766D","#00BFC4"),labels = cond_labels) +
  facet_grid(~ version, labeller = labeller(version = version_labels)) +
  xlab("Category") +
  ylab("Proportion of Category Examples Selected") +
  coord_flip() +
  theme_pubr(base_size = 20, legend = "bottom") 
ggsave(paste('cat selection prop',".jpg"),plot = p ,path = "figure",width = 12, height = 6)

  

# final test accuracies across categories 
training_accu_cat_df <- data %>%
  filter(phase == "test", block %in% 7:9) %>% 
  group_by(version,cond, cat) %>%
  summarize(Pr_corr = mean(corr)) %>%
  ungroup() 

p <- ggplot(training_accu_cat_df,
            aes(x = cat, y = Pr_corr, fill = cond)) +
  geom_col(position = "dodge") +
  scale_fill_manual(name = "Condition", values = c("#F8766D","#00BFC4"),labels = cond_labels) +
  facet_grid(~ version, labeller = labeller(version = version_labels)) +
  xlab("Category") +
  ylab("Mean Classification Accuracy over Test Blocks 7-9") +
  coord_flip() +
  theme_pubr(base_size = 20, legend = "bottom") 
ggsave(paste('final test accu cat',".jpg"),plot = p ,path = "figure",width = 12, height = 6)

#---------------------------------------------------------
# subject_level accuracy distribution
version_cond_df <- expand_grid(levels(data$version),levels(data$cond))
version_cond_levels <- apply(version_cond_df,1,function(row){
                                                  paste(row[1],row[2],sep = ": ")
                                                 })
accudist_test_df = data %>%
                   filter(phase == "test", block %in% 7:9) %>%
                   unite("version_cond",version,cond, sep = ": ") %>%
                   mutate(version_cond = factor(version_cond, levels = version_cond_levels)) %>%
                   group_by(version_cond,subj) %>%
                   summarize(PrCorr_test = mean(corr == 1)) %>%
                   ungroup() 

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

p_test <- create_ridge_plot(accudist_test_df,
                            "PrCorr_test", "version_cond",.05,
                            "Test Accuracy over Blocks 7-9", "Version x Condition")

ggsave(paste('accuracy distribution_test',".jpg"),plot = p_test ,path = "../figure",width = 16, height = 8)
#-------------------------------------------------------------
# confusion matrix for test phase
trial_count_by_subj_cat <- filter(data,phase == "test") %>%
                           group_by(cond,subj,cat) %>%
                           summarize(N_trials_cat = n()) %>%
                           ungroup()


confusion_mat_incomplete <- filter(data,phase == "test") %>%
                            group_by(cond,subj,cat,resp) %>%
                            summarize(count_resp_subj = n()) %>%
                            left_join(trial_count_by_subj_cat, by = c("cond","subj","cat")) %>%
                            mutate(prop_resp_subj = count_resp_subj/N_trials_cat) %>%
                            group_by(cond,cat,resp) %>%
                            summarize(prop_resp = mean(prop_resp_subj))
                            
                            

var_allcomb <- expand.grid(cond = unique(confusion_mat_incomplete$cond),
                           resp = unique(confusion_mat_incomplete$resp), cat = unique(confusion_mat_incomplete$cat))

confusion_mat_complete <- var_allcomb %>%
                          left_join(confusion_mat_incomplete, by = c("cond","resp", "cat")) %>%
                          replace_na(list(prop_resp = 0))


p = ggplot(data = confusion_mat_complete, aes(x = resp, y = cat, fill = prop_resp)) + 
    geom_tile() + 
    geom_text(aes(label = ifelse(prop_resp > .15, round(prop_resp,3), '')), color = "white") +
    scale_fill_gradient(name = "Response Proportion", low = "white", high = "black") + 
    ggtitle("Category Response Matrix") +
    xlab("Response") +
    ylab ("Category") +
    facet_wrap(~cond, labeller = as_labeller(facet_labels)) +
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
  


