rm(list=ls())

install.packages("nycflights13")

# load the tidyverse library, which contains dplyr
library(tidyverse)

# we also use data from the nycflights13 package
library(nycflights13)

# Take careful note of the conflicts message that's printed when you
# load the tidyverse. It tells you that dplyr overwrites some functions
# in base R. If you want to use the base version of these functions after
# loading dplyr, you'll need to use their full names: stats::filter()
# and stats::lag().

# look at the data
str(flights)
head(nycflights13::flights)

# view the whole dataset in data viewer
# It prints differently because it's a tibble. Tibbles are data frames,
# but slightly tweaked to work better in the tidyverse.

View(flights)

# datatypes used:
    # int stands for integers.
    # dbl stands for doubles, or real numbers.
    # chr stands for character vectors, or strings.
    # dttm stands for date-times (a date + a time)
    # lgl stands for logical, vectors that contain only TRUE or FALSE.
    # fctr stands for factors, which R uses to represent categorical variables with fixed possible values.
    # date stands for dates.

# nearly all dplyr functions work the same way
  # the first argument is a dataframe
  # the subsequent arguments describe what to do with the data frame, using variable names (without quotes)
  # the result is a new dataframe





# -------------------------- FILTER ROWS WITH filter() ----------------------------------- #

# Select all flights on January 1st

jan1 <- filter(flights, month == 1, day == 1)
jan1

dec25 <- filter(flights, month == 12, day == 25)
dec25

# when doing comparisons:
# Computers use finite precision arithmetic (they obviously can't store
# an infinite number of digits!) so remember that every number you
# see is an approximation. Instead of relying on ==, use near()

sqrt(2) ^ 2 == 2
near(sqrt(2) ^ 2, 2)

# BOOLEAN LOGIC

filter(flights, month == 11 | month == 12)

# a shorter way to write this or is with x %in% y
# This will select every row where x is of the values in y

filter(flights, month %in% c(11, 12))

# Sometimes you can simplify complicated subsetting by remembering
# De Morgan's law: !(x & y) is the same as !x | !y, and !(x | y) is the same as !x & !y.
# For example, if you wanted to find flights that weren't delayed (on arrival or departure)
# by more than two hours, you could use either of the following two filters:

dma <- filter(flights, !(arr_delay > 120 | dep_delay > 120))
dma
dmb <- filter(flights, arr_delay <= 120, dep_delay <= 120)
dmb

dma == dmb

# MISSING VALUES

# almost any operation involving an unknown value will also be unknown

x <- NA
NA > 5
10 == NA
NA + 10
NA / 2
NA == NA

# determine if a value is missing

is.na(x)

# filter() only includes rows where the condition is TRUE; it
# excludes both FALSE and NA values. If you want to preserve missing
# values, ask for them explicitly:

df <- tibble(x = c(1, NA, 3))
filter(df, x > 1)
filter(df, is.na(x) | x > 1)

############## EXERCISES

# Find all flights that:
  # Had an arrival delay of two or more hours
  # Flew to Houston (IAH or HOU)
  # Were operated by United, American, or Delta

  # Departed in summer (July, August, and September)
  # Arrived more than two hours late, but didn't leave late
  # Were delayed by at least an hour, but made up over 30 minutes in flight

  # Departed between midnight and 6 a.m. (inclusive)

filter(flights, arr_delay >= 120)
View(filter(flights, dest %in% c("IAH", "HOU")))
View(filter(flights, carrier %in% c("UA", "AA", "DL")))

View(filter(flights, month %in% c(7, 8, 9)))
View(filter(flights, dep_delay >= 60, arr_delay < 30))
View(filter(flights, dep_time < 600))

# Another useful dplyr filtering helper is between(). What does it do?
# Can you use it to simplify the code needed to answer the previous challenges?

View(filter(flights, between(dep_time, 0, 600)))

# How many flights have a missing dep_time? What other variables are missing?
# What might these rows represent?

nrow(filter(flights, is.na(dep_time)))

# Why is NA ^ 0 not missing? Why is NA | TRUE not missing?
# Why is FALSE & NA not missing? Can you figure out the general
# rule? (NA * 0 is a tricky counterexample!)

NA ^ 0
NA | TRUE
NA * 0






# -------------------------- ARRANGE ROWS WITH arrange() ----------------------------------- #

# arrange() changes the order of rows
# each additional column will be used to break ties in the values of preceding columns
# Missing values are always sorted at the end

