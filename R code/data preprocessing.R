library(Rcpp) # required by mice
library(mice) 
library(base) # required by dplyr
library(dplyr)
library(plyr) # join datasets
library(data.table) # required by splitstackshape
library(splitstackshape)
library(chron)
library(ggplot2)

### loading datasets
rental_15_Q3 <- read.csv("/Users/yaoyi/Documents/Data Mining /DM project/Dataset/2015-Q3/HealthyRide Rentals 2015 Q3.csv")
station <- read.csv("/Users/yaoyi/Documents/Data Mining /DM project/Dataset/2015-Q3/HealthyRideStations2015.csv")
anyDuplicated(rental_15_Q3$Trip.id) # check whether there exists duplicate trip id
class(rental_15_Q3)
any(is.na(rental_15_Q3)) # no missing values

rental_15_Q4 <- read.csv("/Users/yaoyi/Documents/Data Mining /DM project/Dataset/2015-Q4/HealthyRide Rentals 2015 Q4.csv")
anyDuplicated(rental_15_Q4$Trip.id)
any(is.na(rental_15_Q4)) # missing values
any(is.null(rental_15_Q4))
m_15_Q4 <- rental_15_Q4[rowSums(is.na(rental_15_Q4)) > 0,]
table(rental_15_Q4$From.station.id)

Mode <- function(x,na.rm = TRUE) {
  ux <- unique(x)
  ux[which.max(tabulate(match(x, ux)))]
}
Mode(rental_15_Q4$From.station.id) # 1010
rental_15_Q4$From.station.id[9759] = 1010
rental_15_Q4$From.station.id[10182] = 1010
rental_15_Q4$From.station.name[9759] ='10th St & Penn Ave (David L. Lawrence Convention Center)'
rental_15_Q4$From.station.name[10182] ='10th St & Penn Ave (David L. Lawrence Convention Center)'
any(is.na(rental_15_Q4))


MissingValues <- function(x){
  for (var in 1:ncol(x)) {
    if (class(x[,var])%in% c("numeric",'integer')) {
      x[is.na(x[,var]),var] <- Mode(x[,var],na.rm = TRUE)
    } else if (class(x[,var]) %in% c("character", "factor")) {
      x[x[,var] == 'Missing',var] <- Mode(x[,var],na.rm = TRUE)
    }
  }
}



rental_16_Q1 <- read.csv("/Users/yaoyi/Documents/Data Mining /DM project/Dataset/2016-Q1/HealthyRide Rentals 2016 Q2.csv")
anyDuplicated(rental_16_Q1$Trip.id)
any(is.na(rental_16_Q1)) # no missing values

rental_16_Q2 <- read.csv("/Users/yaoyi/Documents/Data Mining /DM project/Dataset/2016-Q2/HealthyRide Rentals 2016 Q2.csv")
anyDuplicated(rental_16_Q2$Trip.id)
any(is.na(rental_16_Q2))  # missing values
m_16_Q2 = rental_16_Q2[rowSums(is.na(rental_16_Q2)) > 0,]
pMiss <- function(x){sum(is.na(x))/length(x)*100}
apply(rental_16_Q2,2,pMiss) # From.station.id: 7.2%
for (var in 1:ncol(rental_16_Q2)) {
  if (class(rental_16_Q2[,var])%in% c("numeric",'integer')) {
    rental_16_Q2[is.na(rental_16_Q2[,var]),var] <- Mode(rental_16_Q2[,var],na.rm = TRUE)
  }
}
any(is.na(rental_16_Q2))  # no missing value

rental_16_Q3 <- read.csv("/Users/yaoyi/Documents/Data Mining /DM project/Dataset/2016-Q3/HealthyRide Rentals 2016 Q3.csv")
anyDuplicated(rental_16_Q3$Trip.id)
any(is.na(rental_16_Q3)) # missing values
m_16_Q3 <- rental_16_Q3[rowSums(is.na(rental_16_Q3)) > 0,]
apply(rental_16_Q3,2,pMiss) # To.station.id 17%
for (var in 1:ncol(rental_16_Q3)) {
  if (class(rental_16_Q3[,var])%in% c("numeric",'integer')) {
    rental_16_Q3[is.na(rental_16_Q3[,var]),var] <- Mode(rental_16_Q3[,var],na.rm = TRUE)
  }
}
any(is.na(rental_16_Q3)) # no missing value

