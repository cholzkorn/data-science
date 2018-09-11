rm(list=ls())

# ------------------- INTRODUCTION ---------------------------------------- #

# t's rare that a data analysis involves only a single table of data. Typi-
# cally you have many tables of data, and you must combine them to
# answer the questions that you're interested in. Collectively, multiple
# tables of data are called relational data because it is the relations, not
# just the individual datasets, that are important.

# There are only relations between two tables
  # 1:n
  # m:n
  # n:n

# To work with relational data you need verbs that work with pairs of
# tables. There are three families of verbs designed to work with rela-
# tional data:
  # 1. Mutating joins, which add new variables to one data frame from
  # matching observations in another. (LEFT JOIN, RIGHT JOIN)

  # 2. Filtering joins, which filter observations from one data frame
  # based on whether or not they match an observation in the other
  # table. (INNER JOIN)

  # 3. Set operations, which treat observations as if they were set elements

# The most common place to find relational data is in a relational
# database management system (or RDBMS)
  # SQL

# In R we use dplyr to work with databases and it has some similarities to SQL

# We will need:
library(tidyverse)
library(nycflights13)

# Overviews of the tables in this database
airlines
airports
planes
weather

## KEYS

# primary key: uniquely identifies an observation in its own table
# foreign key: uniquely identifies an observation in another table

# A variable can be both a primary key and a foreign key. For exam-
# ple, origin is part of the weather primary key, and is also a foreign
# key for the airport table.

# Once you've identified the primary keys in your tables, it's good
# practice to verify that they do indeed uniquely identify each obser-
# vation. One way to do that is to count() the primary keys and look
# for entries where n is greater than one:

planes %>%
  count(tailnum) %>%
  filter(n > 1)

weather %>%
  count(year, month, day, hour, origin) %>%
  filter(n > 1)

# Sometimes a table doesn't have an explicit primary key: each row is
# an observation, but no combination of variables reliably identifies it.
# For example, what's the primary key in the flights table? You
# might think it would be the date plus the flight or tail number, but
# neither of those are unique:

flights %>%
  count(year, month, day, flight) %>%
  filter(n > 1)

flights %>%
  count(year, month, day, tailnum) %>%
  filter(n > 1)

# When starting to work with this data, I had naively assumed that
# each flight number would be only used once per day: that would
# make it much easier to communicate problems with a specific flight.
# Unfortunately that is not the case! If a table lacks a primary key, it's
# sometimes useful to add one with mutate() and row_number().
# That makes it easier to match observations if you've done some fil-
# tering and want to check back in with the original data. This is
# called a surrogate key.

### EXERCISES

# Add a surrogate key to flights

?row_number
flights

skey_flights <- flights %>%
                mutate(skey = 1:nrow(flights)) %>%
                select(skey, year:time_hour)

skey_flights



# --------------- MUTATING JOINS ------------------------------------------ #

# Mutating joins are left joins or right joins

flights2 <- flights %>%
  select(year:day, hour, origin, dest, tailnum, carrier)

flights2

# adding the full airline name to flights2 and remove origin and dest
# the foreign key here is "carrier"

flights2 %>%
  select(-origin, -dest) %>%
  left_join(airlines, by = "carrier")

# this would also work with mutate() and base R subsetting
# The first one is obviously easier to read:

flights2 %>%
  select(-origin, -dest) %>%
  mutate(name = airlines$name[match(carrier, airlines$carrier)])




# --------------- INNER JOIN ------------------------------------------------ #

x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  3, "x3"
)

y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  4, "y3"
)

# Inner Join:

x %>%
  inner_join(y, by = "key")





# --------------- OUTER JOIN ------------------------------------------------ #

# There are three types of outer joins:
  # A left join keeps all observations in x
  # A right join keeps all observations in y
  # A full join keeps all observations in x and y

# The most commonly used join is the left join: you use this whenever
# you look up additional data from another table, because it preserves
# the original observations even when there isn't a match. The left join
# should be your default join: use it unless you have a strong reason to
# prefer one of the others





# --------------- DUPLICATE KEYS ------------------------------------------------ #

# So far all the diagrams have assumed that the keys are unique. But
# that's not always the case. This section explains what happens when
# the keys are not unique. There are two possibilities:

# 1. One table has duplicate keys. This is useful when you want to
# add in additional information as there is typically a one-tomany relationship:

x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  1, "x4"
)

