rm(list=ls())

# load the tidyverse package

library(tidyverse)

# ------------------------------- FACETS ----------------------------------------------------#

# facets are subplots that each display one subset of the data

# we again work with the included mpg dataset
str(mpg)

# first we facet our plot by a single variable: class
# the ~ sign indicates a formula

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

# now we facet the plot on the combination of two variables, drv and cyl

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ cyl)

# If you prefer to not facet in the rows or columns dimension, use a .
# instead of a variable name, e.g., + facet_grid(. ~ cyl).

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)


############ EXERCISES

# what happens if you facet on a continuous variable?
ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ year, nrow = 2)

# What do the empty cells in a plot with facet_grid(drv ~ cyl)
# mean? How do they relate to this plot?
ggplot(data = mpg) +
  geom_point(mapping = aes(x = drv, y = cyl))

# What plots does the following code make? What does . do?

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(drv ~ .)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_grid(. ~ cyl)

# Take the first faceted plot in this section:

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy)) +
  facet_wrap(~ class, nrow = 2)

# What are the advantages to using faceting instead of the color
# aesthetic? What are the disadvantages? How might the balance
# change if you had a larger dataset?

# Read ?facet_wrap. What does nrow do? What does ncol do?
# What other options control the layout of the individual panels?
# Why doesn't facet_grid() have nrow and ncol variables?

# When using facet_grid() you should usually put the variable
# with more unique levels in the columns. Why?