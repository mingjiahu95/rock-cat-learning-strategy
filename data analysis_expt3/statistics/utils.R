calc_alpha <- function(omega, kappa) {
  omega * (kappa-2) + 1
}

calc_beta <- function(omega, kappa) {
  (1-omega) * (kappa-2) + 1 
}

dbetabinom <- function(k, n, alpha, beta) {
  
  log_binom_coeff <- lchoose(n, k)
  log_beta_num <- lbeta(k + alpha, n - k + beta)
  log_beta_den <- lbeta(alpha, beta)
  log_pmf <- log_binom_coeff + log_beta_num - log_beta_den
  pmf <- exp(log_pmf)
  
  return(pmf)
}

dbetabinom_sum <- function(k_total, omegas, kappas, n) {
  
  num_dists <- length(omegas)
  k_values <- 0:n
  
  # Compute the PMF for the first distribution
  pmf_total_vec <- exp(beta_binomial_custom_lpmf(k_values, omegas[1], kappas[1], n))
  # Iterate over the remaining distributions
  for (i in 2:num_dists) {
    pmf_next <- exp(beta_binomial_custom_lpmf(k_values, omegas[i], kappas[i], n))
    # Perform the convolution manually to handle probability distribution summing
    pmf_new <- numeric(length(pmf_total_vec) + length(pmf_next) - 1)
    for (j in 1:length(pmf_total_vec)) {
      for (k in 1:length(pmf_next)) {
        pmf_new[j + k - 1] <- pmf_new[j + k - 1] + pmf_total_vec[j] * pmf_next[k]
      }
    }
    pmf_total_vec <- pmf_new
  }
  
  # The possible total k values range from 0 to n * num_dists
  max_k_total <- n * num_dists
  epsilon <- 1e-06
  if (any(k_total > max_k_total)){
    stop(paste0("total k values can't be greater than ", max_k_total))
  }
  if (abs(sum(pmf_total_vec) - 1) > 1e-06){
    warning("the sum of probabilities over k range is quite different from 0")
  }
  pmf_total <- pmf_total_vec[k_total+1] # k_total range starts from 0 and ends with n * num_dists
  
  return(pmf_total)
}

log_lik_beta_binomial_custom <- function(i, prep) {
  mu <- brms::get_dpar(prep, "mu", i = i)
  kappa <- brms::get_dpar(prep, "kappa", i = i)
  trials <- prep$data$trials[i]
  y <- prep$data$Y[i]
  beta_binomial_custom_lpmf(y, mu, kappa, trials)
}

posterior_predict_beta_binomial_custom <- function(i, prep, ...) {
  mu <- brms::get_dpar(prep, "mu", i = i)
  kappa <- brms::get_dpar(prep, "kappa", i = i)
  trials <- prep$data$trials[i]
  beta_binomial_custom_rng(mu, kappa, trials)
}

posterior_epred_beta_binomial_custom <- function(prep) {
  mu <- brms::get_dpar(prep, "mu")
  trials <- prep$data$trials
  trials <- matrix(trials, nrow = nrow(mu), ncol = ncol(mu), byrow = TRUE)
  mu * trials
}

"model {
  for(i in 1:Ntotal) {
    y[i] ~ dbinom(p[i],n[i])
    p[i] ~ dbeta(alpha_cond_cat[g_list[i],k_list[i]],beta_cond_cat[g_list[i],k_list[i]])
  }
  
  for(g in 1:Ncond){
    for(k in 1:Ncat){
      alpha_cond_cat[g,k] <- omega_cond_cat[g,k]*(kappa_cond_cat[g,k]-2)+1 
      beta_cond_cat[g,k]  <- (1-omega_cond_cat[g,k])*(kappa_cond_cat[g,k]-2)+1
      omega_cond_cat[g,k] <-  ilogit(omega_cat[k] + omega_cond[g]) # + omega_cond_cat[g,k]
      # omega_cond_cat[g,k] ~ dnorm(0,1) # hyperprior for interaction terms
      kappa_cond_cat[g,k] <- kappa_prime_cond_cat[g,k] + 2
      kappa_prime_cond_cat[g,k] ~ dgamma(0.01, 0.01) # mean = 1, sd = 10
    }
  }
  
  for(k in 1:Ncat) {
    intercept_cat[k] ~  dnorm(0,1) # hyperprior for category mean
    # omega_cat[k] <- mu_cat[k] + sigma_cat[k]
    # mu_cat[k] ~ dnorm(0,1)
    # sigma_cat[k] ~ dgamma(0.01, 0.01)
  }
  
  for(g in 1:Ncond) {
    omega_cond[g] ~  dnorm(0,1) # hyperprior for condition mean
    # omega_cond[g] <- mu_cond[g] + sigma_cond[g]
    # mu_cond[g] ~ dnorm(0,1)
    # sigma_cond[g] ~ dgamma(0.01, 0.01)
  }
}"