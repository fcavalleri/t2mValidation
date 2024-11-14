library(ncdf4)
library(lubridate)
library(matrixStats)

rean <- "..."
varname <- "..."

path_in <- "..."
filename <- paste0(path_in,"Climatologies_1991-2020.nc")

# Get monthly climatologies 

nc <- nc_open(filename,write=FALSE)
monthly_temp <- ncvar_get( nc, varname, start=NA, count=NA, verbose=FALSE )
nc_close( nc )

n_lon <- dim(monthly_temp)[1]
n_lat <- dim(monthly_temp)[2]

# Define interpolation parameters
# Method 2nd degree Taylor series

n_days <- 366

STEP <- 2*pi/12; TETA <- seq(STEP/2, 2*pi - STEP/2, STEP); 
MAT_REG_12 <- matrix(nrow=12,ncol=4)
MAT_REG_12[,1] <- sin(TETA); MAT_REG_12[,2] <- cos(TETA); MAT_REG_12[,3] <- sin(2*TETA); MAT_REG_12[,4] <- cos(2*TETA)

STEP <- 2*pi/n_days; TETA <- seq(STEP/2, 2*pi - STEP/2, STEP); 
MAT_REG_366 <- matrix(nrow=n_days,ncol=4)
MAT_REG_366[,1] <- sin(TETA); MAT_REG_366[,2] <- cos(TETA); MAT_REG_366[,3] <- sin(2*TETA); MAT_REG_366[,4] <- cos(2*TETA)

daily_ts <- array(0,c(n_lon,n_lat,n_days))

for(i in 1:n_lon){
    for(j in 1:n_lat){
        if (j == 1) {writeLines(paste0(i,"/",n_lon))}
        if(is.na(monthly_temp[i,j,1])==TRUE){daily_ts[i,j,] <- rep(NA,n_days)}
        else{
        lm_T <- lm(monthly_temp[i,j,] ~ MAT_REG_12[,1] + MAT_REG_12[,2] + MAT_REG_12[,3] + MAT_REG_12[,4])
        daily_ts[i,j,] <- lm_T$coefficients[1] + lm_T$coefficients[2]*MAT_REG_366[,1] + lm_T$coefficients[3]*MAT_REG_366[,2] + lm_T$coefficients[4]*MAT_REG_366[,3] + lm_T$coefficients[5]*MAT_REG_366[,4]  
        }
    }
}

# Build yearly climatology netcdf file

path_output <- "..."
infile <- "...template netcdf file to fill"
outfile <- paste0(path_in,"DailyClimatologies_1991-2020_leap.nc")
system(paste0("cdo selvar,TMIN ",infile," ",outfile))
system(paste0("ncrename -O -v TMIN,Tmean ", outfile))

nc <- nc_open(outfile,write=TRUE) 
ncvar_put( nc, 'Tmean', daily_ts, start=NA, count=NA, verbose=FALSE )
nc_close( nc )
