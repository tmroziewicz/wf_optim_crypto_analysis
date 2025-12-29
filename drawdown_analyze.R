all.equal(coredata(pnl.xts$`5_40`), coredata(pnl_calculated.xts$X5_40 ))
identical(coredata(pnl.xts$`5_40`), coredata(pnl_calculated.xts$X5_40 ))

sharpe(coredata(pnl.xts$`5_40`), 365*24)

sharpe(pnl_calculated.xts$`7_100`, 365*24)

apply(pnl_calculated.xts,2,sharpe, 365*24)

drawdown(pnl_calculated.xts$`7_100`)

drawdowns <- Drawdowns(pnl.xts$`5_40`)

DrawdownDeviation(pnl_calculated.xts$`7_100`)

AverageDrawdown()

drawdown_df <- table.Drawdowns(final.return.xts$return[date.filter.str], top = 1, digits = 4, geometric = TRUE)

sharpe(final.return.xts$return[date.filter.str], 365*24)

plot(1+cumsum(final.return.xts$return[date.filter.str]))

From <- "From"
To <- "To"
for ( row_no in 1:nrow(drawdown_df)) {
  print(drawdown_df[row_no,])
  fromto <- drawdown_df[row_no,c(From,To)]
  
  drawdown_date_filter <- paste(as.character(fromto[[1]]), (as.character(fromto[[2]]) ), sep="/")
  
  plot(cumsum(final.return.xts$return[drawdown_date_filter]))
}
scale_factor <- 365*24

sharpe(final.return.xts$return[drawdown_date_filter],scale_factor)