### combine rental datasets
frames <-  rbind(rental_15_Q3,rental_15_Q4,rental_16_Q1,rental_16_Q2,rental_16_Q3)
data <- frames
anyDuplicated(data$Trip.id) # no duplicate trip id
any(is.na(data)) # no missing value

### merge rental data with station data based on station id
class(data$From.station.id) # integer
class(station$StationNum) # integer
colnames(data)[6] <- "StationNum"
class(station)
data<-join(data, station,
           type = "left")
any(is.na(data))
m_data <- data[rowSums(is.na(data)) > 0,] # station_id = 50
data <- na.omit(data)

### extract time information: day, month, year, hour, minute
data <- cSplit(data, "Starttime", " ", stripWhite = FALSE)
data <- cSplit(data, "Starttime_1", "/", stripWhite = FALSE)
data <- cSplit(data, "Starttime_2", ":", stripWhite = FALSE)
colnames(data)[14:18]<-c("Starttime_Month","Starttime_Day","Starttime_Year","Starttime_Hour","Starttime_Min")
data <- cSplit(data, "Stoptime", " ", stripWhite = FALSE)
data <- cSplit(data, "Stoptime_1", "/", stripWhite = FALSE)
data <- cSplit(data, "Stoptime_2", ":", stripWhite = FALSE)
colnames(data)[18:22]<-c("Stoptime_Month","Stoptime_Day","Stoptime_Year","Stoptime_Hour","Stoptime_Min")

### divide one day into 4 parts: Morning (5 am - 12 pm), Afternoon (12 pm - 17 pm),
### Evening (17 pm - 21 pm), and Night (21 pm - 5 am)
data$DayParts <- NA
data$DayParts[data$Starttime_Hour>=5 & data$Starttime_Hour<12]<- 'Morning'
data$DayParts[data$Starttime_Hour>=12 & data$Starttime_Hour<17]<- 'Afternoon'
data$DayParts[data$Starttime_Hour>=17 & data$Starttime_Hour<21]<- 'Evening'
data$DayParts[data$Starttime_Hour>=21 | data$Starttime_Hour<5]<- 'Night'
table(data$DayParts)

### seasons
data$Season <- NA
data$Season[data$Starttime_Month==12 | data$Starttime_Month==1 | data$Starttime_Month==2] <-'Winter'
data$Season[data$Starttime_Month==3 | data$Starttime_Month==4 | data$Starttime_Month==5] <-'Spring'
data$Season[data$Starttime_Month==6 | data$Starttime_Month==7 | data$Starttime_Month==8] <-'Summer'
data$Season[data$Starttime_Month==9 | data$Starttime_Month==10 | data$Starttime_Month==11] <-'Autumn'
table(data$Season)

### holiday, weekday, weekend
data$Holiday <- NA
## holiday
## 2015
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==7 & data$Starttime_Day==3]<- 1
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==7 & data$Starttime_Day==4]<- 1
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==9 & data$Starttime_Day==7]<- 1
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==9 & data$Starttime_Day==11]<- 1
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==11 & data$Starttime_Day==11]<- 1
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==11 & data$Starttime_Day==26]<- 1
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==11 & data$Starttime_Day==27]<- 1
data$Holiday[data$Starttime_Year==2015 & data$Starttime_Month==12 & data$Starttime_Day==25]<- 1
## 2016
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==1 & data$Starttime_Day==1]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==1 & data$Starttime_Day==15]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==1 & data$Starttime_Day==18]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==2 & data$Starttime_Day==15]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==3 & data$Starttime_Day==25]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==3 & data$Starttime_Day==27]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==5 & data$Starttime_Day==15]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==5 & data$Starttime_Day==30]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==7 & data$Starttime_Day==4]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==9 & data$Starttime_Day==5]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==9 & data$Starttime_Day==11]<- 1
data$Holiday[data$Starttime_Year==2016 & data$Starttime_Month==9 & data$Starttime_Day==12]<- 1
data$Holiday[is.na(data$Holiday)] <- 0
table(data$Holiday) # 5539
h1 <- subset(data,data$Holiday==1) # 5539

### weekday: 0,6 -> weekends, otherwise, weekdays
n = length(data$Starttime_Day)
dayInWeek = NULL
for (i in 1:n) {
  d = data$Starttime_Day
  m = data$Starttime_Month
  y = data$Starttime_Year
  result = day.of.week(m[i],d[i],y[i])
  dayInWeek = c(dayInWeek,result)
}
data = cbind(data,dayInWeek)
table(data$dayInWeek)
data$Weekday <- NA # weekday - 1, weekends - 0
data$Weekday[data$dayInWeek<=5 & data$dayInWeek>0]<- 1
data$Weekday[data$dayInWeek==6 | data$dayInWeek==0]<- 0
table(data$Weekday)


