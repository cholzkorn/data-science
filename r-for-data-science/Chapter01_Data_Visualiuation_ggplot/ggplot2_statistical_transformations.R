rm(list=ls())

# load the tidyverse library

library(tidyverse)

# in this exercise we use the diamonds dataset that comes with ggplot2

str(diamonds)

# The chart shows that more diamonds are available with high-quality cuts than
# with low quality cuts

# On the x-axis, the chart displays cut, a 'variable from diamonds.

# but there is no mapping for y!

# Bar charts, histograms, and frequency polygons bin your data
# and then plot bin counts, the number of points that fall in each bin

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut))

# other automatic transformations:
  # Smoothers fit a model to your data and then plot predictions from the model.
  # Boxplots compute a robust summary of the distribution and display a specially formatted box.

# The algorithm used to calculate new values for a graph is called a stat

# You can learn which stat a geom uses by inspecting the default value for the stat argument.
?geom_bar()

# You can generally use geoms and stats interchangeably. For example,
# you can re-create the previous plot using stat_count() instead of geom_bar()
# This works because every geom has a default stat, and every stat has a default geom.

ggplot(data = diamonds) +
  stat_count(mapping = aes(x = cut))

# we might want to override the default stat, for example changing count() to
# identity(). This lets us map the height of the bars to the raw values of a y variable

# we learn about tribble() later

demo <- tribble(
  ~a, ~b,
  "bar_1", 20,
  "bar_2", 30,
  "bar_3", 40
)

ggplot(data = demo) +
  geom_bar(
    mapping = aes(x = a, y = b), stat = "identity"
  )

# You might want to draw greater attention to the statistical transformation in your code.
# For example, you might use stat_summary(), which summarizes the y values for each unique x value,
# to draw attention to the summary that you're computing:

ggplot(data = diamonds) +
  stat_summary(
    mapping = aes(x = cut, y = depth),
    fun.ymin = min,
    fun.ymax = max,
    fun.y = median
  )

# ggplot2 provides over 20 stats for you to use. Each stat is a function,
# so you can get help in the usual way, e.g., ?stat_bin. To see a complete list of stats,
# try the ggplot2 cheatsheet

############### EXERCISES

# What is the default geom associated with stat_summary()?
# How could you rewrite the previous plot to use that geom function instead of the stat function?

ggplot(data = diamonds) +
  geom_crossbar(
    mapping = aes(x = cut, y = depth),
    ymin = min,
    ymax = max,
    y = median
  )

# What does geom_col() do? How is it different to geom_bar()?
# Answer: it does not automatically count and therefore needs a y argument

ggplot(data = diamonds) +
  geom_col(mapping = aes(x = cut, y = depth))

# What variables does stat_smooth() compute? What parameters control its behavior?
# Answer: it computes a regression, x and y inputs

ggplot(data = diamonds) +
  geom_smooth(mapping = aes(x = carat, y = price))

# In our proportion bar chart, we need to set group = 1. Why? In
# other words what is the problem with these two graphs?
# Answer: we added a y argument, disturbing the count stat

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, y = ..prop.., group = 1))

ggplot(data = diamonds) +
  geom_bar(
    mapping = aes(x = cut, fill = color, y = ..prop.., group = 1)
  )

