# Obtain temperature climatologies from tmin and tmax observations

path_in <- "..."
path_out <- "..."

tmin_name <- "TMND_"
tmax_name <- "TMXD_"

years <- seq(1990,2010,1)

# 1 Merge yearly files into 1 single file
infiles <- paste0(path_in,tmin_name,years,".nc", collapse = " ")
outfile <- paste0(path_out,tmin_name,"1990-2010.nc")
system(paste0("cdo -s mergetime ",infiles," ",outfile))

# 2 Calculate yearly, monthly and seasonal climatologies
infile <- paste0(path_out,tmin_name,"1990-2010.nc")

outfile <- paste0(path_out,"Clim_Tmin_1990-2010_year.nc")
system(paste0("cdo timmean ",infile," ",outfile))

outfile <- paste0(path_out,"Clim_Tmin_1990-2010_seas.nc")
system(paste0("cdo yseasmean ",infile," ",outfile))

outfile <- paste0(path_out,"Clim_Tmin_1990-2010_mon.nc")
system(paste0("cdo ymonmean ",infile," ",outfile))

# Repeat for Tmax
infiles <- paste0(path_in,tmax_name,years,".nc", collapse = " ")
outfile <- paste0(path_out,tmax_name,"1990-2010.nc")
system(paste0("cdo -s mergetime ",infiles," ",outfile))

infile <- paste0(path_out,tmax_name,"1990-2010.nc")
system(paste0("cdo timmean ",infile," ",paste0(path_out,"Clim_Tmax_1990-2010_year.nc")))

infile <- paste0(path_out,tmax_name,"1990-2010.nc")
system(paste0("cdo yseasmean ",infile," ",paste0(path_out,"Clim_Tmax_1990-2010_seas.nc")))

infile <- paste0(path_out,tmax_name,"1990-2010.nc")
system(paste0("cdo ymonmean ",infile," ",paste0(path_out,"Clim_Tmax_1990-2010_mon.nc")))

# 3 Average Tmax and Tmin to get Tmean climatology

tmin <- paste0(path_out,"Clim_Tmin_1990-2010_year.nc")
tmax <- paste0(path_out,"Clim_Tmax_1990-2010_year.nc")
mergefile <- paste0(path_out,"merge.nc")
system(paste0("cdo -s merge ",tmin," ",tmax," ",mergefile))
outfile <- paste0(path_out,"Clim_Tmean_1990-2010_year.nc")
system(paste0("cdo -s expr,'T2mean=(T2min+T2max)/2' ",mergefile," ",outfile))
system(paste0("rm ",mergefile))

tmin <- paste0(path_out,"Clim_Tmin_1990-2010_seas.nc")
tmax <- paste0(path_out,"Clim_Tmax_1990-2010_seas.nc")
mergefile <- paste0(path_out,"merge.nc")
system(paste0("cdo -s merge ",tmin," ",tmax," ",mergefile))
outfile <- paste0(path_out,"Clim_Tmean_1990-2010_seas.nc")
system(paste0("cdo -s expr,'T2mean=(T2min+T2max)/2' ",mergefile," ",outfile))
system(paste0("rm ",mergefile))

tmin <- paste0(path_out,"Clim_Tmin_1990-2010_mon.nc")
tmax <- paste0(path_out,"Clim_Tmax_1990-2010_mon.nc")
mergefile <- paste0(path_out,"merge.nc")
system(paste0("cdo -s merge ",tmin," ",tmax," ",mergefile))
outfile <- paste0(path_out,"Clim_Tmean_1990-2010_mon.nc")
system(paste0("cdo -s expr,'T2mean=(T2min+T2max)/2' ",mergefile," ",outfile))
system(paste0("rm ",mergefile))


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
