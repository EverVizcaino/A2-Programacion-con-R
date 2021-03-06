library('ggplot2')
library('forecast')
library('tseries')

dia <- read.csv("dia.csv")
hora <- read.csv("hora.csv")
str(dia)
dia$dteday <- as.Date(dia$dteday)
ggplot(dia, aes(dteday, cnt)) + geom_line() + scale_x_date('Mes')  + ylab("Bicis usadas diariamente") +xlab("")
recuento <- ts(dia[, c('cnt')])
dia$outliers <- tsclean(recuento)
ggplot() + geom_line(data = dia, aes(x = dteday, y = outliers)) + ylab('Recuento de bicis sin outliers')
dia$recuento_ma_sem = ma(dia$outliers, order=7) 
dia$recuento_ma_mes = ma(dia$outliers, order=30)
ggplot() +
  geom_line(data = dia, aes(x = dteday, y = outliers, colour = "Cuenta")) +
  geom_line(data = dia, aes(x = dteday, y = recuento_ma_sem,   colour = "MA semanal"))  +
  geom_line(data = dia, aes(x = dteday, y = recuento_ma_mes, colour = "MA mensual"))  +
  ylab('Recuento Bicis')
cuenta_ma <- ts(na.omit(dia$recuento_ma_sem), frequency=30)
desc <- decompose(cuenta_ma, s.window="periodic")
desestac <- seasadj(desc)
plot(desestac)
adf.test(cuenta_ma, alternative = "stationary")
Acf(cuenta_ma, main='')
Pacf(cuenta_ma, main='')
cuenta_dif = diff(desestac, differences = 1)
plot(cuenta_dif)
adf.test(cuenta_dif, alternative = "stationary")
Acf(cuenta_dif, main='ACF de serie diferenciada')
Pacf(cuenta_dif, main='PACF de serie diferenciada')
auto.arima(desestac, seasonal=FALSE)
fit2 <- arima(desestac, order=c(1,1,7))
fit2
tsdisplay(residuals(fit2), lag.max=15, main='Estacionalidad en los residuos')
fcast <- forecast(fit2, h=30)
plot(fcast)