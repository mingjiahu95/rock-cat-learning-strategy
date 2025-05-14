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
library(gridExtra)
library(cmdstanr)

# Source DBDA2E Helpers from OSF Repository
source("https://osf.io/uahfc/download")
source("../../utils/beta-binom.R")

# Load data 
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
  
Ntotal <- nrow(df)
Ncond <- n_distinct(df$cond)
Ncat <- n_distinct(df$cat)

beta_binomial_custom <- custom_family(
  "beta_binomial_custom", dpars = c("mu", "kappa"),
  links = c("logit", "identity"),
  lb = c(0, 2), ub = c(1, NA),
  type = "int", vars = "trials[n]"
)

stan_funs <- "
  real beta_binomial_custom_lpmf(int y, real mu, real kappa, int T) {
    return beta_binomial_lpmf(y | T, mu * kappa + 1, (1 - mu) * kappa + 1);
  }

  int beta_binomial_custom_rng(real mu, real kappa, int T) {
    return beta_binomial_rng(T, mu * kappa + 1, (1 - mu) * kappa + 1);
  }
"

stanvars <- stanvar(scode = stan_funs, block = "functions") 

rerun = FALSE
if (rerun){
  options(mc.cores = parallel::detectCores())
  priors <- c(
    set_prior("gamma(0.01,0.01)",lb = 2, dpar = "kappa", class = "Intercept"),
    set_prior("normal(0, 1)", class = "b", coef = "condCCP"),
    set_prior("normal(0, 1)", class = "b", coef = "condGCP"),
    set_prior("normal(0, 1)", class = "b", coef = "condGEA"),
    set_prior("normal(0, 1)", class = "b", coef = "mocycleidEQcycle:condCCP"),
    set_prior("normal(0, 1)", class = "b", coef = "mocycleidEQcycle:condGCP"),
    set_prior("normal(0, 1)", class = "b", coef = "mocycleidEQcycle:condGEA")
  )
  
  brm_formula <- bf(N_corr | trials(N_trials) ~ cond * mo(cycle, id = "cycle") + 
                                                (1|cat) + (1|subjID),
                    kappa ~ cond + cycle_fct)
  fit <- brm(brm_formula,  
             data = df, family = beta_binomial_custom, stanvars = stanvars,
             prior = priors,
             control = list(adapt_delta = 0.93),
             chains = 6,
             cores = parallel::detectCores(),
             threads = threading(500),
             backend = "cmdstanr")
  save(fit, file="brms_fit_learnRate_full2.Rdata")
} else {
  load(file="brms_fit_learnRate_full2.Rdata")
}
#expose pmf and rng functions defined by RSTAN
expose_functions(fit, vectorize = TRUE) #expose pmf and rng functions defined by RSTAN

summary(fit)

## predictive posterior plots by cycle and condition
# violin plots
conds_tbl <- df %>%
  distinct(cond, subjID, cycle, cycle_fct, cat, N_trials)

posterior_draws_df <- posterior_epred(fit, newdata = conds_tbl, ndraws = 30) %>%
  t() %>%
  as_tibble() %>%
  setNames(paste0("pred_draw", 1:30)) %>%
  bind_cols(conds_tbl)

df_obs_pred <- posterior_draws_df %>%
  inner_join(df, by = c('cond', 'subjID', 'cycle', 'cycle_fct', 'cat', 'N_trials')) %>%
  group_by(cond, subjID, cycle, cycle_fct) %>%
  summarize(N_corr = sum(N_corr),
            across(starts_with("pred_draw"), sum, .names = 'N_corr_{.col}'),
            N_trials = sum(N_trials),
            across(starts_with("pred_draw"), ~sum(.x)/N_trials, .names = 'Pr_corr_{.col}'),
            Pr_corr = N_corr/N_trials) %>%
  rowwise() %>%
  mutate(N_corr_pred_median = median(c_across(starts_with("N_corr_pred_draw"))),
         Pr_corr_pred_median = N_corr_pred_median/N_trials)
  
