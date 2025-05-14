# Clean up
graphics.off()
rm(list=ls())
set.seed(47405)
# Libraries
# library(pkgbuild)

library(tidyverse)
library(brms)
library(rlang)
library(gghalves)
library(ggpubr)
library(gridExtra)
library(cmdstanr)

# Source DBDA2E Helpers from OSF Repository
source("https://osf.io/uahfc/download")
source("../../utils/beta-binom.R")

# Load data 
data <- readRDS("../data_mod.RDS") #change data set
epsilon <- 1e-6
df <- data %>%
  filter(trialType %in% c("class_response", "cat_selection"), phase == "test") %>%
  select(subjID, condition, stimID, cycle, cat, resp, corr) %>%
  mutate(cond = factor(condition, labels = c("GEE","GEA","GCP","CCP")),
         condition = NULL,
         stimID = as.integer(stimID),
         cycle_fct = as.factor(cycle),
         cat = as.factor(cat),
         resp = as.factor(resp),
         corr = as.logical(corr)
         ) %>%
  group_by(cond, subjID, cycle, cat) %>%
  summarize(N_corr = sum(corr),
            N_trials = length(corr),
            cycle_fct = unique(cycle_fct))
  
Ntotal <- nrow(df)
Ncond <- n_distinct(df$cond)
Ncat <- n_distinct(df$cat)


load(file="brms_fit_learnRate_full.Rdata") #change fit objects here
fit <- fit_full

#expose pmf and rng functions defined by RSTAN
expose_functions(fit, vectorize = TRUE) #expose pmf and rng functions defined by RSTAN

summary(fit)

## predictive posterior plots by cycle and condition
# violin plots
# conds_tbl <- df %>%
#   distinct(cond, subjID, cycle, cycle_fct, cat, N_trials)


posterior_draws_df <- posterior_predict(fit, ndraws = 30) %>%
  t() %>%
  as_tibble() %>%
  setNames(paste0("pred_draw", 1:30)) 

df_obs_pred <- posterior_draws_df %>%
  bind_cols(fit$data) %>%
  group_by(cond, subjID, cycle, cycle_fct) %>%
  summarize(N_corr = sum(N_corr),
            across(starts_with("pred_draw"), sum, .names = 'N_corr_{.col}'),
            N_trials = sum(N_trials),
            across(starts_with("pred_draw"), ~sum(.x)/N_trials, .names = 'Pr_corr_{.col}'),
            Pr_corr = N_corr/N_trials) %>%
  group_by(cond, subjID) %>%
  summarize(Pr_corr_change = Pr_corr[cycle == 4] - Pr_corr[cycle == 0],
            across(starts_with("Pr_corr_pred_draw"), ~.x[cycle == 4]-.x[cycle == 0], .names = '{.col}_change')
            ) 
df_obs_summary <- df_obs_pred %>%
  group_by(cond) %>%
  summarize(PrCorr_change_median = median(Pr_corr_change),
            PrCorr_change_sd = sd(Pr_corr_change))
  
pred_col_names <- grep("^Pr_corr_pred_draw", colnames(df_obs_pred), value = TRUE)
cond_labels <- c("GEE" = "Example Sampling\nEqual", "GEA" = "Example Sampling\nAdaptive",
                 "GCP" = "Paired Category Adaptive\n+ Example Sampling Even", "CCP" = "Paired Category Active\n+ Example Sampling Equal")

p <- ggplot(data = df_obs_pred, mapping = aes(x = cond, fill = cond)) +
  geom_half_violin(
    aes(y = Pr_corr_change, color = cond),
    side = "l",
    alpha = 1,
    bw = 2/58, width = 1, scale = "area",
    trim = T) +
  geom_dotplot(aes(y = Pr_corr_change),
               binaxis = "y", method = "histodot", stackdir = "down",
               fill = NA, color = "darkslategray",stroke = 1.5,
               binwidth = 1/58, dotsize = 1, stackratio = 1.3) +
  geom_segment(mapping = aes(x = as.numeric(cond) - 0.1, xend = as.numeric(cond),
                             y = PrCorr_change_median, yend = PrCorr_change_median),
               data = df_obs_summary) +
  lapply(pred_col_names,
         function (col_name){
           geom_half_violin(
             aes(y = !!sym(col_name)),
             side = "r",
             color = "lightgrey", alpha = 0.02, 
             width = 1, bw = 4/58, scale = "area",
             trim = F)
   }) +
  labs(x = "", y = "Change in Test Accuracy") +
  scale_x_discrete(labels = cond_labels) +
  scale_y_continuous(breaks = seq(-0.2,1,0.2), limits = c(-0.2,1)) +
  # facet_wrap(~ cycle, nrow = 2) +
  theme_pubr(base_size = 20) +
  theme(axis.text.x = element_text(face = "bold")) +
  guides(fill = "none", color = "none") 

