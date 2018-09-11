rm(list=ls())

# we now need the maps package
install.packages("maps")

# load the tidyverse package

library(tidyverse)
library(maps)

# we again use the mpg dataset and the diamond dataset
str(mpg)
str(diamonds)



# ------------------------------- COORDINATE SYSTEMS ----------------------------------------------------#

# The default coordinate system is the Cartesian coordinate system where the x and y position act independently
# to find the location of each point. There are a number of other coordinate systems that are occasionally helpful:

# coord_flip() switches the x- and y-axes. This is useful (for example)
# if you want horizontal boxplots. It's also useful for
# long labels - it's hard to get them to fit without overlapping on the x-axis:

# standard:
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

# and flipped:
ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot() +
  coord_flip()

# coord_quickmap() sets the aspect ratio correctly for maps. This
# is very important if you're plotting spatial data with ggplot2
# (which unfortunately we don't have the space to cover in this book)

nz <- map_data("nz")

str(nz)
head(nz)

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black")

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_quickmap()

# coord_polar() uses polar coordinates. Polar coordinates reveal
# an interesting connection between a bar chart and a Coxcomb chart:

bar <- ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = cut),
    show.legend = FALSE,
    width = 1) +
  theme(aspect.ratio = 1) +
  labs(x = "quality", y = "number of observations")

bar + coord_flip()
bar + coord_polar()



############### EXERCISES

# Turn a stacked bar chart into a pie chart using coord_polar().

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = clarity),
    position = "fill") +
  coord_polar()

# What does labs() do? Read the documentation.
?labs()
# answer: description of the axes

#  What's the difference between coord_quickmap() and coord_map()?

ggplot(nz, aes(long, lat, group = group)) +
  geom_polygon(fill = "white", color = "black") +
  coord_map()
# Answer: latter doesn't work

# What does the following plot tell you about the relationship
# between city and highway mpg? Why is coord_fixed() important? What does geom_abline() do?

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point() +
  geom_abline() +
  coord_fixed()
