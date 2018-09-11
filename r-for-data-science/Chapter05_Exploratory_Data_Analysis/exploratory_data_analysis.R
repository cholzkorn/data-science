rm(list=ls())

library(tidyverse)



# This chapter will show you how to use visualization and transforma-
# tion to explore your data in a systematic way, a task that statisticians
# call exploratory data analysis, or EDA for short. EDA is an iterative
# cycle. You:
    # 1. Generate questions about your data
    # 2. Search for answers by visualizing, transforming and modeling your data
    # 3. Use what you learn to refine your questions and/or generate new questions

# To do data cleaning, you'll need to deploy all the tools
# of EDA: visualization, transformation, and modeling.

# Two questions that will always be useful:

####### What type of variation occurs within my variables? ############
####### What type of covariation occurs between my variables? #########

## Term definitions

# A VARIABLE is a quantity, quality, or property that you can measure.

# A VALUE is the state of a variable when you measure it. The value
# of a variable may change from measurement to measurement.

# An OBSERVATION, or a case, is a set of measurements made under
# similar conditions (you usually make all of the measurements in
# an observation at the same time and on the same object). An
# OBSERVATION will contain several values, each associated with a
# different variable. I'll sometimes refer to an observation as a
# data point.

# TABULAR DATA is a set of values, each associated with a variable
# and an observation. Tabular data is tidy if each value is placed in
# its own "cell," each variable in its own column, and each observation
# in its own row



# --------------------- VARIATION ------------------------------------------------------ #

# Variation is the tendency of the values of a variable to change from
# measurement to measurement. 

# Each of your measurements will include a small amount of error that
# varies from measurement to measurement.


# ------------------ VISUALIZING DISTRIBUTIONS ----------------------------------------- #

# How you visualize the distribution of a variable will depend on
# whether the variable is categorical or continuous. 

# Categorical variable => bar chart

str(diamonds)

ggplot(data = diamonds) +
  geom_bar(mapping = aes(x = cut, fill = cut, alpha = 0.5))

# manually computing the number of observations:

diamonds %>%
  count(cut)

# Distribution of a continuous variable => histogram

ggplot(data = diamonds) +
  geom_histogram(mapping = aes(x = carat, alpha = 0.5), binwidth = 0.5, fill = "blue", show.legend = FALSE)

# You can compute this by hand by combining dplyr::count() and
# ggplot2::cut_width()

diamonds %>%
  count(cut_width(carat, 0.5))

# You can set the width of the intervals in a histogram with the bin
# width argument, which is measured in the units of the x variable

# You can set the width of the intervals in a histogram with the bin
# width argument, which is measured in the units of the x variable

smaller <- diamonds %>%
  filter(carat < 3)

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.1, alpha = 0.5, fill = "blue", show.legend = FALSE)

# If you wish to overlay multiple histograms in the same plot, I recommend using
# geom_freqpoly() instead of geom_histogram()

ggplot(data = smaller, mapping = aes(x = carat, color = cut)) +
  geom_freqpoly(binwidth = 0.1, size = 1.2)



# -------------- TYPICAL VALUES ---------------------------------------------------------------- #

# In both bar charts and histograms, tall bars show the common values of a variable,
# and shorter bars show less-common values. Places that do not have bars reveal
# values that were not seen in your data.
# To turn this information into useful questions, look for anything unexpected:
    # Which values are the most common? Why?
    # Which values are rare? Why? Does that match your expectations?
    # Can you see any unusual patterns? What might explain them?

# As an example, the following histogram suggests several interesting
# questions

ggplot(data = smaller, mapping = aes(x = carat)) +
  geom_histogram(binwidth = 0.01)

    # Why are there more diamonds at whole carats and common
    # fractions of carats?

    # Why are there more diamonds slightly to the right of each peak
    # than there are slightly to the left of each peak?

    # Why are there no diamonds bigger than 3 carats?

##############

# In general, clusters of similar values suggest that subgroups exist in
# your data. To understand the subgroups, ask
    # How are the observations within each cluster similar to each
    # other?

    # How are the observations in separate clusters different from
    # each other?

    # How can you explain or describe the clusters?

    # Why might the appearance of clusters be misleading?

# The following histogram shows the length (in minutes) of 272 erup-
# tions of the Old Faithful Geyser in Yellowstone National Park. Erup-
# tion times appear to be clustered into two groups: there are short
# eruptions (of around 2 minutes) and long eruptions (4-5 minutes),
# but little in between:

ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_histogram(binwidth = 0.25, fill = "blue", alpha = 0.5, show.legend = FALSE)



