rm(list = ls())

# We will take advantage of the fact that you can think about a model
# partitioning your data into patterns and residuals. We'll find pat-
# terns with visualization, then make them concrete and precise with a
# model. We'll then repeat the process, but replace the old response
# variable with the residuals from the model. The goal is to transition
# from implicit knowledge in the data and your head to explicit
# knowledge in a quantitative model. This makes it easier to apply to
# new domains, and easier for others to use.

# For very large and complex datasets this will be a lot of work. There
# are certainly alternative approaches-a more machine learning
# approach is simply to focus on the predictive ability of the model.
# These approaches tend to produce black boxes: the model does a
# really good job at generating predictions, but you don't know why.

# This is a totally reasonable approach, but it does make it hard to
# apply your real-world knowledge to the model. That, in turn, makes
# it difficult to assess whether or not the model will continue to work
# in the long term, as fundamentals change. For most real models, I'd
# expect you to use some combination of this approach and a more
# classic automated approach.

# It's a challenge to know when to stop. You need to figure out when
# your model is good enough, and when additional investment is
# unlikely to pay off.

library(tidyverse)
library(modelr)
options(na.action = na.warn)
library(nycflights13)
library(lubridate)




# ---- WHY ARE LOW QUALITY DIAMONDS MORE EXPENSIVE? -------------------------------- #

# In previous chapters we've seen a surprising relationship between
# the quality of diamonds and their price: low-quality diamonds (poor
# cuts, bad colors, and inferior clarity) have higher prices:

ggplot(diamonds, aes(cut, price)) +
  geom_boxplot()

ggplot(diamonds, aes(color, price)) +
  geom_boxplot()

ggplot(diamonds, aes(clarity, price)) +
  geom_boxplot()

# Note that the worst diamond color is J (slightly yellow), and the
# worst clarity is I1 (inclusions visible to the naked eye).

## PRICE AND CARAT
# It looks like lower-quality diamonds have higher prices because
# there is an important confounding variable: the weight (carat) of
# the diamond. The weight of the diamond is the single most impor-
# tant factor for determining the price of the diamond, and lower
# quality diamonds tend to be larger:

ggplot(diamonds, aes(carat, price)) +
  geom_hex(bins = 50)

# We can make it easier to see how the other attributes of a diamond
# affect its relative price by fitting a model to separate out the effect
# of carat. But first, let's make a couple of tweaks to the diamonds
# dataset to make it easier to work with:
  # 1. Focus on diamonds smaller than 2.5 carats (99.7% of the data)
  # 2. Log-transform the carat and price variables

diamonds2 <- diamonds %>%
  filter(carat <= 2.5) %>%
  mutate(lprice = log2(price), lcarat = log2(carat))

diamonds2

# Together, these changes make it easier to see the relationship
# between carat and price:

ggplot(diamonds2, aes(lcarat, lprice)) +
  geom_hex(bins = 50)

# The log transformation is particularly useful here because it makes
# the pattern linear, and linear patterns are the easiest to work with.
# Let's take the next step and remove that strong linear pattern. We
# first make the pattern explicit by fitting a model:

mod_diamond <- lm(lprice ~ lcarat, data = diamonds2)
mod_diamond

# Then we look at what the model tells us about the data. Note that I
# back-transform the predictions, undoing the log transformation, so
# I can overlay the predictions on the raw data:

grid <- diamonds2 %>%
  data_grid(carat = seq_range(carat, 20)) %>%
  mutate(lcarat = log2(carat)) %>%
  add_predictions(mod_diamond, "lprice") %>%
  mutate(price = 2 ^ lprice)

ggplot(diamonds2, aes(carat, price)) +
  geom_hex(bins = 50) +
  geom_line(data = grid, color = "red", size = 1)

# That tells us something interesting about our data. If we believe our
# model, then the large diamonds are much cheaper than expected.
# This is probably because no diamond in this dataset costs more than
# $19,000.

