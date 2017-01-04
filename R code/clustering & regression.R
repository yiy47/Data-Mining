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
library(colorspace)
library(grid)
library(VIM)
aggr_plot <- aggr(rental_16_Q2,col=c('navyblue','red'),numbers=TRUE,sortVars=TRUE,
                  labels=names(rental_16_Q2),cex.axis=0.7,gap=3,ylab=c("Histogram of Missing Data","Pattern"))
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

### clustering
bike1 <- count(data, c("StationNum"))
bike1 = merge(bike1,station,by=c("StationNum"))
bike1 = bike1[,-c(3)]
samp2 <- bike1[,-1]
rownames(samp2) <- bike1[,1]
labels = rownames(samp2)

# MDS
do.mds <- function(dataset,lbls,do.scatter=T) {
  data.dist = dist(dataset)
  data.mds = cmdscale(data.dist)
  if (do.scatter) {
    plot(data.mds, type = 'n')
    text(data.mds,labels=lbls)       
  }
  data.mds
}

# kmeans: k=2
do.kmeans2 <- function(dataset,lbls,k=2,do.scatter=F) {
  set.seed(123)
  data.clu = kmeans(dataset, centers=k, nstart=10)
  if (do.scatter) {
    plot(dataset,type='n')
    text(dataset,labels=lbls,col=rainbow(k)[data.clu$cluster])    
  }
  data.clu
}
clus1 = do.kmeans2(samp2,labels,k=2)$cluster
clus1
#bike1$StationNum[k2$cluster==2]
do.mds = do.mds(samp2,labels,do.scatter = T)
plot(do.mds,type="n", main="k-means (k=2)")
text(do.mds, labels, col=clus1+1)

# h-clustering: complete k =2
library(cluster)
#data.dist = dist(bike1[,-1])
#hc = hclust(data.dist,method = 'complete')
#plot(hc)
#ent2 <- cluster.entropy(k2$cluster,hc$cluster)
do.hclust_c2 <- function(dataset,lbls,k=2,do.dendrogram=F) {
  data.dist = dist(dataset)
  hc = hclust(data.dist,method='complete') ## change method to be single, complete, average, etc.
  if (do.dendrogram) plot(hc, main = "Hierarchical Clustering with Complete Link (k=4)")
  hc1 = cutree(hc,k)
  print(hc1)
  hc1
}
clu3 = do.hclust_c2(samp2,k=2,do.dendrogram = F)
plot(do.mds,type="n", main="h-clustering with complete link (k=2)")
text(do.mds, labels, col=clu3+1)

# h-clustering: single k =2
library(cluster)
#data.dist = dist(bike1[,-1])
#hc = hclust(data.dist,method = 'complete')
#plot(hc)
#ent2 <- cluster.entropy(k2$cluster,hc$cluster)
do.hclust_s2 <- function(dataset,lbls,k=2,do.dendrogram=F) {
  data.dist = dist(dataset)
  hc = hclust(data.dist,method='single') ## change method to be single, complete, average, etc.
  if (do.dendrogram) plot(hc, main = "Hierarchical Clustering with Complete Link (k=4)")
  hc1 = cutree(hc,k)
  print(hc1)
  hc1
}
clu4 = do.hclust_s2(samp2,k=2,do.dendrogram = F)
plot(do.mds,type="n", main="h-clustering with complete link (k=2)")
text(do.mds, labels, col=clu4+1)

# h-clustering: single k =2
library(cluster)
#data.dist = dist(bike1[,-1])
#hc = hclust(data.dist,method = 'complete')
#plot(hc)
#ent2 <- cluster.entropy(k2$cluster,hc$cluster)
do.hclust_a2 <- function(dataset,lbls,k=2,do.dendrogram=F) {
  data.dist = dist(dataset)
  hc = hclust(data.dist,method='average') ## change method to be single, complete, average, etc.
  if (do.dendrogram) plot(hc, main = "Hierarchical Clustering with Complete Link (k=4)")
  hc1 = cutree(hc,k)
  print(hc1)
  hc1
}
clu5 = do.hclust_s2(samp2,k=2,do.dendrogram = F)
plot(do.mds,type="n", main="h-clustering with complete link (k=4)")
text(do.mds, labels, col=clu5+1)

## purity
cluster.purity <- function(clusters, classes) {
  sum(apply(table(classes, clusters), 2, max)) / length(clusters)
}

## entropy
cluster.entropy <- function(clusters,classes) {
  en <- function(x) {
    s = sum(x)
    sum(sapply(x/s, function(p) {if (p) -p*log2(p) else 0} ) )
  }
  M = table(classes, clusters)
  m = apply(M, 2, en)
  c = colSums(M) / sum(M)
  sum(m*c)
}
entropy1 <- cluster.entropy(clus1,clu3)
entropy1
entropy2 <- cluster.entropy(clu3,clus1)
entropy2
purity1 <- cluster.purity(clus1,clu3)
purity1
purity2 <- cluster.purity(clu3,clus1)
purity2
entropy3 <- cluster.entropy(clu4,clus1)
entropy3
purity3 <- cluster.purity(clu4,clus1)
purity3
entropy4 <- cluster.entropy(clu5,clus1)
entropy4
purity4 <- cluster.purity(clu5,clus1)
purity4
entropy<- cbind(entropy1,entropy2,entropy3,entropy4)
purity <- cbind(purity1,purity2,purity3,purity4)
result <- rbind(entropy,purity)

