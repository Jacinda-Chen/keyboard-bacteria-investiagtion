# A script to explore data analysis and visualization with
# the tidyverse!

# Jacinda Chen
# November 12, 2019
# jrchen@dons.usfca.edu

# load packages
library("ggplot2")
library("dplyr")

# let's take a look at the diamonds dataset
head(diamonds)
dim(diamonds)

# using dplyr to subset data with the filter() function
diamonds %>%
  filter(cut == "Ideal") %>%
  filter(color == "E") %>%
  group_by(clarity) %>%
  summarise(mean_price = mean(price),
            sd_price = sd(price)) %>%
  mutate(se_price = sd_price / sqrt(n()))

# on to ggplot!
ggplot(data = diamonds,
      aes(x = carat,
          y = price)) +
  geom_point(aes(color = clarity),
             size = 0.5)

# boxplot where the x axis is color
# and the y axis is price
ggplot(data = diamonds,
       aes(x = color,
           y = price)) +
  geom_boxplot() # built in stat boxplot

# changing the scales of the plot
ggplot(data = diamonds,
       aes(x = carat,
           y = price,
           color = cut)) +
  geom_point() +
  scale_color_manual(values = c("#857857",
                                  "black",
                                  "black",
                                  "black",
                                  "orange"))

# let's do some faceting
# we want a series of plots, each of which is only
# for a particular clarity level, but all of them
# have carat on the x and price on the y and are colored by cut
ggplot(data = diamonds,
       aes(x = carat,
           y = price)) +
  geom_point(alpha = 0.05) +
  facet_wrap(~clarity)

# let's put dplyr together with ggplot
# barplot with errorbars with color on the x
# and price on the y axis
diamonds %>%
  filter(cut == "Ideal") %>%
  group_by(color) %>%
  summarise(mean_price = mean(price),
            sd_price = sd(price)) %>%
  ggplot(aes(x = color,
             y = mean_price)) +
  geom_col() +
  geom_errorbar(aes(ymin = mean_price - sd_price,
                    ymax = mean_price + sd_price))

diamonds %>%
  filter(cut == "Ideal") %>%
  filter(price > 10000) %>%
  ggplot(aes(x = color,
           y = price)) +
  geom_boxplot()

# practice with facets

diamonds %>%
  filter(cut == "Ideal") %>%
  filter(price > 10000) %>%
  ggplot(aes(x = carat,
             y = price)) +
  geom_boxplot() +
  facet_wrap(~color)

# use the diamonds data set to try to generate a plot with dodge

ggplot(data = diamonds,
       aes(x = clarity,
           fill = cut)) +
  geom_bar(position = "dodge")