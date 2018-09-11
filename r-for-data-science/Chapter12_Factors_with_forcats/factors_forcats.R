rm(list=ls())

# To work with factors, we'll use the forcats package, which provides
# tools for dealing with categorical variables (and it's an anagram of
# factors!). It provides a wide range of helpers for working with fac-
# tors. forcats is not part of the core tidyverse, so we need to load it
# explicitly.

# install.packages("forcats")

library(tidyverse)
library(forcats)

# ------ CREATING FACTORS --------------------------------------------- #

# Imagine that you have a variable that records month:

x1 <- c("Dec", "Apr", "Jan", "Mar")

# Using a string to record this variable has two problems:

  # 1. typos

x2 <- c("Dec", "Apr", "Jam", "Mar")

  # 2. sorting

sort(x1)

# You can fix both of these problems with a factor. To create a factor
# you must start by creating a list of the valid levels:

month_levels <- c(
"Jan", "Feb", "Mar", "Apr", "May", "Jun",
"Jul", "Aug", "Sep", "Oct", "Nov", "Dec" )

# Now you can create a factor:
y1 <- factor(x1, levels = month_levels)

# And any values not in the set will be silently converted to NA:
y2 <- factor(x2, levels = month_levels)
y2

# If you want a want an error, you can use readr::parse_factor():

y2 <- parse_factor(x2, levels = month_levels)

# If you omit the levels, they'll be taken from the data in alphabetical order:

factor(x1)

# Sometimes you'd prefer that the order of the levels match the order
# of the first appearance in the data. You can do that when creating the
# factor by setting levels to unique(x), or after the fact, with fct_inorder():

  # way 1
f1 <- factor(x1, levels = unique(x1))
f1

  # way 2
f2 <- x1 %>% factor() %>% fct_inorder
f2

# If you ever need to access the set of valid levels directly, you can do
# so with levels():

levels(f2)





# ---- GENERAL SOCIAL SURVEY ------------------------------------------------- #

# Sample data:
forcats::gss_cat
?gss_cat

# When factors are stored in a tibble, you can't see their levels so
# easily. One way to see them is with count():

gss_cat %>%
  count(race)

# or with a bar chart
gss_cat %>%
  ggplot(aes(x = race)) +
  geom_bar()

# By default, ggplot2 will drop levels that don't have any values. You
# can force them to display with:

gss_cat %>%
  ggplot(aes(race)) +
  geom_bar() +
  scale_x_discrete(drop = FALSE)




# ---- MODIFYING FACTOR ORDER --------------------------------------------------- #

# It's often useful to change the order of the factor levels in a visualiza-
# tion. For example, imagine you want to explore the average number
# of hours spent watching TV per day across religions:

relig <- gss_cat %>%
  group_by(relig) %>%
  summarize(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(relig, aes(tvhours, relig)) +
  geom_point()

# reorder with fct_reorder():
  # f, the factor whose levels you want to modify
  # x, a numeric vector that you want to use to reorder the levels
  # Optionally, fun, a function that's used if there are multiple values
  # of x for each value of f. The default value is the median.

ggplot(relig, aes(tvhours, fct_reorder(relig, tvhours))) +
  geom_point()

# As you start making more complicated transformations, I'd recom-
# mend moving them out of aes() and into a separate mutate() step.
# For example, you could rewrite the preceding plot as:

relig %>%
  mutate(relig = fct_reorder(relig, tvhours)) %>%
  ggplot(aes(tvhours, relig)) +
    geom_point()

# What if we create a similar plot looking at how average age varies
# across reported income level?

rincome <- gss_cat %>%
  group_by(rincome) %>%
  summarize(
    age = mean(age, na.rm = TRUE),
    tvhours = mean(tvhours, na.rm = TRUE),
    n = n()
  )

ggplot(rincome, aes(age, fct_reorder(rincome, age))) +
  geom_point()


# Here, arbitrarily reordering the levels isn't a good idea! That's
# because rincome already has a principled order that we shouldn't
# mess with. Reserve fct_reorder() for factors whose levels are arbi-
# trarily ordered.

# However, it does make sense to pull "Not applicable" to the front
# with the other special levels. You can use fct_relevel(). It takes a
# factor, f, and then any number of levels that you want to move to
# the front of the line:

ggplot(rincome, aes(age, fct_relevel(rincome, "Not applicable"))) +
  geom_point()

# Another type of reordering is useful when you are coloring the lines
# on a plot. fct_reorder2() reorders the factor by the y values associ-
# ated with the largest x values. This makes the plot easier to read
# because the line colors line up with the legend:

by_age <- gss_cat %>%
  filter(!is.na(age)) %>%
  group_by(age, marital) %>%
  count() %>%
  mutate(prop = n / sum(n))

ggplot(by_age, aes(age, prop, color = marital)) +
  geom_line(na.rm = TRUE)

ggplot(by_age,
       aes(age, prop, color = fct_reorder2(marital, age, prop))) +
  geom_line() +
  labs(color = "marital")


# Finally, for bar plots, you can use fct_infreq() to order levels in
# increasing frequency: this is the simplest type of reordering because
# it doesn't need any extra variables. You may want to combine with
# fct_rev():

gss_cat %>%
  mutate(marital = marital %>% fct_infreq() %>% fct_rev()) %>%
  ggplot(aes(marital)) +
    geom_bar(fill = "blue", alpha = 0.5) +
    stat_count(aes(label = ..count..), geom = "text", vjust = 0)




# ----- MODIFYING FACTOR LEVELS -------------------------------------------------- #

# More powerful than changing the orders of the levels is changing
# their values. This allows you to clarify labels for publication, and
# collapse levels for high-level displays. The most general and power-
# ful tool is fct_recode(). It allows you to recode, or change, the
# value of each level. For example, take gss_cat$partyid:

gss_cat %>%
  count(partyid)

# The levels are terse and inconsistent. Let's tweak them to be longer
# and use a parallel construction:

gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong" = "Strong republican",
                              "Republican, weak" = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak" = "Not str democrat",
                              "Democrat, strong" = "Strong democrat")) %>%
  count(partyid)

# fct_recode() will leave levels that aren't explicitly mentioned as is,
# and will warn you if you accidentally refer to a level that doesn't
# exist.

# To combine groups, you can assign multiple old levels to the same
# new level:

gss_cat %>%
  mutate(partyid = fct_recode(partyid,
                              "Republican, strong" = "Strong republican",
                              "Republican, weak" = "Not str republican",
                              "Independent, near rep" = "Ind,near rep",
                              "Independent, near dem" = "Ind,near dem",
                              "Democrat, weak" = "Not str democrat",
                              "Democrat, strong" = "Strong democrat",
                              "Other" = "No answer",
                              "Other" = "Don't know",
                              "Other" = "Other party")) %>%
  count(partyid)

# If you want to collapse a lot of levels, fct_collapse() is a useful
# variant of fct_recode(). For each new variable, you can provide a
# vector of old levels:

gss_cat %>%
  mutate(partyid = fct_collapse(partyid,
                                other = c("No answer", "Don't know", "Other party"),
                                rep = c("Strong republican", "Not str republican"),
                                ind = c("Ind,near rep", "Independent", "Ind,near dem"),
                                dem = c("Not str democrat", "Strong democrat"))) %>%
  count(partyid)

# Sometimes you just want to lump together all the small groups to
# make a plot or table simpler. That's the job of fct_lump():

gss_cat %>%
  mutate(relig = fct_lump(relig)) %>%
  count(relig)

# In this case, fct_lump overcollapses. We can use the n parameter to choose
# how many groups we want to keep

gss_cat %>%
  mutate(relig = fct_lump(relig, n = 10)) %>%
  count(relig, sort = TRUE) %>%
  print(n = Inf)