# -------------- UNUSUAL VALUES ---------------------------------------------------------------- #

# Outliers are observations that are unusual; data points that don't
# seem to fit the pattern. Sometimes outliers are data entry errors;
# other times outliers suggest important new science. When you have
# a lot of data, outliers are sometimes difficult to see in a histogram.

# In the diamonds dataset, the only evidence of outliers is the unusually wide
# limits on the y-axis

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5)

# ZOOMING
# To make it easy to see the unusual values, we need to zoom in to small values
# of the y-axis with coord_cartesian()

ggplot(diamonds) +
  geom_histogram(mapping = aes(x = y), binwidth = 0.5) +
  coord_cartesian(ylim = c(0,50))

# This allows us to see that there are three unusual values: 0, ~30, and
# ~60. We pluck them out with dplyr:

unusual <- diamonds %>%
  filter(y < 3 | y > 20) %>%
  arrange(y)

unusual

###### EXERCISES
# Explore the distribution of price. Do you discover anything
# unusual or surprising? (Hint: carefully think about the bin
# width and make sure you try a wide range of values.)

ggplot(diamonds) +
  geom_histogram(mapping = aes(price), fill = "green", alpha = 0.5, show.legend = FALSE, binwidth = 20)

# ZOOMING IN!

ggplot(diamonds) +
  geom_histogram(mapping = aes(price), fill = "green", alpha = 0.5, show.legend = FALSE, binwidth = 20) +
  coord_cartesian(xlim = c(0, 2000))



# -------------- MISSING VALUES ---------------------------------------------------------------- #

# Drop the entire row with the strange values:

# If you've encountered unusual values in your dataset, and simply
# want to move on to the rest of your analysis, you have two options:

diamonds2 <- diamonds %>%
  filter(between(y, 3, 20))

# I don't recommend this option as just because one measurement
# is invalid, doesn't mean all the measurements are. Additionally,
# if you have low-quality data, by time that you've applied this
# approach to every variable you might find that you don't have
# any data left!

# Instead, I recommend replacing the unusual values with miss-
# ing values. The easiest way to do this is to use mutate() to
# replace the variable with a modified copy. You can use the
# ifelse() function to replace unusual values with NA

# ifelse() has three arguments. The first argument test should be a
# logical vector. The result will contain the value of the second argu-
# ment, yes, when test is TRUE, and the value of the third argument,
# no, when it is false.

diamonds2 <- diamonds %>%
  mutate(y = ifelse(y < 3 | y > 20, NA, y))

View(diamonds2)

# Like R, ggplot2 subscribes to the philosophy that missing values
# should never silently go missing. It's not obvious where you should
# plot missing values, so ggplot2 doesn't include them in the plot, but
# it does warn that they've been removed

ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
  geom_point()

# To suppress that warning, set na.rm = TRUE

ggplot(data = diamonds2, mapping = aes(x = x, y = y)) +
  geom_point(na.rm = TRUE)

# in nycflights13::flights, missing values in the
# dep_time variable indicate that the flight was cancelled.

# So you might want to compare the scheduled departure times for cancelled
# and noncancelled times. You can do this by making a new variable
# with is.na()

nycflights13::flights %>%
  mutate(
    cancelled = is.na(dep_time),
    sched_hour = sched_dep_time %/% 100,
    sched_min = sched_dep_time %/% 100,
    sched_dep_time = sched_hour + sched_min / 60) %>%
  ggplot(mapping = aes(sched_dep_time)) +
    geom_freqpoly(mapping = aes(color = cancelled), bindwidth = 1/4)

# However, this plot isn't great because there are many more noncancelled flights than cancelled flights.
# In the next section we'll explore some techniques for improving this comparison.





# ------------------ COVARIATION -------------------------------------------------------------------- #

# If variation describes the behavior within a variable, covariation
# describes the behavior between variables. Covariation is the ten-
# dency for the values of two or more variables to vary together in a
# related way. The best way to spot covariation is to visualize the rela-
# tionship between two or more variables. How you do that should
# again depend on the type of variables involved.

# It's common to want to explore the distribution of a continuous
# variable broken down by a categorical variable, as in the previous
# frequency polygon.

# The default appearance of geom_freqpoly() is not that useful for that sort of
# comparison because the height is given by the count.

# That means if one of the groups is much smaller
# than the others, it's hard to see the differences in shape. For example,
# let's explore how the price of a diamond varies with its quality:

ggplot(data = diamonds, mapping = aes(x = price)) +
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500)

# It's hard to see the difference in distribution because the overall
# counts differ so much:

