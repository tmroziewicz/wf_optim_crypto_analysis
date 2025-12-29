if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(xts,yaml,tibble,here,tidyverse,roll,R6,broom,quantmod,tseries,PerformanceAnalytics,tseries,psych)

source("..\\Master-Thesis\\master\\rcode\\logic\\helpers\\metrics_helper.r")
source("..\\Master-Thesis\\master\\rcode\\logic\\helpers\\datetime_helper.r")
source("..\\Master-Thesis\\master\\rcode\\logic\\helpers\\data_helper.r")


#=================== Seasonality statistics ============================================
positions.xts <- readRDS( "c:\\todo-p\\UW\\Master-Thesis-analysis\\data\\3mln_9month\\20231106\\04_positions.rds")


asset_ret_xts <- getLogReturns(positions.xts$Asset) 

asset_ret_xts[is.na(asset_ret_xts),] <- 0

asset_ret_xts$day_of_week <- .indexwday(asset_ret_xts)

asset_ret_xts$hour <- .indexhour(asset_ret_xts)

data_df <- as.data.frame(coredata(asset_ret_xts))


hist(data_df[data_df$day_of_week==6,]$Asset,breaks=100)

hist(data_df$Asset,breaks=100)
data_df$day_of_week <- as.factor(data_df$day_of_week)

data_df$hour <- as.factor(data_df$hour)

str(data_df)

one.way <- aov(Asset ~ day_of_week, data = data_df)
summary(one.way)

one.way.hour <- aov(Asset ~ hour, data = data_df)
summary(one.way.hour)

library(ggplot2)

ggplot(data_df) +
  aes(x = day_of_week, y = Asset, color = day_of_week) +
  geom_jitter() +
  theme(legend.position = "none")

qqnorm(one.way.hour$residuals)

kruskal.test(data_df$Asset, data_df$hour )

t.test_result <- t.test(data_df[data_df$day_of_week==2,]$Asset, data_df$Asset)

wilcox.t <- wilcox.test(data_df[data_df$day_of_week==1,]$Asset, data_df$Asset)
wilcox.t$p.value
t.test_result$p.value

sum_str <- "p.value = t.test(Asset, data_df$Asset)$p.value "
sum_str_2 <- "p.value.wilcox =wilcox.test(Asset, data_df$Asset)$p.value"
sum_expr <- rlang::enquo(sum_str)

sumarise_custom <- function(data) {
  summarise(p.value = t.test(data, data$Asset)$p.value, p.value.wilcox =wilcox.test(data, data$Asset)$p.value)
}
s <- summarise(p.value = t.test(Asset, data_df$Asset)$p.value, p.value.wilcox =wilcox.test(Asset, data_df$Asset)$p.value)

data_df %>% group_by(day_of_week) %>% summarise(p.value = t.test(Asset, data_df$Asset)$p.value, p.value.wilcox =wilcox.test(Asset, data_df$Asset, )$p.value)
data_df %>% group_by(hour) %>% summarise(p.value = t.test(Asset, data_df$Asset)$p.value, p.value.wilcox =wilcox.test(Asset, data_df$Asset)$p.value)
data_df %>% group_by(day_of_week,hour) %>% summarise(n=n(),p.value.ttest = t.test(Asset, data_df$Asset)$p.value, p.value.wilcox =wilcox.test(Asset, data_df$Asset)$p.value) -> p_value_ttest_daily_hourly
data_df %>% group_by(day_of_week,hour) %>% summarise(!!rlang::parse_expr(sum_str), !!rlang::parse_expr(sum_str_2))


#do_ttest_wilcox(data_df, "day_of_week", "hour", "Asset")


p_values_day <- data_df %>% group_by(day_of_week) %>% summarise(!!rlang::parse_expr(sum_str), !!rlang::parse_expr(sum_str_2)) 
p_values_hour <- data_df %>% group_by(hour)        %>% summarise(!!rlang::parse_expr(sum_str), !!rlang::parse_expr(sum_str_2))
p_values_day_hour <- data_df %>% group_by(day_of_week,hour)        %>% summarise(!!rlang::parse_expr(sum_str), !!rlang::parse_expr(sum_str_2))

p_val_colnames <-  c("p.value.ttest","p.value.wilcox")
colnames(p_values_day) <-  c(c('day'), p_val_colnames)
colnames(p_values_hour) <-  c(c('hour'), p_val_colnames)
colnames(p_values_day_hour) <-  c(c('day','hour'), p_val_colnames)


daily_hourly_seasonality_asset_df <- get_seasonality(data_df, "day_of_week","","Asset")


daily_hourly_seasonality_asset_df[daily_hourly_seasonality_asset_df$p.value.ttest < 0.1,]


data_df %>% group_by(day_of_week) %>% group_map(~ t.test(.$Asset, data_df$Asset))

data_df %>% 
  group_by(day_of_week) %>% 
  summarise(d = mean(Asset))

mean(data_df[data_df$day_of_week==0,]$Asset)
#============================================= Saving data =========================================
data_df %>% group_by(day_of_week) %>%  summarise(describe(Asset)) -> weekly_seasonality_asset_df 
weekly_seasonality_asset_df  <- cbind(weekly_seasonality_asset_df,p_values_day[,p_val_colnames])

dc.obj$add_data(weekly_seasonality_asset_df, filename = "weekly_seasonality_asset_df", data_desc ="basic_stats.r Weekly seasonality for asset " )

data_df %>% group_by(hour) %>%  summarise(describe(Asset)) -> hourly_seasonality_asset_df 
hourly_seasonality_asset_df  <- cbind(hourly_seasonality_asset_df,p_values_hour[,p_val_colnames])

dc.obj$add_data(hourly_seasonality_asset_df, filename = "hourly_seasonality_asset_df", data_desc ="basic_stats.r hourly seasonality for asset " )

data_df %>% group_by(day_of_week,hour) %>%  summarise(describe(Asset)) -> daily_hourly_seasonality_asset_df 

daily_hourly_seasonality_asset_df  <- cbind(as.data.frame(daily_hourly_seasonality_asset_df),p_values_day_hour[,p_val_colnames])

daily_hourly_seasonality_asset_df <- daily_hourly_seasonality_asset_df %>% filter(p.value.wilcox <0.1 )
dc.obj$add_data(daily_hourly_seasonality_asset_df, filename = "daily_hourly_seasonality_asset_df", data_desc ="basic_stats.r hourly seasonality for asset " )

dc.obj$save_all_data()