y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2"
)

left_join(x, y, by = "key")

# 2. Both tables have duplicate keys. This is usually an error because
# in neither table do the keys uniquely identify an observation.
# When you join duplicated keys, you get all possible combina-
# tions, the Cartesian product:

x <- tribble(
  ~key, ~val_x,
  1, "x1",
  2, "x2",
  2, "x3",
  3, "x4"
)

y <- tribble(
  ~key, ~val_y,
  1, "y1",
  2, "y2",
  2, "y3",
  3, "y4"
)
left_join(x, y, by = "key")





# --------------- DEFINING THE KEY COLUMNS ------------------------------------------------ #

# Instead of by = "key" we could use other values for joining:

# 1. The default, by = NULL, uses all variables that appear in both
# tables, the so-called NATURAL JOIN. For example, the flights and
# weather tables match on their common variables: year, month,
# day, hour, and origin:

flights2 %>%
  left_join(weather)

# 2. A character vector, by = "x". This is like a natural join, but uses
# only some of the common variables. For example, flights and
# planes have year variables, but they mean different things so
# we only want to join by tailnum:

flights2 %>%
  left_join(planes, by = "tailnum")

# 3. A named character vector: by = c("a" = "b"). This will match
# variable a in table x to variable b in table y. The variables from x
# will be used in the output.

flights2 %>%
  left_join(airports, c("dest" = "faa"))

flights2 %>%
  left_join(airports, c("origin" = "faa"))



#### EXERCISES

# Compute the average delay by destination, then join on the air
# ports data frame so you can show the spatial distribution of
# delays. Here's an easy way to draw a map of the United States:

View(flights)

delays <- flights %>%
  group_by(dest) %>%
  summarize(avg_delay = mean(arr_delay, na.rm = TRUE))

delays


View(airports %>%
  inner_join(delays, c("faa" = "dest")))
  
airports %>%
  inner_join(delays, c("faa" = "dest")) %>%
  ggplot(aes(lon, lat, color = avg_delay, size = avg_delay)) +
  borders("state") +
  geom_point() +
  coord_quickmap()






# ----------------- FILTERING JOINS ---------------------------------------- #

# semi_join(x, y) keeps all observations in x that have a match in y

# anti_join(x, y) drops all observations in x that have a match in y

# Semi-joins are useful for matching filtered summary tables back to
# the original rows. For example, imagine you've found the top-10
# most popular destinations:

top_dest <- flights %>%
  count(dest, sort = TRUE) %>%
  head(10)

top_dest

# Now you want to find each flight that went to one of those destina-
# tions. You could construct a filter yourself:

flights %>%
  filter(dest %in% top_dest$dest)

# Instead you can use a semi-join, which connects the two tables like a
# mutating join, but instead of adding new columns, only keeps the
# rows in x that have a match in y:

flights %>%
  semi_join(top_dest, by = "dest")

# The inverse of a semi-join is an anti-join. An anti-join keeps the
# rows that don't have a match:

flights %>%
  anti_join(planes, by = "tailnum") %>%
  count(tailnum, sort = TRUE)





# ---------------------- JOIN PROBLEMS --------------------------------------- #

# For example, the altitude and longitude uniquely identify each
# airport, but they are not good identifiers!

airports %>% count(alt, lon) %>% filter(n > 1)

# Check that none of the variables in the primary key are missing.
# If a value is missing then it can't identify an observation!

# Check that your foreign keys match primary keys in another
# table. The best way to do this is with an anti_join(). It's com-
# mon for keys not to match because of data entry errors. Fixing
# these is often a lot of work.







# --------------------- SET OPERATIONS ---------------------------------------- #

# The final type of two-table verb are the set operations. Generally, I
# use these the least frequently, but they are occasionally useful when
# you want to break a single complex filter into simpler pieces. All
# these operations work with a complete row, comparing the values of
# every variable. These expect the x and y inputs to have the same
# variables, and treat the observations like sets:

# Sample data:

df1 <- tribble(
  ~x, ~y,
  1, 1,
  2, 1
)

df2 <- tribble(
  ~x, ~y,
  1, 1,
  1, 2
)

# intersect(): return only observations in both x and y
intersect(df1, df2)

# union(): return unique observations in x and y
union(df1, df2)

# setdiff(): return observations in x, but not in y
setdiff(df1, df2)
setdiff(df2, df1)

