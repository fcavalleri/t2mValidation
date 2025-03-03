# This script calculates daily temperature anomalies for the years 1990 to 2010.

library(ncdf4)
library(lubridate)
 
path_clim <- directory of the daily climatologies file
path_in <-  directory of the daily absolute t2m values
path_out <- directory to store the anomalies

# define time interval
years <- 1990:2010
months <- 1:12
days_in_month <- c(31,28,31,30,31,30,31,31,30,31,30,31)

for (year in years){

    # Check if the year is a leap year and set the appropriate number of days in February.
    if (leap_year(year)) {
        days_in_month[2] <- 29
        daily_clim <- paste0(path_clim,"DailyClimatologies_1990-2010_Tmean_leap.nc")
    } else {
        days_in_month[2] <- 28
        daily_clim <- paste0(path_clim,"DailyClimatologies_1990-2010_Tmean.nc")
    }

    for (month in months){
        days <- 1:days_in_month[month]

        for (day in days){
            # Create date strings for file naming and CDO commands.
            date_str <- paste0(sprintf("%04d",year),sprintf("%02d",month),"_",sprintf("%02d",day))
            if (leap_year(year)) {
                date_str_cdo <- paste0(sprintf("%04d",1992),"-",sprintf("%02d",month),"-",sprintf("%02d",day))
            } else {
                date_str_cdo <- paste0(sprintf("%04d",1990),"-",sprintf("%02d",month),"-",sprintf("%02d",day))
            }
            writeLines(date_str)
            
            # Define file paths for absolute values, anomalies, and climatologies.
            abs_val <- paste0(path_in,"DailyTMean_",date_str,".nc")
            #abs_val <- paste0(path_in,"Obs_Mean_",date_str,".nc")
            #abs_val <- paste0(path_in,"ERA5_",date_str,".nc")
            anom <- paste0(path_out,"Anomaly_t2m_",date_str,".nc")
            clim <- paste0(path_clim,"Climatological_t2m_",date_str,".nc")
            
            # Use CDO to select the date from the climatology file and calculate the anomaly.
            system(paste0("cdo -s -seldate,",date_str_cdo," ",daily_clim," ",clim))
            system(paste0("cdo -s sub ",abs_val," ",clim," ",anom))
            system(paste0("rm -f ",clim))
        }
    }
}