# Now we can look at the residuals, which verifies that we've success-
# fully removed the strong linear pattern:

diamonds2 <- diamonds2 %>%
  add_residuals(mod_diamond, "lresid")

ggplot(diamonds2, aes(lcarat, lresid)) +
  geom_hex(bins = 50)

# Importantly, we can now redo our motivating plots using those
# residuals instead of price:

ggplot(diamonds2, aes(cut, lresid)) +
  geom_boxplot()

ggplot(diamonds2, aes(color, lresid)) +
  geom_boxplot()

ggplot(diamonds2, aes(clarity, lresid)) +
  geom_boxplot()

# Now we see the relationship we expect: as the quality of the dia-
# mond increases, so too does its relative price. To interpret the y-axis,
# we need to think about what the residuals are telling us, and what
# scale they are on. A residual of -1 indicates that lprice was 1 unit
# lower than a prediction based solely on its weight. 2-1 is 1/2, so
# points with a value of -1 are half the expected price, and residuals
# with value 1 are twice the predicted price.






# ---- A MORE COMPLICATED MODEL ------------------------------------------------------ #

# If we wanted to, we could continue to build up our model, moving
# the effects we've observed into the model to make them explicit. For
# example, we could include color, cut, and clarity into the model
# so that we also make explicit the effect of these three categorical
# variables:

mod_diamond2 <- lm(
  lprice ~ lcarat + color + cut + clarity,
  data = diamonds2)

# This model now includes four predictors, so it's getting harder to
# visualize. Fortunately, they're currently all independent, which
# means that we can plot them individually in four plots. To make the
# process a little easier, we're going to use the .model argument to
# data_grid:

grid <- diamonds2 %>%
  data_grid(cut, .model = mod_diamond2) %>%
  add_predictions(mod_diamond2)

grid

ggplot(grid, aes(cut, pred)) +
  geom_point()

# If the model needs variables that you haven't explicitly supplied,
# data_grid() will automatically fill them in with the "typical" value.

# For continuous variables, it uses the median, and for categorical
# variables, it uses the most common value (or values, if there's a tie):

diamonds2 <- diamonds2 %>%
  add_residuals(mod_diamond2, "lresid2")

ggplot(diamonds2, aes(lcarat, lresid2)) +
  geom_hex(bins = 50)

# This plot indicates that there are some diamonds with quite large
# residuals-remember a residual of 2 indicates that the diamond is 4x
# the price that we expected. It's often useful to look at unusual values
# individually:

diamonds2 %>%
  filter(abs(lresid2) > 1) %>%
  add_predictions(mod_diamond2) %>%
  mutate(pred = round(2 ^ pred)) %>%
  select(price, pred, carat:table, x:z) %>%
  arrange(price)

?predict
head(predict(mod_diamond2))

# Nothing really jumps out at me here, but it's probably worth spend-
# ing time considering if this indicates a problem with our model, or if
# there are errors in the data. If there are mistakes in the data, this
# could be an opportunity to buy diamonds that have been priced low
# incorrectly








# ---- WHAT AFFECTS THE NUMBER OF DAILY FLIGHTS? --------------------------------- #

# Let's work through a similar process for a dataset that seems even
# simpler at first glance: the number of flights that leave NYC per day.
# This is a really small dataset-only 365 rows and 2 columns-and
# we're not going to end up with a fully realized model, but as you'll
# see, the steps along the way will help us better understand the data.
# Let's get started by counting the number of flights per day and visu-
# alizing it with ggplot2:

daily <- flights %>%
  mutate(date = make_date(year, month, day)) %>%
  group_by(date) %>%
  summarize(n = n())

daily

ggplot(daily, aes(date, n)) +
  geom_line()

## DAY OF THE WEEK EFFECT
# Understanding the long-term trend is challenging because there's a
# very strong day-of-week effect that dominates the subtler patterns.
# Let's start by looking at the distribution of flight numbers by day of
# week:

