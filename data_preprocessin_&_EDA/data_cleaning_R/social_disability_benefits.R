## This dataset contains the number of online applicants for social 
## disability benefits every year. We will walk through it and extract usable
## information to find the change pattern.

# Loading the needed libraries and the dataset
library(tidyverse)
library(stringr)
library(lubridate)
ssa <- read_csv("http://594442.youcanlearnit.net/ssadisability.csv")
glimpse(ssa)
view(ssa)


# The data is not in tidy form, it is wide 
# Lets gather it horizontally
ssa_horizontal <- gather(ssa, months, numbers, -Fiscal_Year)


# This months column contain two information, lets separate it
ssa_horizontal <- separate(ssa_horizontal, months, c('months', 'application'), 
                    sep = '_')


# In our month and Fiscal year columns the name of the months and 
# fiscal years are not in the same format
unique(ssa_horizontal$months)
unique(ssa_horizontal$Fiscal_Year)

ssa_horizontal$months <- substr(ssa_horizontal$months, 1,3)
ssa_horizontal$Fiscal_Year <- str_replace(ssa_horizontal$Fiscal_Year, 
                                          "FY", "20")


# Lets assume that the data has been collected on the first of each month
ssa_horizontal$date <- dmy(paste('01', ssa_horizontal$months, 
                                 ssa_horizontal$Fiscal_Year))


# But each oct, nov and dec are actually from the past year
reduced_year <- which(month(ssa_horizontal$date) > 9)
year(ssa_horizontal$date[reduced_year]) <- year(ssa_horizontal$date
                                                [reduced_year]) - 1
ssa_horizontal$Fiscal_Year[reduced_year] <- 
  as.character(as.numeric(ssa_horizontal$Fiscal_Year[reduced_year]) -1)


# Actually to get the full informative dataset, fiscal year and months column
# are unncessary
ssa_horizontal$Fiscal_Year <- NULL
ssa_horizontal$months <- NULL


# So our final tidy form of the dataset will be as follow
ssa_horizontal$application <- as.factor(ssa_horizontal$application)
ssa_tidy <- spread(ssa_horizontal, application, numbers)


view(ssa_tidy)
