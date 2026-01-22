library(xts)
library(dplyr) 
library(PerformanceAnalytics)
#library(psych)
library(tseries)
source("config.r")

source(paste0(WF_CRYPTO_REPO,"\\master\\rcode\\logic\\helpers\\metrics_helper.r"))
source(paste0(WF_CRYPTO_REPO,"\\master\\rcode\\logic\\helpers\\datetime_helper.r"))
source(paste0(WF_CRYPTO_REPO,"\\master\\rcode\\logic\\helpers\\data_helper.r"))

generate_heatmap <- function(experiment_df) {
  print(head(experiment_df))
  experiment_df %>% filter(general.tfmin ==60 & rev != "workspace" &  rev != "main" & typ !="baseline" &   grepl("global_train", general.raw_data)) %>% select( general.tfmin, general.performance_stat,sharpe_ratio,ir2,sortino_ratio, wf.train_length,wf.test_length ) -> exps_df
  sharpe_heatmap.df <- exps_df %>% filter( general.performance_stat == "sharpe" ) %>% distinct(wf.train_length, wf.test_length, sharpe_ratio, .keep_all = TRUE)
  print(head(sharpe_heatmap.df))
  return(sharpe_heatmap.df)  
}

get_mean_per_tf <- function(experiment_df) {
  print(head(experiment_df))
  experiment_df %>% filter(rev != "workspace" &  rev != "main" & typ !="baseline" &  grepl("global_train", general.raw_data) ) %>% select( general.tfmin, general.performance_stat,sharpe_ratio,wf.train_length,wf.test_length ) -> exps_df
  exps_df %>% group_by(general.tfmin) %>% summarise(mean.sharpe.per.tfmin = mean(sharpe_ratio), max.sharpe.per.tfmin = max(sharpe_ratio), min.sharpe.per.tfmin = min(sharpe_ratio), std.sharpe.per.tfmin = sd(sharpe_ratio),  quantile_25 = quantile(sharpe_ratio, probs=0.25 ), quantile_50 = quantile(sharpe_ratio, probs=0.50 ), quantile_75 = quantile(sharpe_ratio, probs=0.75 )) -> mean.sharpe.per.tf.df
  return (mean.sharpe.per.tf.df)
}


get_trading_stats <- function(returns.xts, freq=0) {
  sharpe_ratio  <- sharpe(returns.xts, freq=freq)
  max_drawdown  <- maxDrawdown(returns.xts)
  sortino_ratio <- sortino_ratio(returns.xts, freq = freq)
  information_ratio2 <- ir2(rets =returns.xts, freq = freq )
  annualized_volatility <- sqrt(freq) * sd(returns.xts)
  annaulized_mean_return <- freq *mean(returns.xts)  
  
  trading_statistics_df <- data.frame(annaulized_mean_return,annualized_volatility, sharpe_ratio,information_ratio2, max_drawdown, sortino_ratio)
  return(trading_statistics_df)
}


get_trading_stats_per_col <- function(col_rets_xts, freq=0) {
  if (is.character(freq)) {
    freq <- eval(parse(text=freq))  
  }
  print("Executing get_trading_stats_per_col")
  print(head(col_rets_xts))  
  print(paste("Second arg",freq))
  list_res <- lapply(col_rets_xts, get_trading_stats, freq)
  return (do.call("rbind",list_res ))
}

get_trading_stats_per_tf  <- function(basic_asset_1min.xts, tfs_str) {
  print("First argument")
  print(head(basic_asset_1min.xts))
  print(tail(basic_asset_1min.xts))
  
  print("Second argument")
  print(tfs_str)
  get_stats_per_tf(basic_asset_1min.xts,tfs_str,"get_trading_stats")
}