ggplot(diamonds) +
  geom_bar(mapping = aes(x = cut))

## DENSITY
# To make the comparison easier we need to swap what is displayed
# on the y-axis. Instead of displaying count, we'll display density,
# which is the count standardized so that the area under each fre-
# quency polygon is one

ggplot(data = diamonds, mapping = aes(x = price, y = ..density..)) +
  geom_freqpoly(mapping = aes(color = cut), binwidth = 500, size = 1.3)

# There's something rather surprising about this plot - it appears that
# fair diamonds (the lowest quality) have the highest average price!
# But maybe that's because frequency polygons are a little hard to
# interpret-there's a lot going on in this plot.

## BOXPLOTS
# Boxplots consist of
    # 1. A box that stretches from the 25th percentile of the distribution
    # to the 75th percentile, a distance known as the interquartile
    # range (IQR). In the middle of the box is a line that displays the
    # median, i.e., 50th percentile, of the distribution. These three
    # lines give you a sense of the spread of the distribution and
    # whether or not the distribution is symmetric about the median
    # or skewed to one side.

    # 2. Visual points that display observations that fall more than 1.5
    # times the IQR from either edge of the box. These outlying
    # points are unusual, so they are plotted individually

    # 3. A line (or whisker) that extends from each end of the box and
    # goes to the farthest nonoutlier point in the distribution.

ggplot(data = diamonds, mapping = aes(x = cut, y = price)) +
  geom_boxplot()

# again, we see that the best diamonds are also the cheapest

# For example, take the class variable in the mpg dataset. You might
# be interested to know how highway mileage varies across classes:

ggplot(data = mpg, mapping = aes(x = class, y = hwy)) +
  geom_boxplot()

# To make the trend easier to see, we can reorder class based on the
# median value of hwy:

# FUN means "FUNction"
?reorder

ggplot(data = mpg) +
  geom_boxplot(mapping = aes(
    x = reorder(class, hwy, FUN = median),
    y = hwy))

# With long variable names, we could flip the boxplot

ggplot(data = mpg) +
  geom_boxplot(mapping = aes(x = reorder(class, hwy, FUN = median),
                              y = hwy,
                              color = class), show.legend = FALSE) +
  labs(x = "car class", y = "highway miles per gallon") +
  coord_flip()

## LETTER VALUE PLOT
# One problem with boxplots is that they were developed in an
# era of much smaller datasets and tend to display a prohibitively
# large number of "outlying values." One approach to remedy this
# problem is the letter value plot. Install the lvplot package, and
# try using geom_lv() to display the distribution of price versus
# cut. What do you learn? How do you interpret the plots?

# install.packages("lvplot")
library(lvplot)

ggplot(data = diamonds) +
  geom_lv(mapping = aes(y = price, x = cut, fill = cut, alpha = 0.5, show.legend = FALSE))





# ------------ TWO CATEGORICAL VARIABLES ------------------------------------------ #

# To visualize the covariation between categorical variables, you'll
# need to count the number of observations for each combination.
# One way to do that is to rely on the built-in geom_count()

# The sizes of the circles indicate the number of occurences

ggplot(data = diamonds) +
  geom_count(mapping = aes(x = cut, y = color, color = color))

# Another approach is to compute the count with dplyr:

diamonds %>%
  count(color, cut)

# Then visualize with geom_tile() and the fill aesthetic
# areas with higher occurences appear darker

diamonds %>%
  count(color, cut) %>%
  ggplot(mapping = aes(x = color, y = cut)) +
  geom_tile(mapping = aes(fill = n))

# If the categorical variables are unordered, you might want to use the
# seriation package to simultaneously reorder the rows and columns
# in order to more clearly reveal interesting patterns. For larger plots,
# you might want to try the d3heatmap or heatmaply packages,
# which create interactive plots





# ------------ TWO CONTINUOUS VARIABLES ------------------------------------------ #

# You've already seen one great way to visualize the covariation
# between two continuous variables: draw a scatterplot with
# geom_point(). You can see covariation as a pattern in the points.

# Example:

ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price))

# Problem: Overplotting
# First approach to solve it: alpha level

ggplot(data = diamonds) +
  geom_point(mapping = aes(x = carat, y = price, alpha = 1/100))

# Transparency can be challenging for large datasets
# Another solution is to use bin

# geom_bin2d() and geom_hex() divide the coordinate plane into 2D
# bins and then use a fill color to display how many points fall into
# each bin. geom_bin2d() creates rectangular bins. geom_hex() creates
# hexagonal bins. You will need to install the hexbin package to use
# geom_hex()