### weather
## date, temperature, wind speed
weather <- read.csv("/Users/yaoyi/Documents/Data Mining /DM project/Dataset/weather/weather.csv", header=TRUE, stringsAsFactors=FALSE, fileEncoding="latin1")
weatherTest = data.frame(weather$Date,weather$Daily.minimum.temperature,weather$Daily.maximum.temperature,weather$Maximum.steady.wind)
weatherTest = weatherTest[!apply(weatherTest == "", 1, all),]
weatherTest$weather.Daily.minimum.temperature = as.numeric(gsub("\\D", "", weatherTest$weather.Daily.minimum.temperature)) 
weatherTest$weather.Daily.maximum.temperature = as.numeric(gsub("\\D", "", weatherTest$weather.Daily.maximum.temperature)) 
weatherTest$weather.Maximum.steady.wind = as.numeric(gsub("\\D", "", weatherTest$weather.Maximum.steady.wind)) 
weatherTest <- cSplit(weatherTest, "weather.Date", "/", stripWhite = FALSE)
colnames(weatherTest)[4:6]<-c("weather_month","weather_day","weather_year")

min.mean = aggregate( weatherTest$weather.Daily.minimum.temperature ~ weatherTest$weather_month + weatherTest$weather_year , weatherTest , mean )
max.mean = aggregate(weatherTest$weather.Daily.maximum.temperature ~ weatherTest$weather_month + weatherTest$weather_year, weatherTest, mean)
wind.mean = aggregate(weatherTest$weather.Maximum.steady.wind ~ weatherTest$weather_month + weatherTest$weather_year, weatherTest, mean)
temperature = merge(min.mean, max.mean, by= c("weatherTest$weather_year", "weatherTest$weather_month"))
temperature = merge(temperature, wind.mean, by= c("weatherTest$weather_year", "weatherTest$weather_month"))

colnames(temperature)[1:5] = c('Year','Month','min.temp','max.temp','wind')
index <- which(is.na(weatherTest)[,1], arr.ind = TRUE) # 66, 129
# 66: 16-7-5; 129: 16-5-7
weatherTest$weather.Daily.minimum.temperature[66] <- 69.66667
weatherTest$weather.Daily.minimum.temperature[129] <- 56.03333
index <- which(is.na(weatherTest)[,2], arr.ind = TRUE)
# 66: 16-7-5; 129: 16-5-7
weatherTest$weather.Daily.maximum.temperature[66] <- 77.63333
weatherTest$weather.Daily.maximum.temperature[129] <- 63.33333
index <- which(is.na(weatherTest)[,3], arr.ind = TRUE)
index
ind <- as.array(index)
for (i in 1:length(ind)) {
  m = weatherTest$weather_month[ind[i]]
  y = weatherTest$weather_year[ind[i]]
  for (k in 1:nrow(temperature)) {
    for (n in 1:nrow(temperature)) {
      if (m == temperature$Month[n] & y == temperature$Year[k]){
        weatherTest$weather.Maximum.steady.wind[ind[i]] = temperature$wind[n]
      }
    }
  }
}
any(is.na(weatherTest)) # no missing values

weatherTest$averge.temp = NA
for (i in 1:nrow(weatherTest)) {
  weatherTest$averge.temp[i] = (weatherTest$weather.Daily.minimum.temperature[i]+weatherTest$weather.Daily.maximum.temperature[i])/2
}
weather.clean = data.frame(weatherTest$weather_year,weatherTest$weather_month,weatherTest$weather_day,
                           weatherTest$averge.temp,weatherTest$weather.Maximum.steady.wind)
colnames(weather.clean) = c('Year','Month','Day','AvgTemp','Wind')
index <- which(weather.clean$Year==16 & weather.clean$Month==9 & weather.clean$Day==30, arr.ind = TRUE)
weather.clean <- weather.clean[-30,]
for (i in 1:nrow(weather.clean)) {
  weather.clean$Year[i] = as.integer(paste0("20", weather.clean$Year[i]))
}



### merge rental dataset with weather dataset based on the date (year, month, day)
mydata <- data
mydata$From.station.name <- NULL
mydata$To.station.name <- NULL
mydata$Bikeid <- NULL
colnames(mydata)[10:12] <- c('Month','Day','Year')
data.final = merge(mydata, weather.clean, by= c("Year", "Month",'Day')) # no missing values