get_stats_per_tf <- function(basic_asset_1min.xts, tfs_str, fun_to_run) {
  print("get_stats_per_tf start ================")
  print(paste("Fun to run " ,fun_to_run ))
  print(paste(" this is list of tf", tfs_str))
  print(class(tfs_str))
  single_asset.xts <- basic_asset_1min.xts[,"1"] ##<- TODo this will strike back at some point 
  basic_desc_stats_list <- list()
  
  for ( time_frequency in tfs_str) {
    time_frequency <- as.integer(time_frequency)
    print(paste(" Doing statistics for current tf " , time_frequency))
    print(head(downsample.xts(single_asset.xts, time_frequency)))
    current_data.xts <- downsample.xts(single_asset.xts, time_frequency)
    asset_ret_xts <- getLogReturns(current_data.xts) 
    asset_ret_xts[is.na(asset_ret_xts),] <- 0
    freq <- calc_frequency_per_day(time_frequency) * 365
    
    tf_desc_df <- do.call(fun_to_run, list(asset_ret_xts, freq))
    #     basic_bh_stats.df <- get_basic_stats(asset_ret_xts, freq)
    #    basic_bh_stats.df <- cbind(time_frequency,basic_bh_stats.df)  
    #   basic_bh_stats_list <- append(basic_bh_stats_list, list(basic_bh_stats.df))
    
    
    #      basic_desc_tbl <- describe(asset_ret_xts, quant=c(.25,.75))
    tf_desc_df <- cbind(time_frequency,tf_desc_df)    
    basic_desc_stats_list <- append(  basic_desc_stats_list, list(tf_desc_df))
    
    print("================")
    
  }
  
  #trading_statistics_df <- do.call("rbind", basic_bh_stats_list)
  basic_asset_desc_tbl <- do.call("rbind", basic_desc_stats_list)
  print("get_stats_per_tf end ================")
  return(basic_asset_desc_tbl)
}




get_basic_stats_per_tf <- function(basic_asset_1min.xts, tfs_str) {
  #call here 
  print("First argument")
  print(head(basic_asset_1min.xts))
  print("Second argument")
  print(tfs_str)
  get_stats_per_tf(basic_asset_1min.xts,tfs_str,"get_describe_per_tf")
}

get_describe_per_tf <- function(asset_ret_xts, freq) {
  print("First argument")
  print(head(asset_ret_xts))
  print("Second argument")
  print(freq)
  
  result_jb <- jarque.bera.test(asset_ret_xts)
  result_all <- bind_cols(
    describe(asset_ret_xts, quant=c(.25,.75))  ,
    Jb_Pvalue=result_jb$p.value
  )
  #freq not really needed but for purpose of simpolicyty added 
  return(result_all)
}

get_date_filter_from_yaml <- function(metric_yaml_path_str) {
  start_prefix_str <- "start "
  end_prefix_str <- "end "
  metrics_yaml <- yaml::read_yaml(metric_yaml_path_str)
  start_date_str <- gsub(start_prefix_str,"",metrics_yaml$start)
  end_date_str <- gsub(end_prefix_str,"",metrics_yaml$end)
  date.filter.str <- paste0(start_date_str,"/",end_date_str)
  return(date.filter.str)
}


filter_data_by_metrics_dates <- function(data_df,metric_yaml_path_str ) {
  print(head(data_df))
  print(metric_yaml_path_str)

  date.filter.str <- get_date_filter_from_yaml(metric_yaml_path_str)
  print(paste("date filter applied in select_date", date.filter.str))
  data_df <- data_df[date.filter.str,]
  return(data_df)
}

get_strategy_asset_returns_by_metrics <- function(data_df, metric_yaml_path_str ) {
  
  #print(metrics_yaml)
  
  cols_to_select_vec <-  c("return", "Asset_returns")
  data_df <- filter_data_by_metrics_dates(data_df,metric_yaml_path_str)
  data_df <- data_df[,cols_to_select_vec]
  colnames(data_df) <- c("Strategy", "Asset")
  return (data_df )

}

get_strategy_stats <- function(data_df,strategy_col, description, freq ) {
  #print(paste("Asset col ", asset_col))
  print(paste("Strategy col ", strategy_col))
  print(paste("Description", description))
  print(paste("Freq", freq))
  print(head(data_df))
  
  
  
  if (is.character(freq)) {
    freq <- eval(parse(text=freq))  
  }

  return ( cbind(description,get_trading_stats(data_df[,strategy_col],freq=freq)) )
}



