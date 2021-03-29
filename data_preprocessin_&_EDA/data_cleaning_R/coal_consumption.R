# In this script we are going to clean a messy dataset which contains the 
# amount of coal consumption of each countries from 1980. 

#Lets import the libraries
library(tidyverse)

# Load the data 
# First row is an empty row so we are going to skip it
coal<- read.csv('http://594442.youcanlearnit.net/coal.csv', skip=1)
view(coal)


# As we saw in the table view that the first column name is "X"
# Other column names are also something else than the year
# Lets change the column names
colnames(coal)[1] <- "region"
colnames(coal)[-1] <- coal[1,2:31]

# First row is still the years which is used as column name, lets remove it
coal <- coal[-1,]


# Lets check all the columns
summary(coal_new)


# We can see that the table is not in tidy form. So make it in tidy form.
# All the columns except the region one will be not changed.
coal <-  gather(coal, key = 'year', value = 'consumption', -region)


# Now check again 
summary(coal)

# All the columns are in character format.
# Change the year column into integer and consumption into numeric
coal$year <- as.integer(coal$year)
coal$consumption <- as.numeric(coal$consumption)


# Lets check the regions
unique(coal$region)


# There are some names which are not countries rather than continents
# Creating a different tibbles for the continets and separating them
non_countries <- c("North America", "Central & South America", "Antarctica", "Europe", "Eurasia", 
                   "Middle East", "Africa", "Asia & Oceania", "World")

match(coal_new_2$region, non_countries)
matches<-which(!is.na(match(coal$region, non_countries)))

coal_countries <- coal[-matches,]
coal_non_countries <- coal[matches,]

# Still, there is some rows which have the value for "World"
# It is the mismatch of units because all the other values are from continents
coal_non_countries <- subset(coal_non_countries, region!="World")

# Now both of the tibbles are ready and clean
view(coal_countries)
view(coal_non_countries)