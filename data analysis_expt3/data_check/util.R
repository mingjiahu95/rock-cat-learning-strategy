create_ridge_plot <- function(data, x_col, y_col, bin_width, x_label = x_col, y_label = y_col, avg_fun = median) {
  
  x_range <- range(data[[x_col]], na.rm = TRUE)
  x_breaks <- seq(floor(x_range[1] / bin_width) * bin_width, 
                  ceiling(x_range[2] / bin_width) * bin_width, 
                  by = bin_width)
  
  avg_values <- data %>% 
    group_by(!!sym(y_col)) %>% 
    summarize(avg_x = avg_fun(!!sym(x_col), na.rm = TRUE)) %>%
    mutate(y_start_pos = row_number(!!sym(y_col)),
           y_end_pos = y_start_pos + 0.9)
  
  ggplot(data, aes(x = !!sym(x_col), y = !!sym(y_col), group = !!sym(y_col))) +
    geom_density_ridges2(
      color = "black",
      fill = "white",
      stat = "binline",
      binwidth = bin_width,
      scale = 0.9
    ) +
    geom_text(
      stat = "bin",
      aes(y = group + after_stat(count / max(count)) * 0,
          label = ifelse(after_stat(count) > 0, after_stat(count), "")),
      vjust = -0.5, size = 3, color = "black", binwidth = bin_width
    ) +
    geom_segment(data = avg_values, 
                 mapping = aes(x = avg_x, xend = avg_x, 
                               y = y_start_pos, 
                               yend = y_end_pos),
                 color = "red", linetype = "dashed") +
    scale_x_continuous(breaks = x_breaks, labels = x_breaks) +
    scale_y_discrete(expand = c(0, 1.2)) + #change for y axis clipping
    xlab(x_label) +
    ylab(y_label) + 
    coord_cartesian(clip = "off") +
    theme_bw(base_size = 15) +
    theme(panel.grid.minor = element_blank(),
          axis.text.x = element_text(vjust = 1))
}

create_ridge_plot_filtered <- function(data, data_filtered, x_col, y_col, bin_width, x_label = x_col, y_label = y_col, avg_fun = median) {
  
  x_range <- range(data[[x_col]], na.rm = TRUE)
  x_breaks <- seq(floor(x_range[1] / bin_width) * bin_width, 
                  ceiling(x_range[2] / bin_width) * bin_width, 
                  by = bin_width)
  
  stats_old <- data %>% 
    group_by(!!sym(y_col)) %>% 
    summarize(avg_x_old = avg_fun(!!sym(x_col), na.rm = TRUE)) %>%
    mutate(y_start_pos = row_number(!!sym(y_col)),
           y_end_pos = y_start_pos + 0.9)
  
  stats_values <- data_filtered %>% 
    group_by(!!sym(y_col)) %>% 
    summarize(avg_x_new = avg_fun(!!sym(x_col), na.rm = TRUE),
              cutoff_x = min(!!sym(x_col)), na.rm = TRUE) %>%
    right_join(stats_old, by = y_col)
  
  ggplot(data, aes(x = !!sym(x_col), y = !!sym(y_col), group = !!sym(y_col))) +
    geom_density_ridges2(
      color = "black",
      fill = "white",
      stat = "binline",
      binwidth = bin_width,
      scale = 0.9
                        ) +
    geom_text(
      stat = "bin",
      aes(y = group + after_stat(count / max(count)) * 0,
          label = ifelse(after_stat(count) > 0, after_stat(count), "")),
      vjust = -0.5, size = 3, color = "black", binwidth = bin_width
             ) +
    geom_segment(data = stats_values, 
                 mapping = aes(x = avg_x_old, xend = avg_x_old, 
                               y = y_start_pos, 
                               yend = y_end_pos),
                 color = "black", linetype = "dashed") +
    geom_segment(data = stats_values, 
                 mapping = aes(x = avg_x_new, xend = avg_x_new, 
                               y = y_start_pos, 
                               yend = y_end_pos),
                 color = "red", linetype = "dashed") +
    geom_segment(data = stats_values, 
                 mapping = aes(x = cutoff_x, xend = cutoff_x, 
                               y = y_start_pos, 
                               yend = y_end_pos),
                 color = "red", linetype = "solid") +
    scale_x_continuous(breaks = x_breaks, labels = x_breaks) +
    scale_y_discrete(expand = c(0, 1.2)) + #change for y axis clipping
    xlab(x_label) +
    ylab(y_label) + 
    coord_cartesian(clip = "off") +
    theme_bw(base_size = 15) +
    theme(panel.grid.minor = element_blank(),
          axis.text.x = element_text(vjust = 1))
}

compute_dprime <- function(df, cat_col, resp_col, cat_value, agg_fun = mean) {
  stats <- df %>%
    group_by(is_target = {{cat_col}} == cat_value,{{cat_col}}) %>%
    summarise(H_FA = mean({{resp_col}} == cat_value, na.rm = TRUE), .groups = 'drop') %>%
    summarise(H = H_FA[is_target], FA = agg_fun(H_FA[!is_target], na.rm = TRUE)) %>% #aggregation function can be changed to mean
    mutate(dprime = H - FA, stats_cat = cat_value) %>%
    select(H, FA, dprime, stats_cat)

  return(stats)
}


compute_exponential_cumsum <- function(blocks, values, lambda) {
  sapply(seq_along(blocks), function(i) {
    weights = exp(-lambda * (blocks[i] - blocks[1:i]))
    sum(values[1:i] * weights) / sum(weights)
  })
}


# ------------------------------------------------------------------------------------------------------------
# create_ridge_plot_stacked <- function(data, x_col, y_col, fill_col, bin_width, x_label = x_col, y_label = y_col, fill_label = fill_col, avg_fun = median) {
#   
#   x_range <- range(data[[x_col]], na.rm = TRUE)
#   x_breaks <- seq(floor(x_range[1] / bin_width) * bin_width, 
#                   ceiling(x_range[2] / bin_width) * bin_width, 
#                   by = bin_width)
#   
#   avg_values <- data %>% 
#     group_by(!!sym(y_col)) %>% 
#     summarize(avg_x = avg_fun(!!sym(x_col), na.rm = TRUE)) %>%
#     mutate(y_start_pos = row_number(!!sym(y_col)),
#            y_end_pos = y_start_pos + 0.9)
#   
#   ggplot(data, aes(x = !!sym(x_col), y = !!sym(y_col), group = !!sym(y_col))) +
#     geom_density_ridges2(
#       aes(fill = !!sym(fill_col)),
#       color = "black",
#       stat = "binline",
#       binwidth = bin_width,
#       scale = 0.9
#     ) +
#     geom_text(
#       stat = "bin",
#       aes(y = group + after_stat(count / max(count)) * 0,
#           label = ifelse(after_stat(count) > 0, after_stat(count), "")),
#       vjust = -0.5, size = 3, color = "black", binwidth = bin_width
#     ) +
#     geom_segment(data = avg_values, 
#                  mapping = aes(x = avg_x, xend = avg_x, 
#                                y = y_start_pos, 
#                                yend = y_end_pos),
#                  color = "red", linetype = "dashed") +
#     scale_x_continuous(breaks = x_breaks, labels = x_breaks) +
#     scale_y_discrete(expand = c(0, 1.2)) + #change for y axis clipping
#     scale_fill_manual(name = fill_label) +
#     xlab(x_label) +
#     ylab(y_label) + 
#     coord_cartesian(clip = "off") +
#     theme_bw(base_size = 15) +
#     theme(panel.grid.minor = element_blank(),
#           axis.text.x = element_text(vjust = 1))
# }