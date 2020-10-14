welldata <- st_as_sf(welldata,coords=c("Lat","Long"), crs=4326)

counties <- st_transform(counties,crs=4326)
ncwelldata <- st_intersection(welldata,counties)

ncwellmap <-raster()
extent(ncwellmap) <- extent(ncwelldata)
rasterize(ncwelldata,ncwellmap)
