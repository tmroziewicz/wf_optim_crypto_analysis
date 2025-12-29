readRDS("./data_to_share/04_basic_asset_desc_tbl.rds")

#argumenst tests 

arg_test_str <- "1;2;3;4@123@sharpe"


args_list <- scan(text=arg_test_str, what="", sep="@")

new_arg_list <- list()

for(arg in args_list) {
  print(arg)
  arg <- scan(text=arg, what="", sep=";")
  print(arg)
  print(class(arg))
  new_arg_list <- append(new_arg_list, list(arg))
}

new_arg_list[[1]] <- arg_list
inside_arg_str <- "1;2;3;4"

arg_list <- scan(text=inside_arg, what="", sep=";")

as.vector(arg_list)


#======================== check heatmaps  generation 
sharpe_df <- readRDS("./data_to_share/01_sharpe_heatmap.rds")

sharpe_df %>% group_by(wf.train_length) %>% summarize(c = n())
source("smooth-matrix.R")

smooth_matrix(sharpe_df, "sharpe_ratio")

#============================== select _ data 
source("dvc_pipeline\\logic\\analyse_helper.r")
params_yaml <- yaml::read_yaml("params.yaml")

input <- "data\20231216_22_months\data\crash-taka\09_wf_test_evalued.rds"

data_selected <- select_data(readRDS(params_yaml$`06_equity_curve`$input), params_yaml$`06_equity_curve`$args)

sum(is.na(data_selected))

#========================================
source("download_or_source.r")
download_or_source("https://raw.githubusercontent.com/ptwojcik/HFD/5bd063ce5b3d5adf2bb772b02c56f3b9f4b8e144/functions_plotHeatmap.R","third_party/functions_plotHeatmap.R")


#======================== EQUITY CURVES
data_path_str <- "data_to_share\\06_02_equity_curve_xts.rds"
data_df <- readRDS(data_path_str)
plot(1+cumsum(data_df$Strategy))

#==================== get_strategy_stats ==================
data_path_str <- "data_to_share\\06_equity_curve_xts.rds"

data_df <- readRDS(data_path_str)
get_strategy_stats(data_df, strategy_col="Strategy",freq=24*365, description="xxxx")

#=============== data processing merging -==================

data_path_str <- "data_to_share\\06_01_equity_curve_xts.rds"

data_df <- readRDS(data_path_str)
source("dvc_pipeline\\logic\\data_processing_helper.r")
data_to_merge <- list ("data_to_share\\06_01_equity_curve_xts.rds" )
merge_files_cols_bind(data_path_str,data_to_merge )

data_path_str <- "data_to_share\\06_merged_equity_curve_xts.rds"
readRDS(data_path_str)

#====================== argument passing ======================



#debug(arg_parser)
#debug(mock_args_fun)
#arg_parser("fun1_arg1#fun1_arg2.0;fun1_arg2.1,fun2_arg_simple")

print(arg_parser("fun1_arg2.0;fun1_arg2.1"))
print(arg_parser("sharpe_ratio")[[1]])



fun_args <- arg_parser("fun1_arg2.0;fun1_arg2.1")

do.call("mock_args_fun",  fun_args[[1]] )


do.call("mock_args_fun",  arg_parser("sharpe_ratio")[[1]] )


append ( list(data_df), arg_parser("sharpe_ratio")[[1]])



do.call("mock_args_fun_2", append ( list(data_df), arg_parser("sharpe_ratio")[[1]]))

mock_args_fun <- function(expected_df, exp_str , expected_vec) {
  print(expected_df)
  print(exp_str)
  print(expected_vec)
}

mock_args_fun_2 <- function(expected_df, exp_str ) {
  print(expected_df)
  print(exp_str)
}

#===================== test loop
data_path_str <- "data_to_share\\08_01_bootstrap_positions.rds"
readRDS(data_path_str)

#========================= bootstrap ma =========================
source("dvc_pipeline\\logic\\bootstrap_helper.r")
position_path_str <- "data\\20231216_22_months\\data\\crash-taka\\04_positions.rds"
wf_index_path_str <- "data\\20231216_22_months\\data\\crash-taka\\06_wf_indexes.rds"
metric_path_str <- "data\\20231216_22_months\\data\\crash-taka\\metrics.yaml"
position_xts <- readRDS(position_path_str)