########################################################################
set.seed(1)
cl = kmeans(bike1[,-c(1)],centers = 2,nstart = 25)
o = order(cl$cluster)
data.frame(bike1$StationNum[o],cl$cluster[o])
plot(bike1$RackQnty,bike1$freq,type = 'n',xlab = "Rack Quantity",ylab = 'Count')
text(x=bike1$RackQnty,y=bike1$freq,labels = bike1$StationNum,col = cl$cluster)
#########################################################################


# clustering evaluation
bike1$StationNum[clus1==2]
set1 = data[data$StationNum=='1000' | data$StationNum=='1001' | data$StationNum=='1010' |
              data$StationNum=='1012' | data$StationNum=='1013' | data$StationNum=='1017' |
              data$StationNum=='1045' | data$StationNum=='1049']
count1 = count(set1,c("Starttime_Day"))
count1$freq = count1$freq/8
#ggplot(count1,aes(x=Starttime_Day,y=freq)) + geom_path()

library(dplyr)
set2=setdiff(data,set1)
count2 = count(set2,c("Starttime_Day"))
count2$freq = count1$freq/42
#ggplot(count2,aes(x=Starttime_Day,y=freq)) + geom_path()

count3 <- count(data,c("Starttime_Day"))
count3$freq = count3$freq
count3$freq = count3$freq/50

count1$g <- 1
count2$g <- 2
count3$g <- 3
count.total = rbind(count1,count2,count3)
ggplot(count.total,aes(Starttime_Day,freq,group=g,col=g)) + geom_path() + xlab("Day in A Month") + ylab("Count")




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
#precipitation = aggregate(weatherTest$weather.Total.daily.precipitation ~ weatherTest$weather_month + weatherTest$weather_year,weatherTest,mean)
temperature = merge(min.mean, max.mean, by= c("weatherTest$weather_year", "weatherTest$weather_month"))
temperature = merge(temperature, wind.mean, by= c("weatherTest$weather_year", "weatherTest$weather_month"))
temperature = merge(temperature, precipitation, by= c("weatherTest$weather_year", "weatherTest$weather_month"))

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
m.precipiation = weatherTest[rowSums(is.na(weatherTest)) > 0,]
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

#################################################
bike <- data.final
bike$StationNum <- as.factor(bike$StationNum)
bike$Year <- as.factor(bike$Year)
bike$Month <- as.factor(bike$Month)
bike$Day <- as.factor(bike$Day)
bike$Holiday <- as.factor(bike$Holiday)
bike$dayInWeek <- as.factor(bike$dayInWeek)
bike$Weekday <- as.factor(bike$Weekday)
bike$Customer[bike$Usertype=='Customer']<- 1
bike$Customer[is.na(bike$Customer)] <- 0
str(bike)
library(plyr)
bike1 <- count(bike, c("StationNum","Year","Month","Day","Holiday","Weekday","dayInWeek","Usertype"))
bike2 <- bike1[,c(1:7)]
bike2 <- bike2[!duplicated(bike2), ]
bike2$Customer <- NA
bike2$Subscriber <- NA
bike2$Daily <- NA


for (i in 1:nrow(bike1)) {
  y = bike1[i,]$Year
  m = bike1[i,]$Month
  d = bike1[i,]$Day
  id = bike1[i,]$StationNum
  user = bike1[i,]$Usertype
  hol = bike1[i,]$Holiday
  weekday = bike1[i,]$Weekday
  dayweek = bike1[i,]$dayInWeek
  if(user=="Customer"){
    bike2[bike2$Year==y & bike2$Month==m & bike2$Day == d & bike2$StationNum==id & bike2$Holiday==hol
          & bike2$Weekday==weekday & bike2$dayInWeek==dayweek,]$Customer = bike1[i,]$freq
  } 
  else if(user=="Subscriber"){
    bike2[bike2$Year==y & bike2$Month==m & bike2$Day == d & bike2$StationNum==id & bike2$Holiday==hol
          & bike2$Weekday==weekday & bike2$dayInWeek==dayweek,]$Subscriber = bike1[i,]$freq
  } 
  else {
    bike2[bike2$Year==y & bike2$Month==m & bike2$Day == d & bike2$StationNum==id & bike2$Holiday==hol
          & bike2$Weekday==weekday & bike2$dayInWeek==dayweek,]$Daily = bike1[i,]$freq
  }
}
bike2[is.na(bike2)] <- 0
bike2$Count <- (bike2$Customer + bike2$Subscriber + bike2$Daily)
bikesharing <- merge(bike2,weather.clean,by= c("Year", "Month",'Day'))
any(is.na(bikesharing)) # no missing values
bikesharing <- bikesharing[,c(11,4,1,2,3,5,6,7,8,9,10,12,13)]
#write.csv(bikesharing,file = "bikesharing.csv", row.names = FALSE)

