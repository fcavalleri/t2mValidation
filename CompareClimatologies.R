# adapt paths, file and variable names

library(ncdf4)
library(lubridate)

path_rean <- "..."
path_obs <- "..."
path_comp <- "..."

obs <- "..."
rean <- "..."

### Monthly climatologies

infile_rean <- paste0(path_rean, rean, "...")
infile_obs <- paste0(path_obs, rean, "...")
outfile_comp <- paste0(path_comp, rean)

# Extract values to compare: Tmean
compare <- paste0(path_comp, rean, "Compare.nc")
system(paste0("rm -f ", compare))

system(paste0("cdo -s merge ", infile_rean, " ", infile_obs, " ", compare))

meandiff <- paste0(path_comp, rean, "24MeanDiff.nc")
system(paste0("cdo -s expr,'DiffMean24 = t2m_24mean - Tmean - 273.15' ", compare, " ", meandiff))

tmindiff <- paste0(path_comp, rean, "TminDiff.nc")
system(paste0("cdo -s expr,'DiffTmin = t2m_min - TMIN - 273.15' ", compare, " ", tmindiff))

tmaxdiff <- paste0(path_comp, rean, "TmaxDiff.nc")
system(paste0("cdo -s expr,'DiffTmax = t2m_max - TMAX - 273.15' ", compare, " ", tmaxdiff))

# Aggregate differences

outfile <- paste0(path_comp, rean, "TempComparison_month.nc")
system(paste0("rm -f ", outfile))
system(paste("cdo -s merge", meandiff, tmindiff, tmaxdiff, outfile, sep = " "))
system(paste("rm -f", meandiff, tmindiff, tmaxdiff, sep = " "))


### Seasonal climatologies

rean <- "..."

infile_rean <- paste0(path_rean, rean, "...")
infile_obs <- paste0(path_obs, rean, "...")
outfile_comp <- paste0(path_comp, rean)

# Extract values to compare: mean
compare <- paste0(path_comp, rean, "Compare.nc")
system(paste0("rm -f ", compare))

system(paste0("cdo -s merge ", infile_rean, " ", infile_obs, " ", compare))

outfile <- paste0(path_comp, rean, "TempComparison_seas.nc")
system(paste0("cdo -s expr,'DiffMean24 = t2m_24mean - Tmean - 273.15' ", compare, " ", outfile))

### Year climatologies

rean <- "..."

infile_rean <- paste0(path_rean, rean, "...")
infile_obs <- paste0(path_obs, rean, "...")
outfile_comp <- paste0(path_comp, rean)

# Extract values to compare: mean
compare <- paste0(path_comp, rean, "Compare.nc")
system(paste0("rm -f ", compare))

system(paste0("cdo -s merge ", infile_rean, " ", infile_obs, " ", compare))

outfile <- paste0(path_comp, rean, "TempComparison_year.nc")
system(paste0("cdo -s expr,'DiffMean24 = t2m_24mean - Tmean - 273.15' ", compare, " ", outfile))

tmindiff <- paste0(path_comp, rean, "TminDiff.nc")
system(paste0("cdo -s expr,'DiffTmin = t2m_min - TMIN - 273.15' ", compare, " ", tmindiff))

tmaxdiff <- paste0(path_comp, rean, "TmaxDiff.nc")
system(paste0("cdo -s expr,'DiffTmax = t2m_max - TMAX - 273.15' ", compare, " ", tmaxdiff))

# Aggregate differences

outfile <- paste0(path_comp, rean, "TempComparison_year.nc")
system(paste0("rm -f ", outfile))
system(paste("cdo -s merge", meandiff, tmindiff, tmaxdiff, outfile, sep = " "))
system(paste("rm -f", meandiff, tmindiff, tmaxdiff, sep = " "))
