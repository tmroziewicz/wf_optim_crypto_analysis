library(xts)
library(yaml)
library(tibble)
library(here)
library(tidyverse)
library(R6)
library(broom)
library(quantmod)
library(PerformanceAnalytics)
library(kableExtra)
library(psych)
library(latex2exp)
library(ggtext)
library(cli)
library(optparse)


options(scipen=999)

cost_sense_prepare <- function(cost_sense_xts) {
  fee_cols <- grep("fee", colnames(cost_sense_xts))
  cost_sense_fee_xts <- cost_sense_xts[,fee_cols ]
  cost_sense_fee_xts$`0.001` <- cost_sense_xts$return
  colnames(cost_sense_fee_xts) <- gsub("fee_.", "", colnames(cost_sense_fee_xts))
  colnames(cost_sense_fee_xts) <- gsub("e\\.", "e-", colnames(cost_sense_fee_xts))
  colnames(cost_sense_fee_xts) <- as.numeric(colnames(cost_sense_fee_xts))
  const_sense_curve_xts <- exp(cumsum(cost_sense_fee_xts))
  return (const_sense_curve_xts)
}


parser <- OptionParser()
parser <- add_option(parser, "--inputfile", action="store_true", type="character", default="", help="Specify input file [default]")
parser <- add_option(parser,  "--outputfile", action="store_true",type="character" , default="" , help="Specify output file")
opt <- parse_args(parser)





total_start <- "2018-01-01"
total_end <-"2021-09-12"
total_date_filter <- paste0(total_start,"/",total_end)

data_path_str <- here("data_to_share")

#---- bitcoin price
btc_df <- read.csv(file.path(data_path_str,"btcusd_d.csv"))
equity_curve_xts       <- 			readRDS(here(data_path_str,"06_merged_equity_curve_xts.rds"))
#experiment_df             <- 		readRDS(here(data_path_str,"experiment_df.rds"))
sharpe_heatmap.df         <- 		readRDS(here(data_path_str,"01_sharpe_heatmap.rds"))
#simple_experiment_df      <- 		readRDS(here(data_path_str,"simple_experiment_df.rds"))
smoothed.df               <- 		readRDS(here(data_path_str,"02_smoothed_heatmap.rds"))
mean_sharpe_per_tf_df     <- 		readRDS(here(data_path_str,"mean_sharpe_per_tf_df.rds"))


#modify  mean_sharpe_per_tf_df updating with values 60 
mean_sharpe_per_tf_60min.df <- sharpe_heatmap.df %>%  summarise(mean.sharpe.per.tfmin = mean(sharpe_ratio), max.sharpe.per.tfmin = max(sharpe_ratio), min.sharpe.per.tfmin = min(sharpe_ratio), std.sharpe.per.tfmin = sd(sharpe_ratio),  quantile_25 = quantile(sharpe_ratio, probs=0.25 ), quantile_50 = quantile(sharpe_ratio, probs=0.50 ), quantile_75 = quantile(sharpe_ratio, probs=0.75 ))

mean_sharpe_per_tf_df <- bind_rows(
  mean_sharpe_per_tf_df%>%filter(!general.tfmin==60),
bind_cols(general.tfmin=60,mean_sharpe_per_tf_60min.df ) )





boot_ma_signif_df <- 					    bind_rows(
                                          readRDS(file.path(data_path_str,"09_01_bootstrap_ma_significance.rds")),
         					                        readRDS(file.path(data_path_str,"09_02_bootstrap_ma_significance.rds"))
         					                        )

boot_pos_signif_df <- 					    bind_rows(
  readRDS(file.path(data_path_str,"09_01_bootstrap_pos_significance.rds")),
  readRDS(file.path(data_path_str,"09_02_bootstrap_pos_significance.rds"))
) 


btc_df$date <- as.Date(btc_df$Data)
btc_xts <- as.xts(btc_df$Zamkniecie , order.by = btc_df$date)
btc_xts <- btc_xts[total_date_filter,]
colnames(btc_xts) <- "Bitcoin"



basic_asset_desc_tbl    <- 			readRDS(file.path(data_path_str,"04_basic_asset_desc_tbl.rds"))
trading_statistics_df     <- 		readRDS(file.path(data_path_str,"05_trading_statistics_df.rds"))


boot_positions_01.vec         <- readRDS(file.path(data_path_str,"08_01_bootstrap_positions.rds"))
boot_positions_02.vec         <- readRDS(file.path(data_path_str,"08_02_bootstrap_positions.rds"))
boot_positions_stats       <- bind_rows(
  describe(boot_positions_01.vec, quant=c(.25,.75)),
  describe(boot_positions_02.vec, quant=c(.25,.75))
)%>% cbind(Description = boot_pos_signif_df$Description,.)

boot_ma_01.vec        <- readRDS(file.path(data_path_str,"09_01_bootstrap_ma.rds"))
boot_ma_02.vec        <- readRDS(file.path(data_path_str,"09_02_bootstrap_ma.rds"))

