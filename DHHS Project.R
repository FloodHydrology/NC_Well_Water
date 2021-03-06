#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Title: DHHS Project
#Name: Wesley Hayes
#Date: 8/17/2020
#Purpose: Analyze data contained in DHHS well testing database
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1.0 Setup---------------------------------------------------------------------
remove(list=ls())

#install libraries of interest
library(raster)
library(sf)
library(tidyverse)
library(readxl)
library("RColorBrewer")
library(mapview)
library(colorRamps)


#Define projection
p<-"+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

data_dir<-"C:\\Users\\Wesley\\Desktop\\NEU Files\\DHHS Project\\"

#reading well data, counties shapefile, DEQ susceptibility zones
welldata <- read.csv(paste0(data_dir,'DHHS_cleaned.csv'),fileEncoding="UTF-8-BOM")
counties <- st_read(paste0(data_dir,"counties.shp"))
deq_high <- st_read(paste0(data_dir,"DEQ susc\\gw_higher_susc_final.shp"))
deq_mod  <- st_read(paste0(data_dir,"DEQ susc\\gw_mod_susc_final.shp"))
deq_low  <- st_read(paste0(data_dir,"DEQ susc\\gw_lower_susc_final.shp"))

#Replacing - with NA
welldata[welldata=="-"] <- NA

#reading standards
standards <- read.csv(paste0(data_dir,'Standards.csv'),fileEncoding="UTF-8-BOM")

#Fixing Dates and creating a year column in welldata
welldata$Date <- as.Date(format="%m/%d/%Y",welldata$Date)
welldata$Year <- as.numeric(format(welldata$Date,'%Y'))

## 2.0 Spatial Distribution of Well Tests---------------------------------------------------------
#creating simple features point object from well tests
welldata <- st_as_sf(welldata,coords=c("Lat","Long"), crs=4326)

#transforming counties + DEQ zones to match well projection
counties <- st_transform(counties,crs=4326)
deq_high <- st_transform(deq_high,crs=4326)
deq_mod <- st_transform(deq_mod,crs=4326)
deq_low <- st_transform(deq_low,crs=4326)

#removing non-nc well tests
ncwelldata <- welldata[counties,]

#rasterize to create raster with count of tests in each cell
ncwellmap <-raster(ncol=2624,nrow=1186)
extent(ncwellmap) <- extent(ncwelldata)
res(ncwellmap) <- .03

#Total testing count raster
totaltests <- rasterize(ncwelldata,ncwellmap,field='ID',fun="count")

#Separating data by year 
ncwelldata09 <- ncwelldata %>% filter(Year ==2009)
ncwelldata10 <- ncwelldata %>% filter(Year ==2010)
ncwelldata11 <- ncwelldata %>% filter(Year ==2011)
ncwelldata12 <- ncwelldata %>% filter(Year ==2012)
ncwelldata13 <- ncwelldata %>% filter(Year ==2013)
ncwelldata14 <- ncwelldata %>% filter(Year ==2014)
ncwelldata15 <- ncwelldata %>% filter(Year ==2015)
ncwelldata16 <- ncwelldata %>% filter(Year ==2016)
ncwelldata17 <- ncwelldata %>% filter(Year ==2017)
ncwelldata18 <- ncwelldata %>% filter(Year ==2018)


#Creating rasters for each year 
tests09 <- rasterize(ncwelldata09,ncwellmap,field='ID',fun="count")
tests10 <- rasterize(ncwelldata10,ncwellmap,field='ID',fun="count")
tests11 <- rasterize(ncwelldata11,ncwellmap,field='ID',fun="count")
tests12 <- rasterize(ncwelldata12,ncwellmap,field='ID',fun="count")
tests13 <- rasterize(ncwelldata13,ncwellmap,field='ID',fun="count")
tests14 <- rasterize(ncwelldata14,ncwellmap,field='ID',fun="count")
tests15 <- rasterize(ncwelldata15,ncwellmap,field='ID',fun="count")
tests16 <- rasterize(ncwelldata16,ncwellmap,field='ID',fun="count")
tests17 <- rasterize(ncwelldata17,ncwellmap,field='ID',fun="count")
tests18 <- rasterize(ncwelldata18,ncwellmap,field='ID',fun="count")

par(mfrow = c(5,2), col.axis = "white", col.lab = "white", tck = 0)
plot(tests09,col=ygobb(75),main="2009")
plot(tests10,col=ygobb(75),main="2010")
plot(tests11,col=ygobb(75),main="2011")
plot(tests12,col=ygobb(75),main="2012")
plot(tests13,col=ygobb(75),main="2013")
plot(tests14,col=ygobb(75),main="2014")
plot(tests15,col=ygobb(75),main="2015")
plot(tests16,col=ygobb(75),main="2016")
plot(tests17,col=ygobb(75),main="2017")
plot(tests18,col=ygobb(75),main="2018")
