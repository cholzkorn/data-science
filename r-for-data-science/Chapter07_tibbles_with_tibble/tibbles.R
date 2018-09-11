rm(list=ls())

# ------------ tibble() BASICS --------------------------------------------- #

# Throughout this book we work with "tibbles" instead of R's tradi-
# tional data.frame. Tibbles are data frames, but they tweak some
# older behaviors to make life a little easier.

# If this chapter leaves you wanting to learn more about tibbles, you
# might enjoy:
vignette("tibble")

# the tibble package is part of the tidyverse

library(tidyverse)

# Almost all of the functions that you'll use in this book produce tib-
# bles, as tibbles are one of the unifying features of the tidyverse.

# other R packages use regular data frames, so you might want to
# coerce a data frame to a tibble. You can do that with as_tibble()

as_tibble(iris)

# You can create a new tibble from individual vectors with tibble().
# tibble() will automatically recycle inputs of length 1, and allows
# you to refer to variables that you just created, as shown here:

tibble(
  x = 1:5,
  y = 1,
  z = x ^ 2 + y
)

# If you're already familiar with data.frame(), note that tibble()
# does much less: it never changes the type of the inputs (e.g., it never
# converts strings to factors!), it never changes the names of variables,
# and it never creates row names.

# It's possible for a tibble to have column names that are not valid R
# variable names, aka nonsyntactic names. For example, they might
# not start with a letter, or they might contain unusual characters like
# a space. To refer to these variables, you need to surround them with
# backticks, `

tb <- tibble(
  ':)' = "smile",
  ' ' = "space",
  '2000' = "number"
)
tb

# You'll also need the backticks when working with these variables in
# other packages, like ggplot2, dplyr, and tidyr.

#### tribble() - transposed tibble

# Another way to create a tibble is with tribble(), short for trans-
# posed tibble. tribble() is customized for data entry in code: column
# headings are defined by formulas (i.e., they start with ~), and entries
# are separated by commas. This makes it possible to lay out small
# amounts of data in easy-to-read form:

tribble(
  ~x, ~y, ~z,
  #--/---/---
  "a", 2, 3.6,
  "b", 1, 8.5
)





# ---------------- tibbles VERSUS data.frame ---------------------------------- #

# There are two main differences in the usage of a tibble versus a clas-
# sic data.frame: printing and subsetting.

##### PRINTING #####

# Tibbles have a refined print method that shows only the first 10
# rows, and all the columns that fit on screen. This makes it much easier
# to work with large data. In addition to its name, each column
# reports its type, a nice feature borrowed from str():

?runif

tibble(
  a = lubridate::now() + runif(1e3) * 86400,
  b = lubridate::today() + runif(1e3) * 30,
  c = 1:1e3,
  d = runif(1e3),
  e = sample(letters, 1e3, replace = TRUE)
)

# If we want to print more columns we can do the following:
# width = Inf prints all columns

nycflights13::flights %>%
  print(n = 10, width = Inf)

# You can also control the default print behavior by setting options:
    # options(tibble.print_max = n, tibble.print_min = m):
    # if more than m rows, print only n rows. Use
    # options(dplyr.print_min = Inf) to always show all rows.

    # Use options(tibble.width = Inf) to always print all col-
    # umns, regardless of the width of the screen.

# complete list of options:
package?tibble

# A final option is to use RStudio's built-in data viewer to get a scrolla-
# ble view of the complete dataset.

nycflights13::flights %>%
  View()


##### SUBSETTING #####

df <- tibble(
  x = runif(5),
  y = rnorm(5)
)

df

# Extract by name
df$x
df[["x"]]

# Extract by position
df[[1]]

# To use these in a pipe, you'll need to use the special placeholder .:
df %>% .$x
df %>% .[["x"]]

# Compared to a data.frame, tibbles are more strict: they never do
# partial matching, and they will generate a warning if the column you
# are trying to access does not exist.




# ---------------------- INTERACTING WITH OLDER CODE -------------------------- #

# Some older functions don't work with tibbles. If you encounter one
# of these functions, use as.data.frame() to turn a tibble back to a
# data.frame:

class(as.data.frame(tb))

# The main reason that some older functions don't work with tibbles
# is the [ function. We don't use [ much in this book because
# dplyr::filter() and dplyr::select() allow you to solve the same
# problems with clearer code 

##### EXERCISES

# How can you tell if an object is a tibble? (Hint: try printing
# mtcars, which is a regular data frame.)

mtcars
as_tibble(mtcars)

# What does tibble::enframe() do? When might you use it?

?tibble::enframe()
tibble::enframe(c(1,2,3,4))

# converting atomic vectors to data frames and vice versa!

# What option controls how many additional column names are
# printed at the footer of a tibble?

?tibble
