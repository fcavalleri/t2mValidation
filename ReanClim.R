# Obtain temperature climatologies from ISAC-CNR observations

year_start <- ...
year_end <- ...

path_in <- "..."
path_out <- "..."

rean_name <- "..._"
tmean_name <- "..._"
tmin_name <- "..._"
tmax_name <- "..._"

years <- seq(year_start,year_end,1)

for (y in years){
    year_folder <- paste0(path_in,y,"/")

    filename_mean <- paste0(year_folder,rean_name,tmean_name,y)
    filename_min <- paste0(year_folder,rean_name,tmin_name,y)
    filename_max <- paste0(year_folder,rean_name,tmax_name,y)

    for (m in 1:12){
        filename_mean_month <- paste0(filename_mean,sprintf("%02d",m),".nc")
        filename_min_month <- paste0(filename_min,sprintf("%02d",m),".nc")
        filename_max_month <- paste0(filename_max,sprintf("%02d",m),".nc")

        # 1. Get monthly climatologies
        outfile_mean <- paste0(path_out,tmean_name,y,sprintf("%02d",m),".nc")
        outfile_min <- paste0(path_out,tmin_name,y,sprintf("%02d",m),".nc")
        outfile_max <- paste0(path_out,tmax_name,y,sprintf("%02d",m),".nc")

        system(paste0("cdo timmean ",filename_mean_month," ",outfile_mean))
        system(paste0("cdo timmin ",filename_min_month," ",outfile_min))
        system(paste0("cdo timmax ",filename_max_month," ",outfile_max))
    }

}

# 2 Merge monthly files into 1 single file
infiles <- paste0(path_out,tmean_name,"*")
outfile <- paste0(path_out,"Monthly_",tmean_name,"_",year_start,"-",year_end,".nc")
system(paste0("cdo -s mergetime ",infiles," ",outfile))

infiles <- paste0(path_out,tmin_name,"*")
outfile <- paste0(path_out,"Monthly_",tmin_name,"_",year_start,"-",year_end,".nc")
system(paste0("cdo -s mergetime ",infiles," ",outfile))

infiles <- paste0(path_out,tmax_name,"*")
outfile <- paste0(path_out,"Monthly_",tmax_name,"_",year_start,"-",year_end,".nc")
system(paste0("cdo -s mergetime ",infiles," ",outfile))


# 3 Calculate yearly, monthly and seasonal climatologies
infile <- paste0(path_out,"Monthly_",tmean_name,"_",year_start,"-",year_end,".nc")
outfile <- paste0(path_out,"Clim_",tmean_name,"_",year_start,"-",year_end,"_year.nc")
system(paste0("cdo timmean ",infile," ",outfile))
outfile <- paste0(path_out,"Clim_",tmean_name,"_",year_start,"-",year_end,"_seas.nc")
system(paste0("cdo yseasmean ",infile," ",outfile))
outfile <- paste0(path_out,"Clim_",tmean_name,"_",year_start,"-",year_end,"_mon.nc")
system(paste0("cdo ymonmean ",infile," ",outfile))

infile <- paste0(path_out,"Monthly_",tmin_name,"_",year_start,"-",year_end,".nc")
outfile <- paste0(path_out,"Clim_",tmin_name,"_",year_start,"-",year_end,"_year.nc")
system(paste0("cdo timmean ",infile," ",outfile))
outfile <- paste0(path_out,"Clim_",tmin_name,"_",year_start,"-",year_end,"_seas.nc")
system(paste0("cdo yseasmean ",infile," ",outfile))
outfile <- paste0(path_out,"Clim_",tmin_name,"_",year_start,"-",year_end,"_month.nc")
system(paste0("cdo ymonmean ",infile," ",outfile))

infile <- paste0(path_out,"Monthly_",tmax_name,"_",year_start,"-",year_end,".nc")
outfile <- paste0(path_out,"Clim_",tmax_name,"_",year_start,"-",year_end,"_year.nc")
system(paste0("cdo timmean ",infile," ",outfile))
outfile <- paste0(path_out,"Clim_",tmax_name,"_",year_start,"-",year_end,"_seas.nc")
system(paste0("cdo yseasmean ",infile," ",outfile))
outfile <- paste0(path_out,"Clim_",tmax_name,"_",year_start,"-",year_end,"_month.nc")
system(paste0("cdo ymonmean ",infile," ",outfile))



# Optional: Split into monthly and seasonal files (to get average trend)
infile <- paste0(path_out,tmin_name,"1990-2010.nc")
outfile_seas <- paste0(path_out,tmin_name,"1990-2010_")
system(paste0("cdo splitseas,%S ",infile," ",outfile_seas))

infile <- paste0(path_out,tmax_name,"1990-2010.nc") 
outfile_seas <- paste0(path_out,tmax_name,"1990-2010_")
system(paste0("cdo splitseas,%S ",infile," ",outfile_seas))

infile <- paste0(path_out,tmin_name,"1990-2010.nc")
outfile_mon <- paste0(path_out,tmin_name,"1990-2010_")
system(paste0("cdo splitmon,%m ",infile," ",outfile_mon))

infile <- paste0(path_out,tmax_name,"1990-2010.nc")
outfile_mon <- paste0(path_out,tmax_name,"1990-2010_")
system(paste0("cdo splitmon,%m ",infile," ",outfile_mon))