### data split
cluster1 = bikesharing[(bikesharing$StationNum=='1000' | bikesharing$StationNum=='1001' | bikesharing$StationNum=='1010' |
                          bikesharing$StationNum=='1012' | bikesharing$StationNum=='1013' | bikesharing$StationNum=='1017' |
                          bikesharing$StationNum=='1045' | bikesharing$StationNum=='1049'),]
cluster1 = bikesharing[!(bikesharing$StationNum %in% cluster1$StationNum),]
## autumn 2015 - 9, 10, 11
autumn <- cluster1[which(cluster1$Month=='9' | cluster1$Month=='10' | cluster1$Month=='11'),]
autumn$Day <- as.numeric(autumn$Day)
autumn.train <- autumn[which(autumn$Day<20),]
autumn.test <- autumn[-which(autumn$Day<20),]
autumn$Day <- as.factor(autumn$Day)
t.autumn = autumn.test[,-c(1,9,10,11)]


## linear regression
# customer
cust.lm.autumn = lm(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
summary(cust.lm.autumn)
pre.lm.autumn = predict(cust.lm.autumn,t.autumn)
table(pre.lm.autumn<0)
pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
table(pre.lm.autumn<0)
pre.lm.autumn = round(pre.lm.autumn)
actual.cust.autumn = autumn.test[,9]

accuracy <- function(fact,prediction){
  count = 0
  for(i in 1:length(fact)){
    if(isTRUE(((prediction[i] >= fact[i]-2) && (prediction[i]<= fact[i]+2)))){
      count = count + 1
    }
  }
  accuracy = count/length(fact)
  print(accuracy)
  return(accuracy)
}
cust.lm.autumn.res = rmse.mae.acc(actual.cust.autumn,pre.lm.autumn) #[1] 0.4266212
cust.lm.autumn.res
# Function that returns Mean Absolute Error, rmse and accuracy
rmse.mae.acc <- function(fact, prediction)
{
  count = 0
  for(i in 1:length(fact)){
    if(isTRUE(((prediction[i] >= fact[i]-2) && (prediction[i]<= fact[i]+2)))){
      count = count + 1
    }
  }
  accuracy = count/length(fact)
  compare = data.frame(cbind(fact,prediction))
  error = compare$fact - compare$prediction
  rmse <- sqrt(mean(error)^2)
  mae <- mean(abs(error))
  result <- rbind(rmse,mae,accuracy)
  return (result)
}
r = rmse.mae.acc(actual.cust.autumn,pre.lm.autumn)
r





# subscriber
subs.lm.autumn = lm(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
summary(subs.lm.autumn)
pre.lm.autumn = predict(subs.lm.autumn,t.autumn)
table(pre.lm.autumn<0)
pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
table(pre.lm.autumn<0)
pre.lm.autumn = round(pre.lm.autumn)
actual.subs.autumn = autumn.test[,10]
subs.lm.autumn.res = rmse.mae.acc(actual.subs.autumn,pre.lm.autumn) #[1] 0.4266212
subs.lm.autumn.res


# daily
day.lm.autumn = lm(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
summary(day.lm.autumn)
pre.lm.autumn = predict(day.lm.autumn,t.autumn)
table(pre.lm.autumn<0)
pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
table(pre.lm.autumn<0)
pre.lm.autumn = round(pre.lm.autumn)
actual.day.autumn = autumn.test[,11]
day.lm.autumn.res = rmse.mae.acc(actual.day.autumn,pre.lm.autumn) #[1] 1
day.lm.autumn.res
r<- cbind(cust.lm.autumn.res,subs.lm.autumn.res,day.lm.autumn.res)
r
# total count
lm.autumn = lm(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
summary(lm.autumn)
pre.lm.autumn = predict(lm.autumn,t.autumn)
table(pre.lm.autumn<0)
pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
table(pre.lm.autumn<0)
pre.lm.autumn = round(pre.lm.autumn)
actual.autumn = autumn.test[,1]
lm.autumn.res = rmse.mae.acc(actual.autumn,pre.lm.autumn) #[1] 0.334471
lm.autumn.res

### regression tree
# customer
library(rpart)
cust.tree.autumn = rpart(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
print(cust.tree.autumn$cptable)
opt<-which.min(cust.tree.autumn$cptable[,"xerror"])
cp <- cust.tree.autumn$cptable[opt,'CP']
cust.tree.autumn.prune = prune(cust.tree.autumn,cp)
pre.tree.autumn = predict(cust.tree.autumn.prune,t.autumn)
table(pre.tree.autumn<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.autumn = round(pre.tree.autumn)
cust.tree.autumn.res = rmse.mae.acc(actual.cust.autumn,pre.tree.autumn) #[1] 0.3924915
cust.tree.autumn.res

# subscriber
subs.tree.autumn = rpart(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
print(subs.tree.autumn$cptable)
opt<-which.min(subs.tree.autumn$cptable[,"xerror"])
cp <- subs.tree.autumn$cptable[opt,'CP']
subs.tree.autumn.prune = prune(subs.tree.autumn,cp)
pre.tree.autumn = predict(subs.tree.autumn.prune,t.autumn)
table(pre.tree.autumn<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.autumn = round(pre.tree.autumn)
subs.tree.autumn.res = rmse.mae.acc(actual.subs.autumn,pre.tree.autumn) #[1] 0.8020478
subs.tree.autumn.res

# daily
day.tree.autumn = rpart(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
print(day.tree.autumn$cptable)
opt<-which.min(day.tree.autumn$cptable[,"xerror"])
cp <- day.tree.autumn$cptable[opt,'CP']
day.tree.autumn.prune = prune(day.tree.autumn,cp)
pre.tree.autumn = predict(day.tree.autumn.prune,t.autumn)
table(pre.tree.autumn<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.autumn = round(pre.tree.autumn)
day.tree.autumn.res = rmse.mae.acc(actual.day.autumn,pre.tree.autumn) #[1] 1
day.tree.autumn.res
r2 <- cbind(cust.tree.autumn.res,subs.tree.autumn.res,day.tree.autumn.res)
r2
# total count
tree.autumn = rpart(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,autumn.train)
print(tree.autumn$cptable)
opt<-which.min(tree.autumn$cptable[,"xerror"])
cp <- tree.autumn$cptable[opt,'CP']
tree.autumn.prune = prune(tree.autumn,cp)
pre.tree.autumn = predict(tree.autumn.prune,t.autumn)
table(pre.tree.autumn<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.autumn = round(pre.tree.autumn)
tree.autumn.res = rmse.mae.acc(actual.autumn,pre.tree.autumn) #[1] 0.2832765
tree.autumn.res
r1 = cbind(cust.tree.autumn.res,subs.tree.autumn.res,day.tree.autumn.res)
r1

### random forest
# customer
library(randomForest)
cust.rf.autumn = randomForest(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              autumn.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.autumn = predict(cust.rf.autumn, t.autumn)
table(pre.rf.autumn<0)
cust.res.rf.autumn = rmse.mae.acc(actual.cust.autumn,pre.rf.autumn)
cust.res.rf.autumn

# subscriber
subs.rf.autumn = randomForest(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              autumn.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.autumn = predict(subs.rf.autumn, t.autumn)
table(pre.rf.autumn<0)
subs.res.rf.autumn = rmse.mae.acc(actual.subs.autumn,pre.rf.autumn)
subs.res.rf.autumn

# daily
day.rf.autumn = randomForest(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                             autumn.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.autumn = predict(day.rf.autumn, t.autumn)
table(pre.rf.autumn<0)
pre.rf.autumn[pre.rf.autumn<0] <- min(pre.rf.autumn[pre.rf.autumn>0])
table(pre.rf.autumn<0)
day.res.rf.autumn = rmse.mae.acc(actual.day.autumn,pre.rf.autumn)
day.res.rf.autumn
r3 = cbind(cust.res.rf.autumn,subs.res.rf.autumn,day.res.rf.autumn)
r3


# total count
rf.autumn = randomForest(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                         autumn.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.autumn = predict(rf.autumn, t.autumn)
table(pre.rf.autumn<0)
#pre.rf.autumn[pre.rf.autumn<0] <- min(pre.rf.autumn[pre.rf.autumn>0])
#table(pre.rf.autumn<0)
res.rf.autumn = rmse.mae.acc(actual.autumn,pre.rf.autumn)
res.rf.autumn
r4 <- cbind(lm.autumn.res,tree.autumn.res,res.rf.autumn)
r4

## winter - 12, 1, 2
winter <- cluster1[which(cluster1$Month=='12' | cluster1$Month=='1' | cluster1$Month=='2'),]
winter$Day <- as.numeric(winter$Day)
winter.train <- winter[which(winter$Day<20),]
winter.test <- winter[-which(winter$Day<20),]
winter.train$Day = as.factor(winter.train$Day)
winter.test$Day = as.factor(winter.test$Day)
t.winter = winter.test[,-c(1,9,10,11)]


## linear regression
# customer
cust.lm.winter = lm(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
summary(cust.lm.winter)
pre.lm.winter = predict(cust.lm.winter,t.winter)
table(pre.lm.winter<0)
pre.lm.winter[pre.lm.winter<0] <- min(pre.lm.winter[pre.lm.winter>0])
table(pre.lm.winter<0)
pre.lm.winter = round(pre.lm.winter)
actual.cust.winter = winter.test[,9]
cust.lm.winter.res = rmse.mae.acc(actual.cust.winter,pre.lm.winter) #[1] 0.6557377

# subscriber
subs.lm.winter = lm(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
summary(subs.lm.winter)
pre.lm.winter = predict(subs.lm.winter,t.winter)
table(pre.lm.winter<0)
pre.lm.winter[pre.lm.winter<0] <- min(pre.lm.winter[pre.lm.winter>0])
table(pre.lm.winter<0)
pre.lm.winter = round(pre.lm.winter)
actual.subs.winter = winter.test[,10]
subs.lm.winter.res = rmse.mae.acc(actual.subs.winter,pre.lm.winter) #[1] 0.9289617

# daily
day.lm.winter = lm(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
summary(day.lm.winter)
pre.lm.winter = predict(day.lm.winter,t.winter)
table(pre.lm.winter<0)
pre.lm.winter[pre.lm.winter<0] <- min(pre.lm.winter[pre.lm.winter>0])
table(pre.lm.winter<0)
pre.lm.winter = round(pre.lm.winter)
actual.day.winter = winter.test[,11]
day.lm.winter.res = rmse.mae.acc(actual.day.winter,pre.lm.winter) #[1] 1
r5 <- cbind(cust.lm.winter.res,subs.lm.winter.res,day.lm.winter.res)
r5

# total count
lm.winter = lm(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
summary(lm.winter)
pre.lm.winter = predict(lm.winter,t.winter)
table(pre.lm.winter<0)
pre.lm.winter[pre.lm.winter<0] <- min(pre.lm.winter[pre.lm.winter>0])
table(pre.lm.winter<0)
pre.lm.winter = round(pre.lm.winter)
actual.winter = winter.test[,1]
lm.winter.res = rmse.mae.acc(actual.winter,pre.lm.winter) #[1] 0.5628415


### regression tree
# customer
cust.tree.winter = rpart(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
print(cust.tree.winter$cptable)
opt<-which.min(cust.tree.winter$cptable[,"xerror"])
cp <- cust.tree.winter$cptable[opt,'CP']
cust.tree.winter.prune = prune(cust.tree.winter,cp)
pre.tree.winter = predict(cust.tree.winter.prune,t.winter)
table(pre.tree.winter<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.winter = round(pre.tree.winter)
cust.tree.winter.res = rmse.mae.acc(actual.cust.winter,pre.tree.winter) #[1] 0.6502732

# subscriber
subs.tree.winter = rpart(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
print(subs.tree.winter$cptable)
opt<-which.min(subs.tree.winter$cptable[,"xerror"])
cp <- subs.tree.winter$cptable[opt,'CP']
subs.tree.winter.prune = prune(subs.tree.winter,cp)
pre.tree.winter = predict(subs.tree.winter.prune,t.winter)
table(pre.tree.winter<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.winter = round(pre.tree.winter)
subs.tree.winter.res = rmse.mae.acc(actual.subs.winter,pre.tree.winter) #[1] 0.9234973

# daily
day.tree.winter = rpart(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
print(day.tree.winter$cptable)
opt<-which.min(day.tree.winter$cptable[,"xerror"])
cp <- day.tree.winter$cptable[opt,'CP']
day.tree.winter.prune = prune(day.tree.winter,cp)
pre.tree.winter = predict(day.tree.winter.prune,t.winter)
table(pre.tree.winter<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.winter = round(pre.tree.winter)
day.tree.winter.res = rmse.mae.acc(actual.day.winter,pre.tree.winter) #[1] 1
r6 <- cbind(cust.tree.winter.res,subs.tree.winter.res,day.tree.winter.res)
r6

# total count
tree.winter = rpart(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,winter.train)
print(tree.winter$cptable)
opt<-which.min(tree.winter$cptable[,"xerror"])
cp <- tree.winter$cptable[opt,'CP']
tree.winter.prune = prune(tree.winter,cp)
pre.tree.winter = predict(tree.winter.prune,t.winter)
table(pre.tree.winter<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.winter = round(pre.tree.winter)
tree.winter.res = rmse.mae.acc(actual.winter,pre.tree.winter) #[1] 0.6174863

### random forest
# customer
library(randomForest)
cust.rf.winter = randomForest(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              winter.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.winter = predict(cust.rf.winter, t.winter)
table(pre.rf.winter<0)
cust.res.rf.winter = rmse.mae.acc(actual.cust.winter,pre.rf.winter)
cust.res.rf.winter

# subscriber
subs.rf.winter = randomForest(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              winter.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.winter = predict(subs.rf.winter, t.winter)
table(pre.rf.winter<0)
subs.res.rf.winter = rmse.mae.acc(actual.subs.winter,pre.rf.winter)
subs.res.rf.winter

# daily
day.rf.winter = randomForest(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                             winter.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.winter = predict(day.rf.winter, t.winter)
table(pre.rf.winter<0)
pre.rf.winter[pre.rf.winter<0] <- min(pre.rf.winter[pre.rf.winter>0])
table(pre.rf.winter<0)
day.res.rf.winter = rmse.mae.acc(actual.day.winter,pre.rf.winter)
day.res.rf.winter
r7 <- cbind(cust.res.rf.winter,subs.res.rf.winter,day.res.rf.winter)
r7

# total count
rf.winter = randomForest(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                         winter.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.winter = predict(rf.winter, t.winter)
table(pre.rf.winter<0)
#pre.rf.autumn[pre.rf.autumn<0] <- min(pre.rf.autumn[pre.rf.autumn>0])
#table(pre.rf.autumn<0)
res.rf.winter = rmse.mae.acc(actual.winter,pre.rf.winter)
res.rf.winter
r8 = cbind(lm.winter.res,tree.winter.res,res.rf.winter)
r8




## spring - 3,4,5
spring <- cluster1[which(cluster1$Month=='3' | cluster1$Month=='4' | cluster1$Month=='5'),]
spring$Day <- as.numeric(spring$Day)
spring.train <- spring[which(spring$Day<20),]
spring.test <- spring[-which(spring$Day<20),]
spring.train$Day = as.factor(spring.train$Day)
spring.test$Day = as.factor(spring.test$Day)
t.spring = spring.test[,-c(1,9,10,11)]


## linear regression
# customer
cust.lm.spring = lm(Customer~StationNum + Month  + Holiday + Weekday + dayInWeek + AvgTemp + Wind, spring.train)
summary(cust.lm.spring)
pre.lm.spring = predict(cust.lm.spring,t.spring)
table(pre.lm.spring<0)
pre.lm.spring[pre.lm.spring<0] <- min(pre.lm.spring[pre.lm.spring>0])
table(pre.lm.spring<0)
pre.lm.spring = round(pre.lm.spring)
actual.cust.spring = spring.test[,9]
cust.lm.spring.res = rmse.mae.acc(actual.cust.spring,pre.lm.spring) #[1] 0.2941176

# subscriber
subs.lm.spring = lm(Subscriber~StationNum + Month + Holiday + Weekday + dayInWeek + AvgTemp +Wind,spring.train)
summary(subs.lm.spring)
pre.lm.spring = predict(subs.lm.spring,t.spring)
table(pre.lm.spring<0)
pre.lm.spring[pre.lm.spring<0] <- min(pre.lm.spring[pre.lm.spring>0])
table(pre.lm.spring<0)
pre.lm.spring = round(pre.lm.spring)
actual.subs.spring = spring.test[,10]
subs.lm.spring.res = rmse.mae.acc(actual.subs.spring,pre.lm.spring) #[1] 0.8319328

# daily
day.lm.spring = lm(Daily~StationNum + Month + Holiday + Weekday + dayInWeek + AvgTemp +Wind,spring.train)
summary(day.lm.spring)
pre.lm.spring = predict(day.lm.spring,t.spring)
table(pre.lm.spring<0)
pre.lm.spring[pre.lm.spring<0] <- min(pre.lm.spring[pre.lm.spring>0])
table(pre.lm.spring<0)
pre.lm.spring = round(pre.lm.spring)
actual.day.spring = spring.test[,11]
day.lm.spring.res = rmse.mae.acc(actual.day.spring,pre.lm.spring) #[1] 1
r10 <- cbind(cust.lm.spring.res,subs.lm.spring.res,day.lm.spring.res)
r10

# total count
lm.spring = lm(Count~StationNum + Month + Holiday + Weekday + dayInWeek + AvgTemp +Wind,spring.train)
summary(lm.spring)
pre.lm.spring = predict(lm.spring,t.spring)
table(pre.lm.spring<0)
pre.lm.spring[pre.lm.spring<0] <- min(pre.lm.spring[pre.lm.spring>0])
table(pre.lm.spring<0)
pre.lm.spring = round(pre.lm.spring)
actual.spring = spring.test[,1]
lm.spring.res = rmse.mae.acc(actual.spring,pre.lm.spring) #[1] 0.2226891


### regression tree
# customer
cust.tree.spring = rpart(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,spring.train)
print(cust.tree.spring$cptable)
opt<-which.min(cust.tree.spring$cptable[,"xerror"])
cp <- cust.tree.spring$cptable[opt,'CP']
cust.tree.spring.prune = prune(cust.tree.spring,cp)
pre.tree.spring = predict(cust.tree.spring.prune,t.spring)
table(pre.tree.spring<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.spring = round(pre.tree.spring)
cust.tree.spring.res = rmse.mae.acc(actual.cust.spring,pre.tree.spring) #[1] 0.3613445

# subscriber
subs.tree.spring = rpart(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,spring.train)
print(subs.tree.spring$cptable)
opt<-which.min(subs.tree.spring$cptable[,"xerror"])
cp <- subs.tree.spring$cptable[opt,'CP']
subs.tree.spring.prune = prune(subs.tree.spring,cp)
pre.tree.spring = predict(subs.tree.spring.prune,t.spring)
table(pre.tree.spring<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.spring = round(pre.tree.spring)
subs.tree.spring.res = rmse.mae.acc(actual.subs.spring,pre.tree.spring) #[1] 0.7647059

# daily
day.tree.spring = rpart(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,spring.train)
print(day.tree.spring$cptable)
opt<-which.min(day.tree.spring$cptable[,"xerror"])
cp <- day.tree.spring$cptable[opt,'CP']
day.tree.spring.prune = prune(day.tree.spring,cp)
pre.tree.spring = predict(day.tree.spring.prune,t.spring)
table(pre.tree.spring<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.spring = round(pre.tree.spring)
day.tree.spring.res = rmse.mae.acc(actual.day.spring,pre.tree.spring) #[1] 1
r11 <- cbind(cust.tree.spring.res,subs.tree.spring.res,day.tree.spring.res)
r11
# total count
tree.spring = rpart(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,spring.train)
print(tree.spring$cptable)
opt<-which.min(tree.spring$cptable[,"xerror"])
cp <- tree.spring$cptable[opt,'CP']
tree.spring.prune = prune(tree.spring,cp)
pre.tree.spring = predict(tree.spring.prune,t.spring)
table(pre.tree.spring<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.spring = round(pre.tree.spring)
tree.spring.res = rmse.mae.acc(actual.spring,pre.tree.spring) #[1] 0.2773109


### random forest
# customer
library(randomForest)
cust.rf.spring = randomForest(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              spring.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.spring = predict(cust.rf.spring, t.spring)
table(pre.rf.spring<0)
cust.res.rf.spring = rmse.mae.acc(actual.cust.spring,pre.rf.spring)
cust.res.rf.spring

# subscriber
subs.rf.spring = randomForest(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              spring.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.spring = predict(subs.rf.spring, t.spring)
table(pre.rf.spring<0)
subs.res.rf.spring = rmse.mae.acc(actual.subs.spring,pre.rf.spring)
subs.res.rf.spring

# daily
day.rf.spring = randomForest(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                             spring.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.spring = predict(day.rf.spring, t.spring)
table(pre.rf.spring<0)
pre.rf.spring[pre.rf.spring<0] <- min(pre.rf.spring[pre.rf.spring>0])
table(pre.rf.spring<0)
day.res.rf.spring = rmse.mae.acc(actual.day.spring,pre.rf.spring)
day.res.rf.spring
r12 <- cbind(cust.res.rf.spring,subs.res.rf.spring,day.res.rf.spring)
r12
# total count
rf.spring = randomForest(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                         spring.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.spring = predict(rf.spring, t.spring)
table(pre.rf.spring<0)
#pre.rf.autumn[pre.rf.autumn<0] <- min(pre.rf.autumn[pre.rf.autumn>0])
#table(pre.rf.autumn<0)
res.rf.spring = rmse.mae.acc(actual.spring,pre.rf.spring)
res.rf.spring
r13 <- cbind(lm.spring.res,tree.spring.res,res.rf.spring)
r13






## summer - 6, 7, 8
summer <- cluster1[which(cluster1$Month=='6' | cluster1$Month=='7' | cluster1$Month=='8'),]
summer$Day <- as.numeric(summer$Day)
summer.train <- summer[which(summer$Day<20),]
summer.test <- summer[-which(summer$Day<20),]
summer.train$Day = as.factor(summer.train$Day)
summer.test$Day = as.factor(summer.test$Day)
t.summer = summer.test[,-c(1,9,10,11)]
str(summer.train)
str(summer.test)


## linear regression
# customer
cust.lm.summer = lm(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
summary(cust.lm.summer)
pre.lm.summer = predict(cust.lm.summer,t.summer)
table(pre.lm.summer<0)
pre.lm.summer[pre.lm.summer<0] <- min(pre.lm.summer[pre.lm.summer>0])
table(pre.lm.summer<0)
pre.lm.summer = round(pre.lm.summer)
actual.cust.summer = summer.test[,9]
cust.lm.summer.res = rmse.mae.acc(actual.cust.summer,pre.lm.summer) #[1] 0.2953488

# subscriber
subs.lm.summer = lm(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
summary(subs.lm.summer)
pre.lm.summer = predict(subs.lm.summer,t.summer)
table(pre.lm.summer<0)
pre.lm.summer[pre.lm.summer<0] <- min(pre.lm.summer[pre.lm.summer>0])
table(pre.lm.summer<0)
pre.lm.summer = round(pre.lm.summer)
actual.subs.summer = summer.test[,10]
subs.lm.summer.res = rmse.mae.acc(actual.subs.summer,pre.lm.summer) #[1] 0.7395349

# daily
day.lm.summer = lm(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
summary(day.lm.summer)
pre.lm.summer = predict(day.lm.summer,t.summer)
table(pre.lm.summer<0)
pre.lm.summer[pre.lm.summer<0] <- min(pre.lm.summer[pre.lm.summer>0])
table(pre.lm.summer<0)
pre.lm.summer = round(pre.lm.summer)
actual.day.summer = summer.test[,11]
day.lm.summer.res = rmse.mae.acc(actual.day.summer,pre.lm.summer) #[1] 1
r14 <- cbind(cust.lm.summer.res,subs.lm.summer.res,day.lm.summer.res)
r14

# total count
lm.summer = lm(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
summary(lm.summer)
pre.lm.summer = predict(lm.summer,t.summer)
table(pre.lm.summer<0)
pre.lm.summer[pre.lm.summer<0] <- min(pre.lm.summer[pre.lm.summer>0])
table(pre.lm.summer<0)
pre.lm.summer = round(pre.lm.summer)
actual.summer = summer.test[,1]
lm.summer.res = rmse.mae.acc(actual.summer,pre.lm.summer) #[1] 0.2674419


### regression tree
# customer
cust.tree.summer = rpart(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
print(cust.tree.summer$cptable)
opt<-which.min(cust.tree.summer$cptable[,"xerror"])
cp <- cust.tree.summer$cptable[opt,'CP']
cust.tree.summer.prune = prune(cust.tree.summer,cp)
pre.tree.summer = predict(cust.tree.summer.prune,t.summer)
table(pre.tree.summer<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.summer = round(pre.tree.summer)
cust.tree.summer.res = rmse.mae.acc(actual.cust.summer,pre.tree.summer) #[1] 0.3023256

# subscriber
subs.tree.summer = rpart(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
print(subs.tree.summer$cptable)
opt<-which.min(subs.tree.summer$cptable[,"xerror"])
cp <- subs.tree.summer$cptable[opt,'CP']
subs.tree.summer.prune = prune(subs.tree.summer,cp)
pre.tree.summer = predict(subs.tree.summer.prune,t.summer)
table(pre.tree.summer<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.summer = round(pre.tree.summer)
subs.tree.summer.res = rmse.mae.acc(actual.subs.summer,pre.tree.summer) #[1] 0.7674419

# daily
day.tree.summer = rpart(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
print(day.tree.summer$cptable)
opt<-which.min(day.tree.summer$cptable[,"xerror"])
cp <- day.tree.summer$cptable[opt,'CP']
day.tree.summer.prune = prune(day.tree.summer,cp)
pre.tree.summer = predict(day.tree.summer.prune,t.summer)
table(pre.tree.summer<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.summer = round(pre.tree.summer)
day.tree.summer.res = rmse.mae.acc(actual.day.summer,pre.tree.summer) #[1] 1
r15 <- cbind(cust.tree.summer.res,subs.tree.summer.res,day.tree.summer.res)
r15

# total count
tree.summer = rpart(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,summer.train)
print(tree.summer$cptable)
opt<-which.min(tree.summer$cptable[,"xerror"])
cp <- tree.summer$cptable[opt,'CP']
tree.summer.prune = prune(tree.summer,cp)
pre.tree.summer = predict(tree.summer.prune,t.summer)
table(pre.tree.summer<0)
#pre.lm.autumn[pre.lm.autumn<0] <- min(pre.lm.autumn[pre.lm.autumn>0])
#table(pre.lm.autumn<0)
pre.tree.summer = round(pre.tree.summer)
tree.summer.res = rmse.mae.acc(actual.summer,pre.tree.summer) #[1] 0.2860465


### random forest
# customer
library(randomForest)
cust.rf.summer = randomForest(Customer~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              summer.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.summer = predict(cust.rf.summer, t.summer)
table(pre.rf.summer<0)
cust.res.rf.summer = rmse.mae.acc(actual.cust.summer,pre.rf.summer)
cust.res.rf.summer

# subscriber
subs.rf.summer = randomForest(Subscriber~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                              summer.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.summer = predict(subs.rf.summer, t.summer)
table(pre.rf.summer<0)
subs.res.rf.summer = rmse.mae.acc(actual.subs.summer,pre.rf.summer)
subs.res.rf.summer

# daily
day.rf.summer = randomForest(Daily~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                             summer.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.summer = predict(day.rf.summer, t.summer)
table(pre.rf.summer<0)
pre.rf.summer[pre.rf.summer<0] <- min(pre.rf.summer[pre.rf.summer>0])
table(pre.rf.summer<0)
day.res.rf.summer = rmse.mae.acc(actual.day.spring,pre.rf.summer)
day.res.rf.summer
r16 <- cbind(cust.res.rf.summer,subs.res.rf.summer,day.res.rf.summer)
r16

# total count
rf.summer = randomForest(Count~StationNum + Month + Year + Holiday + Weekday + dayInWeek + AvgTemp +Wind,
                         summer.train,ntree=500,mtry=5, importance = TRUE)
pre.rf.summer = predict(rf.summer, t.summer)
table(pre.rf.summer<0)
#pre.rf.autumn[pre.rf.autumn<0] <- min(pre.rf.autumn[pre.rf.autumn>0])
#table(pre.rf.autumn<0)
res.rf.summer = rmse.mae.acc(actual.summer,pre.rf.summer)
res.rf.summer
c17 <- cbind(lm.summer.res,tree.summer.res,res.rf.summer)
c17
