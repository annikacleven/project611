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

##GGSAVE
#ensure_directory("figures")
#ggsave("figures/best_lambda.png", bestlambdaplot)

best_model <- glmnet(x, y, alpha = 1, lambda = best_lambda, family = "binomial")
coefs <-coef(best_model)

Names <- c(coefs@Dimnames[[1]])
Values <- c(coefs@x)

coef_df <-as.data.frame(cbind(Names, round(Values,6)))

ensure_directory("derived_data")
write_csv(coef_df, "derived_data/lasso_coefs.csv")

set.seed(12345)

rainier_train_tbl <- slice_sample(all_data_no_na, prop = .8, replace=FALSE)
rainier_test_tbl <- setdiff(all_data_no_na, rainier_train_tbl)

linmod <- lm(as.numeric(success_trip) ~ `Relative Humidity AVG` +
                `Wind Speed Daily AVG`, data = rainier_train_tbl)

linpreds <- predict(linmod, rainier_test_tbl)
min <- min(linpreds)
max <- max(linpreds)
linpreds_transform <- (linpreds-min)/(max-min)

rainier_test_tbl <- rainier_test_tbl %>%
  mutate(probs = linpreds_transform,
         prediction = ifelse(probs < .500, "Fail", "Success"))

#misclassification rate
mc <- sum(rainier_test_tbl$success_trip != rainier_test_tbl$prediction)/length(rainier_test_tbl$success_trip)

#pred table
pred_tbl_lin <- rainier_test_tbl %>% group_by(success_trip, prediction) %>% tally()

#saving the predictions into a table
ensure_directory("derived_data")
write_csv(pred_tbl_lin, "derived_data/pred_tbl_linearmod.csv")

#creating a grid table of temp and humidity avg
grid_vec1 <- seq(from  = 0, to = 70, by = 1)
grid_vec2 <- seq(from  = 0, to = 100, by = 1)
grid_tbl <- expand_grid(`Wind Speed Daily AVG` = grid_vec1, `Relative Humidity AVG` = grid_vec2)
#dim(grid_tbl)

#creating predictions and standardizing
linpreds3 <- predict(linmod, grid_tbl)
min <- min(linpreds3)
max <- max(linpreds3)
linpreds3_transform <- (linpreds3-min)/(max-min)
grid_tbl <- grid_tbl %>%
  mutate(prob_of_success = linpreds3_transform,
         prediction = ifelse(prob_of_success < .500, "Fail", "Success"))
#creating raster plot
raster <- ggplot(grid_tbl, aes(`Wind Speed Daily AVG`, `Relative Humidity AVG`, z=prob_of_success,fill = prob_of_success)) +
  geom_raster() +
  stat_contour(breaks=c(0.5), color="black")+
  scale_fill_viridis_b()+
  labs(fill = "Predicted Prob of Success")

ensure_directory("figures")
ggsave("figures/raster.png", raster)












