library(tidyverse)
library(gridExtra)
library(ggplot2)
library(ggpubr)
library(RColorBrewer)

# ---- Load the Data ----
setwd("../data")
files = dir(pattern = "revised.txt$") #change it for revised version
data = do.call(bind_rows, lapply(files, read.table, fill = T))
data[is.na(data)] <- -1
nrows = sapply(files, function(f) nrow(read.table(f, fill = T)))
setwd("../data analysis")

# ---- define the data types ----
colnames(data) = c("cond","subj","block","phase","trial","cat","token","resp","corr","rt_decision","rt_selection")
data$cond = factor(data$cond,labels = c("random","student_chosen"))
data$subj = as.integer(data$subj)
data$block = as.integer(data$block) 
data$phase = factor(data$phase,labels = c("train","test")) 
data$trial = as.integer(data$trial)
data$cat = factor(data$cat,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
data$resp = factor(data$resp,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice")) 
data$corr = as.integer(data$corr) 

#remove outlier
data = filter(data,!(cond == "student_chosen" & subj %in% c(81,118,181))) 

#---------------------------------------------------------
# add train stimuli location info
setwd("../data/TrainStim")
TrainStim_files = dir(pattern = "condSC")
TrainStim_data = do.call(bind_rows, lapply(TrainStim_files, read.table, fill = T))
colnames(TrainStim_data) = c("subj","cat","token")
TrainStim_data$cat = factor(TrainStim_data$cat,labels = c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice"))
TrainStim_data$row = rep(rep(1:6,each = 8),n_distinct(TrainStim_data$subj))
TrainStim_data$col = rep(1:8,times = 6,n_distinct(TrainStim_data$subj))
TrainStim_data$cond = "student_chosen"
setwd("../../data analysis")

data = left_join(data,TrainStim_data)
  

#---------------------------------------------------------
# mean classification accuracy for the last 3 test blocks for each subject
accu_test <- data %>%
             filter(cond == "student_chosen", phase == "test", block %in% c(7,8,9)) %>%
             group_by(subj) %>%
             summarize(Pr_corr_sub = mean(corr == 1)) %>%
             ungroup() 

#-------------------------------------------------------------
# sensitivity measure for each category and subject
compute_stats <- function(subj_block_df, cat_col, resp_col, cat_value) {
  # Calculate H for the target category
  H <- sum(subj_block_df[[resp_col]] == cat_value & subj_block_df[[cat_col]] == cat_value) / sum(subj_block_df[[cat_col]] == cat_value)
  
  # Calculate false alarm rates for each non-target category
  FA_values <- subj_block_df %>%
    filter(.data[[cat_col]] != cat_value) %>%
    group_by(.data[[cat_col]]) %>%
    summarise(FA = sum(.data[[resp_col]] == cat_value) / n(), .groups = 'drop') %>%
    pull(FA)
  
  FA <- max(FA_values, na.rm = TRUE)
  dprime <- H - FA
  
  return(data.frame(H = H, FA = FA, dprime = dprime, stats_cat = cat_value))
}

dprime_cat_test <- data %>%
  filter(cond == "student_chosen", phase == "test", block != 9) %>%
  group_by(subj, block) %>%
  nest() %>%
  mutate(stats = map(data, ~{
    unique_cats <- unique(.x$cat)
    map_df(unique_cats, function(cat) compute_stats(.x, 'cat', 'resp', cat))
  })) %>%
  select(-data) %>%
  unnest(stats) %>%
  ungroup() %>%
  mutate(block_train = block + 1) %>%
  select(-block)

#-------------------------------------------------------------
# selection proportions for each category and subject
prop_cat_train <- filter(data, cond == "student_chosen", block != 1, phase == "train") %>%
                  group_by(subj,block) %>%
                  reframe(
                          stats_cat = as.factor(levels(cat)),
                          prop_cat = sapply(levels(cat), function(c) sum(cat == c)/length(cat))
                         ) %>%
                  ungroup() %>%
                  mutate(block_train = block, block = NULL)

prop_cmp_cat_block <- inner_join(dprime_cat_test,prop_cat_train,
                                 join_by(subj,block_train,stats_cat)
                                 ) 
#-------------------------------------------------------------
# compute the selection distance between adjacent training trials
select_dist_train <- filter(data, cond == "student_chosen", phase == "train") %>%
                     group_by(subj,block) %>%
                     mutate(
                            dist_select = sqrt((row - lag(row))^2 + (col - lag(col))^2)
                           ) %>%
                     filter(!is.na(dist_select)) %>%
                     ungroup()

#-------------------------------------------------------------
# compute the category selection repetition rate
cat_levels <- c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice")
num_rep_cat_train <- filter(data, cond == "student_chosen", phase == "train") %>%
                     group_by(subj,block) %>%
                     mutate(cat = as.character(cat)) %>%
                     reframe(
                             stats_cat = factor(cat_levels,levels = cat_levels),
                             num_cat = sapply(cat_levels, function(c) sum(cat == c & lag(cat, default = "none") == c))
                            ) %>% 
                     filter(!is.na(num_cat)) %>%
                     ungroup()

#-------------------------------------------------------------
# subject-level performance measure
prop_select_ranked <- prop_cmp_cat_block %>%
                      group_by(subj,block_train) %>%
                      mutate(dprime_rank = rank(dprime,ties.method = "first"))

k = 3
prop_select_topk <- prop_select_ranked %>%
                    filter(block_train %in% c(4,5,6)) %>%
                    filter(dprime_rank <= k) %>%
                    group_by(subj) %>%
                    summarize(mean_prop_cat = sum(prop_cat)/n_distinct(block_train)) %>%
                    ungroup() %>%
                    mutate(group = ntile(mean_prop_cat,5))

mean_dist_select <- select_dist_train %>%
                    # filter(block %in% c(4,5,6)) %>%
                    group_by(subj) %>%
                    summarize(mean_dist = mean(dist_select))

num_rep_select <- num_rep_cat_train %>%
                  filter(block %in% c(4,5,6)) %>%
                  group_by(subj) %>%
                  summarize(num_rep = sum(num_cat)/n_distinct(block)) %>%
                  ungroup()

#-------------------------------------
# create correlation plots
cor_coef <- round(cor(prop_select_topk$mean_prop_cat, accu_test$Pr_corr_sub), 2)
df <- data.frame(x = prop_select_topk$mean_prop_cat,
                 y = accu_test$Pr_corr_sub)

# Create the scatter plot with the line of best fit
p <- ggplot(df, aes(x = x, y = y)) +
     geom_point() +  
     geom_smooth(method = "lm", se = FALSE, color = "red") + 
     ggtitle("") +
     xlab("Selection Proportion") +
     ylab("Test Accuracy") + 
     theme_pubr() +
     geom_text(x = Inf, y = Inf, label = paste("R = ", cor_coef), 
               vjust = 2, hjust = 2, size = 6, color = "black")  

ggsave("Blockmid_Low3.png",p, path = "strategy figures/maxFA", width = 8, height = 8)
#-------------------------------------
# create stacked area charts for subgroups of subjects

area_chart_df <- left_join(prop_cmp_cat_block,prop_select_topK,by = join_by(subj)) %>%
                 group_by(subj,block_train) %>%
                 mutate(dprime_rank = rank(dprime,ties.method = "first"),
                        dprime_rank = as.factor(dprime_rank)) %>%
                 group_by(group,block_train,dprime_rank) %>%
                 summarize(prop_cat_by_group = mean(prop_cat)) %>%
                 ungroup()
  

area_chart <-  ggplot(data = area_chart_df, 
                      aes(x = block_train, y = prop_cat_by_group, fill = dprime_rank)) +
               geom_area(position = 'stack') +
               geom_line(color = "black", position = position_stack(vjust = 0)) +
               facet_wrap(~group) +
               labs(x = "Training Block", y = "Response Proportion", fill = "Category Rank", title = "Proportions of Category Selection") +
               scale_x_continuous(breaks = c(4,5,6)) +
               scale_fill_manual(values = colorRampPalette(c("red", "green"))(10)) +
               theme_pubr() 
                 
#-------------------------------------
# create clustergram for selection distances
color_vals = colorRampPalette(c("black","white"))(100)
clustergram_matrix <- select(select_dist_train,c(subj,block,trial,dist_select)) %>%
                      group_by(subj) %>%
                      mutate(col_draw = row_number()) %>%
                      select(-c(block,trial)) %>%
                      spread(col_draw,dist_select) %>%
                      ungroup() %>%
                      as.data.frame()

rownames(clustergram_matrix) <- clustergram_matrix$subj

annotation_row <- data.frame(TestAccuracy = accu_test$Pr_corr_sub)
rownames(annotation_row) <- accu_test$subj

library(pheatmap)
select(clustergram_matrix, -subj) %>%
pheatmap(main = "Clustered Heatmap of Selection Distances",
         show_colnames = FALSE,
         annotation_row = annotation_row, 
         clustering_method = "ward.D2",
         cutree_rows = 2, gaps_col = seq(15,15*9,by = 15),
         color = color_vals,
         cluster_cols = FALSE,
         fontsize_row = 5)

#-------------------------------------
# create clustergram for category selection repetition
color_vals = colorRampPalette(c("black","white"))(100)
# color_vals = colorRampPalette(c("white","black"))(100)
clustergram_matrix <- num_rep_cat_train %>%
                      group_by(subj) %>%
                      arrange(block,stats_cat) %>%
                      mutate(col_draw = row_number()) %>%
                      select(-c(block,stats_cat)) %>%
                      spread(col_draw,num_cat) %>%
                      ungroup() %>%
                      as.data.frame()

rownames(clustergram_matrix) <- clustergram_matrix$subj

annotation_row <- data.frame(TestAccuracy = accu_test$Pr_corr_sub)
rownames(annotation_row) <- accu_test$subj

annotation_col <- data.frame(category = rep(cat_levels,9),
                             block = rep(1:9,each = 8))

library(pheatmap)
pheatmap_results <- select(clustergram_matrix, -subj) %>%
  pheatmap(main = "Clustered Heatmap of Category Selection Repetition",
           show_colnames = FALSE,
           annotation_row = annotation_row, annotation_col = annotation_col,
           clustering_method = "ward.D2",
           cutree_rows = 4, gaps_col = seq(8,8*9,by = 8),
           color = color_vals,
           cluster_cols = FALSE,
           fontsize_row = 5)

#-------------------------------------
# create clustergram for dprime and selection proportions
# color_vals = colorRampPalette(brewer.pal(11, 'Spectral'))(100)
color_vals = colorRampPalette(c("white","black"))(100)
clustergram_matrix <- #select(prop_cmp_cat_block,c(subj,block_train,stats_cat,dprime,prop_cat)) %>%
                      #group_by(subj,block_train) %>%
                      #mutate(rec_norm = (1-dprime+0.125)/sum(1-dprime+0.125),
                      #       dprime = NULL) %>%
                      #ungroup() %>%
                      #gather(key = "block_stats",value = "measurement",rec_norm,prop_cat) %>%
                      #arrange(subj,block_train,stats_cat,block_stats) %>%
                      select(prop_cmp_cat_block,c(subj,block_train,stats_cat,prop_cat)) %>%
                      arrange(subj,block_train,stats_cat) %>%
                      group_by(subj) %>%
                      mutate(col_draw = row_number()) %>%
                      #select(-c(block_train,stats_cat, block_stats)) %>%
                      #spread(col_draw,measurement) %>%
                      select(-c(block_train,stats_cat)) %>%
                      spread(col_draw,prop_cat) %>%
                      ungroup() %>%
                      as.data.frame()

# clustergram_matrix <- mutate(prop_select_ranked,dprime_rank = as.factor(dprime_rank)) %>%
#                       select(subj,block_train,dprime_rank,prop_cat) %>%
#                       arrange(subj,block_train,dprime_rank) %>%
#                       group_by(subj) %>%
#                       mutate(col_draw = row_number()) %>%
#                       select(-c(block_train,dprime_rank)) %>%
#                       spread(col_draw,prop_cat) %>%
#                       ungroup() %>%
#                       as.data.frame()

rownames(clustergram_matrix) <- clustergram_matrix$subj

annotation_row <- data.frame(TestAccuracy = accu_test$Pr_corr_sub)
rownames(annotation_row) <- accu_test$subj

cat_names <- c("Andesite", "Basalt", "Diorite", "Gabbro", "Obsidian", "Pegmatite", "Peridotite", "Pumice")
annotation_col <- data.frame(category = rep(rep(cat_names,each = 1),8))#change each param to 2
# annotation_col <- data.frame(cat_ranking = as.factor(rep(1:8,8)))


library(pheatmap)
pheatmap_results <- select(clustergram_matrix, -subj) %>%
                    pheatmap(main = "Clustered Heatmap of category selection",
                             show_colnames = FALSE, 
                             annotation_row = annotation_row, annotation_col = annotation_col,
                             clustering_method = "ward.D2",
                             cutree_rows = 2, gaps_col = seq(8,8*8,by = 8),
                             color = color_vals,
                             cluster_cols = FALSE,
                             fontsize_row = 5)

#-------------------------------------
# clustering analysis of test accuracy
cluster_assignments = cutree(pheatmap_results$tree_row, k = 4)
main_cluster = which.max(table(cluster_assignments))
subj_main_cluster = clustergram_matrix$subj[cluster_assignments == main_cluster]
subj_other_clusters = clustergram_matrix$subj[cluster_assignments != main_cluster]
plot_data <- mutate(accu_test,
                    cluster = ifelse(subj %in% subj_main_cluster,1,2),
                    cluster = as.factor(cluster))

ggplot(plot_data, aes(x = cluster, y = Pr_corr_sub, color = cluster)) +
  geom_boxplot(width = 0.3, outlier.shape = NA) +  
  geom_jitter(width = 0.05, alpha = 0.7) +  
  theme_minimal() +  # Minimal theme
  labs(title = "End-of-Training Test Accuracy by clusters",
       x = "Training Category Repetition Pattern",
       y = "Test Accuracy") +
  theme_pubr() +
  theme(panel.grid.major.y = element_line(color = "grey80"))



#-------------------------------------
# correlation analyses between variables of interest
panel.cor <- function(x, y, digits = 2, prefix = "", cex.cor, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(0, 1, 0, 1))
  r <- abs(cor(x, y, use = "complete.obs"))
  txt <- format(c(r, 0.123456789), digits = digits)[1]
  txt <- paste(prefix, txt, sep = "")
  if (missing(cex.cor)) cex.cor <- 0.8/strwidth(txt)
  text(0.5, 0.5, txt, cex =  cex.cor * (1 + r) / 2)
}

panel.hist <- function(x, ...) {
  usr <- par("usr")
  on.exit(par(usr))
  h <- hist(x, plot = FALSE, breaks = 12)  
  y <- h$counts
  y <- y / max(y)
  xleft <- h$breaks[1]
  xright <- h$breaks[length(h$breaks)]
  par(usr = c(xleft, xright, 0, 1.1))
  rect(h$breaks[-length(h$breaks)], 0, h$breaks[-1], y, col = col, ...)
}

panel.lm <- function(x, y, col = par("col"), bg = NA, pch = par("pch"), cex = 1, col.smooth = "black", ...) {
  # Determine the range for x and y
  xrange <- range(x, na.rm = TRUE)
  yrange <- range(y, na.rm = TRUE)
  
  # Extend the ranges slightly to ensure points are not on the edge
  xdiff <- xrange[2] - xrange[1]
  ydiff <- yrange[2] - yrange[1]
  xrange <- xrange + c(-0.05 * xdiff, 0.05 * xdiff)
  yrange <- yrange + c(-0.05 * ydiff, 0.05 * ydiff)
  
  usr <- par("usr")
  on.exit(par(usr))
  par(usr = c(xrange[1], xrange[2], yrange[1], yrange[2]))
  
  points(x, y, pch = pch, col = col, bg = bg, cex = cex)
  abline(lm(y ~ x), col = col.smooth, ...)
}

scatterplot_df <- data.frame(Location = mean_dist_select$mean_dist,
                             Diff_Cat = prop_select_topK$prop_cat,
                             Performance = accu_test$Pr_corr_sub)
pairs(
  scatterplot_df,
  upper.panel = panel.cor,
  diag.panel  = panel.hist,
  lower.panel = panel.lm
)

  

  


