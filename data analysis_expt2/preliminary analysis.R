library(tidyverse)
library(ggridges)
library(ggpubr)


# ---- Load the Data ----
setwd("../data_expt2")
# survey_file <- dir(pattern = "survey_data.csv")
files <- dir(pattern = "LearnStrategy.*\\.csv$") 
data <- do.call(bind_rows, lapply(files, read.csv, nrows = 290)) #skip = 1, nrows = 289
grid_table <- do.call(bind_rows, lapply(files, read.csv, header = F,skip = 292, nrows = 48)) %>%
              select(c(1:2,18:21)) %>%
              setNames(c("subj","cond","cat","token","row","col"))
# survey_data1 <- read.csv("survey_data1.csv")
# survey_data2 <- read.csv("survey_data2.csv")
setwd("../data analysis_expt2")

# setwd("../data_expt2/pilot")
# survey_file <- dir(pattern = "survey_data.csv")
# files_pilot <- dir(pattern = "LearnStrategy.*\\.csv$") 
# data_pilot <- do.call(bind_rows, lapply(files_pilot, read.csv, skip = 1, nrows = 289)) 
# # survey_data1 <- read.csv("survey_data1.csv")
# # survey_data2 <- read.csv("survey_data2.csv")
# setwd("../../data analysis_expt2")

# survey_data_cleaned1 <- survey_data1 %>%
#                         select(subj,cond,score)
# survey_data_cleaned2 <- select(survey_data2, participant, condition, Q1, SC0) %>%
#                        rename(subj = participant, cond = condition, score = SC0, strategy = Q1) %>%
#                        filter(!is.na(subj) & !is.na(score)) %>%
#                        mutate(subj = subj + max(survey_data_cleaned1$subj)) %>%
#                        mutate(strategy = lapply(str_split(strategy, ","), function(x) {
#                               if (length(x) == 1 && x == "") numeric(0) else as.numeric(x)
#                               })
#                               )
# survey_data_cleaned <- full_join(survey_data_cleaned1,survey_data_cleaned2,by = join_by(subj, cond)) %>%
#                        mutate(score = coalesce(score.x,score.y),.keep = "unused")
# data_pilot_cleaned <- select(data_pilot,participant,condition,block, phase, trial, cat, token, row, col, resp, corr, t_select, t_resp) %>%
#                       rename(subj = participant,cond = condition) %>%
#                       filter(!is.na(trial) & !is.na(subj)) %>%
#                       mutate(subj = as.character(subj),
#                              cond = paste0('sona_',cond),
#                              resp = lead(resp)) #data correction
data <- select(data,participant,condition,block, phase, trial, cat, token, cat_rec, token_rec, row, col, resp, corr, t_select, t_resp) %>%
               rename(subj = participant,cond = condition) %>%
               filter(!is.na(trial) & !is.na(subj)) 
              # mutate(dataset_cond = paste0('prolific_',cond)) 
              # bind_rows(data_pilot_cleaned)



