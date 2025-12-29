
#=========================== function to hanlde the position ===============================

setwd("c:\\todo-p\\UW\\Master-Thesis")
source("c:\\todo-p\\UW\\Master-Thesis\\master\\rcode\\logic\\strategy.r")
source("c:\\todo-p\\UW\\Master-Thesis\\master\\rcode\\logic\\helpers\\metrics_helper.r")
source("dvc_pipeline/logic/bootstrap_helper.R")

final.return.xts <- readRDS( "c:\\todo-p\\UW\\Master-Thesis-analysis\\data\\3mln_9month\\20231106\\09_wf_test_evalued.rds")
positions.xts <- readRDS( "c:\\todo-p\\UW\\Master-Thesis-analysis\\data\\3mln_9month\\20231106\\04_positions.rds")
pnl.xts <- readRDS( "c:\\todo-p\\UW\\Master-Thesis-analysis\\data\\3mln_9month\\20231106\\05_pnl.rds")
wf.index.df <- readRDS( "c:\\todo-p\\UW\\Master-Thesis-analysis\\data\\3mln_9month\\20231106\\06_wf_indexes.rds")
param.path.str <- "c:\\todo-p\\UW\\Master-Thesis\\master//rcode//logic/strategy_param.yaml"


emas.xts <- readRDS( "c:\\todo-p\\UW\\Master-Thesis-analysis\\data\\3mln_9month\\20231106\\03_precalculated.rds")

asset_ema.xts <- emas.xts$Asset
asset_ema.xts$EMA <- EMA(emas.xts$Asset, n = 5)

sharpe(strategy.obj$calculate.pnl(temp.xts), 365*24)
sharpe(final.return.xts$return[date.filter.str], 365*24)



#=========================== bootstrap positions ===================================
#take position vector from given winning strategy 
#calculate positions length, code it with rle store
#
temp.xts <- positions.xts[,c(1,ncol(positions.xts))]
temp.xts <-  final.return.xts[, c("Asset","positions")]
colnames(temp.xts) <- c("Asset","Position")
start.date.str <- "2018-03-23 00:59:00"
end.date.str <- "2018-08-04 23:59:00"
date.filter.str <- paste(start.date.str,end.date.str,sep="/")

temp.xts <- temp.xts[date.filter.str, ]

sharpe_boot <- bootstrap_positions(temp.xts, no_iter=10)

dc.obj$add_data(sharpe_boot, "boot_positions", data_desc="bootstrap_wip.r Based on positiion from the best strategy, bootstrap is generated.")
summary(sharpe_boot)

sum(sharpe_boot>2.87)

print(x)


#========================== bootstrap MA combination ================================



#=================================== Calculate PNL for each ma 


strategy.obj <- Strategy$new(param.path.str = param.path.str)

calc_pnl_for_each_ma <- function(strategy.obj, positions.xts) {
  mas_combinations.vec <- get_ma_combinations_vec(positions.xts)
  result.xts <- xts(order.by=index(positions.xts))
  for (ma.str in mas_combinations.vec  ) {
    
    pnl.xts <- calc_pnl_for_ma(strategy.obj,positions.xts, ma.str)
    result.xts <- merge.xts(result.xts, pnl.xts)
  }
  return (result.xts)
}



pnl_calculated.xts <- calc_pnl_for_each_ma(strategy.obj, positions.xts )

colnames(pnl_calculated.xts) <- colnames(positions.xts)[2:ncol(positions.xts)]

colnames(pnl_calculated.xts)

plot(cumsum(pnl_calculated.xts$`7_100`))

pos.xts <- positions.xts[date.filter.str, ]

#========================================= white reality check ===============================
max.ix <- which.max(sharpe_heatmap.df$sharpe_ratio)
best_sharpe_dbl <- sharpe_heatmap.df[max.ix,]$sharpe_ratio
best_sharpe_dbl <- 2.87
detrended_sharpe <- sharpe_heatmap.df$sharpe_ratio - mean(sharpe_heatmap.df$sharpe_ratio)


z_score <- (best_sharpe_dbl - mean(sharpe_heatmap.df$sharpe_ratio))/sd(sharpe_heatmap.df$sharpe_ratio)
pnorm(q = z_score, lower.tail = FALSE)


max_sharpe_per_simulation <- c()
iter_no <- 10
for ( i in 1:iter_no) {
  sharpe_sim_max <- max(sample(detrended_sharpe, replace = TRUE))
  max_sharpe_per_simulation <- append(max_sharpe_per_simulation,sharpe_sim_max )  
}

mean_sim <- mean(max_sharpe_per_simulation)
median(max_sharpe_per_simulation)
sd_sim <- sd(max_sharpe_per_simulation)


(best_sharpe_dbl - mean_sim)/sd_sim



sharpe_sim_max 

sum(max_sharpe_per_simulation>2.87)

#================================= White reality check based on the boostrap of returns 

orginal.return.xts <- final.return.xts$return[date.filter.str]
sharpe(orginal.return.xts, 24*365)

mean.dbl <- mean(orginal.return.xts$return)

detrended.xts <- orginal.return.xts - mean.dbl
detrended.mat <- coredata(detrended.xts)
class(detrended.mat)
plot(cumsum(detrended.xts))
iter_no <- 10000 
mean_sim_vec <- c()
sharpe_sim_vec <- c()
for ( i in 1:iter_no ) {
  sample.mat <- sample(detrended.mat,replace=TRUE)
  mean_sample.dbl <- mean(sample.mat )
  mean_sim_vec <- append(mean_sim_vec, mean_sample.dbl)
  sharpe_sim_vec <- append(sharpe_sim_vec, sharpe(sample.mat, 24*365))
}

sum(mean_sim_vec> mean.dbl)
sum(sharpe_sim_vec> 2.87)

hist(mean_sim_vec)


#================================ Bootstrap 10% time ===================
#In order to see what is the level of confidence for the sharpe, and how it is depends on the selected period of time,
#booostrap will be performed to find confidence interval for time 

orginal.return.xts <- final.return.xts$return[date.filter.str]
orginal_sharpe.dbl <- sharpe(orginal.return.xts, 24*365)
orginal_returns.mat <- coredata(orginal.return.xts)
orginal_size.int <- length(orginal_returns.mat) 
fraction.dbl <- 0.9
sample_size.int <-as.integer(fraction.dbl * orginal_size.int)



mean_sim_vec <- c()
sharpe_sim_vec <- c()
for ( i in 1:iter_no ) {
  sample.mat <- sample(orginal_returns.mat, size = sample_size.int)
  mean_sample.dbl <- mean(sample.mat )
  mean_sim_vec <- append(mean_sim_vec, mean_sample.dbl)
  sharpe_sim_vec <- append(sharpe_sim_vec, sharpe(sample.mat, 24*365))
}

hist(mean_sim_vec)
hist(sharpe_sim_vec)
mean(sharpe_sim_vec)
max(sharpe_sim_vec)
sd(sharpe_sim_vec)

jarque.bera.test(coredata(orginal.return.xts))

hist(orginal.return.xts, breaks=100)
kurtosis(orginal.return.xts)
skewness(orginal.return.xts)


x <- runif(100)  # alternative
jarque.bera.test(x)