boot_ma_stats             <-  bind_rows(
  describe(boot_ma_01.vec, quant=c(.25,.75)),
  describe(boot_ma_02.vec, quant=c(.25,.75))
)%>% cbind(Description = boot_pos_signif_df$Description,.)
#)%>% bind_cols(boot_pos_signif_df$Description,.)



#seasonality 
format_seasonality <- function( df_seasonality ) {
  df_seasonality %>% 
    mutate(across(where(is.numeric), ~ round(., digits = 3))) %>%
    mutate( across(c(p.value.ttest, p.value.wilcox),~  paste0(.,ifelse( ( .<0.1 &  .>0.05) , "*","")  ))) %>% 
    mutate( across(c(p.value.ttest, p.value.wilcox),~  paste0(.,ifelse( ( .<=0.05 &  .>=0.01) , "**","")  ))) %>%
    mutate( across(c(p.value.ttest, p.value.wilcox),~  paste0(.,ifelse( ( .<=0.01 ) , "***","")  )))
  
}


daily_hourly_seasonality_asset_df <- 					 readRDS(file.path(data_path_str,"10_daily_hourly_seasonality.rds"))
daily_hourly_seasonality_asset_df <-    daily_hourly_seasonality_asset_df %>% filter(p.value.wilcox < 0.1 | p.value.ttest < 0.1) %>% format_seasonality(.)

hourly_seasonality_asset_df  <- 					 readRDS(file.path(data_path_str,"10_hourly_seasonality.rds")) %>% format_seasonality(.)
weekly_seasonality_asset_df <- 					 readRDS(file.path(data_path_str,"10_daily_seasonality.rds")) %>% format_seasonality(.)

daily_hourly_seasonality_asset_df <- coredata(daily_hourly_seasonality_asset_df)
#     <- 					 readRDS(file.path(data_path_str,""))




#strategies results  train 

strategies_stats    <- 					 readRDS(file.path(data_path_str,"07_merged_strategy_stats_xts.rds"))


#cost sensitivity 
cost_sense_xts    <- 					 readRDS(file.path(data_path_str,"15_cost_sensitivitiy.rds"))

const_sense_curve_xts <- cost_sense_prepare(cost_sense_xts)

cost_sense_stats_df <- readRDS(file.path(data_path_str,"15_cost_sensitivitiy_stats.rds"))
cost_sense_stats_tbl <- dplyr::as_tibble(cost_sense_stats_df, rownames = "Cost") 
cost_sense_stats_tbl %>% 
  mutate(across('Cost', str_replace, "e\\.","e-")) %>%
  mutate(across('Cost', str_replace, "fee_.","")) %>%  
  mutate(across('Cost', str_replace, "return","0.001")) %>%
  slice(4:n()) %>%
#  mutate(Cost=paste0(formatC(as.numeric(Cost) * 100, format = "f", digits = 2), "\\%")
  mutate(Cost=as.numeric(Cost)) %>% arrange(Cost)-> cost_sense_stats_tbl

#cost_sense_stats_df

#unseen data variables 

unseen_strategies_stats    <- 					 readRDS(file.path(data_path_str,"12_unseen_merged_strategy_stats.rds"))

#================== unseen strat formatting 
STR_AVOL <- "annualized_volatility"
STR_AMR <- "annaulized_mean_return"
STR_MDD <- "max_drawdown"
trad_stat_select_vec <- c("time_frequency", STR_AMR,STR_AVOL,"sharpe_ratio","information_ratio2",STR_MDD,"sortino_ratio")
trad_stat_name_vec <- c("Annualized Mean Return","Annualized Volatility","Sharpe Ratio","Information Ratio**","Max Drawdown","Sortino Ratio")

fun_cell_max_str <- "cell_spec(., bold = ifelse( . == max(.), TRUE, FALSE)      )"
fun_cell_min_str <- "cell_spec(., bold = ifelse( . == min(.), TRUE, FALSE)      )"





#portfolio of unseen 
unseen_strategies_portfolio <-  merge.xts ( readRDS(file.path(data_path_str,"13_01_merged_unseen_portfolio_14_10.rds"))$Portfolio,
                                            readRDS(file.path(data_path_str,"13_01_merged_unseen_portfolio_7_28.rds"))$Portfolio,
                                            readRDS(file.path(data_path_str,"13_03_portfolio_combined.rds"))$Portfolio_Combined,
                                            readRDS(file.path(data_path_str,"13_01_merged_unseen_portfolio_BH.rds"))$Portfolio
)

colnames(unseen_strategies_portfolio) <- c("Portfolio_14_10", "Portfolio_7_28","Portfolio_Combined", "Portfolio_Buy_Hold")

# portfolio  statistics 
unseen_portfolio_stats <- bind_rows( 
  readRDS(file.path(data_path_str,"14_01_merged_unseen_portfolio_7_28_stats.rds")),
  readRDS(file.path(data_path_str,"14_01_merged_unseen_portfolio_14_10_stats.rds")),
  readRDS(file.path(data_path_str,"14_01_merged_unseen_portfolio_BH_stats.rds")),
  readRDS(file.path(data_path_str,"14_01_portfolio_combined_stats.rds"))
)

sprintf("dasfd %s dfdf", "str")