# ---- data cleaning ----------------------------------------------
data$phase = factor(data$phase,labels = c("train","test"))
data$cat = factor(data$cat,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
data$resp = factor(data$resp,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
data$cat_rec = factor(data$cat_rec,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
data$cond = fct_recode(data$cond, "GEE" = "TCN", "GEA" = "TCR", "CE" = "SCN", "CEA" = "SCR")
# dataset_cond_levels = sprintf("%s_%s",rep("prolific",each=4),c("TCN","TCR","SCN","SCR"))
# data$dataset_cond = factor(data$dataset_cond,levels = dataset_cond_levels)
# data <- data %>%
#         separate(dataset_cond, c("dataset","cond"), sep = "_") %>%
#         mutate(cond = factor(cond, levels = c("TCN","TCR","SCN","SCR")))

#-----------------------------------------------------------------------------------
# saveRDS(data,"prolific data.RDS")
data <- readRDS("prolific data.RDS")
# valid_subj_accu_df <- data %>%
#                       filter(phase == "test", block %in% 7:9) %>%
#                       group_by(cond,subj) %>%
#                       summarize(Pr_corr_test = mean(corr == 1)) %>%
#                       group_by(cond) %>%
#                       filter(percent_rank(Pr_corr_test) > .15) %>%
#                       ungroup()  
# 
# data_cleaned <- data %>%
#                 semi_join(valid_subj_accu_df,by = "subj")



#---------------------------------------------------------
# test learning curves
learning_curve_df <- data %>%
                     filter(phase == "test") %>%
                     group_by(cond,subj,block) %>%
                     summarize(Pr_corr = mean(corr)) %>%
                     group_by(cond,block) %>%
                     summarize(Prcorr_mean = mean(Pr_corr),
                               # Prcorr_ci = list({
                               # boot_samples <- boot(Pr_corr, 
                               #     function(x,i){mean(x[i])}, 
                               #     R=5000, ncpus=8)
                               # boot.ci(boot_samples, type = "basic")$basic[4:5]}
                               # ),            
                               N_subj = n_distinct(subj)) %>%
                     # rowwise() %>%
                     # mutate(Prcorr_ci_lower = Prcorr_ci[1],
                     #        Prcorr_ci_upper = Prcorr_ci[2]) %>%
                     ungroup()
                    

cond_labels <- c("GEE" = "Given Example\nEven\n", "CE" = "Choose Example\n",
                 "GEA" = "Given Example\nAdapted\n", "CEA" = "Choose Example\nAdaptive\n")
p <- ggplot(data = learning_curve_df,
            aes(y=Prcorr_mean, x=block, color = cond)) +
     geom_line(aes(group = cond),linewidth = .7) +
     geom_point(aes(shape = cond),size = 3) +
     # geom_errorbar(aes(ymin = Prcorr_ci_lower, ymax = Prcorr_ci_upper), width = .1) +
     scale_color_manual(values = c("GEE" = "red", "GEA" = "gray", "CE" = "red","CEA" = "gray")) +
     scale_shape_manual(name = "Condition", values = c(1,2,3,4), labels = cond_labels) +
     scale_linetype_manual(name = "Condition", values = c("solid","dashed","dotted","dotdash"), labels = cond_labels) +
     # facet_wrap(~ dataset) +
     xlab("Block") +
     ylab ("Mean Test Accuracy") +
     # ggtitle(paste0("N_subj_TCN = ",N_subj_TCN,", ","N_subj_TCR = ", N_subj_TCR,", ",
     #                "N_subj_SCN = ", N_subj_SCN,", ","N_subj_SCR = ", N_subj_SCR)) +
     scale_x_continuous(breaks = 1:9) +
     scale_y_continuous(limits = c(0.4,0.9)) +
     theme_pubr(base_size = 36, legend = "right") +
     theme(legend.text = element_text(hjust = 0.5),
           legend.position = "none") 
     # guides(color = "none")


ggsave(paste0('test learning curves_demo',".jpg"),plot = p ,path = "figure",width = 12, height = 9)

#---------------------------------------------------------
# subject test accuracy distribution
all_subj_accu_df <- data %>%
                    filter(phase == "test", block %in% 7:9) %>%
                    group_by(cond,subj) %>%
                    summarize(Pr_corr_test = mean(corr == 1)) %>%
                    ungroup() 

p_test <- create_ridge_plot_filtered(all_subj_accu_df, valid_subj_accu_df,
                                     "Pr_corr_test","cond",
                                     "Test Accuracy over Blocks 7-9", "Condition",
                                     bin_width = .05, avg_fun = median)

ggsave(paste('accuracy distribution test block79 without outlier',".jpg"),plot = p_test ,path = "figure_new",width = 12, height = 8)


-------------------------------------
# survey score correlation with test performance
accudist_test_df <- read.csv("test accuracy1.csv") %>%
                     bind_rows(accudist_test_df2)

survey_corr_df <- inner_join(accudist_test_df,survey_data_cleaned) %>%
                  group_by(cond) %>%
                  mutate(cor_coef = cor(score, Pr_corr_sub)) %>%
                  ungroup()


# Create the scatter plot with the line of best fit
p <- ggplot(survey_corr_df, aes(x = score, y = Pr_corr_sub)) +
  geom_point() +  
  geom_smooth(method = "lm", se = FALSE, color = "red") + 
  ggtitle("") +
  xlab("survey score") +
  ylab("Test Accuracy") + 
  facet_wrap(~cond) +
  theme_pubr() +
  geom_text(aes(label = sprintf("R = %.2f", cor_coef)), 
            x = 40, y = 0.9, 
            size = 4, color = "black", 
            data = ~ distinct(.x, cond, cor_coef, .keep_all = TRUE))

ggsave(paste('survey score correlation',".jpg"),plot = p ,path = "figure",width = 12, height = 12)




#-------------------------------------------------------------
# confusion matrix for test phase
trial_count_by_subj_cat <- filter(data_cleaned,phase == "test") %>%
                           group_by(cond,subj,cat) %>%
                           summarize(N_trials_cat = n()) %>%
                           ungroup()


confusion_mat_incomplete <- filter(data_cleaned,phase == "test") %>%
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

ggsave(paste("confusion matrix",".jpg"),plot = p ,path = "figure",width = 12, height = 6)

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
  


