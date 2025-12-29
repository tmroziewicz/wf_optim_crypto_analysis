if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(xts,dplyr,psych)

subset_column <- function(data_xts , col_to_select ) {
  return (data_xts[,col_to_select])
}

add_day_hour_feature <- function(data_xts) {
  data_xts$day_of_week <- .indexwday(data_xts)
  data_xts$hour <- .indexhour(data_xts)
  return(data_xts)
}

transform_to_df <- function(data_xts) {
  return (as.data.frame(coredata(data_xts)))
}

get_daily_hourly_seasonality <- function(data_xts) {
  print("get_daily_hourly_seasonality")
  return(data_xts)
}
get_hourly_seasonality <- function(data_xts) {
  print("get_hourly_seasonality")
  return(data_xts)
}

do_ttest_wilcox <- function(data_xts, day_of_week="", hour="", col_to_select) {
  table_name_str <- deparse(substitute(data_xts)) 
  
  sum_str <-   paste("p.value = t.test(",col_to_select,",", table_name_str,"$",col_to_select,")$p.value ")
  
  sum_str_2 <- paste("p.value.wilcox =wilcox.test(",col_to_select,",", table_name_str,"$",col_to_select,")$p.value")
  
  data_xts %>% group_by(!!sym(day_of_week),!!sym(hour)) %>% summarise(!!rlang::parse_expr(sum_str), !!rlang::parse_expr(sum_str_2))
  #data_xts %>% group_by(!!sym(day_of_week),!!sym(hour)) %>% summarise(p.value.ttest = t.test(Asset, data_xts$Asset)$p.value, p.value.wilcox =wilcox.test(Asset, data_xts$Asset)$p.value)
}

get_seasonality <- function(data_xts, day_of_week=FALSE, hour=FALSE, col_to_select) {
  print("get_seasonality")
  
  print(head(data_xts))
  print(col_to_select)
  p_val_colnames <-  c("p.value.ttest","p.value.wilcox")
  
  day_hour_col <- c()
  if( eval(parse(text=day_of_week))) {
    day_of_week="day_of_week"
    day_hour_col <- append(day_hour_col, day_of_week)
  } else {
    day_of_week <- ""
  }
  if(eval(parse(text=hour))  ) {
    hour <- "hour"
    day_hour_col <- append(day_hour_col, hour)
  } else {
    hour <- ""
  }
  
    
  p_value_df <- do_ttest_wilcox(data_xts, day_of_week,hour, col_to_select)
  
  colnames(p_value_df) <-  c(day_hour_col, p_val_colnames)
  
  data_xts %>% group_by(!!sym(day_of_week),!!sym(hour)) %>%  summarise(describe(!!sym(col_to_select))) -> seasonality_df 
  
  result_df  <- bind_cols(seasonality_df,p_value_df[,p_val_colnames])
  
  return(result_df)
}
