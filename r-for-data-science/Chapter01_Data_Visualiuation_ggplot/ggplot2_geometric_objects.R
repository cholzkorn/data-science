rm(list=ls())

# load the tidyverse package

library(tidyverse)

# we again use the mpg dataset
str(mpg)

# ------------------------------- GEOMETRIC OBJECTS ----------------------------------------------------#

# A geom is the geometrical object that a plot uses to represent data.

# For example, bar charts use bar geoms, line charts use line geoms,
# boxplots use boxplot geoms, and so on. Scatterplots break the trend;
# they use the point geom.

# point geom
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy))

# line geom
# the argument method is loess by default (locally weighted scatterplot smoothing)

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# we could also choose a linear model method

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy), method = "lm")

# we can also draw different linetypes
# here we set linetype equal to our drv object from our dataframe

# geom_smooth() will draw a different line, with a different linetype, for each unique value
# of the variable that you map to linetype

# this now generates 3 lines, each representing a type of drive (forward, rear or 4-wheel-drive)

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, linetype = drv))

# the same can be done with color

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, color = drv))

# Many geoms, like geom_smooth(), use a single geometric object to
# display multiple rows of data. For these geoms, you can set the
# group aesthetic to a categorical variable to draw multiple objects.

ggplot(data = mpg) +
  geom_smooth(mapping = aes(x = displ, y = hwy, group = drv))

# To display multiple geoms in the same plot, add multiple geom
# functions to ggplot():

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_smooth(mapping = aes(x = displ, y = hwy))

# to avoid duplication as above we could also pass global mappings directly after ggplot()
# further mappings can still be passed in the corresponding geom_*() functions

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = class)) +
  geom_smooth()

# ... and with those local data arguments we can override the global ones.
# In this plot we color the points by class in the geom_point() function
# later we filter the global data selection to show only the line graph
# of the points where class equals subcompact
# se = FALSE means that that the confidence interval will not be drawn

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point(mapping = aes(color = class)) +
  geom_smooth(
    data = filter(mpg, class == "subcompact"),
    se = FALSE
  )

####################### EXERCISES

# What geom would you use to draw a line chart? A boxplot? A
# histogram? An area chart?

ggplot(data = mpg) +
  geom_line(mapping = aes(x = displ, y = hwy, color = drv))

ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = displ, y = hwy, color = drv))

ggplot(data = mpg) +
  geom_histogram(mapping = aes(x = displ, color = drv))

# Run this code in your head and predict what the output will
# look like. Then, run the code in R and check your predictions:

ggplot(
  data = mpg,
  mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_point() +
  geom_smooth(se = FALSE)

# What does show.legend = FALSE do? What happens if you
# remove it? Why do you think I used it earlier in the chapter?

# What does the se argument to geom_smooth() do?

# Will these two graphs look different? Why/why not?

ggplot(data = mpg, mapping = aes(x = displ, y = hwy)) +
  geom_point() +
  geom_smooth()

ggplot() +
  geom_point(
    data = mpg,
    mapping = aes(x = displ, y = hwy)
  ) +
  geom_smooth(
    data = mpg,
    mapping = aes(x = displ, y = hwy)
  )


