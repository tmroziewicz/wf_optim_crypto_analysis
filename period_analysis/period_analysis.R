if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(xts,tidyverse,tsfeatures, PerformanceAnalytics,pracma)
data(brown72)
strategy_return.xts <- final.return.xts$return
asset_returns.xts <- final.return.xts$Asset_returns
stratey_cumsum.xts <- cumsum(return.xts)
asset_cumsum.xts <- cumsum(asset_return.xts)


genarate_tsfeatures <- function(period.xts) {
    print(head(period.xts,1))
    cumsum.xts <- cumsum(period.xts)
    result.df <- bind_cols(
    
      tsfeatures(
        period.xts,
                 c("lumpiness",
                   "nonlinearity", "stability")
               ),
      tsfeatures(
        cumsum.xts,
        c("acf_features", "flat_spots","hurst","entropy","crossing_points","nonlinearity", "stability")
      ),
      hurstexp(period.xts)
    
    )
  
  return (unlist(result.df))
}
station_features(final.return.xts$Asset)
station_features(final.return.xts$Asset_returns)
station_features(cumsum(final.return.xts$Ass))

h <- hurstexp(brown72, d=128)
class(h)

features <- genarate_tsfeatures(final.return.xts$Asset_returns)
unlist(features)

start.date.str <- "2018-03-23 00:59:00"
end.date.str <- "2018-08-03 23:59:00"
date.filter.str <- paste(start.date.str,end.date.str,sep="/")

ep <- endpoints(final.return.xts$Asset_returns[date.filter.str],'days')
applied_df <- period.apply(x = final.return.xts$Asset_returns[date.filter.str],INDEX=ep[1:(length(ep)-1)], FUN =  genarate_tsfeatures)

sum_per_wf_df$return


split.list <- split.xts(final.return.xts$Asset_returns[date.filter.str], f="days"  )
days_features = lapply(split.list[-1], FUN = genarate_tsfeatures)

in.xts <- index(final.return.xts$Asset_returns[date.filter.str], f="days",k=3)


hurst(final.return.xts$Asset[date.filter.str])
HurstIndex(final.return.xts$Asset[date.filter.str])
hurstexp(final.return.xts$Asset_returns[date.filter.str])
hwl <- bind_cols(
  tsfeatures(asset_returns.xts,
             c("acf_features","entropy","lumpiness",
               "flat_spots","crossing_points","nonlinearity", "stability", "hurst")),
  tsfeatures(asset_cumsum.xts,
             c("hurst","acf_features",'pacf_features')),
  tsfeatures(asset_cumsum.xts,"stl_features", s.window='periodic', robust=TRUE),
  tsfeatures(asset_cumsum.xts, "max_kl_shift", width=48),
  tsfeatures(asset_returns.xts,
             c("mean","var"), scale=FALSE, na.rm=TRUE),
  tsfeatures(asset_cumsum.xts,
             c("max_level_shift","max_var_shift"), trim=TRUE)) %>%
  select(mean, var, x_acf1, trend, linearity, curvature,
         seasonal_strength, peak, trough,
         entropy, lumpiness, spike, max_level_shift, max_var_shift, flat_spots,
         crossing_points, max_kl_shift, time_kl_shift)

#============================
sum_per_wf_df <- period.apply(x = final.return.xts$return[date.filter.str],INDEX=ep[1:(length(ep)-1)], FUN = sum)
cols  <- colnames(applied_df)
lm_result_list <- list()
for (c in cols ) {
  print(c)
  lm_result <- lm(coredata(sum_per_wf_df$return) ~ coredata(applied_df[,c]) )
  
  tidy_lm <-  bind_cols(c,tidy(lm_result)[2,])
  lm_result_list <- append(lm_result_list, list(tidy_lm))
  
}

lm_tseries_to_return <- do.call(  rbind,lm_result_list)
lm_tseries_to_return <- lm_tseries_to_return[,-2]
colnames(lm_tseries_to_return)[1] <-  "TS Feature"

