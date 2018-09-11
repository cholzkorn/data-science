rm(list=ls())

# install tidyverse package
# install.packages("tidyverse")

# load library
library(tidyverse)

# how to make sure we're using a function from a package: ggplot2::ggplot()

# QUESTION: Do cars with big engines use more fuel than cars with small engines?

# we have a look a the mpg dataframe within ggplot2:
ggplot2::mpg

# ------------------- PLOTTING BASICS -----------------------------------------------------#

# ggplot() creates a coordinate system you can add layers to
# the function geom_point() adds layers of points to your plot while mapping = aes() defines
# which x and y variables to use
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy))

# reusable function for plotting:
# ggplot(data = <DATA>) +
#   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

# we can add aestethics to the plot, for example color

ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, color = class))

# we could also map class to the size aesthetic, but that's not a good idea for discrete variables,
# so we get a warning

ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, size = class))

# other options are alpha for transparency or shape for the shape of the points
# but ATTENTION: shape can only handle 6 different shapes at a time by default

ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, alpha = class))
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, shape = class))

# we could also make all of our points blue, but for that we have to put x and y
# into brackets

ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy), color = "blue")

# explore the structure of our data
str(mpg)
levels(mpg)

####### EXERCISEs
# map continuous variable to color
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, color = year))
# map same variable to multiple aestethics
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, color = displ))
# what does the stroke aesthetic do?
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, stroke = displ))
# map aesthetic to something other than a variable name -> legend changes to FALSE and TRUE!
ggplot(data = mpg) + geom_point(mapping = aes(x = displ, y = hwy, color = displ < 5))
