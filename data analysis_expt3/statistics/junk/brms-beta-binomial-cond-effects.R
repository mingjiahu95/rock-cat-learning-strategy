# Clean up
graphics.off()
rm(list=ls())
set.seed(47405)
# Libraries
# library(pkgbuild)

library(tidyverse)
library(brms)
library(rlang)
library(gridExtra)
library(cmdstanr)
set_cmdstan_path("C:/Users/super/.cmdstan/cmdstan-2.35.0")

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

rerun = TRUE
if (rerun){
  options(mc.cores = parallel::detectCores())
  priors <- c(
    set_prior("gamma(0.01,0.01)",lb = 2, dpar = "kappa", class = "Intercept"),
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
             control = list(adapt_delta = 0.92),
             cores = 4,
             threads = threading(10),
             backend = "cmdstanr")
  save(fit, file="brms_fit_learnRate_full.Rdata")
} else {
  load(file="brms_fit_learnRate_full.Rdata")
}
#expose pmf and rng functions defined by RSTAN
expose_functions(fit, vectorize = TRUE) #expose pmf and rng functions defined by RSTAN

summary(fit)

# check diagnostic plots for condition parameters
cond_parNames = head(colnames(cond_samples),-3)
for ( parName in cond_parNames) {
diagMCMC(codaObject= as.mcmc(fit), 
         parName=parName)
}

# compute and visualize the contrasts for conditional effects and learning rates
conds_tbl <- df %>%
  distinct(cond, subjID, cycle, cycle_fct, cat, N_trials)
  

posterior_draw_df <- t(posterior_linpred(fit, newdata = conds_tbl, re_formula = NA)) %>%
                     as_tibble() %>% 
                     setNames(paste0("sample", 1:ncol(.))) 

posterior_samples_by_cond <- conds_tbl %>%
  bind_cols(posterior_draw_df) %>%
  pivot_longer(cols = starts_with("sample"), names_prefix = "sample",
               names_to = "sample", values_to = "estimate") %>%
  group_by(cycle) %>%
  reframe(GEAvsGEE = estimate[cond == "GEA"] - estimate[cond == "GEE"],
          GCPvsGEE = estimate[cond == "GCP"] - estimate[cond == "GEE"],
          CCPvsGCP = estimate[cond == "CCP"] - estimate[cond == "GCP"],
          GCPvsGEA = estimate[cond == "GCP"] - estimate[cond == "GEA"]) %>%
  pivot_longer(cols = contains("vs"),
               names_to = "contrast", values_to = "estimate")
  
conditional_contrast_stats <- 
  posterior_samples_by_cond %>%
  group_by(cycle, contrast) %>%
  summarize(stats = list({
    CI <- quantile(estimate, c(0.025, 0.5, 0.975))
    setNames(CI,c("lower", "median", "upper"))
  })) 

learnRate_posterior_samples <- 
  as_draws_df(fit)  %>%
  select(starts_with("bsp_mocycle") & contains("cond")) %>%
  rename_with(~ sub("^bsp_mocycleidEQcycle:cond", "b_", .x)) %>%
  add_column(sample = 1:nrow(.), .before = 1) %>%
  mutate(GEAvsGEE = b_GEA,
         GCPvsGEE = b_GCP,
         CCPvsGCP = b_CCP - b_GCP,
         GCPvsGEA = b_GCP - b_GEA,
         .keep = "unused") %>%
  pivot_longer(cols = contains("vs"),
               names_to = "contrast", values_to = "estimate")
  

learnRate_contrast_stats <- 
  learnRate_posterior_samples %>%
  group_by(contrast) %>%
  summarize(stats = list({
      CI <- quantile(estimate, c(0.025, 0.5, 0.975))
      setNames(CI,c("lower", "median", "upper"))
    })
  )

p <- ggplot(posterior_samples_by_cond, aes(x = factor(cycle), y = estimate, fill = contrast)) +
  geom_violin(
    position = position_dodge(width = 0.8),  # Separate densities by contrast
    color = "black",
    alpha = 0.5,
    draw_quantiles = c(0.025, 0.5, 0.975)
  ) +
  labs(x = "Cycle",y = "Effect Estimate") 
ggsave("posterior condition effects.png", plot = p, path = "figure/cond_effect_simplex", width = 12, height = 8)


p <- ggplot(learnRate_posterior_samples, aes(x = factor(contrast), y = estimate)) +
  geom_violin(
    position = position_dodge(width = 0.8),  # Separate densities by contrast
    color = "black",
    alpha = 0.5,
    draw_quantiles = c(0.025, 0.5, 0.975)
  ) +
  labs(x = "Contrast",y = "Effect Estimate") 
ggsave("posterior learn rate effects.png", plot = p, path = "figure/cond_effect_simplex", width = 12, height = 8)

# make posterior predictive plot
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
  ggsave(filename, plot = p, path = "figure/learnRate_simplex", width = 11, height = 9)
}


