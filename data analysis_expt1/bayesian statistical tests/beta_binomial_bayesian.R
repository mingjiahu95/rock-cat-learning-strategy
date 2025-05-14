# Clean up
graphics.off()
rm(list=ls())
set.seed(47405)

# Libraries
library(tidyverse)
library(gamlss)
library(runjags)
library(gridExtra)

# Source DBDA2E Helpers from OSF Repository
source("https://osf.io/uahfc/download")

# Get Mingjia's data 
df <- readRDS("../data.rds") %>%
      filter(phase == "test", block %in% 7:9) %>%
      group_by(version,cond,subj) %>%
      summarize(N_trials = n(),
                N_corr = sum(corr == 1)) %>%
      ungroup()
      
      

## Beta-binomial, Bayesian-style

# Prep for JAGS
y <- as.integer(df$N_corr)
n <- as.integer(df$N_trials)
x1 <- as.integer(df$version) # 1 is before; 2 is after
x2 <- as.integer(df$cond) # 1 is random; 2 is student-chosen
Ntotal <- nrow(df)

# Values (p.alpha & p.beta) for the prior for the mode
# mean.pct <- mean(y/48) # Across all groups; divide y by the number of items
# sd <- 0.1
# p.alpha <- ((1 - mean.pct) / sd ^ 2 - 1 / mean.pct) * mean.pct ^ 2
# p.beta <- p.alpha * (1 / mean.pct - 1)
p.alpha <- 1
p.beta <- 1

# Package for JAGS
dataList = list(
  y = y ,
  n = n ,
  x1 = x1 ,
  x2 = x2,
  p.alpha = p.alpha ,
  p.beta = p.beta ,
  Ntotal = Ntotal 
)

model = "
model {
  
  for( i in 1:Ntotal ){
    y[i]     ~  dbinom(p[i], n[i])
    p[i]     ~  dbeta(alpha[i],beta[i])
    idx[i] <- (x1[i]-1)*2+x2[i]
    alpha[i] <- omega[idx[i]]*(kappa[idx[i]]-2)+1 
    beta[i]  <- (1-omega[idx[i]])*(kappa[idx[i]]-2)+1
  }
  
  for(g in 1:4){
      omega[g]       ~  dbeta(p.alpha,p.beta)
      kappa[g]       <- kappa.prime[g] + 2
      kappa.prime[g] ~  dgamma(0.01, 0.01) # mean = 1, sd = 10
  }
  
}"

rerun <- TRUE

if (rerun) { # If we are going to rerun the chains
  parameters <- c('omega','kappa')
  tic <- Sys.time()
  jags.result <- run.jags(model, 
                          data=dataList, 
                          monitor = parameters, 
                          n.chains = 3, 
                          adapt  = 5000,
                          burnin = 5000, 
                          sample = 30000,
                          method='parallel')
  toc <- Sys.time()
  toc-tic  # Time difference of 1.328313 mins
  coda.samples <- as.mcmc.list( jags.result )
  save(jags.result, coda.samples, file="codaSamples.Rdata")
} else { # Go get the jags output and coda samples
  load(file="codaSamples.Rdata")
}


# Diagnostics
for ( parName in c("omega[1]","omega[2]","omega[3]","omega[4]",
                   "kappa[1]","kappa[2]","omega[3]","omega[4]") ) {
 diagMCMC( codaObject=coda.samples , parName=parName)
}

# Switch into matrix form for analysis
mcmcMat = as.matrix(coda.samples,chains=TRUE)


# Plot the data & estimates
# Randomly sample 25 omegas and kappas
sample <- mcmcMat[sample(nrow(mcmcMat),50),1:9]
colnames(sample) <- c('chains','omega11','omega12','omega21','omega22',
                               'kappa11','kappa12','kappa21','kappa22')
sample <- as.data.frame(sample)
# Change from omega & kappa into alpha and beta
sample <- sample %>% 
          mutate(a11 = omega11*(kappa11-2)+1,
                 b11 = (1.0-omega11)*(kappa11-2)+1,
                 a12 = omega12*(kappa12-2)+1,
                 b12 = (1.0-omega12)*(kappa12-2)+1,
                 a21 = omega21*(kappa21-2)+1,
                 b21 = (1.0-omega21)*(kappa21-2)+1,
                 a22 = omega22*(kappa22-2)+1,
                 b22 = (1.0-omega22)*(kappa22-2)+1
                 ) 

# Make the plot
p_list <- list()
x1_var_levels <- levels(df$version)
x2_var_levels <- levels(df$cond)
x1_var_names <- c("Before", "After")
x2_var_names <- c("Random", "Student Chosen")
var_names_comb <- expand.grid(x1_var_names, x2_var_names)
x_var_names <- paste(var_names_comb$Var1, var_names_comb$Var2, sep = ": ")

N_subj <- group_by(df, version, cond) %>%
          summarize(n_subj = n_distinct(subj))


for (x1_i in 1:2) {
  for (x2_i in 1:2) {
    par_name = c()
    par_name$a <- paste0("a",x1_i,x2_i)
    par_name$b <- paste0("b",x1_i,x2_i)
    x_i <- (x1_i - 1)*2 + x2_i #2 is the number of levels for x2 variable
    p_list[[x_i]] <-  filter(df, version == x1_var_levels[x1_i], cond == x2_var_levels[x2_i]) %>%
      ggplot(aes(x=N_corr/N_trials)) +
      stat_bin(aes(y=after_stat(density)),bins=49,fill= "#BEBEBE") +
      #scale_x_continuous(breaks=seq(0,1,(1/16)),labels = seq(0,48,3), limits = c(0,1)) +
      scale_x_continuous(breaks=seq(10/48,1,(1/48)),labels = seq(10,48), limits = c(10/48,1)) +
      # scale_y_continuous(expand = c(0,0)) + 
      mapply(function(a,b) {
        stat_function(fun = dbeta, args = list(a,b),colour="black",alpha = 0.3)
      },
      a=sample[[par_name$a]],b=sample[[par_name$b]]) +
      xlab("Number of Correct Responses over Blocks 7-9") + ylab("Density") + 
      ggtitle(paste0(x_var_names[x_i], "\n", "N_subj = ", N_subj$n_subj[x_i])) + 
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),
            axis.ticks.y = element_blank(), axis.text.y = element_blank(), 
            axis.text.x = element_text(angle = 315, vjust = -0.5),
            panel.background = element_blank(), axis.line = element_line(colour = "black"),
            plot.title = element_text(hjust = 0.5))
  }
}
p <- arrangeGrob(grobs = p_list, nrow=2)
ggsave("test accuracy distribution.png", p, path = "figure", scale = 3)


# Contrast the posteriors
png("figure/mode_before_HDI.png")
plotPost(mcmcMat[,'omega[2]']-mcmcMat[,'omega[1]'])
dev.off()
png("figure/conc_before_HDI.png")
conc_RvsSC_before <- plotPost(mcmcMat[,'kappa[2]']-mcmcMat[,'kappa[1]'])
dev.off()
png("figure/mode_after_HDI.png")
mode_RvsSC_after <- plotPost(mcmcMat[,'omega[4]']-mcmcMat[,'omega[3]'])
dev.off()
png("figure/conc_after_HDI.png")
conc_RvsSC_after <- plotPost(mcmcMat[,'kappa[4]']-mcmcMat[,'kappa[3]'])
dev.off()