arrange(flights, year, month, day)

# this can also be done in descending order

arrange(flights, desc(year, month, day))

################# EXERCISES

# How could you use arrange() to sort all missing values to the
# start? (Hint: use is.na().)

arrange(flights, desc(is.na(dep_time)))


# Sort flights to find the most delayed flights. Find the flights that left earliest
arrange(flights, desc(dep_delay))
arrange(flights, dep_delay)

# Sort flights to find the fastest flights.
View(arrange(flights, air_time))

# Which flights traveled the longest? Which traveled the shortest?
View(arrange(flights, distance))
View(arrange(flights, desc(distance)))




# -------------------------- ARRANGE ROWS WITH select() ----------------------------------- #

# select() lets us select a few columns from our dataset
# we could also assign this to a new object

select(flights, year, month, day)
dates <- select(flights, year, month, day)
dates


# Select all columns between year and day
select(flights, year:day)

# Select all columns except those from year to day (inclusive)
select(flights, -(year:day))

# HELPER FUNCTIONS FOR select()
  # starts_with("abc") matches names that begin with "abc".
  # ends_with("xyz") matches names that end with "xyz".
  # contains("ijk") matches names that contain "ijk".
  # matches("(.)\\1") selects variables that match a regular
      # expression. This one matches any variables that contain
      # repeated characters. You'll learn more about regular expressions
      # in Chapter 11.
  # num_range("x", 1:3) matches x1, x2, and x3.

# select() can be used to rename variables, but it's rarely useful
# because it drops all of the variables not explicitly mentioned.
# Instead, use rename(), which is a variant of select() that keeps all
# the variables that aren't explicitly mentioned:

rename(flights, tail_num = tailnum)

# Another option is to use select() in conjunction with the everything() helper.
# This is useful if you have a handful of variables you'd like to move to the
# start of the data frame:

select(flights, time_hour, air_time, everything())

############# EXERCISES

# What happens if you include the name of a variable multiple times in a select() call?

select(flights, year, year, month)

# What does the one_of() function do? Why might it be helpful in conjunction with this vector?

vars <- c("year", "month", "day", "dep_delay", "arr_delay")
select(flights, one_of(vars))

# Does the result of running the following code surprise you?
# How do the select helpers deal with case by default? How can you change that default?

select(flights, contains("TIME"))
select(flights, contains("TIME", ignore.case = FALSE))




# -------------------------- ADD NEW VARIABLES WITH mutate() ----------------------------------- #

# mutate() always adds new columns at the end of your dataset sowe'll start by creating
# a narrower dataset so we can see the new variables.

flights_sml <- select(flights,
                      year:day,
                      ends_with("delay"),
                      distance,
                      air_time)

head(flights_sml)

# now we add new columns with mutate()

mutate(flights_sml,
       gain = arr_delay - dep_delay,
       speed = distance / air_time * 60)

# Note that you can refer to columns that you've just created

mutate(flights_sml,
       gain = arr_delay - dep_delay,
       hours = air_time / 60,
       gain_per_hour = gain / hours
       )

# If you only want to keep the new variables, use transmute()

transmute(flights_sml,
           gain = arr_delay - dep_delay,
           hours = air_time / 60,
           gain_per_hour = gain / hours
           )

# USEFUL CREATION FUNCTIONS
# There are many functions for creating new variables that you can
#use with mutate(). The key property is that the function must be
#vectorized: it must take a vector of values as input, and return a vector
# with the same number of values as output. There's no way to list
# every possible function that you might use, but here's a selection of
# functions that are frequently useful:
    # Arithmetic operators +, -, *, /, ^
    # Modular arithmetic (%/% and %%)
      # %/% (integer division) and %% (remainder)
      # the modular arithmetic can be used to seperate the hours and the minutes
      # from our dataset

transmute(flights, 
          dep_time,
          hour = dep_time %/% 100,
          minute = dep_time %% 100)


    # Logs log(), log2(), log10()
      # All else being equal, I recommend using log2() because it's easy
      # to interpret: a difference of 1 on the log scale corresponds to
      # doubling on the original scale and a difference of -1 corre-
      # sponds to halving
    # O???sets
      # lead() and lag() allow you to refer to leading or lagging values. This allows
      # you to compute running differences (e.g., x -
      # lag(x)) or find when values change (x != lag(x)). They are
      # most useful in conjunction with group_by(), which you'll learn
      # about shortly:

