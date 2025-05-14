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
epsilon <- 1e-6
df <- readRDS("../prolific data.RDS") %>% 
  filter(phase == "test") %>%
  mutate(subj = factor(subj),
         cond = recode_factor(cond, "random" = "GEE" , "student_chosen" = "CE"),
         block_set = case_match(block,
                                1:3 ~ 1,4:6 ~ 2,7:9 ~ 3)
  ) %>%
  group_by(cond, subj, block_set, cat) %>%
  summarize(N_trials = n(),
            N_corr = sum(corr)
  ) %>%
  ungroup() %>%
  mutate(block_set_fct = factor(block_set, labels = c("1-3", "4-6", "7-9")))

# load brms fit objects
load(file = "brms_fit_objects.Rdata")
fit = fit_object[[3]]
expose_functions(fit_object[[1]], vectorize = TRUE)
summary(fit)

posterior_draw_df <- t(posterior_predict(fit)) %>% #posterior_epred
  as_tibble() %>% 
  setNames(paste0("sample", 1:ncol(.))) 


posterior_samples_quartile_contrast <- fit$data %>%
  bind_cols(posterior_draw_df) %>%
  pivot_longer(cols = starts_with("sample"), names_prefix = "sample",
               names_to = "sample", values_to = "N_corr_pred") %>%
  mutate(sample = as.integer(sample)) %>%
  group_by(cond,subj,sample) %>%
  summarize(PrCorr_obs = sum(N_corr)/sum(N_trials),
            PrCorr_pred = sum(N_corr_pred)/sum(N_trials))%>%
  group_by(cond,sample) %>%
  reframe(
    quartile = c("lq", "m", "uq"),
    Pr_corr_pred = quantile(PrCorr_pred, probs = c(0.25, 0.5, 0.75)),
    Pr_corr_obs = quantile(PrCorr_obs, probs = c(0.25, 0.5, 0.75))
  )  %>%
  group_by(sample, quartile) %>%
  summarize(Pr_corr_pred_CEvsGEE = Pr_corr_pred[cond == "CE"] - Pr_corr_pred[cond == "GEE"],
            Pr_corr_obs_CEvsGEE = Pr_corr_obs[cond == "CE"] - Pr_corr_obs[cond == "GEE"],
            Pr_corr_pred_GEAvsGEE = Pr_corr_pred[cond == "GEA"] - Pr_corr_pred[cond == "GEE"],
            Pr_corr_obs_GEAvsGEE = Pr_corr_obs[cond == "GEA"] - Pr_corr_obs[cond == "GEE"],
            Pr_corr_pred_CEAvsCE = Pr_corr_pred[cond == "CEA"] - Pr_corr_pred[cond == "CE"],
            Pr_corr_obs_CEAvsCE = Pr_corr_obs[cond == "CEA"] - Pr_corr_obs[cond == "CE"]) %>%
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

p <- ggplot(posterior_samples_quartile_contrast, 
            aes(x = Pr_corr_pred, y = quartile, fill = factor(stat(quantile)))
            ) +
  geom_density_ridges_gradient(scale = 0.8, 
                               calc_ecdf = TRUE, quantiles = c(0.025, 0.975)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("lightgray","darkgray", "lightgray")) +
  guides(fill = "none") +
  scale_x_continuous(name = "Difference in posterior distribution of final test accuracy",
                     breaks = seq(-0.2, 0.2, 0.05)) +
  scale_y_discrete(name = "", labels = c("lower quartile", "median", "upper quartile"),
                   expand = expansion(mult = c(0, 0.05))) +
  facet_wrap(~contrast, nrow = 2,
             labeller = as_labeller(function(labels) gsub("vs", " - ", labels))) +
  theme_pubr(base_size = 20) +
  theme(axis.text.x = element_text(angle = 315, vjust = -1, hjust = 1))

ggsave("posterior distribution in final accuracy.png", plot = p, path = "figure/cond_contrast", width = 12, height = 8)


posterior_conc_df <- as_draws_df(fit, variable = "kappa_cond.+", regex = TRUE) %>%
  rename(sample = .draw) %>%
  rename_with(~paste0(gsub("b_kappa_cond","",.x), "vsGEE"),
              starts_with("b_kappa_cond")) %>%
  select(!c(.chain, .iteration)) %>%
  group_by(sample) %>%
  summarize(CEAvsCE = CEAvsGEE - CEvsGEE,
            CEAvsGEA = CEAvsGEE - GEAvsGEE - 2,
            CEvsGEE = CEvsGEE,
            GEAvsGEE = GEAvsGEE) %>%
  pivot_longer(cols = contains("vs"), 
               names_to = "contrast", values_to = "kappa") %>%
  mutate(density = "density")

p <- ggplot(posterior_conc_df,  
            aes(x = kappa, y = density, fill = factor(stat(quantile)))
) +
  geom_density_ridges_gradient(scale = 0.8, 
                               calc_ecdf = TRUE, quantiles = c(0.025, 0.975)) +
  geom_vline(xintercept = 0, linetype = "dashed") +
  scale_fill_manual(values = c("lightgray","darkgray", "lightgray")) +
  guides(fill = "none") +
  scale_x_continuous(name = "Posterior distribution of difference in concentration parameter ",
                     breaks = seq(-50, 50, 10), limits = c(-50,50)) +
  scale_y_discrete(name = "", expand = expansion(mult = c(0, 0.05))) +
  facet_wrap(~contrast, nrow = 2,
             labeller = as_labeller(function(labels) gsub("vs", " - ", labels))
  ) +
  theme_pubr(base_size = 20) +
  theme(axis.title.y = element_blank(),
        axis.text.y = element_blank(),
        axis.ticks.y = element_blank())
ggsave("posterior distribution of concentration.png", plot = p, path = "figure/cond_contrast", width = 12, height = 8)

