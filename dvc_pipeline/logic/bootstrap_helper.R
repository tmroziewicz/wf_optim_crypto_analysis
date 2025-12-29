source("dvc_pipeline/logic/analyse_helper.r")
bootstrap_positions <- function(asset_positions.xts, no_iter=10, freq=0) {
  current_wd_str <- getwd()
  setwd("..\\Master-Thesis")
  source("..\\Master-Thesis\\master\\rcode\\logic\\strategy.r")
  param_path_str <- "..\\Master-Thesis\\master\\rcode\\logic\\strategy_param.yaml"
  strategy.obj <- Strategy$new(param.path.str = param_path_str)
  setwd(current_wd_str)
  
  orginal.vec <- as.vector(coredata(asset_positions.xts[,2]))
  
  encoding <- rle(orginal.vec)
  temp.xts <- asset_positions.xts$Asset 
  
  #reconstructed.vec <- rep(encoding$values, encoding$lengths)
  
  #setequal(orginal.vec,reconstructed.vec)
  
  df <- data.frame(values=encoding$values, lengths = encoding$lengths)
  df[sample(nrow(df),nrow(df)),]
  
  vec <- c()
  for (i in 1 : no_iter) {
    sample.df <- df[sample(nrow(df),nrow(df)),]
    temp.xts$Position <- rep(sample.df$values, sample.df$lengths)
    #print(sharpe(strategy.obj$calculate.pnl(temp.xts), 365*24))
    vec <- append(vec,sharpe(strategy.obj$calculate.pnl(temp.xts), freq) )
    #print(x)
  }
  return (vec)
}
#strategy_return_xts - this is usually taken form result of 09 step 
prepare_and_execute_position_bootstrap <- function(strategy_return_xts, metrics_yaml_path_str, iter_no,freq,seed =0 ) {
  if (is.character(freq)) {
    freq <- eval(parse(text=freq))  
  }
  set.seed(seed)
  strategy_return_filtered_xts <- filter_data_by_metrics_dates(strategy_return_xts, metrics_yaml_path_str)
  sharpe_boot <- bootstrap_positions(strategy_return_filtered_xts, no_iter=iter_no, freq)
  return(sharpe_boot)
}

#=================================== Calculate PNL for each ma 

#take positions 
#take indexes for wf
#for each step wf take random MA 


calc_pnl_for_ma <- function(strategy.obj, positions.xts, ma.str ) {
  pnl.xts <- strategy.obj$calculate.pnl(merge.xts(positions.xts$Asset, positions.xts[,ma.str] ))
  return(pnl.xts)
}

get_ma_combinations_vec <- function(positions.xts) {
  return (colnames(positions.xts)[2:ncol(positions.xts)])
}

get_empty_path_xts <- function(ma_positions.xts, position.col.str) {
  bootposition.xts <- xts(order.by=index(ma_positions.xts), x = rep(0,nrow(ma_positions.xts)))
  colnames(bootposition.xts) <- position.col.str
  bootposition.xts[,position.col.str] <- 0
  return(bootposition.xts)
}

get_random_ma_path <- function(ma_positions.xts, wf.index.df, mas_combinations.vec ) {
  
  col_start.str <- "test_start_date"
  
  col_end.str <- "test_end_date"
  
  #print(head(ma_positions.xts))
  
  position.col.str <- "Positions"
  bootposition.xts <- get_empty_path_xts(ma_positions.xts, position.col.str )

  for ( i in 1:nrow(wf.index.df)) {
    
    start_idx.int <- wf.index.df[i,col_start.str]
    
    end_idx.int <- wf.index.df[i,col_end.str]
    #draw random combination of ma, this is just column name 
    random_ma.str <- sample(mas_combinations.vec,1)
    
    bootposition.xts[start_idx.int:end_idx.int, position.col.str ] <- ma_positions.xts[start_idx.int:end_idx.int, random_ma.str]
  }
  
  return (bootposition.xts)
}

#temp.xts <- temp.xts[date.filter.str, ]

do_bootstrap_ma <- function(positions.xts, wf.index.df, date.filter.str,no_iter, freq =0) {
  current_wd_str <- getwd()
  setwd("..\\Master-Thesis")
  source("..\\Master-Thesis\\master\\rcode\\logic\\strategy.r")
  param_path_str <- "..\\Master-Thesis\\master\\rcode\\logic\\strategy_param.yaml"
  strategy.obj <- Strategy$new(param.path.str = param_path_str)
  setwd(current_wd_str)
  sharpe_vec <- c()
  mas_combinations.vec <- get_ma_combinations_vec(positions.xts)
  for ( s in 1:no_iter) {
    random_ma_path.xts <- get_random_ma_path(positions.xts, wf.index.df ,mas_combinations.vec)
    pnl.xts <- strategy.obj$calculate.pnl(merge.xts(positions.xts$Asset, random_ma_path.xts ))
    sharpe_ratio <- sharpe(pnl.xts[date.filter.str, ], freq)
    sharpe_vec <- append(sharpe_vec, sharpe_ratio)
  }  
  return (sharpe_vec)
}

prepare_and_execute_ma_bootstrap <- function(position_xts, wf_index_path_str, metric_path_str, no_iter=0, freq=0, seed =0 ) {
 #print(head(position_xts))
 
 if (is.character(freq)) {
    freq <- eval(parse(text=freq))  
 }  
  
 wf_index_df <- readRDS(wf_index_path_str) 
 
 data_filter_str <- get_date_filter_from_yaml(metric_path_str)
 
 set.seed(seed)
 
 result <- do_bootstrap_ma(positions.xts = position_xts, wf.index.df = wf_index_df,date.filter.str = data_filter_str, no_iter=no_iter, freq=freq  )
 
 return(result)
}

calculate_significance <- function(bootstrap_result_vec, strategy_result_path_str, col_str="sharpe_ratio" ) {
  strategy_result_df <- readRDS(strategy_result_path_str)

  print(strategy_result_df)
  
  no_simulation <- length(bootstrap_result_vec)
  
  strategy_sharpe_ratio <- strategy_result_df[,col_str]
  
  no_higher_int <- sum(bootstrap_result_vec>=strategy_result_df[,col_str])
  
  significance_dbl <- (no_higher_int/no_simulation)*100
  
  description <- strategy_result_df$description

  result_df <- data.frame(
              "Description"=description,
              "Strategy Sharpe Ratio"= strategy_sharpe_ratio,
              "Number of simulation"=no_simulation,
             "Number of simulation with higher score"= no_higher_int,
             "Significance %"=significance_dbl)
  return(result_df)
}

#get_higher_records()
