# Install and load necessary packages
library(grDevices)
library(png)
library(grid)
library(gridExtra)
library(dplyr)

# Set the directory where the PNG files are stored
path <- "../experiment code/rocksall480/"

# Read in the token count file
subj_sample_data <- read.csv(file = "Item Sampling Pattern.csv") %>%
                    filter(subj == 2) 


############################
read_img <- function(data,i) {
  i_token <- sprintf("%02d",data$token[i])
  i_cat <- data$cat[i]
  filename <- paste0(path,"I_",i_cat,"_",i_token,".png")
  img <- readPNG(filename)
  img_grob <- rasterGrob(img, interpolate=TRUE)
  
  # Add index and accuracy to the top of each image
  count_token <- data$token_count[i]
  annotated_img <- gTree(children=gList(img_grob, 
                                        textGrob(label = paste0(i_cat, "_", i_token), 
                                                 x = 0.3, #0.1
                                                 y = 0.95, 
                                                 gp = gpar(col = "black", fontsize = 14)),
                                        textGrob(label = count_token,
                                                 x = 0.5,
                                                 y = 0.5,
                                                 gp = gpar(col = "white", fontsize = 14))))
  return(annotated_img)
}

# Read the images
img_list <- lapply(1:nrow(subj_sample_data), read_img, data = subj_sample_data)

# Create a grid of images
grid.arrange(
  grobs = img_list,
  ncol = 8
)