# install.packages("hexbin")

# bin2D

ggplot(data = smaller) +
  geom_bin2d(mapping = aes(x = carat, y = price))

# geom_hex

ggplot(data = smaller) +
  geom_hex(mapping = aes(x = carat, y = price))


# Another option is to bin one continuous variable so it acts like a cat-
# egorical variable. Then you can use one of the techniques for visual-
# izing the combination of a categorical and a continuous variable that
# you learned about. For example, you could bin carat and then for
# each group, display a boxplot:

# for every 0.1 carat, we create a bin, using the function cut_width()

ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
  geom_boxplot(mapping = aes(group = cut_width(carat, 0.1)))

# all boxplots look the same, even though they represent different numbers
# of observations

# to solve this, we can use cut_number() instead of cut_width

ggplot(data = smaller, mapping = aes(x = carat, y = price)) +
  geom_boxplot(mapping = aes(group = cut_number(carat, 20)))





# ------------ PATTERNS AND MODELS ------------------------------------------ #

# Patterns in your data provide clues about relationships. If a system-
# atic relationship exists between two variables it will appear as a pat-
# tern in the data. If you spot a pattern, ask yourself
  # Could this pattern be due to coincidence (i.e., random chance)? 
  # How can you describe the relationship implied by the pattern?
  # How strong is the relationship implied by the pattern?
  # What other variables might affect the relationship?
  # Does the relationship change if you look at individual sub-
  # groups of the data?

# A scatterplot of Old Faithful eruption lengths versus the wait time
# between eruptions shows a pattern: longer wait times are associated
# with longer eruptions. The scatterplot also displays the two clusters
# that we noticed earlier:

ggplot(data = faithful) +
  geom_point(mapping = aes(x = eruptions, y = waiting))

## PATTERNS
# Patterns provide one of the most useful tools for data scientists
# because they reveal covariation. If you think of variation as a phe-
# nomenon that creates uncertainty, covariation is a phenomenon that
# reduces it. If two variables covary, you can use the values of one
# variable to make better predictions about the values of the second. If
# the covariation is due to a causal relationship (a special case), then
# you can use the value of one variable to control the value of the second

## MODELS
# Models are a tool for extracting patterns out of data. For example,
# consider the diamonds data. It's hard to understand the relationship
# between cut and price, because cut and carat, and carat and price,
# are tightly related. It's possible to use a model to remove the very
# strong relationship between price and carat so we can explore the
# subtleties that remain. The following code fits a model that predicts
# price from carat and then computes the residuals (the difference
# between the predicted value and the actual value).

#### The residuals give us a view of the price of the diamond, once the effect  ####
#### of carat has been removed                                                  ####

# RESIDUALS = Difference between predicted value and actual value

# install.packages("modelr")

library(modelr)
library(tidyverse)

mod <- lm(log(price) ~ log(carat), data = diamonds)

diamonds2 <- diamonds %>%
  add_residuals(mod) %>%
  mutate(resid = exp(resid))

ggplot(data = diamonds2) +
  geom_point(mapping = aes(x = carat, y = resid))



# https://www.youtube.com/watch?time_continue=1&v=VamMrPZ-8fc
# The residual plot gives us an idea of goodness of fit
# General idea: if the residuals are evenly scattered around
# a horizontal line we can not see a clear trend and the
# fit might be good.
    # if we find a trend, we might opt for a non-linear model

# Once you've removed the strong relationship between carat and
# price, you can see what you expect in the relationship between cut
# and price-relative to their size, better quality diamonds are more
# expensive

ggplot(data = diamonds2) +
  geom_boxplot(mapping = aes(x = cut, y = resid))

# MORE INFORMATION ON MODELS LATER!






# ------------ GGPLOT2 CALLS ------------------------------------------ #

# As we move on from these introductory chapters, we'll transition to
# a more concise expression of ggplot2 code. So far we've been very
# explicit, which is helpful when you are learning:

ggplot(data = faithful, mapping = aes(x = eruptions)) +
  geom_freqpoly(binwidth = 0.25)

# Rewriting the previous plot more concisely yields

ggplot(faithful, aes(eruptions)) +
  geom_freqpoly(binwidth = 0.25)

# Sometimes we'll turn the end of a pipeline of data transformation
# into a plot. Watch for the transition from %>% to +. I wish this transi-
# tion wasn't necessary but unfortunately ggplot2 was created before
# the pipe was discovered

diamonds %>%
  count(cut, clarity) %>%
  ggplot(aes(clarity, cut, fill = n)) +
    geom_tile()

