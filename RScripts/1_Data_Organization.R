#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Title: Data Organization
#Coder: Nate Jones
#Date: 8/13/2020
#Purpose: Organize North Carolina Well Data
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#0. Data Sources----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Sources of data
# NC State County Boundaries http://data-ncdenr.opendata.arcgis.com/datasets/nc-counties/
# USGS modeled well data https://pubs.er.usgs.gov/publication/70191369

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#1.0 Setup workspace------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Clear workspace
remove(ls=list())

#install libraries of interest
library(raster)
library(sf)
library(tidyverse)

#Define directories of interest
data_dir<-"C:\\Users\\cnjones7\\Box Sync\\My Folders\\Research Projects\\Private Wells\\NorthCarolina\\spatial_data\\I_Data\\"
work_dir<-"C:\\Users\\cnjones7\\Box Sync\\My Folders\\Research Projects\\Private Wells\\NorthCarolina\\spatial_data\\II_Work\\"

#Define projection of interest
p<-"+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

#Load data of interet into R environment
wells<-raster(paste0(data_dir,"DomesticWells_USA_REM\\REM_map1990.tif"))
counties<-st_read(paste0(data_dir, "NC_Counties\\counties.shp"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2.0 Subset data----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Project counties into wells coords
counties_proj<-counties %>% st_transform(., crs=st_crs(wells@crs))

#Crop wells
wells<-crop(wells, counties_proj)
wells<-mask(wells, counties_proj)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#3.0 Export data----------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#project wells and counties into master projection
wells<-projectRaster(wells, crs=p)
counties<-counties %>% st_transform(., crs=st_crs(p))

#export data






