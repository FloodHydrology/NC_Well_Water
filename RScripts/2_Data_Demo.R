#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Title: Data Demo
#Coder: Nate Jones
#Date: 8/13/2020
#Purpose: Demonstrate simple overlay
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#1.0 Setup workspace------------------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Clear workspace
remove(ls=list())

#install libraries of interest
library(raster)
library(sf)
library(fasterize)
library(parallel)
library(tidyverse)

#Define directories of interest
data_dir<-"C:\\Users\\cnjones7\\Box Sync\\My Folders\\Research Projects\\Private Wells\\NorthCarolina\\spatial_data\\II_Work\\"

#Define projection of interest
p<-"+proj=utm +zone=17 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

#Load data of interet into R environment
wells<-raster(paste0(data_dir,"wells.tif"))
counties<-st_read(paste0(data_dir,"counties.shp"))

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#2.0 Estimate n_wells for Haywood County----------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Isolate county in charlotte
county<-counties %>% filter(CO_NAME=='HAYWOOD')

#Reproject into master projection
county<-st_transform(county, crs = st_crs(p))

#Crop wells to this area
wells_crop<-crop(wells, county)

#Plot County
plot(st_geometry(county))
county %>% st_geometry() %>% plot()
wells %>% plot(.,add=T)

#Estimate Well users
raster::extract(
  x=wells_crop, 
  y=county, 
  fun=sum, na.rm=T)

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#3.0 Use an alternative method -------------------------------------------------
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#Define extractorize function --------------------------------------------------
extracterize<-function(r, #Large Raster
                       p, #Inidividual Polygon 
                       uid, #Uniquie ID
                       fun=function(x){mean(x, na.rm=T)} #Aggregate Function (mean for now)
){
  
  #reproject polygon 
  p<-st_transform(p, crs=r@crs)
  
  #convert ws_poly to to a grid of points
  p_grd<-fasterize::fasterize(p, crop(r, p))
  p_pnt<-rasterToPoints(p_grd) %>% 
    as_tibble() %>% 
    st_as_sf(., coords = c("x", "y"), crs = r@crs) %>% 
    as_Spatial(.)
  
  #Extract values at points
  p_values <- raster::extract(r, p_pnt)
  
  #Apply function
  result<- fun(p_values)
  
  #Create output
  output<-tibble(
    uid,
    value = result
  )
  
  #Export Output
  output
}


#Apply function to Haywood County-----------------------------------------------
extracterize(
  r = wells, 
  p = county, 
  fun = function(x){sum(x, na.rm=T)},
  uid = 1
)

#Apply function to all counties ------------------------------------------------
#Modify extracterize function
fun<-function(n){
  extracterize(
    r = wells , 
    p = counties[n,] ,
    fun = function(x){sum(x, na.rm=T)} ,
    uid = county$FID[n]
  )
}

#Test
fun(1)

#Run for all counties using lapply
x<-lapply(seq(1,10), fun)  #nrow(counties)

#bind rows
output<-bind_rows(x)
