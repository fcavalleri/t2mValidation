library(rgdal)
library(raster)
library(ncdf4)
library(lubridate)
library(ggplot2)

years <- 1991:2020
months <- 1:12
days_in_month <- c(31,28,31,30,31,30,31,31,30,31,30,31)

rean <- "..."

path_in_rean_anom <- "..."
path_in_obs_anom <- "..."
path_out <- "..."

for (year in years){
if (leap_year(year)) {days_in_month[2]<-29} else {days_in_month[2]<-28}
    for (month in months){

    # REANALYSES Monthly Mean Anomalies  
    #infiles_rean <- paste0(path_in_rean_anom,"Anomaly_t2m_",sprintf("%04d",year),sprintf("%02d",month),"*")
    #outfile_rean_month <- paste0(path_in_rean_anom,"Anomaly_t2m_monthly_",sprintf("%04d",year),sprintf("%02d",month),".nc")
    #system(paste0("cdo -s ensmean ",infiles_rean," "," ",outfile_rean_month))
    
    # OBSERVATIONS Monthly Mean Anomalies  
    #infiles_obs <- paste0(path_in_obs_anom,"Anomaly_t2m_",sprintf("%04d",year),sprintf("%02d",month),"*")
    #outfile_obs_month <- paste0(path_in_obs_anom,"Anomaly_t2m_monthly_",sprintf("%04d",year),sprintf("%02d",month),".nc")
    #system(paste0("cdo -s ensmean ",infiles_obs," "," ",outfile_obs_month))

    # DIFFERENCES Monthly
    #outfile <- paste0(path_out,"Diff_monthly_Anomaly_t2m_",sprintf("%04d",year),sprintf("%02d",month),".nc")
    #system(paste0("cdo -s sub ",outfile_rean_month," ",outfile_obs_month," ",outfile))

    days <- 1:days_in_month[month]
        for (day in days){
            date_str <- paste0(sprintf("%04d",year),sprintf("%02d",month),sprintf("%02d",day))
            writeLines(date_str)

            # REANALYSES Anomalies  
            infile_rean <- paste0(path_in_rean_anom,"Anomaly_t2m_",date_str,".nc")

            # OBSERVATIONS Anomalies
            infile_obs <- paste0(path_in_obs_anom,"Anomaly_t2m_",date_str,".nc")

            # DIFFERENCES Daily
            outfile <- paste0(path_out,"Diff_Anomaly_t2m_",date_str,".nc")
            system(paste0("cdo -s sub ",infile_rean," ",infile_obs," ",outfile))
            
        }
    }
}

# Daily MAE and RMSE

for (year in years){
infiles <- paste0(path_out,"Diff_Anomaly_t2m_",year,"*")
merge <- paste0(path_out_scores,"Merge_Daily_year_",year,".nc")    
system(paste0("cdo -s mergetime ",infiles," ",merge))
}

infiles <- paste0(path_out_scores,"Merge_Daily_year_*")
merge <- paste0(path_out_scores,"Merge_Daily.nc")    
system(paste0("cdo -s mergetime ",infiles," ",merge))
system(paste0("rm -f ",infiles))      
outfile_year <- paste0(path_out_scores,"MAE_Anomaly_Daily_Diff_t2m_1991-2020_year.nc")
system(paste0("cdo -s timmean -abs ",merge," ",outfile_year))
outfile_seas <- paste0(path_out_scores,"MAE_Anomaly_Daily_Diff_t2m_1991-2020_seas.nc")
system(paste0("cdo -s yseasmean -abs ",merge," ",outfile_seas))

outfile_year <- paste0(path_out_scores,"RMSE_Anomaly_Daily_Diff_t2m_1991-2020_year.nc")
system(paste0("cdo -s sqrt -timmean -sqr ",merge," ",outfile_year))
outfile_seas <- paste0(path_out_scores,"RMSE_Anomaly_Daily_Diff_t2m_1991-2020_seas.nc")
system(paste0("cdo -s sqrt -yseasmean -sqr ",merge," ",outfile_seas))

system(paste0("rm -f ",merge))


# Monthly MAE and RMSE
  
path_in_rean_anom <- paste0("/media/met_mods2/METEO/Rielab/DataForValidation/Reanalyses/",rean,"/t2m/Anom/")
path_in_obs_anom <- paste0("/media/met_mods2/METEO/Rielab/DataForValidation/Obs/",rean,"/ConvToNetcdf/Anom/")
path_out <- paste0("/media/met_mods2/METEO/Rielab/DataForValidation/Comparisons/",rean,"/Anom/")

new_folder <- "Scores/"
#system(paste0("mkdir ",path_out,new_folder))
path_out_scores <- paste0(path_out,new_folder)

infiles <-paste0(path_out,"Diff_monthly_Anomaly_t2m_*")
merge <- paste0(path_out_scores,"Merge_Monthly.nc")    
system(paste0("cdo -s mergetime ",infiles," ",merge))

outfile_year <- paste0(path_out_scores,"MAE_Anomaly_Monthly_Diff_t2m_1991-2020_year.nc")
system(paste0("cdo -s timmean -abs ",merge," ",outfile_year))
outfile_seas <- paste0(path_out_scores,"MAE_Anomaly_Monthly_Diff_t2m_1991-2020_seas.nc")
system(paste0("cdo -s yseasmean -abs ",merge," ",outfile_seas))

outfile_year <- paste0(path_out_scores,"RMSE_Anomaly_Monthly_Diff_t2m_1991-2020_year.nc")
system(paste0("cdo -s sqrt -timmean -sqr ",merge," ",outfile_year))
outfile_seas <- paste0(path_out_scores,"RMSE_Anomaly_Monthly_Diff_t2m_1991-2020_seas.nc")
system(paste0("cdo -s sqrt -yseasmean -sqr ",merge," ",outfile_seas))

system(paste0("rm -f ",merge))