ggsave("posterior predictions violin.png", plot = p, path = "figure/model prediction", width = 18, height = 6)


#--------------------------------------------------
# histograms
# pred_samples <- posterior_predict(fit)
# sample_indices <- sample(1:nrow(pred_samples), 30)
# pred_samples <- t(pred_samples[sample_indices,])
# colname_combs <- expand.grid(num = 1:30, name = "N_corr_pred")
# colnames(pred_samples) <- paste(colname_combs$name, colname_combs$num, sep = "_")
# df <- bind_cols(df, as.data.frame(pred_samples)) # re-define df for debugging
# 
# 
# pred_plot_list <- list()
# cond_levels <- levels(df$cond)
# cycle_levels <- unique(df$cycle)
# cond_names <- c("GEE", "GEA", "GCP", "CCP")
# N_subj <- group_by(df, cond) %>%
#           summarize(n_subj = n_distinct(subjID))
# 
# pred_col_names <- grep("^N_corr_pred", colnames(df), value = TRUE)
# plot_name_indices <- c(1,2,3,4)
# plot_order_indices <- c(1,3,2,4)
# # omega_col_names <- grep("^omega", colnames(df), value = TRUE)
# # kappa_col_names <- grep("^kappa", colnames(df), value = TRUE)
# for (icycle in 1:length(cycle_levels)){
#   for (icond in 1:length(cond_levels)) {
#     plot_name_idx <- plot_name_indices[icond]
#     plot_order_idx <- plot_order_indices[icond]
#     data_main <-
#       filter(df, cond == cond_levels[plot_name_idx], cycle == cycle_levels[icycle]) %>%
#       group_by(subjID) %>%
#       summarize(across(starts_with("N_corr"), sum, .names = "{.col}")) %>%
#       ungroup()
#     # data_dpars <-
#     #   filter(df, `E/N vs. A` == x1_var_levels[x1_i], `G vs. C` == x2_var_levels[x2_i]) %>%
#     #   group_by(cat) %>%
#     #   summarize(across(starts_with(c("omega","kappa")), unique, .names = "{.col}")) %>%
#     #   ungroup()
#     # print(summary(data_dpars))
#     pred_plot_list[[plot_order_idx]] <- 
#       ggplot() + 
#       stat_bin(aes(x=N_corr, y=after_stat(density)), data=data_main, bins=49, color="black", fill="white") +
#       scale_x_continuous(breaks=seq(0,48,2),labels = seq(0,48,2), limits = c(0,49)) +
#       scale_y_continuous(expand = c(0,0)) + 
#       lapply(pred_col_names,
#              function (col_name){
#                stat_density(data = data_main, aes(x = !!sym(col_name), y = after_stat(density)),
#                             geom = "line", color = "#BEBEBE", alpha = 0.7)
#              }) +
#       # mapply(function(omega_col_name,kappa_col_name) {
#       #         omega <- data_dpars[[omega_col_name]]
#       #         kappa <- data_dpars[[kappa_col_name]]
#       #         stat_function(
#       #           fun = function(x){
#       #             dbetabinom_sum(x, omega, kappa, 6)
#       #           },
#       #           xlim = c(0,48), n = 49,
#       #           colour = "#BEBEBE", alpha = 0.7)
#       #       },
#       #       omega_col_names,kappa_col_names) +
#       xlab("") +
#       ylab("Density") + 
#       ggtitle(paste0(cond_names[plot_name_idx], "\n", "N_subj = ", N_subj$n_subj[plot_name_idx])) + 
#       theme_pubr(base_size = 20) +
#       theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
#             axis.ticks.y = element_blank(), axis.text.y = element_blank(), 
#             axis.text.x = element_text(angle = 315, vjust = -0.5),
#             panel.background = element_blank(), axis.line = element_line(colour = "black"),
#             plot.title = element_text(hjust = 0.5))
#     
#   }
#   p <- grid.arrange(grobs = pred_plot_list, nrow=2, bottom = "Number of Correct Responses over Blocks 7-9") 
#   filename <- paste0("posterior predictive plot_", cycle_levels[icycle], ".png")
#   ggsave(filename, plot = p, path = "figure/model prediction", width = 11, height = 9)
# }
# 
# 
