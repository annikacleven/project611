#This file builds a boosting model that will attempt to predict the success
#of hikers trying to summitt

# Split the dataset into training and testing sets
library(caTools)
library(readr)
library(dplyr)
library(tidyverse)

#set up functions for later
source("~/work/utils.R")

#importing necessary data
all_data <- read_csv("~/work/derived_data/all_data.csv")

all_data_no_na <- all_data %>%
  drop_na() %>% #either all weather data is missing or none is
  filter(`Success Percentage` <= 1) %>%
  mutate(season = lubridate::quarter(lubridate::mdy(Date))) %>%
  mutate(temp_cat = case_when(
    `Temperature AVG`>= 0 & `Temperature AVG`<= 10 ~ "0-10",
    `Temperature AVG`>= 10 & `Temperature AVG`<= 20 ~ "10-20",
    `Temperature AVG`>= 20 & `Temperature AVG`<= 30 ~ "20-30",
    `Temperature AVG`>= 30 & `Temperature AVG`<= 40 ~ "30-40",
    `Temperature AVG`>= 40 & `Temperature AVG`<= 50 ~ "40-50",
    `Temperature AVG`>= 50 & `Temperature AVG`<= 60 ~ "50-60"
  ),
  success_trip = as.factor(case_when(`Success Percentage` > 0 ~ "Success",
                                     `Success Percentage` == 0 ~ "Fail")))

set.seed(12345)
rainier_train_tbl <- slice_sample(all_data_no_na, prop = .8, replace=FALSE)
rainier_test_tbl <- setdiff(all_data_no_na, rainier_train_tbl)

# Fit a boosting model to the training data
library(gbm)
boost <- gbm(success_trip ~ `Temperature AVG` + `Relative Humidity AVG`+
               `Wind Speed Daily AVG` + `Wind Direction AVG` + `Solare Radiation AVG`
             , data = rainier_train_tbl,
             distribution = "gaussian",
             n.trees = 1000, shrinkage = 0.01,
             interaction.depth = 4,
             bag.fraction = 0.7,
             n.minobsinnode = 5)

# Use the model to predict the mpg of the test data
boostpreds <- predict(boost, newdata = rainier_test_tbl)
min4 <- min(boostpreds)
max4 <- max(boostpreds)
boostpreds_transform <- (boostpreds-min4)/(max4-min4)

rainier_test_tbl <- rainier_test_tbl %>%
  mutate(boostprobs = boostpreds_transform,
         boostprediction = ifelse(boostprobs < .500, "Fail", "Success"))

mc_boost <- sum(rainier_test_tbl$success_trip != rainier_test_tbl$boostprediction)/length(rainier_test_tbl$success_trip)
#missclassification of .33

boost_pred_tbl <- rainier_test_tbl %>% group_by(success_trip, boostprediction) %>% tally()
ensure_directory("derived_data")
write_csv(boost_pred_tbl, "derived_data/pred_tbl_boostmod.csv")
