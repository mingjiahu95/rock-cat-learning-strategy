# Install and load necessary packages
library(grDevices)
library(png)
library(grid)
library(gridExtra)
library(ggplot2)

# Set the directory where the PNG files are stored
path <- "../experiment code/rocksall480/"

# Function to read the PNG images
accu_data_R <- read.csv(file = "Item Classification Accuracy_R.csv") #change between conditions
accu_data_SC <- read.csv(file = "Item Classification Accuracy_SC.csv") #change between conditions
# # Define color palette
# palette_func <- colorRamp(c("red","green"), space = "rgb")
# get_color <- function(value){rgb_val <- palette_func(value)
#                              rgb(rgb_val[1], rgb_val[2], rgb_val[3], maxColorValue = 255)}
############################
read_img <- function(cat,token,accu_data_R,accu_data_SC) {
  type_list <- c("Andesite","Basalt","Diorite","Gabbro","Obsidian","Pegmatite","Peridotite","Pumice")
  rocktype <- type_list[cat]
  j_rock <- unique(accu_data_R$token[accu_data_R$cat == rocktype])[token] # check if the values match that of SC file
  j_char <- sprintf("%02d", j_rock)
  filename <- paste0(path,"I_",rocktype,"_",j_char,".png")
  img <- readPNG(filename)
  img_grob <- rasterGrob(img, interpolate=TRUE, gp = gpar(alpha = .2))
  
  # Add index and accuracy to the top of each image
  accu_token_R <- with(accu_data_R,Pr_corr[cat == rocktype & token == j_rock])
  accu_cat_vec_R <- with(accu_data_R,Pr_corr[cat == rocktype])
  accu_token_SC <- with(accu_data_SC,Pr_corr[cat == rocktype & token == j_rock])
  accu_cat_vec_SC <- with(accu_data_SC,Pr_corr[cat == rocktype])
  accu_cat_vec_both <- c(accu_cat_vec_R,accu_cat_vec_SC)
  # color_val_R <- (accu_token_R - min(accu_cat_vec_both))/(max(accu_cat_vec_both) - min(accu_cat_vec_both))
  # color_val_SC <- (accu_token_SC - min(accu_cat_vec_both))/(max(accu_cat_vec_both) - min(accu_cat_vec_both))
  text_R = paste("R cond:\n",round(accu_token_R,3))
  text_SC = paste("SC cond:\n",round(accu_token_SC,3))
  annotated_img <- gTree(children=gList(img_grob, 
                                        textGrob(label = j_char, 
                                                 x = .08, 
                                                 y = 0.95, 
                                                 gp = gpar(col = "black", fontsize = 20,fontface = "bold")),
                                        textGrob(label = text_R,
                                                 x = .08,
                                                 y = 0.8,
                                                 gp = gpar(col = "black", fontsize = 20)),#col = get_color(color_val_R)
                                        textGrob(label = text_SC,
                                                 x = .08,
                                                 y = 0.4,
                                                 gp = gpar(col = "black", fontsize = 20)) #col = get_color(color_val_SC)
                                        ))
  return(annotated_img)
}

# Read the images
type_list <- c("Andesite","Basalt","Diorite","Gabbro","Obsidian","Pegmatite","Peridotite","Pumice")
for (itype in 1:length(type_list)){
  
  img_list <- lapply(1:12, read_img, cat = itype,accu_data_R = accu_data_R,accu_data_SC = accu_data_SC)
  
  # Create a grid of images
  p <- grid.arrange(
    grobs = img_list,
    nrow = 4
  )
  ggsave(paste0(type_list[itype],".png"), p, width = 28, height = 15)
}






