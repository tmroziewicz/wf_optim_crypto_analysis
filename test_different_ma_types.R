if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(xts,yaml,R6,quantmod)

vec <- c(10,	29,	44,	60,	63,	88,	76,	120)

EMA(vec, n = 3)
SMA(vec, n = 3)
DEMA(vec, n=3)
ALMA(vec,n=5)
HMA(vec,n=3/2)
ZLEMA(vec,n=3)



asset_price_xts <- cumsum(asset_ret_xts)



drawdown(asset_price_xts)
EMA(asset_price_xts,10) >EMA(asset_price_xts,20)

fun <- get("DEMA")

fun(asset_price_xts,10)


  



