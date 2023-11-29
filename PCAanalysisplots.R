#This runs PCA

#libraries
library(readr)
library(tidyverse)

#for using ensure_directory function later
source("utils.R")

#read in data
all_data <- read_csv("~/work/derived_data/all_data.csv")

#clean up data for pca coloring
all_data_no_na <- all_data %>%
  drop_na() %>%
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
  success_trip = case_when(`Success Percentage` > 0 ~ "Success",
                           `Success Percentage` == 0 ~ "Fail"))

#set up for PCA
rainier.matrix <- all_data %>%
  drop_na() %>%
  filter(`Success Percentage` <= 1) %>%
  dplyr::select(-c(Route, Date,month_day2)) %>%
  as.matrix()

rownames(rainier.matrix) <- all_data_no_na$Date

#run pca 
rainier.pca <- prcomp(rainier.matrix)

#pull out the first two components
PC1 <- rainier.pca$x[,1]
PC2 <- rainier.pca$x[,2]

rainier.tbl <- cbind(all_data_no_na, PC1)


#plot of pca clustering by quarter
byquarter <- rainier.tbl %>%
  ggplot(aes(x = PC1, y = PC2, color = as.factor(season)))+
  geom_point()+
  labs(color = "Quarter")

##ADD GGSAVE STATEMENT
ensure_directory("figures")
ggsave("figures/pca_quarter.png", byquarter)

#plot of pca clustering by temperature category
bytempcat <- rainier.tbl %>%
  ggplot(aes(x = PC1, y = PC2, color = as.factor(temp_cat)))+
  geom_point()+
  labs(color = "Temperature Category")

##ADD GGSAVE STATEMENT
ensure_directory("figures")
ggsave("figures/pca_temp.png", bytempcat)

pc1_and_temp <- rainier.tbl %>%
  ggplot(aes(x = `Temperature AVG`, y = PC1, color = as.factor(success_trip)))+
  geom_point()+
  labs(color = "Trip Success")

##ADD GGSAVE STATEMENT
ensure_directory("figures")
ggsave("figures/pc1_and_temp.png", pc1_and_temp)