(x <- 1:10)
lag(x)
lead(x)

    # cumsum(), cumprod(), cummin(), cummax() are base R functions
    # dplyr provides cummean() for cumulative means

x
cumsum(x)
cummean(x)

      # Logical comparisons <, <=, >, >=, !=
      # Ranking

y <- c(1, 2, 2, NA, 3, 4)
min_rank(y)
min_rank(desc(y))

row_number(y)
dense_rank(y)
percent_rank(y)
cume_dist(y)

############ EXERCISES

# Currently dep_time and sched_dep_time are convenient to lookat,
# but hard to compute with because they're not really continuous
# numbers. Convert them to a more convenient representation of
# number of minutes since midnight.

select(flights, dep_time, sched_dep_time)

transmute(flights,
          dep_hour = dep_time %/% 100,
          dep_minute = dep_time %% 100,
          sched_dep_hour = sched_dep_time %/% 100,
          sched_dep_minute = sched_dep_time %% 100)

# Compare dep_time, sched_dep_time, and dep_delay. How
# would you expect those three numbers to be related?

select(flights, dep_time, sched_dep_time, dep_delay)

# Find the 10 most delayed flights using a ranking function. How
# do you want to handle ties? Carefully read the documentation for min_rank().

?min_rank()
select(flights, flight, dep_delay)
transmute(flights, flight, min_rank(dep_delay))

# What does 1:3 + 1:10 return? Why?

1:3 + 1:10

# What trigonometric functions does R provide?
sin(10)
tan(10)
cos(10)



# -------------------------- ADD NEW VARIABLES WITH summarize() ----------------------------------- #

# The last key verb is summarize(). It collapses a data frame to a single row:

summarize(flights, delay = mean(dep_delay, na.rm = TRUE))

# summarize is most useful when combined with group_by(), because then we get
# results for individual groups

# Together group_by() and summarize() provide one of the tools that
# you'll use most commonly when working with dplyr: grouped summaries

by_day <- group_by(flights, year, month, day)
summarize(by_day, delay = mean(dep_delay, na.rm = TRUE))

# (APPROACH A) Code we could already write:

# Group flights by destination.
by_dest <- group_by(flights, dest)

# Summarize to compute distance, average delay, and number offlights.
delay <- summarize(by_dest,
                   count = n(),
                   dist = mean(distance, na.rm = TRUE),
                   delay = mean(arr_delay, na.rm = TRUE))

# Filter to remove noisy points and Honolulu airport, which is almost
# twice as far away as the next closest airport.
delay <- filter(delay, count > 20, dest != "HNL")

# It looks like delays increase with distance up to ~750 miles
# and then decrease. Maybe as flights get longer there's more
# ability to make up delays in the air?

ggplot(data = delay, mapping = aes(x = dist, y = delay)) +
  geom_point(aes(size = count), alpha = 1/3) +
  geom_smooth(se = FALSE)

# (APPROACH B) There's another way to tackle the same problem with the pipe, %>%:
# this way we don't have to name as many dataframes

# the pipe directly lets you modify a variable in the same line, without
# creating variables in between
# a good way to pronounce %>% when reading code is "then."

# the variable is passed on to the next function with %>%
x <- c(3, 5) %>% mean()
x

delays <- flights %>%
  group_by(dest) %>%
  summarize(
    count = n(),
    dist = mean(distance, na.rm = TRUE),
    delay = mean(arr_delay, na.rm = TRUE)) %>%
    filter(count > 20, dest != "HNL")

##### MISSING VALUES

# You may have wondered about the na.rm argument we used earlier.
# What happens if we don't set it?

flights %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay))

# if there's any missing value in the input, the output will be a missing value!!

flights %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay, na.rm = TRUE))

# In this case, where missing values represent cancelled flights, we
# could also tackle the problem by first removing the cancelled flights.
# We'll save this dataset so we can reuse it in the next few examples:

not_cancelled <- flights %>%
                  filter(!is.na(dep_delay), !is.na(arr_delay))

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(mean = mean(dep_delay))

##### COUNTS

# Whenever you do any aggregation, it's always a good idea to include
# either a count (n()), or a count of nonmissing values
# (sum(!is.na(x))). That way you can check that you're not drawing
# conclusions based on very small amounts of data.

