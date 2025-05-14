library(tidyverse)
library(jsonlite)

MDS_df = read.csv("rocksmds_cleaned.csv")
num_cats = n_distinct(MDS_df$cat)
cat_names = unique(MDS_df$cat)
dist_cat = vector("numeric",num_cats^2)
sim_cat = vector("numeric",num_cats^2)
ref_cat = vector("character",num_cats^2)
pair_cat = vector("character",num_cats^2)
df_idx = 0
for (i in 1:num_cats){
  for (j in 1:num_cats){
    ref_cat_name = cat_names[i]
    paired_cat_name = cat_names[j]
    token_idx_ref_cat = with(MDS_df,unique(token[cat == ref_cat_name]))
    token_idx_pair_cat = with(MDS_df,unique(token[cat == paired_cat_name]))
    cat_pair_df = filter(MDS_df,cat %in% c(ref_cat_name,paired_cat_name))
    dist_token = matrix(NA, nrow = length(token_idx_ref_cat), ncol = length(token_idx_pair_cat))
    sim_token = matrix(NA, nrow = length(token_idx_ref_cat), ncol = length(token_idx_pair_cat))
    for (m in 1:length(token_idx_ref_cat)){
      for (n in 1:length(token_idx_pair_cat)){
        token_idx_ref = token_idx_ref_cat[m]
        token_idx_pair = token_idx_pair_cat[n]
        ref_token_coord = filter(cat_pair_df,cat == ref_cat_name,token == token_idx_ref) %>% pull()
        pair_token_coord = filter(cat_pair_df,cat == paired_cat_name,token == token_idx_pair) %>% pull()
        dist_token[m,n] = sqrt(sum((ref_token_coord - pair_token_coord)^2))
        sim_token[m,n] = exp(-0.5*dist_token[m,n])
      }
    }
    df_idx = df_idx + 1
    dist_cat[df_idx] = sum(dist_token)/length(dist_token)
    sim_cat[df_idx] = sum(sim_token)/length(sim_token)
    ref_cat[df_idx] = ref_cat_name
    pair_cat[df_idx] = paired_cat_name 
  }
}
output_df <-  data.frame(ref = ref_cat, pair = pair_cat, 
                         distance = dist_cat, similarity = sim_cat)

# json_data <- toJSON(output_df, pretty = FALSE)
# json_data_no_quotes <- gsub('"([a-zA-Z0-9_]+)"\\s*:', '\\1:', json_data)
# json_data_single_line <- gsub('\\{\\s+', '{', json_data_no_quotes)
# json_data_single_line <- gsub('\\s+\\}', '}', json_data_single_line)
# json_data_with_newlines <- gsub('},', '},\n', json_data_single_line)
# cat(json_data_with_newlines)