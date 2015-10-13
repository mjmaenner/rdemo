# Uncomment the code for the first time you download the data:
# create a temporary file to store our downloaded crime data
# tmp<-tempfile()

# go to http://www.atlantapd.org/crimedatadownloads.aspx to find latest file path
# they change it each time they uplaod new data
# crimeURL<-"http://www.atlantapd.org/pdf/crime-data-downloads/85FB2BA9-E419-489A-8079-4ACEB419D937.zip"

# download file, unzip
# download.file(crimeURL,tmp)
# crimefile<-unzip(tmp, list=TRUE)
# crimeatl <- read.csv(unz(tmp, crimefile[1]))
# write.csv(crimeatl, "Desktop/crimeatl.csv", row.names=FALSE)
# if you prefer to download and unzip the file manually, can just use read.csv()

crimeatl<-read.csv("Desktop/crimeatl.csv", header=TRUE)

dim(crimeatl)

summary(crimeatl)

head(crimeatl)

table(crimeatl$Avg.Day)
aggregate(crimeatl$MaxOfnum_victims, by=list(crimeatl$Avg.Day), FUN="mean", na.rm=TRUE)
# uncomment if this is the first time you are using these packages:       
# install.packages(c("ggplot2","ggmap","ggthemes","lubridate"))


# the "x" and "y" coordinates are factors, not numbers
summary(crimeatl[,c("x","y")])
class(crimeatl$x)
# convert them to numeric
crimeatl$lon<-as.numeric(as.character(crimeatl$x))
crimeatl$lat<-as.numeric(as.character(crimeatl$y))

# still a problem, there might be a typo-- lat of -84?
summary(crimeatl[, c("lon","lat")])

# we will just drop the ones that don't make sense
crimeatl<- crimeatl[ crimeatl$lat > 33, ]

# here are our datapoints:
ggplot(data=crimeatl, aes(x=lon, y=lat)) + geom_point()
  
# hexbins help reduce overplotting
ggplot(data=crimeatl, aes(x=lon, y=lat)) + geom_hex()

# we can add a map projection, to fix the aspect ratio:
ggplot(data=crimeatl, aes(x=lon, y=lat)) + geom_hex()+
  scale_fill_distiller(palette="YlOrRd", breaks=pretty_breaks(n=10))

# figure out map dimensions:
r.lon <- range(crimeatl$lon, na.rm=TRUE)
r.lat <- range(crimeatl$lat, na.rm=TRUE)
bounds<-c(r.lon[1], r.lat[1], r.lon[2], r.lat[2])
bounds

# get the map tiles
atl.map <- get_map(location=bounds, maptype = "toner", zoom=13, crop=FALSE)

# create the map
ggmap(atl.map) + 
  geom_hex(data=crimeatl, aes(x=lon, y=lat)) +
  scale_fill_distiller(palette="YlOrRd", breaks=pretty_breaks(n=10))

#remove the lat/lon marks, add transparency, change number of bins
ggmap(atl.map) + 
  geom_hex(data=crimeatl, aes(x=lon, y=lat), alpha=.7, bins=100) +
  scale_fill_distiller(palette="YlOrRd", breaks=pretty_breaks(n=10))+
  theme_map()+theme(legend.position="right")

# just look at homicide
murderatl<- crimeatl[ crimeatl$UC2.Literal == "HOMICIDE",]

# are the number of homicides increasing or decreasing over time?
library(lubridate)
murderatl$murderdate<-mdy(murderatl$occur_date)
murderatl$murderyear<-year(murderatl$murderdate)

table(murderatl$murderyear)

# but we are only through week 40 of 2015 -- how does that project?
69/(40/52)

murderatl$murdermonth<-month(murderatl$murderdate)
table(murderatl$murderyear, murderatl$murdermonth)

ggmap(atl.map) + 
  geom_hex(data=murderatl, aes(x=lon, y=lat), alpha=.7, bins=40) +
  scale_fill_distiller(palette="Reds")+
  theme_map()+theme(legend.position="right")

