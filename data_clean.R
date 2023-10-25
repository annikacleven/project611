#Cleaning the Data and turning into versions we want
library(readr)
install.packages("dplyr")
library(dplyr)
install.packages("tidyverse")
library(tidyverse)

#sourcing utils for ensure_directory function for later 
source("utils.R")

climbing_statistics <- read_csv("source_data/climbing_statistics.csv")
Rainier_Weather <- read_csv("source_data/Rainier_Weather.csv")

#joining the dataset
all_data <- full_join(climbing_statistics, Rainier_Weather, by = "Date")

#adding variables that will be helpful later
#install.packages("lubridate")
library(lubridate)
all_data <- all_data %>%
  mutate(
    month_num = month(mdy(Date)),
    year_num = year(mdy(Date)),
    date_num = day(mdy(Date))) %>%
  mutate(month_day2 = as.Date(str_c(month_num, "/", date_num),"%m/%d"),
         day_of_year = yday(mdy(Date))) 

ensure_directory("derived_data")
write_csv(all_data, "derived_data/all_data.csv")