daily <- daily %>%
  mutate(wday = wday(date, label = TRUE))

ggplot(daily, aes(wday, n)) +
  geom_boxplot()

# One way to remove this strong pattern is to use a model. First, we fit
# the model, and display its predictions overlaid on the original data:

mod <- lm(n ~ wday, data = daily)

grid <- daily %>%
  data_grid(wday) %>%
  add_predictions(mod, "n")

grid

ggplot(daily, aes(wday, n)) +
  geom_boxplot() +
  geom_point(data = grid, aes(x = wday, y = n), color = "red", size = 4)

# Next we compute and visualize the residuals

daily <- daily %>%
  add_residuals(mod)

daily %>%
  ggplot(aes(date, resid)) +
  geom_ref_line(h = 0) +
  geom_line()

# Note the change in the y-axis: now we are seeing the deviation from
# the expected number of flights, given the day of week. This plot is
# useful because now that we've removed much of the large day-of
# week effect, we can see some of the subtler patterns that remain:

  # Our model seems to fail starting in June: you can still see a
  # strong regular pattern that our model hasn't captured. Drawing
  # a plot with one line for each day of the week makes the cause
  # easier to see:

ggplot(daily, aes(date, resid, color = wday)) +
  geom_ref_line(h = 0) +
  geom_line()

  # Our model fails to accurately predict the number of flights on
  # Saturday: during summer there are more flights than we expect,
  # and during fall there are fewer. We'll see how we can do better
  # to capture this pattern in the next section.

# There are some days with far fewer flights than expected:

daily %>%
  filter(resid < -100)

# If you're familiar with American public holidays, you might spot
# New Year's Day, July 4th, Thanksgiving, and Christmas. There
# are some others that don't seem to correspond to public holi-
# days. You'll work on those in one of the exercises.

# There seems to be some smoother long-term trend over the
# course of a year. We can highlight that trend with
# geom_smooth():

daily %>%
  ggplot(aes(date, resid)) +
  geom_ref_line(h = 0) +
  geom_line(color = "grey50") +
  geom_smooth(se = FALSE, span = 0.20)

# There are fewer flights in January (and December), and more in
# summer (May-Sep). We can't do much with this pattern quanti-
# tatively, because we only have a single year of data. But we can
# use our domain knowledge to brainstorm potential explanations.

#### SEASONAL SATURDAY EFFECT ####

# Let's first tackle our failure to accurately predict the number of
# flights on Saturday. A good place to start is to go back to the raw
# numbers, focusing on Saturdays:

daily %>%
  filter(wday == "Sat") %>%
  ggplot(aes(date, n)) +
    geom_point() +
    geom_line() +
    scale_x_date(NULL, date_breaks = "1 month", date_labels = "%b")

# Our pattern seems to be influenced by school holidays
# Let's create a "term" variable that roughly captures the three school
# terms, and check our work with a plot:

term <- function(date) {
  cut(date,
      breaks = ymd(20130101, 20130605, 20130825, 20140101),
      labels = c("spring", "summer", "fall"))}

daily <- daily %>%
  mutate(term = term(date))

daily %>%
  filter(wday == "Sat") %>%
  ggplot(aes(date, n, color = term)) +
    geom_point(alpha = 1/3) +
    geom_line() +
    scale_x_date(
      NULL,
      date_breaks = "1 month",
      date_labels = "%b"
    )

# (I manually tweaked the dates to get nice breaks in the plot. Using a
# visualization to help you understand what your function is doing is
# a really powerful and general technique.)

# It's useful to see how this new variable affects the other days of the week:

daily %>%
  ggplot(aes(wday, n, color = term)) +
    geom_boxplot()

# It looks like there is significant variation across the terms, so fitting a
# separate day-of-week effect for each term is reasonable. This
# improves our model, but not as much as we might hope:

mod1 <- lm(n ~ wday, data = daily)
mod2 <- lm(n ~ wday * term, data = daily)

daily %>%
  gather_residuals(without_term = mod1, with_term = mod2) %>%
  ggplot(aes(date, resid, color = model)) +
    geom_line(alpha = 0.75)

# We can see the problem by overlaying the predictions from the
# model onto the raw data:

grid <- daily %>%
  data_grid(wday, term) %>%
  add_predictions(mod2, "n")

ggplot(daily, aes(wday, n)) +
  geom_boxplot() +
  geom_point(data = grid, color = "red") +
  facet_wrap(~ term)

# Our model is finding the mean effect, but we have a lot of big outli-
# ers, so the mean tends to be far away from the typical value. We can
# alleviate this problem by using a model that is robust to the effect of
# outliers: MASS::rlm(). This greatly reduces the impact of the outli-
# ers on our estimates, and gives a model that does a good job of
# removing the day-of-week pattern:

library(MASS)

mod3 <- MASS::rlm(n ~ wday * term, data = daily)

daily %>%
  add_residuals(mod3, "resid") %>%
  ggplot(aes(date, resid)) +
    geom_hline(yintercept = 0, size = 2, color = "white") +
    geom_line()

# It's now much easier to see the long-term trend, and the positive and
# negative outliers.





# ---- COMPUTED VARIABLES ----------------------------------------------------------- #

# If you're experimenting with many models and many visualizations,
# it's a good idea to bundle the creation of variables up into a function
# so there's no chance of accidentally applying a different transforma-
# tion in different places. For example, we could write:

compute_vars <- function(data) {
  data %>%
    mutate(
      term = term(date),
      wday = wday(date, label = TRUE))
  }

# Another option is to put the transformations directly in the model formula:

wday2 <- function(x) wday(x, label = TRUE)
mod3 <- lm(n ~ wday2(date) * term(date), data = daily)

# Either approach is reasonable. Making the transformed variable
# explicit is useful if you want to check your work, or use them in a
# visualization. But you can't easily use transformations (like splines)
# that return multiple columns. Including the transformations in the
# model function makes life a little easier when you're working with
# many different datasets because the model is self-contained.









# ---- TIME OF YEAR: AN ALTERNATIVE APPROACH --------------------------------------------- #

# In the previous section we used our domain knowledge (how the US
# school term affects travel) to improve the model. An alternative to
# making our knowledge explicit in the model is to give the data more
# room to speak. We could use a more flexible model and allow that to
# capture the pattern we're interested in. A simple linear trend isn't
# adequate, so we could try using a natural spline to fit a smooth
# curve across the year:

library(splines)

mod <- MASS::rlm(n ~ wday * ns(date, 5), data = daily)

daily %>%
  data_grid(wday, date = seq_range(date, n = 13)) %>%
  add_predictions(mod) %>%
  ggplot(aes(date, pred, color = wday)) +
    geom_line() +
    geom_point()








# ---- LEARNING MORE ABOUT MODELS --------------------------------------------------------- #

# Statistical Modeling: A Fresh Approach by Danny Kaplan. This
# book provides a gentle introduction to modeling, where you
# build your intuition, mathematical tools, and R skills in parallel.
# The book replaces a traditional "introduction to statistics"
# course, providing a curriculum that is up-to-date and relevant
# to data science.

# An Introduction to Statistical Learning by Gareth James, Daniela
# Witten, Trevor Hastie, and Robert Tibshirani (available online
# for free). This book presents a family of modern modeling tech-
# niques collectively known as statistical learning. For an even
# deeper understanding of the math behind the models, read the
# classic Elements of Statistical Learning by Trevor Hastie, Robert
# Tibshirani, and Jerome Friedman (also available online for free).

# Applied Predictive Modeling by Max Kuhn and Kjell Johnson.
# This book is a companion to the caret package and provides
# practical tools for dealing with real-life predictive modeling
# challenges.





