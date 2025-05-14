graphics.off()
rm(list=ls())
set.seed(47405)
# Libraries
# library(pkgbuild)
library(tidyverse)
library(brms)
library(gridExtra)
library(ggpubr)
library(ggridges)
library(parallel)
source("../../utils/beta-binom.R")

# Load experimental data
data <- readRDS("../data_full.RDS") #change data set
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

# Load brms fit object
load(file="brms_fit_learnRate_full.Rdata")
fit = fit_full
expose_functions(fit, vectorize = TRUE)
summary(fit)

posterior_learnRate_df <- as_draws_df(fit, variable = "bsp_.+cycle:cond", regex = TRUE) %>%
  rename(sample = .draw) %>%
  rename_with(~paste0(gsub("bsp_.+cond","",.x), "vsGEE"),
              starts_with("bsp")) %>%
  select(!c(.chain, .iteration)) %>%
  pivot_longer(cols = contains("vs"), 
               names_to = "contrast", values_to = "learn_rate") %>%
  mutate(density = "density")

posterior_conc_df <- as_draws_df(fit, variable = "b_.+cond", regex = TRUE) %>%
  rename(sample = .draw) %>%
  rename_with(~paste0(gsub("b_.+cond","",.x), "vsGEE"),
              starts_with("b")) %>%
  select(!c(.chain, .iteration)) %>%
  group_by(sample) %>%
  summarize(GCPvsGEA = GCPvsGEE - GEAvsGEE,
            CCPvsGEA = CCPvsGEE - GEAvsGEE,
            GCPvsGEE = GCPvsGEE,
            CCPvsGEE = CCPvsGEE,
            GEAvsGEE = GEAvsGEE) %>%
  pivot_longer(cols = contains("vs"), 
               names_to = "contrast", values_to = "conc") %>%
  mutate(density = "density") 

posterior_draw_df <- t(posterior_predict(fit)) %>%
  as_tibble() %>% 
  setNames(paste0("sample", 1:ncol(.))) 
save(posterior_draw_df, file = "posterior_draw_df.Rdata")
load("posterior_draw_df.Rdata")  

posterior_samples_quartile_contrast <- fit$data %>%
  bind_cols(posterior_draw_df) %>%
  pivot_longer(cols = starts_with("sample"), names_prefix = "sample",
               names_to = "sample", values_to = "N_corr_pred") %>%
  mutate(sample = as.integer(sample)) %>%
  filter(cycle == 4) %>% #focus on final test performance
  group_by(cond,subjID,sample) %>%
  summarize(PrCorr_obs = sum(N_corr)/sum(N_trials),
            PrCorr_pred = sum(N_corr_pred)/sum(N_trials))%>%
  group_by(cond,sample) %>%
  reframe(
    quartile = c("lq", "m", "uq"),
    Pr_corr_pred = quantile(PrCorr_pred, probs = c(0.25, 0.5, 0.75)),
    Pr_corr_obs = quantile(PrCorr_obs, probs = c(0.25, 0.5, 0.75))
  )  %>%
  group_by(sample,quartile) %>%
  summarize(Pr_corr_pred_GEAvsGEE = Pr_corr_pred[cond == "GEA"] - Pr_corr_pred[cond == "GEE"],
            Pr_corr_obs_GEAvsGEE = Pr_corr_obs[cond == "GEA"] - Pr_corr_obs[cond == "GEE"],
            Pr_corr_pred_GCPvsGEE = Pr_corr_pred[cond == "GCP"] - Pr_corr_pred[cond == "GEE"],
            Pr_corr_obs_GCPvsGEE = Pr_corr_obs[cond == "GCP"] - Pr_corr_obs[cond == "GEE"],
            Pr_corr_pred_CCPvsGEE= Pr_corr_pred[cond == "CCP"] - Pr_corr_pred[cond == "GEE"],
            Pr_corr_obs_CCPvsGEE = Pr_corr_obs[cond == "CCP"] - Pr_corr_obs[cond == "GEE"]) %>%
  ungroup() %>%
  pivot_longer(cols = starts_with("Pr_corr"),
               names_to = c(".value", "contrast"),
               names_pattern = "(Pr_corr_pred|Pr_corr_obs)_(.*)") %>%
  group_by(contrast, quartile) %>%
  reframe(
    bound_type = c("lower","median","upper"),
    Pr_corr_pred_cutoff =  quantile(Pr_corr_pred, c(0.025, 0.5, 0.975))
  ) %>%
  ungroup()

p <- ggplot(posterior_learnRate_df,  
            aes(x = learn_rate, y = density, fill = factor(stat(quantile)))
  ) +
  geom_density_ridges_gradient(scale = 0.8, 
                               calc_ecdf = TRUE, quantiles = c(0.025, 0.975)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("lightgray","darkgray", "lightgray")) +
  guides(fill = "none") +
  scale_x_continuous(name = "Posterior distribution of difference in learning rate coefficient ",
                     breaks = seq(-0.1, 0.4, 0.1)) +
  scale_y_discrete(name = "", expand = expansion(mult = c(0, 0.05))) +
  facet_wrap(~contrast, nrow = 2,
             labeller = as_labeller(function(labels) gsub("vs", " - ", labels))
             ) +
  theme_pubr(base_size = 25) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())
ggsave("posterior distribution of learning rate.png", plot = p, path = "figure/cond_contrast", width = 12, height = 8)

p <- ggplot(posterior_conc_df,  
            aes(x = conc, y = density, fill = factor(stat(quantile)))
  ) +
  geom_density_ridges_gradient(scale = 0.8, 
                               calc_ecdf = TRUE, quantiles = c(0.025, 0.975)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("lightgray","darkgray", "lightgray")) +
  guides(fill = "none") +
  scale_x_continuous(name = "Posterior distribution of difference in concentration coefficient ",
                     breaks = seq(-2, 2, 0.4)) +
  scale_y_discrete(name = "", expand = expansion(mult = c(0, 0.05))) +
  facet_wrap(~contrast, nrow = 3,
             labeller = as_labeller(function(labels) gsub("vs", " - ", labels))
  ) +
  theme_pubr(base_size = 25) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank(),
        axis.text.x = element_text(size = 15))
ggsave("posterior distribution of concentration of test accuracy.png", plot = p, path = "figure/cond_contrast", width = 12, height = 8)

p <- ggplot(filter(posterior_samples_quartile_contrast, cycle == 4), 
            aes(x = Pr_corr_pred, y = quartile, fill = factor(stat(quantile)))
  ) +
  geom_density_ridges_gradient(scale = 0.8, 
                               calc_ecdf = TRUE, quantiles = c(0.025, 0.975)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("lightgray","darkgray", "lightgray")) +
  guides(fill = "none") +
  scale_x_continuous(name = "Difference in posterior distribution of test accuracy",
                     breaks = seq(-0.2, 0.2, 0.05)) +
  scale_y_discrete(name = "", labels = c("lower quartile", "median", "upper quartile"),
                   expand = expansion(mult = c(0, 0.05))) +
  facet_wrap(~contrast, nrow = 2,
             labeller = as_labeller(function(labels) gsub("vs", " - ", labels))) +
  theme_pubr(base_size = 20) +
  theme(axis.text.x = element_text(angle = 315, vjust = -1, hjust = 1))

ggsave("posterior distribution in final test accuracy.png", plot = p, path = "figure/cond_contrast", width = 12, height = 8)
