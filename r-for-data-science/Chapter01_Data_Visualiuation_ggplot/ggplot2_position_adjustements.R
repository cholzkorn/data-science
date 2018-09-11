rm(list=ls())

# load the tidyverse package

library(tidyverse)

# we again use the mpg dataset and the diamond dataset
str(mpg)
str(diamonds)

# ------------------------------- POSITION ADJUSTEMENTS ----------------------------------------------------#

# You can color a bar chart using either the color aesthetic, or more usefully, fill:

# this colors the outline of the bars only
ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, color = cut))

# fill is the better option:

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = cut))

# Note what happens if you map the fill aesthetic to another variable, like clarity:
# the bars are automatically stacked. Each colored rectangle represents a combination of cut and clarity

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = clarity))

# position = "identity" will place each object exactly where it falls in the context of the graph.
# note that the order differs from the first plot
# also, we added alpha for fun or whatever

ggplot(
  data = diamonds,
  mapping = aes(x = cut, fill = clarity)) +
  geom_bar(alpha = 1/5, position = "identity")

# here the same plot but with fill = NA, which leaves the bars empty

ggplot(
  data = diamonds,
  mapping = aes(x = cut, color = clarity)) +
  geom_bar(fill = NA, position = "identity")

# position = "fill" works like stacking, but makes each set of
# stacked bars the same height. This makes it easier to compare proportions across groups:

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = clarity),
    position = "fill"
  )

# position = "dodge" places overlapping objects directly beside
# one another. This makes it easier to compare individual values
# I also added alpha so we can slightly see the grid lines underneath

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = clarity),
    position = "dodge", alpha = 3/5
  )

# OVERPLOTTING
# There's one other type of adjustment that's not useful for bar charts,
# but it can be very useful for scatterplots.

# The values of hwy and displ are rounded so the points appear on a
# grid and many points overlap each other. This problem is known as
# overplotting. This arrangement makes it hard to see where the mass
# of the data is.

# You can avoid this gridding by setting the position adjustment to
# "jitter." position = "jitter" adds a small amount of random noise
# to each point. This spreads the points out because no two points are
# likely to receive the same amount of random noise

# Because this is such a useful operation, ggplot2 comes with a shorthand for
# geom_point(position = "jitter"): geom_jitter()

# Example

ggplot(data = mpg) +
  geom_point(
    mapping = aes(x = displ, y = hwy, color = drv),
    position = "jitter"
  )

# To learn more about a position adjustment, look up the help page
# associated with each adjustment: ?position_dodge, ?position_fill,
# ?position_identity, ?position_jitter, and ?position_stack.



#################### EXERCISES

# What is the problem with this plot? How could you improve it?

ggplot(data = mpg, mapping = aes(x = cty, y = hwy)) +
  geom_point()

# improvement:

ggplot(data = mpg, mapping = aes(x = cty, y = hwy, color = drv)) +
  geom_jitter()

# What parameters to geom_jitter() control the amount of jittering?
?geom_jitter
# Answer: width and height for vertical and horizontal jitter

# Compare and contrast geom_jitter() with geom_count()
ggplot(data = mpg, mapping = aes(x = cty, y = hwy, color = drv)) +
  geom_count()
# Answer: geom_count() doesn't add additional points, but the sizes of the points which have
# multiple rounded values increase

# What's the default position adjustment for geom_boxplot()?
# Create a visualization of the mpg dataset that demonstrates it.
ggplot(data = mpg, mapping = aes(x = displ, y = hwy, color = drv)) +
  geom_boxplot(position = "dodge")