### current bike distribution
station$StationNum <- as.factor(station$StationNum)
summary(station$RackQnty)
#dat <- data.frame(x=station,above=station$RackQnty>18.12)
ggplot(station,aes(x=reorder(StationNum, 
                             +RackQnty),RackQnty,fill=RackQnty))+
  geom_bar(stat="identity") + coord_flip() + 
  xlab('StationNum') + ylab('Rack Quantity') + ggtitle("Current Bike Distribution at Each Station")

### different users
str(data.final)
table(data.final$Usertype) # mode: customer
index <- which(!data.final$Usertype=='Customer' & !data.final$Usertype=='Daily' & !data.final$Usertype =='Subscriber' )
index # [1] 108792 109975
data.final$Usertype[108792] <- 'Customer'
data.final$Usertype[109975] <- 'Customer'
ggplot(data.final,aes(x=reorder(Usertype,Usertype,
                                function(x)-length(x)), fill=Usertype)) +
  geom_text(stat='count',aes(label=..count..),vjust=-0.5) + 
  geom_bar() + xlab('User Type') + ggtitle('Different User Types Vs. Bike Rentals')

### holidays
data.final$Holiday <- as.factor(data.final$Holiday)
table(data.final$Holiday)
ggplot(data.final,aes(x=Holiday,fill=Holiday)) + geom_bar() +
  geom_text(stat='count',aes(label=..count..),vjust=-0.5) + ggtitle('Holiday Vs. Bike Rentals') + coord_flip()

### hour, weekends, weekdays
table(data.final$Starttime_Hour,data.final$Weekday)
data.final$DayType <- NA
data.final$DayType[data.final$Holiday==1] <-'Holiday' # holiday
data.final$DayType[data.final$Holiday==0 & data.final$Weekday==0] <- 'Weekend' # weekends
data.final$DayType[is.na(data.final$DayType)] <- 'Weekday' # weekday
table(data.final$DayType)
ggplot(data.final,aes(factor(Day),fill=factor(DayType)))+geom_bar(position = "dodge") + facet_grid(DayType~.) +
  ggtitle('Holiday, Weekend, Weekday Vs. Bike Rental by Day') + 
  xlab('Day in Month') + ylab('Daily Bike Trips')

### seasons
data.final$Season <- as.factor(data.final$Season)
not.include.2015.7.ind <- which(data.final$Year==2015 & data.final$Month==7)
include <- data.final[!not.include.2015.7.ind,]
not.include.2015.8.ind <- which(include$Year==2015 & include$Month==8)
include <- include[!not.include.2015.8.ind,]
not.include.2016.9.ind <- which(include$Year==2016 & include$Month==9)
include <- include[!not.include.2016.9.ind,]
ggplot(include,aes(x=Season,fill=Season)) + geom_bar() +
  geom_text(stat='count',aes(label=..count..),vjust=-0.5) + ggtitle('Seasons Vs. Bike Rentals') + coord_flip()

### daytimes
data.final$DayParts <- as.factor(data.final$DayParts)
ggplot(data.final,aes(x=DayParts,fill=DayParts)) + geom_bar() +
  geom_text(stat='count',aes(label=..count..),vjust=-0.5) + ggtitle('DayParts Vs. Bike Rentals') + coord_flip()

### day in weeks
data.final$dayInWeek <- as.factor(data.final$dayInWeek)
ggplot(data.final,aes(x=dayInWeek,fill=dayInWeek)) + geom_bar() +
  geom_text(stat='count',aes(label=..count..),vjust=-0.5) + ggtitle('Days in Week Vs. Bike Rentals') + coord_flip()


### temperature (day)
ggplot(data.final,aes(AvgTemp)) + geom_line(stat = 'count') + ggtitle('Temperature Vs. Bike Rental')
ggplot(data.final,aes(Wind)) + geom_line(stat = 'count') + ggtitle('Wind Speed Vs. Bike Rental')

### temperature (month)
avg.temp.month = aggregate(data.final$AvgTemp ~ data.final$Month, data.final, mean)
avg.temp.month$`data.final$Month` = as.factor(avg.temp.month$`data.final$Month`)
par("mar") # Error in plot.new() : figure margins too large
par(mar=c(2,2,2,2))
matplot(avg.temp.month[,1],avg.temp.month[,2],type="l",lty=1,lwd=2,ylab="AvgTemp-Month",
        xlab="Month",ylim = c(0,80)) 
abline(h=60, col="red")
abline(h=80,col='red')
title('Avg Temperature of Each Month')