calculate_portfolio <- function(merged_returns_xts, col_to_select, title="Portfolio", calc_rets = FALSE) {
  #select only strategy column, there are also asset columns
  as.data.frame(merged_returns_xts) %>% select (starts_with(col_to_select))  -> strategy_returns_df
  
  strategy_pct_return_df <- (exp(strategy_returns_df)-1)
  
  
  #calculated initial weight per asset, distribution equally
  weight <- 1/ncol(strategy_pct_return_df)
  
  #prepare vector which will be populate in first row, this will be initial capital assigned
  weights <- rep(weight,ncol(strategy_pct_return_df))
  
  #first row with weight and return 
  first_row_weighted <- (1+head(strategy_pct_return_df,1)) * weights
  
  #firt row assigned
  strategy_pct_return_df[1,] <- first_row_weighted
  
  #rest of the rows will get +1 assigned  so pct_return plus 1 
  strategy_pct_return_df[2:nrow(strategy_pct_return_df),] <- strategy_pct_return_df[2:nrow(strategy_pct_return_df),] +1
  
  #now perfrom CUMPRODUCT (1+r1)*(1+r2)
  equity_curve_xts <- cumprod(strategy_pct_return_df)
  
  #add sum of the each asset into portfolio
  equity_curve_xts %>% rowwise()  %>% mutate(!!title := sum(across(starts_with(col_to_select)), na.rm = T)) -> equity_curve_xts
  
  #populate the rownames of newly generated equity curve with initial rownames of input data, 
  #it is neded in as.xts function 
  #rownames(equity_curve_xts) <- index(merged_returns_xts)
  
  return(xts(equity_curve_xts, order.by=index(merged_returns_xts)))
}


get_cost_sensitivity_returns <- function( orginal_results_xts ) {
  print(head(orginal_results_xts))
  current_wd_str <- getwd()
  setwd(WF_CRYPTO_REPO)
  source(paste0(WF_CRYPTO_REPO,"\\master\\rcode\\logic\\strategy.r"))
  param_path_str <- paste0(WF_CRYPTO_REPO,"\\master\\rcode\\logic\\strategy_param.yaml")
  setwd(current_wd_str)
  
  strategy.obj <- Strategy$new(param.path.str = param_path_str)
  setwd(current_wd_str)
  
  #initialize it 
  strategy.obj <- Strategy$new(param.path.str = param_path_str)
  
  #based 
  #higher_fee_result_xts <- strategy.obj$calculate.pnl(result_xts[,c("Asset","positions")])
  
  
  merged_cost_sensitive_xts <-  orginal_results_xts[,c("Asset","Asset_returns", "positions", "return")]
  for (current_fee_dbl in  c(0.0005, 0.0007, 0.002,  0.003, 0.004,0.005)) {
    print (current_fee_dbl )
    strategy.obj$fee_int <- current_fee_dbl
    print ( paste("Confirming that fee was set ",strategy.obj$fee_int ))
    current_rets <- strategy.obj$calculate.pnl(orginal_results_xts[,c("Asset","positions")])
    colnames(current_rets) <- paste("fee_", current_fee_dbl)
    merged_cost_sensitive_xts <- merge.xts(merged_cost_sensitive_xts, current_rets)
  }
  

  print("Returning results from  get_cost_sensitivity_returns")
  print(head(merged_cost_sensitive_xts))
  return (merged_cost_sensitive_xts)
}

calculate_portfolio_of_portfolio <-  function ( portfolio_bh_xts, portfolio_paths_list) {
  print(paste("Inside function calculate_portfolio_of_portfolio" ))
  print(portfolio_paths_list)
  rm(merged_portfolio_xts)
  
  #data_df <- readRDS(input_file)
  for (current_portfolio in portfolio_paths_list) {
    print( head(readRDS(current_portfolio)))
    if (!exists("temp_porfolio_xts")  ) {
      temp_porfolio_xts <- readRDS(current_portfolio)$Portfolio
    } else {
      temp_porfolio_xts <- merge.xts(temp_porfolio_xts, readRDS(current_portfolio)$Portfolio)
    }
  }
  
  temp_porfolio_xts <- merge.xts(temp_porfolio_xts, portfolio_bh_xts$Portfolio)
  
  colnames(temp_porfolio_xts) <- c("Portfolio_7_28","Portfolio_14_10", "Portfolio_BH")
  
  log_rets_xts <- getLogReturns(temp_porfolio_xts)
  log_rets_xts[is.na(log_rets_xts$Portfolio_7_28),] <- 0
  return ( calculate_portfolio(log_rets_xts, col_to_select = "Portfolio", title = "Portfolio_Combined" ))
  
}
getLogReturnsNoNA <- function(data_df ) {
  temp_df <- getLogReturns(data_df)
  temp_df[is.na(temp_df[,1]),] <- 0
  return (temp_df)
}