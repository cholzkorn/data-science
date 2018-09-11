rm(list=ls())

# load the tidyverse
library(tidyverse)

# There are three interrelated rules which make a dataset tidy:
  # 1. There are three interrelated rules which make a dataset tidy:
  # 2. Each observation must have its own row
  # 3. Each value must have its own cell.

# That interrelationship leads to an even simpler set of practical instructions
  # 1. Put each dataset in a tibble.
  # 2. Put each variable in a column.



# ------- SPREADING AND GATHERING --------------------------- #

# Common Problems:
  # One variable might be spread across multiple columns.
  # One observation might be scattered across multiple rows.

# To fix these problems, you'll need the two most important functions in tidyr: gather()
# and spread()

## GATHERING
# A common problem is a dataset where some of the column names
# are not names of variables, but values of a variable.

# Take table4a; the column names 1999 and 2000 represent values of the year vari-
# able, and each row represents two observations, not one

table4a

# To tidy a dataset like this, we need to gather those columns into a
# new pair of variables. To describe that operation we need three parameters:
  # 1. The set of columns that represent values, not variables. In this example '1999' and '2000'
  # 2. The name of the variable whose values form the column names. I call that the key
  # and here it is year
  # 3. The name of the variable whose values are spread over the cells. I call that value
  # and here it's number of cases

# Together those parameters generate the call to gather()
# So now we GATHER the column names and turn them into values (observations)

table4a %>%
  gather('1999', '2000', key = "year", value = "cases")

# We can use gather() to tidy table4b in a similar fashion.
# The only difference is the variable stored in the cell values:

table4b %>%
  gather('1999', '2000', key = "year", value = "population")

# To combine the tidied versions of table4a and table4b into a single
# tibble, we need to use dplyr::left_join(), which you'll learn
# about in Chapter 10:

tidy4a <- table4a %>%
  gather(`1999`, `2000`, key = "year", value = "cases")
tidy4b <- table4b %>%
  gather(`1999`, `2000`, key = "year", value = "population")

left_join(tidy4a, tidy4b)



## SPREADING

# Spreading is the opposite of gathering. You use it when an observa-
# tion is scattered across multiple rows. For example, take table2-an
# observation is a country in a year, but each observation is spread
# across two rows:

table2

# So now we SPREAD cases on count, thus transforming the column count
# into two new columns, cases and population (the factors of cases)

spread(table2, key = type, value = count)

# As you might have guessed from the common key and value argu-
# ments, spread() and gather() are complements. gather() makes
# wide tables narrower and longer; spread() makes long tables
# shorter and wider.





# ------- SEPARATING AND PULL --------------------------- #

#### SEPARATE ####

# So far you've learned how to tidy table2 and table4, but not
# table3. table3 has a different problem: we have one column (rate)
# that contains two variables (cases and population)

table3

# We can solve this with separate()
# By default, separate() will split values wherever it sees a nonalphanumeric character

table3 %>%
  separate(rate, into = c("cases", "population"))

# We could re-write:

table3 %>%
  separate(rate, into = c("cases", "population"), sep = "/")

# If we look closely, cases and population are being seperated, but they
# are character vectors. We need them as numbers:

table3 %>%
  separate(rate,
           into = c("cases", "population"),
           sep = "/",
           convert = TRUE)

# We can also seperate a vector by number of digits, by setting
# sep to a number

table3 %>%
  separate(year, into = c("century", "year"), sep = 2)


#### UNITE ####

# unite() combines multiple columns into one

table5

table5 %>%
  unite(new, century, year)

# by default, unite() uses an _
# this is why we need sep = ""

table5 %>%
  unite(new, century, year, sep = "")






# -------------- MISSING VALUES -------------------------------------------------- #

# A value can be missing in two ways:
  # Explicitly: NA ~ presence of an absence
  # Implicitly: Simply not present in the data ~ absence of a presence

# The following tibble misses two values:
  # Explicitly: return of the 4th quarter of 2015
  # Implicitly: the row of the 1st quarter of 2016

stocks <- tibble(
  year = c(2015, 2015, 2015, 2015, 2016, 2016, 2016),
  qtr = c( 1, 2, 3, 4, 2, 3, 4),
  return = c(1.88, 0.59, 0.35, NA, 0.92, 0.17, 2.66)
)
stocks

# 1. making implicit values explicit

stocks %>%
  spread(year, return)

# Because these explicit missing values may not be important in other
# representations of the data, you can set na.rm = TRUE in gather()
# to turn explicit missing values implicit:

stocks %>%
  spread(year, return) %>%
  gather(year, return, '2015':'2016', na.rm = TRUE)

# Another important tool for making missing values explicit in tidy
# data is complete():

stocks %>%
  complete(year, qtr)

# There's one other important tool that you should know for working
# with missing values. Sometimes when a data source has primarily
# been used for data entry, missing values indicate that the previous
# value should be carried forward:

treatment <- tribble(
  ~ person, ~ treatment, ~response,
  "Derrick Whitmore", 1, 7,
  NA, 2, 10,
  NA, 3, 9,
  "Katherine Burke", 1, 4
)
treatment

# You can fill in these missing values with fill(), which pastes the most
# recent non-missing value

treatment %>%
  fill(person)