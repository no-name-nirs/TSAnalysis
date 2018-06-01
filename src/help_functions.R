#разложение xts на компоненты (чтобы не потерять даты)
decompose.xts <-
  function (x,
            type = c("additive", "multiplicative"),
            filter = NULL)
  {
    dts <- decompose(as.ts(x), type, filter)
    dts$x <- .xts(dts$x, .index(x))
    dts$seasonal <- .xts(dts$seasonal, .index(x))
    dts$trend <- .xts(dts$trend, .index(x))
    dts$random <- .xts(dts$random, .index(x))
    
    with(dts,
         structure(
           list(
             x = x,
             seasonal = seasonal,
             trend = trend,
             random = if (type == "additive")
               x - seasonal - trend
             else
               x / seasonal / trend,
             figure = figure,
             type = type
           ),
           class = "decomposed.xts"
         ))
  }

#построение acf и pacf
plot_acf_pacf <- function(ts_object) {
  #' Plot ACF and PACF for Time Series Object
  #'
  #' Creates \emph{Autocorrelation} and \emph{Partial Autocorrelation} plot
  #' utilizing \code{ggplot2} with custom themes to ensure plots are
  #' consistent. Utlizes \code{autoplot} function for plots.
  #'
  #' @param ts_object time series object used to create plot
  #' @param ts_object_name preferred title of plot
  #' @examples
  #' data(AirPassengers)
  #'
  #' air_pass_ts <- as.ts(AirPassengers)
  #'
  #' plot_acf_pacf(air_pass_ts, 'Air Passengers Data Set')
  #print(ts_object)
  if (is.xts(ts_object) == TRUE) {
    a <- autoplot(
      acf(ts_object, plot = FALSE),
      colour = 'turquoise4',
      conf.int.fill = '#4C4CFF',
      conf.int.value = 0.95,
      conf.int.type = 'ma'
    ) +
      theme(
        panel.background = element_rect(fill = "gray98"),
        axis.line.y   = element_line(colour = "gray"),
        axis.line.x = element_line(colour = "gray")
      )
    
    b <- autoplot(
      pacf(ts_object, plot = FALSE),
      colour = 'turquoise4',
      conf.int.fill = '#4C4CFF',
      conf.int.value = 0.95,
      conf.int.type = 'ma'
    ) +
      theme(
        panel.background = element_rect(fill = "gray98"),
        axis.line.y   = element_line(colour = "gray"),
        axis.line.x = element_line(colour = "gray")
      ) + labs(y = "PACF")
    
    grid.arrange(a, b)
  }
else {
  warning('Make sure object entered is time-series object!')
}}

#разделить ряд на test/train 20/80
split_ts <- function(data){
  freq <- switch(periodicity(data)$scale,
                 daily=365,
                 weekly=52,
                 monthly=12,
                 quarterly=4,
                 yearly=1)
  attr(data, 'frequency') <- freq
  
  length(data)
  index = round(0.8*length(data))
  train = data[1:index]
  test = data[-(1:index)]
  return(list(train = train, test = test, freq = freq))
}

#обратное к diff и diff_lag для pred
undiff <- function(data, pred, list_lag){
  #pred$mean<-cumsum(pred$mean)
  #pred$fitted<-cumsum(pred$fitted)
  #pred$upper<-cumsum(pred$upper)
  #pred$lower<-cumsum(pred$lower)
  #pred$x<-cumsum(pred$x)
  #return(pred)
  print(pred[1:10])
  null_element <- data[1,1]
  for (lag in list_lag) {
    
    y <- diffinv(pred$mean, lag = lag)
    for (i in 1:(length(y)-lag)) {
      y[i] <- y[i] + null_element
    }
    pred$mean <- y[1:(length(y)-lag)]
    
    y <- diffinv(pred$fitted, lag = lag)
    for (i in 1:(length(y)-lag)) {
      y[i] <- y[i] + null_element
    }
    pred$fitted <- y[1:(length(y)-lag)]
    
    y <- diffinv(pred$upper[,2], lag = lag)
    for (i in 1:(length(y)-lag)) {
      y[i] <- y[i] + null_element
    }
    pred$upper[,2] <- y[1:(length(y)-lag)]
    
    y <- diffinv(pred$lower[,2], lag = lag)
    for (i in 1:(length(y)-lag)) {
      y[i] <- y[i] + null_element
    }
    pred$lower[,2] <- y[1:(length(y)-lag)]
    
  }

  return(pred)
}

#обратное к log для pred
unlog <- function(pred){
  pred$mean<-exp(pred$mean)
  pred$fitted<-exp(pred$fitted)
  pred$upper<-exp(pred$upper)
  pred$lower<-exp(pred$lower)
  pred$x<-exp(pred$x)
  return(pred)
}

#обратное к boxcox и log для pred
unboxcox <- function(pred, list_lambda){
  for (tr in list_lambda) {
  pred$mean<-boxcox.inv(pred$mean, tr)
  pred$fitted<-boxcox.inv(pred$fitted, tr)
  pred$upper<-boxcox.inv(pred$upper, tr)
  pred$lower<-boxcox.inv(pred$lower, tr)
  pred$x<-boxcox.inv(pred$x, tr)
  }
  return(pred)
}