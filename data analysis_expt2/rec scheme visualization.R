#---------------------------------------------------------
# load libraries and data sets
library(tidyverse)
library(ggpubr)
source("util.R")

data <- readRDS("prolific data.RDS") 

# ---- data cleaning ----------------------------------------------
valid_subj_accu_df <- data %>%
  filter(phase == "test", block %in% 7:9) %>%
  group_by(cond,subj) %>%
  summarize(Pr_corr_test = mean(corr == 1)) %>%
  group_by(cond) %>%
  filter(percent_rank(Pr_corr_test) > .15) %>%
  ungroup()  

data_cleaned_SCR <- data %>%
  semi_join(valid_subj_accu_df,by = "subj")%>%
  filter(cond == "SCR") 
#---------------------------------------------------------
# compute d-prime for each block and category
# epsilon <- .000001
dprime_prop_test <- data_cleaned_SCR %>%
                    filter(phase == "test", block %in% 1:8) %>%
                    group_by(subj, block) %>%
                    nest() %>%
                    mutate(stats = map(data, ~ {
                             df <- .x  
                             map_df(unique(df$cat), 
                                    function(cat_value) {
                                      compute_dprime(df, cat, resp, cat_value)
                                    })
                            })
                          ) %>%
                    unnest(stats) %>%
                    mutate(dprime_pos = dprime - min(dprime),
                           dprime_prop = dprime_pos/sum(dprime_pos)
                           ) %>%
                    ungroup() %>%
                    select(subj,block,stats_cat,H,FA,dprime,dprime_prop) %>% 
                    mutate(block_train = block + 1,
                           .keep = "unused")

# compute selection proportion for each block and category
cat_prop_rec <- data_cleaned_SCR %>%
  select(-cond) %>%
  filter(phase == "train") %>%
  group_by(subj,block,cat_rec) %>% 
  summarize(cat_count = n()) %>%
  group_by(subj,block) %>%
  mutate(cat_prop = cat_count/sum(cat_count)) %>%
  ungroup()

cat_prop_dprime <- full_join(cat_prop_rec, dprime_prop_test,
                             join_by(subj,cat_rec == stats_cat,block == block_train)) 

#---------------------------------------------------------
# plot histogram showing blockwise d prime and recommended category proportion
plot_data_allcats <- cat_prop_dprime %>%
                     replace_na(list(cat_count = 0,cat_prop = 0)) %>%
                     group_by(subj) %>%
                     arrange(mad(cat_count)) %>%
                     filter(subj == "5a3e5d407a3e3a0001dd3f7c") 
                     
p <- ggplot(plot_data_allcats, aes(x = block)) +
     geom_area(aes(y = cat_count, fill = cat_rec), position = "stack") +
     scale_x_continuous(breaks = 1:9) +
     scale_y_continuous(breaks = seq(0,16,2)) +
     scale_fill_discrete(name = "Category") +
     xlab("Training Block") +
     ylab("Number of Category Examples") +
     theme_bw(base_size = 15)

ggsave("training category recommendation.png", p,path = "figure/rec_demo")

cat_names <- c("Pegmatite","Pumice")
  plot_data_cats <- filter(plot_data_allcats, cat_rec %in% cat_names) 
  testColor <- "#BEBEBE"
  trainColor <- "black"     
  max_rec_num <- max(plot_data_cats$cat_count)
  sec_axis_name <- paste0("Scaled Test Performance in Prior Block\n", "Pr(H) - Pr(FA)")
  
  p <- ggplot(plot_data_cats, aes(x=block)) +
    geom_line(aes(y=cat_count), linewidth=2, color=trainColor) + 
    geom_line(aes(y=(dprime + 1)/2*max_rec_num), linewidth=2, color=testColor) +
    scale_x_continuous(breaks = 1:9) +
    scale_y_continuous(
      name = "Number of Training Examples",
      limits = c(0,4),
      sec.axis = sec_axis(~./max_rec_num*2 - 1, name = sec_axis_name)
    ) + 
    facet_wrap( .~ cat_rec, nrow = 1) +
    ggtitle('') +
    theme_bw(base_size = 15) +
    theme(
      axis.title.y.left = element_text(color = trainColor, size=13),
      axis.title.y.right = element_text(color = testColor, size=13),
      axis.text.y.left = element_text(color = trainColor, size=13),
      axis.text.y.right = element_text(color = testColor, size=13),
      plot.title = element_text(hjust = 0.5)
    ) 
  # filename = paste("recommendation", "cats", sep = "_")
  ggsave(paste0("recommendation_cats",".png"), p, path = "figure/rec_demo", scale = 5)


