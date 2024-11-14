# specify the product and provide daily climatology netcdf files

library(ncdf4)
library(lubridate)

source <- "..."

path_clim <- "..."
path_in <- "..."
path_out <- "..."

years <- 1991:2020
months <- 1:12
days_in_month <- c(31,28,31,30,31,30,31,31,30,31,30,31)

for (year in years){

	if (leap_year(year)) {
		days_in_month[2] <-29
		daily_clim <- paste0(path_clim,"DailyClimatologies_1991-2020_leap.nc")   ###
		} else {
		days_in_month[2] <-28
		daily_clim <- paste0(path_clim,"DailyClimatologies_1991-2020.nc")    ###
		}

	for (month in months){
	    days <- 1:days_in_month[month]

        for (day in days){
        date_str <- paste0(sprintf("%04d",year),sprintf("%02d",month),sprintf("%02d",day))
        if (leap_year(year)) {date_str_cdo <- paste0(sprintf("%04d",1992),"-",sprintf("%02d",month),"-",sprintf("%02d",day))} else {date_str_cdo <- paste0(sprintf("%04d",1991),"-",sprintf("%02d",month),"-",sprintf("%02d",day))}
		writeLines(date_str)
        abs_val <- paste0(path_in,"###filename",date_str,".nc")
      
        anom <- paste0(path_out,"Anomaly_t2m_",date_str,".nc")
        clim <- paste0(path_clim,"Climatological_t2m_",date_str,".nc")
        system(paste0("cdo -s -seldate,",date_str_cdo," ",daily_clim," ",clim))
        system(paste0("cdo -s sub ",abs_val," ",clim," ",anom))
        system(paste0("rm -f ",clim))

        }
    }
}
