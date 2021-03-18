# Data cleaning of Water Quality
# In this script we will clean the dataset of the water quality of austin USA


# Loading the libraries
library(tidyverse)
library(stringr)
library(lubridate)


# Loading the data
water <- read_csv('http://594442.youcanlearnit.net/austinwater.csv')
glimpse(water)


# We will keep the information about the temparature and the pH of water
# Other irrelevant columns will be removed
# lets create another tibbles with useful columns

water_shortened <- tibble('site_name' = water$SITE_NAME,
                          'site_type' = water$SITE_TYPE,
                          'sample_time'=water$SAMPLE_DATE,
                          'parameter_type'=water$PARAM_TYPE,
                          'parameter'=water$PARAMETER,
                          'result'=water$RESULT,
                          'unit'=water$UNIT)

# Lets check which parameters are available here
unique(water_shortened$parameter)


# There are 2,041 parameters
# So lets change the direction of the experiment
unique(water_shortened$parameter_type)


# It returns only 95 unique values. We can work on parameter_type column
# pH value and temperature values are of "Alkalinity/Hardness/pH" and 
# conventionals type
water_param_type <- 
  subset(water_shortened, 
         water_shortened$parameter_type == "Alkalinity/Hardness/pH" |
           water_shortened$parameter_type == "Conventionals")


unique(water_param_type$parameter)
# Now we have only 16 unique values for the parameters
# We can easily narrow down our desired data
water_param_type <- 
  subset(water_param_type,
         water_param_type$parameter == "PH" |
           water_param_type$parameter == "WATER TEMPERATURE")


# There are number of columns which are in character format instead of factor
# Changing the column value types
water_param_type$site_type <- as.factor(water_param_type$site_type)
water_param_type$parameter_type <- as.factor(water_param_type$parameter_type)
water_param_type$parameter <- as.factor(water_param_type$parameter)
water_param_type$unit <- as.factor(water_param_type$unit)
water_param_type$sample_time <- mdy_hms(water_param_type$sample_time)

glimpse(water_param_type)
summary(water_param_type)


# Here, the unit column has a value for "Feet" and "MG/L"
# It is unusual unit for pH and temperature
# Lets check these values
subset(water_param_type, unit=="Feet")

# The row seems legitimate, so just change the "Feet" to "Deg. Fahrenheit"
row_to_change <- which(water_param_type$unit == "Feet")

water_param_type$unit[row_to_change] <- "Deg. Fahrenheit"


row_to_change <- which(water_param_type$unit == "MG/L" & 
                         water_param_type$parameter == "PH")
water_param_type$unit[row_to_change] <- "Standard units"


row_to_change <- which(water_param_type$unit == "MG/L" & 
                         water_param_type$result > 70
)
water_param_type$unit[row_to_change] <- "Deg. Fahrenheit"

row_to_change <- which(water_param_type$unit == "MG/L")
water_param_type$unit[row_to_change] <- "Deg. Celsius"


# There are some observations where the resulted temperature is extremely high
# It can be result of wrong data collection
# So lets remove those values
row_to_remove <- which(water_param_type$result>100)
water_param_type <- water_param_type[-row_to_remove,]


# Removing one observation with NA value
#row_with_na <- which(is.na(water_param_type$result))
#water_param_type <- water_param_type[-row_with_na,]
summary(water_param_type)


# Still there are some rows where the temparature is  quite high 
# This is because some data may be collected in wrong units (deg. celsius 
# instead of deg. fahrenheit)
row_wrong_deg <- which(water_param_type$result>50 
                       & water_param_type$unit =="Deg. Celsius")
water_param_type$unit[row_wrong_deg] <- "Deg. Fahrenheit"


# Now lets change the temperature unit into a single one
only_fahrenheit <- which(water_param_type$unit=="Deg. Fahrenheit")
water_param_type$result[only_fahrenheit] <- 
  (water_param_type$result[only_fahrenheit] -32) * (5.0/9.0)
water_param_type$unit[only_fahrenheit] <- "Deg. Celsius"

summary(water_param_type)


# Dropping some unused columns
water_param_type <- water_param_type[, -c(4,7)]
view(water_param_type)


# Checking  if there is any duplicate value
dup_check <- water_param_type[,-5]
dup_rows <- which(duplicated(dup_check))


# So now get rid of the duplicate values
water_param_type <- water_param_type[-dup_rows, ]

# And the final tidy version of the dataset is as follow
water_tidy <- spread(water_param_type, parameter, result)

view(water_tidy)