rename_cols_in_equity_curve <- function(equity_curve_xts, col_names ) {
  colnames(equity_curve_xts  ) <- c(col_names[1],"Buy And Hold BTC", col_names[2], "" )
  return (equity_curve_xts[,1:ncol(equity_curve_xts)-1])
}

equity_curve_xts <- rename_cols_in_equity_curve(equity_curve_xts =equity_curve_xts, strategies_stats$description )



get_model_file_name <- function(model_no, Asset, Train.Length, Test.Length) {
  prefix = "11"
  postfix ="equity_curve_xts.rds"
  return(paste(prefix,paste0("0",model_no),Asset,Train.Length,Test.Length, postfix, sep="_"))
}
#equities curve 
models_df <- data.frame(Asset=c("BTC","BTC","ETH",'ETH', "BTC","ETH"), Train.Length=c("7","14","7","14","BH","BH"),
            Test.Length=c("28","10","28","10","",""))

for ( row_no in 1:nrow(models_df)) {
  print(models_df[row_no,'Asset'])  
  model_file_str <- get_model_file_name(row_no,models_df[row_no,'Asset'], 
                      models_df[row_no,'Train.Length'],
                      models_df[row_no,'Test.Length']
                      )
  print(model_file_str)
}


model_vec <- c("BTC Train 7 Test 28"="11_01_BTC_7_28_equity_curve_xts.rds",
              "BTC Train 14 Test 10"="11_02_BTC_14_10_equity_curve_xts.rds",
              "ETH Train 7 Test 28" = "11_03_ETH_7_28_equity_curve_xts.rds",
              "ETH Train 14 Test 10"= "11_04_ETH_14_10_equity_curve_xts.rds",
              "BNB Train 7 Test 28" = "11_05_BNB_7_28_equity_curve_xts.rds",
              "BNB Train 14 Test 10"= "11_06_BNB_14_10_equity_curve_xts.rds"

              )


temp_list <- list()

for ( model_desc in names(model_vec)) {
  print(model_desc)  
  print(model_vec[model_desc])
  temp_xts <- readRDS(file.path(data_path_str,model_vec[model_desc]))[,"Strategy"]
  temp_list <- append(temp_list,list(temp_xts) )
}

merged_xts <- do.call("cbind", temp_list )



merged_xts <- cbind(merged_xts,readRDS(file.path(data_path_str,model_vec[1]))[,"Asset"])
merged_xts <- cbind(merged_xts,readRDS(file.path(data_path_str,model_vec[3]))[,"Asset"])
merged_xts <- cbind(merged_xts,readRDS(file.path(data_path_str,model_vec[5]))[,"Asset"])

merged_cumsum_xts <- exp(cumsum(merged_xts))
merged_cumsum_xts <- merged_cumsum_xts[endpoints(merged_cumsum_xts,"minutes",k = 5760)]

colnames(merged_cumsum_xts) <- c(names(model_vec),"Buy And Hold BTC", "Buy And Hold ETH","Buy And Hold BNB")



best_sharpe_dbl <- strategies_stats[1,"sharpe_ratio"]
fee <- 0.001
rmarkdown::render(here(opt$inputfile), output_file=here(opt$outputfile), output_format = 'all', params = list(asset_name = "BTC" , fee=fee,
                                                                                        best_sharpe_dbl=best_sharpe_dbl,
                                                                                        equity_curve_xts      =  equity_curve_xts,
                                                                                        sharpe_heatmap.df        =  sharpe_heatmap.df , 
                                                                                        smoothed.df              =  smoothed.df,
                                                                                        mean_sharpe_per_tf_df = mean_sharpe_per_tf_df,
                                                                                        
                                                                                        #boot_positions_vec = boot_positions, #b
                                                                                        #boot_ma_vec = ma_boot_sharpe.vec,
                                                                                        boot_pos_signif_df=boot_pos_signif_df,
                                                                                        boot_ma_signif_df=boot_ma_signif_df,
                                                                                        #bootstrap descriptive stats 
                                                                                        boot_positions_stats =  boot_positions_stats,
                                                                                        boot_ma_stats = boot_ma_stats,
                                                                                        
                                                                                        basic_asset_desc_tbl=basic_asset_desc_tbl,
                                                                                        trading_statistics_df=trading_statistics_df,
                                                                                        daily_hourly_seasonality_asset_df=daily_hourly_seasonality_asset_df,
                                                                                        hourly_seasonality_asset_df=hourly_seasonality_asset_df,
                                                                                        weekly_seasonality_asset_df = weekly_seasonality_asset_df,
                                                                                        strategies_stats = strategies_stats,
                                                                                        unseen_strategies_stats=unseen_strategies_stats,
                                                                                        unseen_equity_curves=merged_cumsum_xts,
                                                                                        unseen_strategies_portfolio=unseen_strategies_portfolio,
                                                                                        unseen_portfolio_stats = unseen_portfolio_stats,
                                                                                        const_sense_curve_xts= const_sense_curve_xts,
                                                                                        cost_sense_stats_df = cost_sense_stats_tbl,
                                                                                        btc_xts = btc_xts
                                                                                        ))

