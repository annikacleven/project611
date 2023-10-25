#this file produces the plot of the most popular routes to summit Rainier
#
#install.packages("tidyverse")
library(tidyverse)
library(ggplot2)

all_data <- read_csv("derived_data/all_data.csv")
source("utils.R")

the_plot <- all_data %>%
  group_by(Route) %>%
  summarize(count = sum(Attempted)) %>%
  arrange(desc(count)) %>%
  ggplot(aes(x = reorder(Route, - count), y = log(count), fill = Route))+
  geom_bar(stat = "identity")+
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1))+
  guides(fill = FALSE) +
  labs(x = "Route to the Summit", y = "Log Count of Hikers")

ensure_directory("figures")
ggsave("figures/log_popular_routes.png", the_plot)