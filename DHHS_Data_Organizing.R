#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Title: DHHS Organized
#Name: Wesley Hayes
#Date: 1/7/2021
#Purpose: Organize DHHS testing database with the goal of easily identifying and 
#         categorizing the quantity and type of testing occurring. 
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# 1.0 Setup---------------------------------------------------------------------
# Clears workspace, adds necesarry packages, defines directory, reads relevant
# files, formats database NAs, and fixes date formating
#

remove(list=ls())

#install libraries of interest
library(raster)
library(sf)
library(tidyverse)
library(readxl)
library(lubridate) #seems this should install w/ tidyverse but I had some issues
library(tidycensus)

#define directory
data_dir<-"C:\\Users\\Wesley\\Desktop\\Research\\DHHS_Project\\"

#reading well data and counties shapefile
data <- read.csv(paste0(data_dir,'DHHS_base.csv'),fileEncoding="UTF-8-BOM")
nc_counties <- st_read(paste0(data_dir,"counties.shp"))

#Replacing "-" with NA (converting database missing values to r missing values)
data[data=="-"] <- NA

#date management
data$Date <- mdy(data$Date)

# 2.0 Organizing Tests----------------------------------------------------------
# Currently, this section creates a unique identifier for each well, messily
# organizes tests and creates a test identifier, and produces summery or subset
# dataframes to outline testing breakdown. 
#

#creating a wellid column to act as a unique identifier for each test location
data <- data %>% mutate(wellid=paste(Lat,Long))
data <- data %>% mutate(wellid=as.integer(factor(wellid)))

#creating a testvariable variable - maybe not the best way but...
data$testvariable <- paste(is.na(data$TC),is.na(data$EC),
                           is.na(data$As),is.na(data$U),
                           is.na(data$Cr6),is.na(data$SO4),
                           is.na(data$V),is.na(data$Cd),
                           is.na(data$Fe),is.na(data$Se),
                           is.na(data$Pb),is.na(data$NO2.),
                           is.na(data$NO3),is.na(data$Mn),
                           is.na(data$Fl),is.na(data$Zn),
                           is.na(data$Hardness),is.na(data$Alkalinity),
                           is.na(data$Na),is.na(data$Cr),
                           is.na(data$Cl),is.na(data$Cu),
                           is.na(data$Hg))

#Listing different iterations of test types
testtypes <- data %>% group_by(testvariable) %>% summarise(n=n())

#creating a subset of initial tests (tests occurring the first day)
initdata <- data %>% group_by(wellid) %>% filter(Date == min(Date))

#create a subset of wells with multiple initial tests
repeattests <- initdata %>% summarise(n=n()) %>% filter(n>1)

#un-grouping created frames
ungroup(repeattests)
ungroup(initdata)

#join the remaining data to the repeated test list
repeattests <- left_join(repeattests,initdata,by="wellid")

# 3.0 Census Data --------------------------------------------------------------

# Census API setup - key is unique, request from census.gov
census_api_key("a81275dce8926f834dc4ebb8bc5953192a25c939")

# 4.0 EPA Well Users ----------------------------------------------------------
urlname <- "https://raw.githubusercontent.com/USEPA/PDW_Paper_2020/master/data/Well_Estimates/Blocks%20By%20State/final_estimates_blocks_NC.csv"

#Commented out because it is pretty huge

#ncwellusers <- read_csv(url(urlname))
