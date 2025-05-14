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
# set_cmdstan_path("C:/Users/super/.cmdstan/cmdstan-2.35.0")

# Source DBDA2E Helpers from OSF Repository
source("https://osf.io/uahfc/download")
source("../../utils/beta-binom.R")

# Load Prolific data 
epsilon <- 1e-6
df <- readRDS("../prolific data.RDS") %>% 
      filter(phase == "test") %>%
      mutate(block_set = case_when(block <= 3 ~ 1,
                                  block <= 6 ~ 2,
                                  block <= 9 ~ 3),
             block_set = as.integer(block_set),
            `G vs. C` = if_else(grepl("G",cond),"G","C"),
            `E/N vs. A` = if_else(grepl("A",cond),"A","E/N"),
            `G vs. C` = factor(`G vs. C`,levels = c("G","C")),
            `E/N vs. A` = factor(`E/N vs. A`,levels = c("E/N","A")),
             subj = factor(subj)
             ) %>%
      group_by(cond,`G vs. C`,`E/N vs. A`, subj, block_set, cat) %>%
      summarize(N_trials = n(),
                N_corr = sum(corr),
                # Pr_corr = N_corr/N_trials,
                # Pr_corr = if_else(Pr_corr == 1, Pr_corr - epsilon, Pr_corr),
                # Pr_corr = if_else(Pr_corr == 0, Pr_corr + epsilon, Pr_corr)
               ) %>%
      ungroup() %>%
      mutate(block_set_fct = as.factor(block_set),
             cond = factor(cond, levels = c("GEE", "GEA", "CE", "CEA"))
             ) 

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
  brm_formula <- bf(N_corr | trials(N_trials) ~ cond + (1|cat) + (1|subj),
                    kappa ~ cond)
  
  priors <- c(set_prior("gamma(0.01,0.01)", lb = 2, dpar = "kappa", class = "Intercept"),
              set_prior("normal(0, 1)", class = "b", coef = "condCE"),
              set_prior("normal(0, 1)", class = "b", coef = "condCEA"),
              set_prior("normal(0, 1)", class = "b", coef = "condGEA"))
  
  fit_obj_idx = 0
  fit_object = list()
  for (blockset in unique(df$block_set)){
    fit_obj_idx = fit_obj_idx + 1
    var_name = paste0("fit_blockset_", blockset)
    fit <- brm(brm_formula,  
               data = filter(df, block_set == blockset), 
               family = beta_binomial_custom, stanvars = stanvars,
               prior = priors,
               control = list(adapt_delta = 0.92),
               chains = 6,
               cores = parallel::detectCores(), #speed up the process by using multiple cores
               threads = threading(200),
               backend = "cmdstanr")
    fit_object[[fit_obj_idx]] <- fit
  }
  save(fit_object, file = "brms_fit_objects.Rdata")
} else {
  save(fit, file = "brms_fit_objects.Rdata")
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
conds_tbl <- expand.grid(
  cond = levels(df$cond),
  block_set = as.integer(1:3)
) %>%
  mutate(block_set_fct = as.factor(block_set),
         N_trials = 1)


posterior_draw_df <- t(posterior_linpred(fit, newdata = conds_tbl, re_formula = NA)) %>%
  as_tibble() %>% 
  setNames(paste0("sample", 1:ncol(.))) 

posterior_samples_by_cond <- conds_tbl %>%
  bind_cols(posterior_draw_df) %>%
  pivot_longer(cols = starts_with("sample"), names_prefix = "sample",
               names_to = "sample", values_to = "estimate") %>%
  group_by(block_set) %>%
  reframe(GEAvsGEE = estimate[cond == "GEA"] - estimate[cond == "GEE"],
          CEvsGEE = estimate[cond == "CE"] - estimate[cond == "GEE"],
          CEAvsCE = estimate[cond == "CEA"] - estimate[cond == "CE"]) %>%
  pivot_longer(cols = contains("vs"),
               names_to = "contrast", values_to = "estimate")

conditional_contrast_stats <- 
  posterior_samples_by_cond %>%
  group_by(block_set, contrast) %>%
  summarize(stats = list({
    CI <- quantile(estimate, c(0.025, 0.5, 0.975))
    setNames(CI,c("lower", "median", "upper"))
  })) 

prefixes <- c("Intercept_", "kappa_", "learnRate_")
posterior_samples_by_term <- 
  as_draws_df(fit)  %>%
  select(contains("cond") & !starts_with("simo")) %>%
  rename_with(~ .x %>%
                str_replace_all("^bsp_moblock_setidEQcycle:cond", "learnRate_") %>%
                str_replace_all("^b_", "") %>%
                str_replace_all("cond", "") %>%
                str_replace_all("^([A-Z]+)", "Intercept_\\1")) %>%
  add_column(sample = 1:nrow(.), .before = 1) %>%
  mutate(
    Intercept_GEAvsGEE = Intercept_GEA,
    Intercept_CEvsGEE = Intercept_CE,
    Intercept_CEAvsCE = Intercept_CEA - Intercept_CE,
    kappa_GEAvsGEE = kappa_GEA,
    kappa_CEvsGEE = kappa_CE,
    kappa_CEAvsCE = kappa_CEA - kappa_CE,
    learnRate_GEAvsGEE = learnRate_GEA,
    learnRate_CEvsGEE = learnRate_CE,
    learnRate_CEAvsCE = learnRate_CEA - learnRate_CE,
    .keep = "unused") %>%
  pivot_longer(
    cols = contains("vs"),
    names_to = "name", values_to = "estimate") %>%
  separate(
    col = name, into = c("stats_type", "contrast"),sep = "_") %>%
  mutate(stats_type = factor(stats_type),
         contrast = factor(contrast))


overall_contrast_stats <- 
  posterior_samples_by_term %>%
  group_by(stats_type, contrast) %>%
  summarize(stats = list({
    CI <- quantile(estimate, c(0.025, 0.5, 0.975))
    setNames(CI,c("lower", "median", "upper"))
  }))

p <- ggplot(posterior_samples_by_cond, aes(x = factor(block_set), y = estimate, fill = contrast)) +
  geom_violin(
    position = position_dodge(width = 0.8),  
    color = "black",
    alpha = 0.5,
    draw_quantiles = c(0.025, 0.5, 0.975)
  ) +
  labs(x = "Block Set",y = "Effect Estimate") 
ggsave("posterior condition effects.png", plot = p, path = "figure/simplex regression", width = 12, height = 8)


p <- ggplot(posterior_samples_by_term, aes(x = contrast, y = estimate, fill = contrast)) +
     geom_violin(
       position = position_dodge(width = 0.8),  
       color = "black",alpha = 0.5,
       draw_quantiles = c(0.025, 0.5, 0.975)) +
     labs(x = "Contrast",y = "Effect Estimate") +
     facet_wrap(~stats_type, scales = "free")
ggsave("posterior model parameters.png", plot = p, path = "figure/simplex regression", width = 12, height = 8)

# make posterior predictive plot
pred_samples <- posterior_predict(fit, re_formula = ~(1|cat))
omega_samples <- posterior_epred(fit, re_formula = ~(1|cat), dpar = "mu") #re_formula = ~0
kappa_samples <- posterior_epred(fit, dpar = "kappa")
sample_indices <- sample(1:nrow(pred_samples), 30)
pred_samples <- t(pred_samples[sample_indices,])
omega_samples <- t(omega_samples[sample_indices,])
kappa_samples <- t(kappa_samples[sample_indices,])
all_samples <- cbind(pred_samples, omega_samples, kappa_samples)
colname_combs <- expand.grid(num = 1:30, name = c("N_corr_pred", "omega", "kappa"))
colnames(all_samples) <- paste(colname_combs$name, colname_combs$num, sep = "_")
df <- bind_cols(df, as.data.frame(all_samples)) # re-define df for debugging


pred_plot_list <- list()
x1_var_levels <- levels(df$`E/N vs. A`)
x2_var_levels <- levels(df$`G vs. C`)
x1_var_names <- c("No Algorithm", "With Algorithm")
x2_var_names <- c("Given", "Chosen")
var_names_comb <- expand.grid(x1_var_names, x2_var_names)
# x_var_names <- paste(var_names_comb$Var1, var_names_comb$Var2, sep = ": ")
x_var_names <- c("GEE","GEA","CE", "CEA")
N_subj <- group_by(df, `E/N vs. A`, `G vs. C`) %>%
          summarize(n_subj = n_distinct(subj))

pred_col_names <- grep("^N_corr_pred", colnames(df), value = TRUE)
omega_col_names <- grep("^omega", colnames(df), value = TRUE)
kappa_col_names <- grep("^kappa", colnames(df), value = TRUE)
for (x1_i in 1:2) {
  for (x2_i in 1:2) {
    plot_name_idx <- (x1_i - 1)*2 + x2_i
    plot_order_idx <- (x2_i - 1)*2 + x1_i
    data_main <-
      filter(df, `E/N vs. A` == x1_var_levels[x1_i], `G vs. C` == x2_var_levels[x2_i]) %>%
      group_by(subj) %>%
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
      ggtitle(paste0(x_var_names[plot_name_idx], "\n", "N_subj = ", N_subj$n_subj[plot_name_idx])) + 
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            axis.ticks.y = element_blank(), axis.text.y = element_blank(), 
            axis.text.x = element_text(angle = 315, vjust = -0.5),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            plot.title = element_text(hjust = 0.5))
  }
}
p <- grid.arrange(grobs = pred_plot_list, nrow=2, bottom = "Number of Correct Responses over Blocks 7-9")    
ggsave("posterior predictive plot.png", plot = p, path = "figure/learnRate_linear", width = 11, height = 9)

