library(ncdf4)
library(lubridate)
library(matrixStats)

path_in <- "..."
path_output <- "..." 
tag <- "XXX_"

# NetCDF file name with grid node coordinates
nc_orog <- "..." 

# Where to find the timeseries in column format
path_timeseries <- "..."
tag_TS <- "XXX_"

# Coordinates with observational series
coord_file <- paste0(path_in,"GEO_PAR")
coord_matrix <- read.table(coord_file, sep = "", header = FALSE)[,1:4]
colnames(coord_matrix) <- c("filename","lon","lat","elev")
n_coord <- dim(coord_matrix)[1]

# All coordinates in the netcdf to fill
nc_orog_file <- paste0(path_in,nc_orog)
rean_nc <- nc_open(nc_orog_file)
lat <- ncvar_get(rean_nc,'lat')
lon <- ncvar_get(rean_nc,'lon')
nc_close(rean_nc)

# Build matrices with lon and lat

if (dim(t(lon))[1]==1){
### Regular grid: lon and lat are vectors, covert into matrices 
regular = TRUE
n_lon <- length(lon)
n_lat <- length(lat)
lat_mat <- matrix(rep(lat, n_lon), ncol = n_lon)
lon_mat <- t(matrix(rep(lon, n_lat), ncol = n_lat))
}else{
### Non-regular grid: lon_mat and lat_mat are already matrices
regular = FALSE
n_lon <- dim(lat)[1]
n_lat <- dim(lat)[2]
lat_mat <- lat
lon_mat <- lon
}

# Number of total points in the matrices
n_pts <- n_lon * n_lat

# Find the indices in the matrix where data is present (to be filled)
data_idx <- matrix(nrow=n_coord, ncol=2) # associo indice riga GEO_PAR con posizioni in matrice lon-lat

# Round both coordinates to the same decimal places
dec_round <- 5 # arrotondo al quinto decimale
obs_lon <- round(coord_matrix$lon, dec_round)
obs_lat <- round(coord_matrix$lat, dec_round)

# Search and match the coordinates from the list into the matrices
if (regular==TRUE){
    lon_r <- round(lon, dec_round)
    lat_r <- round(lat, dec_round)
        for (i in 1:n_coord) {
            writeLines(paste("Progress: ", i, "/", n_coord))
            data_idx[i, 2] <- which(abs(lat_r - obs_lat[i]) < 0.0001)
            data_idx[i, 1] <- which(abs(lon_r - obs_lon[i]) < 0.0001)
        }
}else{
    lon_mat_r <- round(lon_mat, dec_round)
    lat_mat_r <- round(lat_mat, dec_round)
        for (i in 1:n_coord) {
            writeLines(paste("Progress: ", i, "/", n_coord))
            m1 <- which(lon_mat_r == obs_lon[i], arr.ind = TRUE)
            m2 <- which(lat_mat_r == obs_lat[i], arr.ind = TRUE)
            o <- outer(seq_len(nrow(m1)), seq_len(nrow(m2)), Vectorize(
                function(i, j) all(m1[i, ] == m2[j, ])))
            data_idx[i, ] <- m1[apply(o, 1, any), ]
        }
}

# Control: plot indices of coordinates to be filled
#plot(data_idx[, 1], data_idx[, 2], pch=19, cex=0.001)
# must look similar to
#plot(obs_lat, obs_lon, pch=19, cex=0.001)
# a rotation is ok, but the points must be in the same position
# because when you put matrices in netcdf they are rotated

# Define the years for extraction

start_year <- 1990
end_year <- 2023
n_years <- end_year + 1 - start_year

# Extract values year by year and store them in a NetCDF file

# Obs coordinates and names
list_coord <- coord_matrix[,2:3]
coord_string_for_filenames <- coord_matrix[,1]

# Extract dates from a single file (same for all files)
#path_timeseries <- "/storage/MORIA-MOLOCH/TMN/TMND/" ### PUT HERE THE PATH TO THE TIMESERIES FILES
filename <- paste0(path_timeseries,tag_TS,coord_string_for_filenames[1])

ref_data <- as.matrix(read.table(filename, sep = ""))
ref_years <- ref_data[, 1]
ref_months <- ref_data[, 2]
ref_days <- ref_data[, 3]
ref_days_in_year <- ref_data[, 4]

FillVal <- NA # cambiare codice dato mancante se serve.

for (year in start_year:end_year){

  # Find the starting row
  start_ind <- which(ref_years == year)[1]

  # Duration of the year
  n_days <- 365
  if (leap_year(year)) {n_days <- 366}

  # Create a 3D matrix with all coordinates
  # Where the value is absent, put the NetCDF fill value = NA
  daily_val <- array(FillVal, c(n_lon, n_lat, n_days))

  # Loop only through existing files to download the values of each
  for (p in 1:n_coord){
    writeLines(paste("Year: ", year, "/", end_year, " ", p, "/", n_coord, sep=""))
    one_lon <- obs_lon[p]
    one_lat <- obs_lat[p]
    
    # Read timeseries
    ### insert correct paths and filenames
    filename <- paste0(path_timeseries,tag_TS,coord_string_for_filenames[p])
    timeseries <- as.matrix(read.table(filename, sep = "", nrows=366, skip=start_ind-1))[,5]
    
    # Remove February 29 if the year is not a leap year
    if (n_days == 365){
      timeseries <- timeseries[-(31+29)]
#      tmax_timeseries <- tmax_timeseries[-(31+29)]
    }

    # Replace -90 with FillVal
    na_ind <- which(timeseries == -90)
    timeseries[na_ind] <- FillVal
 
    # Insert into the 3D matrix
    daily_val[data_idx[p,1], data_idx[p,2], ] <- timeseries   
    }

# Overwrite observations onto a template netcdf file create from orography file
#path_output <- "/storage/MORIA-MOLOCH/TMN/NetCDF/" ### where you want to put the netcdf
infile <- paste0(path_output,"Obs_YearTemplate.nc")
if (leap_year(year)) {infile <- paste0(path_output,"Obs_YearTemplate_leap.nc")}
outfile <- paste0(path_output,tag,year,".nc")

system(paste0("cdo setyear,",year," ",infile," ",outfile))

nc <- nc_open(outfile,write=TRUE)

### SET THE VARIABLE NAME
varname_template <- "mask_name_orog"
varname <- "T2min"
system(paste0("ncrename -O -v ",varname_template,",",varname," ",outfile))
ncvar_put( nc, varname, daily_val, start=NA, count=NA, verbose=FALSE )
nc_close( nc )

}
