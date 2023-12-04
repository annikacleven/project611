#This file creates a lasso model for predicting the success (or lack of)
#on the summit attempt using weather data

#libraries
library(readr)
library(dplyr)
library(tidyverse)
library(glmnet)

#set up functions for later
source("~/work/utils.R")

#getting data 
all_data <- read_csv("~/work/derived_data/all_data.csv")

#formatting data for lasso 
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

#set up for lasso

#define response variable
y <- all_data_no_na$success_trip

#define matrix of predictor variables
x <- data.matrix(all_data_no_na[, c("Relative Humidity AVG",
                                    "Temperature AVG",
                                    "Wind Speed Daily AVG",
                                    "Wind Direction AVG",
                                    "Solare Radiation AVG")])

#perform k-fold cross-validation to find optimal lambda value
cv_model <- cv.glmnet(x, y, alpha = 1, family = "binomial")

#find optimal lambda value that minimizes test MSE
best_lambda <- cv_model$lambda.min

#produce plot of test MSE by lambda value
bestlambdaplot <- plot(cv_model) 

##GGSAVE
ensure_directory("figures")
ggsave("figures/best_lambda.png", bestlambdaplot)

best_model <- glmnet(x, y, alpha = 1, lambda = best_lambda, family = "binomial")
coefs <-coef(best_model)

Names <- c(coefs@Dimnames[[1]])
Values <- c(coefs@x)

coef_df <- as.data.frame(rbind(Names, round(Values,6)))

ensure_directory("derived_data")
write.table(coef_df, "derived_data/lasso_coefs.csv")