prepare_and_execute_ma_bootstrap(position_xts = position_xts, wf_index_path_str = wf_index_path_str, metric_path_str = metric_path_str)


saveRDS(file="xx.rds",c(123,123,53453))

#============================= 
data_path_str <- "data\\20231216_22_months\\data\\crash-taka\\09_wf_test_evalued.rds"
readRDS(data_path_str)

#============================== calculate significance ===============
boot_restult_path_str  <- "data_to_share\\09_01_bootstrap_ma.rds"
boot_result_df <- readRDS(boot_restult_path_str)
strategy_result_path_str <- "data_to_share\\07_01_strategy_stats.rds"
calculate_significance(boot_result_df, strategy_result_path_str)



#============================== 10 seasonality =======================

data_path_str <- "data\\20231216_22_months\\data\\crash-taka\\09_wf_test_evalued.rds"
data_xts <- readRDS(data_path_str)


source("dvc_pipeline\\logic\\seasonality_helper.r")
data_xts <- add_day_hour_feature(data_xts)
get_seasonality(transform_to_df(data_xts),day_of_week = TRUE, hour = TRUE,"return")

daily_hourly_seasonality <- readRDS("data_to_share\\10_daily_hourly_seasonality.rds")

#============================== 11_unseen_data_equity_curve =============

result_xts <- readRDS("data\\20240105_unseen\\data\\TRAIN_7_TEST_28_BTC_ochre-expo\\09_wf_test_evalued.rds")
metric_path_str <- "data\\20240105_unseen\\data\\TRAIN_7_TEST_28_BTC_ochre-expo\\metrics.yaml"
metrics_yaml <- yaml::read_yaml()

unseen_returns_xts <- get_strategy_asset_returns_by_metrics(result_xts,metric_path_str)

plot(exp(cumsum(unseen_returns_xts$Asset)))

#======================== 12 stats === 
equity_curve_xts <- readRDS("data_to_share\\11_04_ETH_14_10_equity_curve_xts.rds")

ep <- endpoints(equity_curve_xts,'months')

asset_sharpe_per_week_xts <- period.apply(equity_curve_xts$Asset,ep,  sharpe,24*365)
strategy_sharpe_per_week_xts <- period.apply(equity_curve_xts$Strategy,ep,  sharpe,24*365)

sum((asset_sharpe_per_week_xts==strategy_sharpe_per_week_xts))


get_strategy_stats(equity_curve_xts,"Strategy", "Descirption dbfasdfsaf", 24*365)

#---- 12 merge stats 
readRDS("data_to_share\\11_01_BTC_7_28_stats_xts.rds")
readRDS("data_to_share\\11_06_ETH_BH_stats_xts.rds")
readRDS("data_to_share\\12_unseen_merged_strategy_stats.rds")

#----- 13 portfolio setup 

merged_returns_xts <- readRDS("data_to_share\\13_01_merged_unseen_returns_14_10.rds")

portfolio_xts <- readRDS("data_to_share\\13_01_merged_unseen_portfolio_BH.rds")
portfolio_xts <- readRDS("data_to_share\\13_02_portfolio_xts.rds")

rownames(merged_returns_xts)

calculate_portfolio(merged_returns_xts,"Strategy","ddffd")


as.data.frame(merged_returns_xts) %>% select (starts_with("Strategy"))  -> strategy_returns_df

weight <- 1/ncol(strategy_returns_df)

strategy_returns_df
(weight+cumsum(strategy_returns_df)) %>% rowwise() %>%
  mutate(sum = sum(across(starts_with("Strategy")), na.rm = T)) -> portfolio_tbl 

weights <- rep(weight,ncol(strategy_returns_df))
first_row_weighted <- (1+head(strategy_returns_df,1)) * weights


pct_chng_df <-(exp(strategy_returns_df)-1)

pct_chng_df[1,] <- first_row_weighted

pct_chng_df[2:nrow(pct_chng_df),] <- pct_chng_df[2:nrow(pct_chng_df),] +1

head(pct_chng_df)
tail(pct_chng_df)



cumprod_pct_chng  <- cumprod(pct_chng_df)

plot(as.xts(cumprod_pct_chng))

