if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(xts,yaml,optparse, tibble,here,tidyverse,roll,R6,broom,quantmod,tseries,PerformanceAnalytics,tseries,psych)

data_path.str <- "c:\\todo-p\\UW\\Master-Thesis-analysis\\data\\3mln_9month\\20231106\\"
main_proj_path.str <- "c:\\todo-p\\UW\\Master-Thesis\\"


setwd(main_proj_path.str)
source(paste0(main_rcode_path.str,"rcode\\logic\\strategy.r"))
source("c:\\todo-p\\UW\\Master-Thesis\\master\\rcode\\logic\\strategy.r")
source("c:\\todo-p\\UW\\Master-Thesis\\master\\rcode\\logic\\helpers\\metrics_helper.r")
source("c:\\todo-p\\UW\\Master-Thesis\\master\\rcode\\logic\\helpers\\datetime_helper.r")

positions.xts <- readRDS( paste0(data_path.str,"04_positions.rds"))
basic_asset_1min.xts <- readRDS( paste0(data_path.str,"01_converted_to_xts.rds"))

#TODO add  date filter 
asset_ret_xts <- getLogReturns(positions.xts$Asset) 

asset_ret_xts[is.na(asset_ret_xts),] <- 0

asset_ret_xts <- 100*asset_ret_xts
#
basic_asset_desc_tbl <- describe(asset_ret_xts, quant=c(.25,.75))
#=================== Trading statistics ============================================



get_basic_stats <- function(returns.xts, freq=0) {
  sharpe_ratio  <- sharpe(returns.xts, freq=freq)
  max_drawdown  <- maxDrawdown(returns.xts)
  sortino_ratio <- sortino_ratio(returns.xts, freq = freq)
  information_ratio2 <- ir2(rets =returns.xts, freq = freq )
  annualized_volatility <- sqrt(freq) * sd(returns.xts)
  annaulized_mean_return <- freq *mean(returns.xts)  
  
  trading_statistics_df <- data.frame(annaulized_mean_return,annualized_volatility, sharpe_ratio,information_ratio2, max_drawdown, sortino_ratio)
  return(trading_statistics_df)
}




#=================== Differnt TF statistic =========================================

params_yaml <- yaml::read_yaml(paste0(data_path.str, "params.yaml"))
tf.vec <- c(1,5,10,15, 30, 60)

single_asset.xts <- basic_asset_1min.xts[,params_yaml$general$asset]
basic_bh_stats_list <- list()
basic_desc_stats_list <- list()
for ( time_frequency in tf.vec) {
  print(paste(" Doing statistics for current tf " , time_frequency))
  print(head(downsample.xts(single_asset.xts, time_frequency)))
  current_data.xts <- downsample.xts(single_asset.xts, time_frequency)
  asset_ret_xts <- getLogReturns(current_data.xts) 
  asset_ret_xts[is.na(asset_ret_xts),] <- 0
  freq <- calc_frequency_per_day(time_frequency) * 365
  basic_bh_stats.df <- get_basic_stats(asset.ret.xts, freq)
  basic_bh_stats.df <- cbind(time_frequency,basic_bh_stats.df)  
  basic_bh_stats_list <- append(basic_bh_stats_list, list(basic_bh_stats.df))
  
  
  basic_desc_tbl <- describe(asset_ret_xts, quant=c(.25,.75))
  basic_desc_tbl <- cbind(time_frequency,basic_desc_tbl)    
  basic_desc_stats_list <- append(  basic_desc_stats_list, list(basic_desc_tbl))
  
  print("================")
  
}

trading_statistics_df <- do.call("rbind", basic_bh_stats_list)
basic_asset_desc_tbl <- do.call("rbind", basic_desc_stats_list)

dc.obj$add_data(trading_statistics_df, filename = "trading_statistics_df", data_desc ="basic_stats.r Trading data description  " )
dc.obj$add_data(basic_asset_desc_tbl, filename = "basic_asset_desc_tbl", data_desc ="basic_stats.r Basic data description  " )
dc.obj$save_all_data()