delays <- not_cancelled %>%
          group_by(tailnum) %>%
          summarize(delay = mean(arr_delay))

# plotting frequencies of x = delay

ggplot(data = delays, mapping = aes(x = delay)) +
  geom_freqpoly(binwidth = 10)

# We can get more insight if we draw a scatterplot of number of flights n()
# versus average delay

delays <- not_cancelled %>%
  group_by(tailnum) %>%
  summarize(delay = mean(arr_delay, na.rm = TRUE), n = n())

ggplot(data = delays, mapping = aes(x = n, y = delay)) +
  geom_point(alpha = 1/10)

# Not surprisingly, there is much greater variation in the average delay
# when there are few flights. The shape of this plot is very characteristic:
# whenever you plot a mean (or other summary) versus group size, you'll see
# that the variation decreases as the sample size increases.

# When looking at this sort of plot, it's often useful to filter out the
# groups with the smallest numbers of observations, so you can see
# more of the pattern and less of the extreme variation in the smallest groups.

delays %>%
  filter(n > 25) %>%
  ggplot(mapping = aes(x = n, y = delay)) +
    geom_point(alpha = 1/10)

####### LAHMAN PACKAGE

# Baseball Stats
library(Lahman)

# First, we convert the data to a tibble
# Convert to a tibble so it prints nicely
batting <- as_tibble(Lahman::Batting)

batters <- batting %>%
  group_by(playerID) %>%
  summarize(
    ba = sum(H, na.rm = TRUE) / sum(AB, na.rm = TRUE),
    ab = sum(AB, na.rm = TRUE))

batters %>%
  filter(ab > 100) %>%
  ggplot(mapping = aes(x = ab, y = ba, alpha = 1/10)) +
  geom_point() +
  geom_smooth(se = FALSE)

# As above, the variation in our aggregate decreases as we get more data points.
# There's a positive correlation between skill (ba) and opportunities to hit the
# ball (ab). This is because teams control who gets to play, and obviously they'll
# pick their best players:

# This also has important implications for ranking. If you naively sort
# on desc(ba), the people with the best batting averages are clearly lucky, not skilled:

batters %>%
  arrange(desc(ba))

# ----------------- USEFUL SUMMARY FUNCTIONS --------------------------------------------- #

# MEASURES OF LOCATION

## Measures of location
# We've used mean(x), but median(x) is also useful. The mean is
# the sum divided by the length; the median is a value where 50%
# of x is above it, and 50% is below it.

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    # average delay
    avg_delay1 = mean(arr_delay),
    # average positive delay
    avg_delay2 = mean(arr_delay[arr_delay > 0]))


## Measures of spread sd(x), IQR(x), mad(x)
# The mean squared deviation, or standard deviation or sd for
# short, is the standard measure of spread. The interquartile range
# IQR() and median absolute deviation mad(x) are robust equivalents
# that may be more useful if you have outliers:

# Why is distance to some destinations more variable
# than to others?

?arrange

not_cancelled %>%
  group_by(dest) %>%
  summarize(distance_sd = sd(distance)) %>%
  arrange(desc(distance_sd))


## Measures of rank min(x), quantile(x, 0.25), max(x)
# Quantiles are a generalization of the median. For example, quantile(x, 0.25)
# will find a value of x that is greater than 25% of
# the values, and less than the remaining 75%:

# When do the first and last flights leave each day?

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    first = min(dep_time),
    last = max(dep_time))


## Measures of position first(x), nth(x, 2), last(x)
# These work similarly to x[1], x[2], and x[length(x)] but let
# you set a default value if that position does not exist (i.e., you're
# trying to get the third element from a group that only has two
# elements). For example, we can find the first and last departure
# for each day:

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(
    first_dep = first(dep_time),
    last_dep = last(dep_time))

# These functions are complementary to filtering on ranks. Filtering
# gives you all variables, with each observation in a separate row:

not_cancelled %>%
  group_by(year, month, day) %>%
  mutate(r = min_rank(desc(dep_time))) %>%
  filter(r %in% range(r))

## COUNTS

# You've seen n(), which takes no arguments, and returns the size
# of the current group. To count the number of non-missing values,
# use sum(!is.na(x)). To count the number of distinct
# (unique) values, use n_distinct(x):

# Which destinations have the most carriers?

not_cancelled %>%
  group_by(dest) %>%
  summarize(carriers = n_distinct(carrier)) %>%
  arrange(desc(carriers))

