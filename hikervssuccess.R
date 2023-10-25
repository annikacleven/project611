#this file produces the plot of the total number of hikers vs the successful 
#hikers for 2014 and 2015 separately
library(tidyverse)
library(ggplot2)

all_data <- read_csv("derived_data/all_data.csv")
source("utils.R")

hiker_vs_success_plot <- all_data %>%
  group_by(Date) %>%
  mutate(count_of_hikers = (sum(Attempted)),
         count_of_success = sum(Succeeded)) %>%
  pivot_longer(cols = c(count_of_hikers,count_of_success )) %>%
  ggplot()+
  geom_smooth(aes(x = day_of_year, y = value, color = name), se = FALSE)+
  facet_wrap(~as.factor(year_num))+
  labs(x = "Day of Year", y = "Hiker Count")+
  guides(color = guide_legend(title = "Category")) +
  scale_color_manual(values = c("red", "blue"),
                     labels = c('Count of All Hikers', 'Count of Succesful Hikers'))

ensure_directory("figures")
ggsave("figures/hiker_vs_success.png", hiker_vs_success_plot)