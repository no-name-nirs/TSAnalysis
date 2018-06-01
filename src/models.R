#список всех моделей
models <- c("ARIMA", "ETS", "meanF", "TBATS", "SES", "Holt", "HW", "Naive", "SNaive")

#функции для всех моделей
model_switch <- function(train, test, freq, model_name) {
  model <- NULL
  pred <- NULL
  switch(model_name,
         ARIMA = {
           model = auto.arima(ts(train, frequency = freq), seasonal = TRUE)
           pred = forecast(model, h=length(test))
           #print(pred)
         },
         ETS = {
           model = ets(ts(train, frequency = freq))
           pred = forecast(model, h=length(test))
           #print(pred)
         },
         TBATS = {
           model = tbats(ts(train, frequency = freq))
           pred = forecast(model, h=length(test))
           #print(pred)
         },
         meanF = {
           pred = meanf(train, h=length(test))
           #print(pred)
         },
         SES = {
           pred = ses(ts(train, frequency = freq), h=length(test))
           #print(pred)
         },
         Holt = {
           pred = holt(ts(train, frequency = freq), h=length(test))
           #print(pred)
         },
         HW = {
           model = HoltWinters(train)
           pred = forecast(model, h=length(test))
           #print(pred)
         },
         Naive = {
           pred = naive(ts(train, frequency = freq), h=length(test))
           #print(pred)
         },
         SNaive = {
           pred = snaive(ts(train, frequency = freq), h=length(test))
           #print(pred)
         }
  )
  return(list(model = model, pred = pred, resid = pred$residuals))
}
