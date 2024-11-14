library(rgdal)
library(raster)
library(ncdf4)
library(lubridate)
library(ggplot2)

years <- 2000:2020

rean <- "..."

# anomalies
rean_path <- "..."
obs_path <- "..."
corr_path <- "..."

#1 create rean unique nc

    for (year in years){
    writeLines(paste(rean,year))
    infiles <- paste0(rean_path,"Anomaly_t2m_",year,"*")
    merge <- paste0(rean_path,"Merge_Daily_year_",year,".nc")   
    system(paste0("rm -f ",merge)) 
    system(paste0("cdo -s mergetime ",infiles," ",merge))
    }

    infiles <- paste0(rean_path,"Merge_Daily_year_*")
    merge_rean <- paste0(rean_path,"Merge_Daily.nc")    
    system(paste0("rm -f ",merge_rean))      
    system(paste0("cdo -s mergetime ",infiles," ",merge_rean))
    system(paste0("rm -f ",infiles))      

#2 create obs unique nc

    for (year in years){
    writeLines(paste(rean,year))
    infiles <- paste0(obs_path,"Anomaly_t2m_",year,"*")
    merge <- paste0(obs_path,"Merge_Daily_year_",year,".nc")   
    system(paste0("rm -f ",merge))  
    system(paste0("cdo -s mergetime ",infiles," ",merge))
    }

    infiles <- paste0(obs_path,"Merge_Daily_year_*")
    merge_obs <- paste0(obs_path,"Merge_Daily.nc")    
    system(paste0("rm -f ",merge_obs))      
    system(paste0("cdo -s mergetime ",infiles," ",merge_obs))
    system(paste0("rm -f ",infiles))      

#3 calculate correlation in time (whole period)
corr_outfile <- paste0(corr_path,"Rean_Obs_Anom_Correlation_2000-2020.nc")
system(paste0("rm -f ",corr_outfile))
system(paste0("cdo -b f32 timcor ",merge_rean," ",merge_obs," ",corr_outfile))
system(paste0("ncrename -O -v Tmean,corr ",corr_outfile))

#4 seasonal correlation
filename_seas <-  paste0(rean_path,"Merge_Daily_")    
system(paste0("cdo splitseas ",merge_rean," ",filename_seas))

filename_seas <-  paste0(obs_path,"Merge_Daily_")    
system(paste0("cdo splitseas ",merge_obs," ",filename_seas))

seas_str <- c("DJF","MAM","JJA","SON")

for (seas in 1:4){
infile_rean <- paste0(rean_path,"Merge_Daily_",seas_str[seas],".nc") 
infile_obs <- paste0(obs_path,"Merge_Daily_",seas_str[seas],".nc")   
corr_outfile <- paste0(corr_path,"Rean_Obs_Anom_Correlation_2000-2020_",seas_str[seas],".nc")
system(paste0("cdo -b f32 timcor ",infile_rean," ",infile_obs," ",corr_outfile))
system(paste0("rm -f ",infile_rean," ",infile_obs))
}

a <- paste0(corr_path,"Rean_Obs_Anom_Correlation_2000-2020_",seas_str,".nc")
infiles <- paste(a,collapse=" ")
corr_outfile <- paste0(corr_path,"Rean_Obs_Anom_Correlation_2000-2020_seas.nc")
system(paste0("rm -f ",corr_outfile))
system(paste0("cdo mergetime ",infiles," ",corr_outfile))

system(paste0("ncrename -O -v t2m_mean,corr ",corr_outfile))