# Counts are so useful that dplyr provides a simple helper if all
# you want is a count:

not_cancelled %>%
  count(dest)

# You can optionally provide a weight variable. For example, you
# could use this to "count" (sum) the total number of miles a
# plane flew:

not_cancelled %>%
  count(tailnum, wt = distance)

# the first column indicates the plane number and the second counts the miles

## Counts and proportions of logical values sum(x > 10), mean(y == 0)
# When used with numeric functions, TRUE is converted to 1 and
# FALSE to 0. This makes sum() and mean() very useful: sum(x)
# gives the number of TRUEs in x, and mean(x) gives the proportion:

# How many flights left before 5am? (these usually
# indicate delayed flights from the previous day)

# TRUE = 1, FALSE = 0

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(n_early = sum(dep_time < 500))

# What proportion of flights are delayed by more
# than an hour?

not_cancelled %>%
  group_by(year, month, day) %>%
  summarize(hour_perc = mean(arr_delay > 60))



# ----------------- GROUPING BY MULTIPLE VARIABLES --------------------------------------------- #

# When you group by multiple variables, each summary peels off one
# level of the grouping. That makes it easy to progressively roll up a
# dataset:

daily <- group_by(flights, year, month, day)
(per_day <- summarize(daily, flights = n()))

(per_month <- summarize(per_day, flights = sum(flights)))

(per_year <- summarize(per_month, flights = sum(flights)))

# Be careful when progressively rolling up summaries: it's OK for
# sums and counts, but you need to think about weighting means and
# variances, and it's not possible to do it exactly for rank-based statistics
# like the median. In other words, the sum of groupwise sums is
# the overall sum, but the median of groupwise medians is not the
# overall median.

## UNGROUPING

# If you need to remove grouping, and return to operations on
# ungrouped data, use ungroup():

daily %>%
  ungroup() %>% # no longer grouped by date
  summarize(flights = n()) # all flights

############# EXERCISES

str(flights)
View(flights)

# Look at the number of cancelled flights per day. Is there a pattern
# Is the proportion of cancelled flights related to the average
# delay?

cancelled <- flights %>%
  group_by(year, month, day) %>%
  filter(is.na(dep_delay) | is.na(arr_delay)) %>%
  summarize(flights = n(), avg_delay = mean(dep_delay, na.rm = TRUE))
cancelled

cancelled_nao <- na.omit(cancelled)

cor(cancelled_nao$flights, cancelled_nao$avg_delay)

not_cancelled <- flights %>%
    group_by(year, month, day) %>%
    filter(!is.na(dep_delay), !is.na(arr_delay)) %>%
    summarize(flights = n(), avg_delay = mean(dep_delay))
not_cancelled

# Which carrier has the worst delays?

carrier_delay <- flights %>%
  group_by(carrier, dest) %>%
  filter(!is.na(dep_delay), !is.na(arr_delay)) %>%
  summarize(n(), avg_delay = mean(arr_delay + dep_delay)) %>%
  arrange(desc(avg_delay))

carrier_delay



# ---------------- Grouped Mutates (and Filters) -------------------------------------------- #

# Grouping is most useful in conjunction with summarize(), but you
# can also do convenient operations with mutate() and filter():

# Find the worst members of each group:

flights_sml %>%
  group_by(year, month, day) %>%
  filter(rank(desc(arr_delay)) < 10)

# Find all groups bigger than a threshold

popular_dests <- flights %>%
  group_by(dest) %>%
  filter(n() > 365)

View(popular_dests)

# Standardize to compute per group metrics:

popular_dests %>%
  filter(arr_delay > 0) %>%
  mutate(prop_delay = arr_delay / sum(arr_delay)) %>%
  select(year:day, dest, arr_delay, prop_delay)

#### EXERCISES

# Which plane (tailnum) has the worst on-time record?

# works better with summarize() than with mutate()
worst_planes <- flights %>%
                group_by(tailnum) %>%
                mutate(total_delay = sum(arr_delay, na.rm = TRUE)) %>%
                select(tailnum, total_delay) %>%
                arrange(desc(total_delay))

worst_planes <- flights %>%
                group_by(tailnum) %>%
                summarize(n(), total_delay = sum((dep_delay + arr_delay), na.rm = TRUE)) %>%
                select(tailnum, total_delay) %>%
                arrange(desc(total_delay))

View(worst_planes)