cumprod_pct_chng %>% rowwise()  %>% mutate(sum = sum(across(starts_with("Strategy")), na.rm = T))  -> portfolio_returns_tbl

rownames(portfolio_returns_tbl) <- rownames(pct_chng_df)


plot(as.xts(portfolio_returns_tbl))

plot(cumprod_pct_chng[,2:ncol(cumprod_pct_chng)])
cumsum_log <- exp(cumsum(strategy_returns_df[,1]))

plot(cumsum_log)

tail(example_xts_cumprod)
tail(cumsum_log)
exp(strategy_returns_df)-1 
#===== portfolio problem with nulls in first row 
portfolio_xts <- readRDS("data_to_share\\13_01_merged_unseen_portfolio_7_28.rds")
getLogReturns(portfolio_xts)


#========================== 

getLogReturns(portfolio_xts)

#==========================  cost sensivity  =============================================================


setwd("..\\Master-Thesis-Analysis")
#get results 
result_xts <- readRDS("data\\20231216_22_months\\data\\crash-taka\\09_wf_test_evalued.rds")
            
#get strategy class
setwd("..\\Master-Thesis")
source("..\\Master-Thesis\\master\\rcode\\logic\\strategy.r")

#parameters of strategy 
param_path_str <- "..\\Master-Thesis\\master\\rcode\\logic\\strategy_param.yaml"




#----- cost sensitivity statistics ----- 

source("dvc_pipeline\\logic\\analyse_helper.r")

cost_sens_xts <- readRDS("./data_to_share/15_cost_sensitivitiy.rds")
get_trading_stats_per_col(cost_sens_xts,24*365)
debug(get_trading_stats_per_cost_sens)
undebug(get_trading_stats_per_cost_sens)
cost_sens_stats_df <- readRDS("./data_to_share/15_cost_sensitivitiy_stats.rds")


#------- test jarque berra ------------
source("dvc_pipeline\\logic\\analyse_helper.r")
input <- "data\\20231216_22_months\\data\\crash-taka\\01_converted_to_xts.rds"

asset_xts <- readRDS(input)
get_basic_stats_per_tf(asset_xts, c(30,60) )
asset_log_xts <- getLogReturns(asset_xts$`1`)[1:1000,]
result_jb <- jarque.bera.test(asset_log_xts)
bind_cols(
  describe(asset_log_xts, quant=c(.25,.75))  ,
  Jb_Pvalue=result_jb$p.value
)

asset_xts <- readRDS(input)


#=======


#----- portoflio of portoflio ---- 
#this section is dedicated to the constucting portfolio of portfolio 
unsen_returns_7_28_xts  <- readRDS("./data_to_share/13_01_merged_unseen_returns_7_28.rds")
unsen_returns_14_10_xts  <- readRDS("./data_to_share/13_01_merged_unseen_returns_14_10.rds")


potfolio_7_28_xts  <- calculate_portfolio(unsen_returns_7_28_xts[1:100,], col_to_select = "Strategy", title = "Fff")
potfolio_14_10_xts <- calculate_portfolio(unsen_returns_14_10_xts[1:100,], col_to_select = "Strategy", title = "Fff")
merged_portfolio_xts <- merge.xts(potfolio_7_28_xts$Portfolio, potfolio_14_10_xts$Portfolio)

colnames(merged_portfolio_xts) <- c("Portfolio_7_28","Portfolio_14_10")

log_rets_xts <- getLogReturns(merged_portfolio_xts[1:1000,])
log_rets_xts[is.na(log_rets_xts$Portfolio_7_28),] <- 0

calculate_portfolio(log_rets_xts[1:1000,], col_to_select = "Portfolio", title = "Fff" )

calculate_portfolio_of_portfolio(list(), c("./data_to_share/13_01_merged_unseen_portfolio_7_28.rds","./data_to_share/13_01_merged_unseen_portfolio_14_10.rds") )

portfolio_combined_xts <- readRDS("./data_to_share/13_03_portfolio_combined.rds")
portfolio_14_10 <- readRDS("./data_to_share/13_01_merged_unseen_portfolio_14_10.rds")

get_strategy_stats(getLogReturnsNoNA(portfolio_14_10), strategy_col="Portfolio",freq=24*365, description="xxxx")



portfolio_combined <- readRDS("./data_to_share/14_01_portfolio_combined_stats.rds")
