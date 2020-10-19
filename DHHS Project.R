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

#Define projection
p<-"+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

data_dir<-"C:\\Users\\Wesley\\Desktop\\NEU Files\\DHHS Project\\"

#reading well data and counties shapefile
welldata <- read.csv(paste0(data_dir,'DHHS_cleaned.csv'),fileEncoding="UTF-8-BOM")
counties <- st_read(paste0(data_dir,"counties.shp"))

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

#transforming counties to match well projection
counties <- st_transform(counties,crs=4326)

#removing non-nc well tests
ncwelldata <- st_intersection(welldata,counties)

#rasterize to create raster with count of tests in each cell
ncwellmap <-raster()
extent(ncwellmap) <- extent(ncwelldata)
rasterize(ncwelldata,ncwellmap,fun="count")
 