pred_col_names <- grep("^Pr_corr_pred_draw", colnames(df_obs_pred), value = TRUE)
p <- ggplot(df_obs_pred, aes(x = cond, fill = cond)) +
  geom_half_violin(
    aes(y = Pr_corr),
    side = "l",
    color = "black", alpha = 0.4,
    bw = 1/48, width = 1
  ) +
  # geom_half_violin(
  #   aes(y = Pr_corr_pred_median),
  #   side = "r",
  #   color = "black", alpha = 0.4, 
  #   width = 1, bw = 1/24) +
  lapply(pred_col_names,
         function (col_name){
           geom_half_violin(
             aes(y = !!sym(col_name)),
             side = "r",
             color = "black", alpha = 0.8, 
             width = 1, bw = 1/48)
   }) +
  labs(x = "Cycle",y = "Proportion Correct") +
  facet_wrap(~ cycle, nrow = 2)
ggsave("posterior predictions violin.png", plot = p, path = "figure/model prediction", width = 18, height = 12)


# histograms
pred_samples <- posterior_predict(fit)
sample_indices <- sample(1:nrow(pred_samples), 30)
pred_samples <- t(pred_samples[sample_indices,])
colname_combs <- expand.grid(num = 1:30, name = "N_corr_pred")
colnames(pred_samples) <- paste(colname_combs$name, colname_combs$num, sep = "_")
df <- bind_cols(df, as.data.frame(pred_samples)) # re-define df for debugging


pred_plot_list <- list()
cond_levels <- levels(df$cond)
cycle_levels <- unique(df$cycle)
cond_names <- c("GEE", "GEA", "GCP", "CCP")
N_subj <- group_by(df, cond) %>%
          summarize(n_subj = n_distinct(subjID))

pred_col_names <- grep("^N_corr_pred", colnames(df), value = TRUE)
plot_name_indices <- c(1,2,3,4)
plot_order_indices <- c(1,3,2,4)
# omega_col_names <- grep("^omega", colnames(df), value = TRUE)
# kappa_col_names <- grep("^kappa", colnames(df), value = TRUE)
for (icycle in 1:length(cycle_levels)){
  for (icond in 1:length(cond_levels)) {
    plot_name_idx <- plot_name_indices[icond]
    plot_order_idx <- plot_order_indices[icond]
    data_main <-
      filter(df, cond == cond_levels[plot_name_idx], cycle == cycle_levels[icycle]) %>%
      group_by(subjID) %>%
      summarize(across(starts_with("N_corr"), sum, .names = "{.col}")) %>%
      ungroup()
    # data_dpars <-
    #   filter(df, `E/N vs. A` == x1_var_levels[x1_i], `G vs. C` == x2_var_levels[x2_i]) %>%
    #   group_by(cat) %>%
    #   summarize(across(starts_with(c("omega","kappa")), unique, .names = "{.col}")) %>%
    #   ungroup()
    # print(summary(data_dpars))
    pred_plot_list[[plot_order_idx]] <- 
      ggplot() + 
      stat_bin(aes(x=N_corr, y=after_stat(density)), data=data_main, bins=49, color="black", fill="white") +
      scale_x_continuous(breaks=seq(0,48,2),labels = seq(0,48,2), limits = c(0,49)) +
      scale_y_continuous(expand = c(0,0)) + 
      lapply(pred_col_names,
             function (col_name){
               stat_density(data = data_main, aes(x = !!sym(col_name), y = after_stat(density)),
                            geom = "line", color = "#BEBEBE", alpha = 0.7)
             }) +
      # mapply(function(omega_col_name,kappa_col_name) {
      #         omega <- data_dpars[[omega_col_name]]
      #         kappa <- data_dpars[[kappa_col_name]]
      #         stat_function(
      #           fun = function(x){
      #             dbetabinom_sum(x, omega, kappa, 6)
      #           },
      #           xlim = c(0,48), n = 49,
      #           colour = "#BEBEBE", alpha = 0.7)
      #       },
      #       omega_col_names,kappa_col_names) +
      xlab("") +
      ylab("Density") + 
      ggtitle(paste0(cond_names[plot_name_idx], "\n", "N_subj = ", N_subj$n_subj[plot_name_idx])) + 
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            axis.ticks.y = element_blank(), axis.text.y = element_blank(), 
            axis.text.x = element_text(angle = 315, vjust = -0.5),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            plot.title = element_text(hjust = 0.5))
    
  }
  p <- grid.arrange(grobs = pred_plot_list, nrow=2, bottom = "Number of Correct Responses over Blocks 7-9") 
  filename <- paste0("posterior predictive plot_", cycle_levels[icycle], ".png")
  ggsave(filename, plot = p, path = "figure/model prediction", width = 11, height = 9)
}


