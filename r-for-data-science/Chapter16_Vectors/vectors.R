rm(list=ls())

# We will use functions from the purr package, which is included in the tidyverse

library(tidyverse)

# There are two types of vectors:
  # Atmomic vectors: logical, integer, double, character, complex and raw
    # integer and double are also called numeric vectors
  # Lists, which are sometimes called recursive vectors because they may
  # contain other lists

# Every vector has two key properties

# 1. Its type, which you can determine with typeof()

typeof(letters)
typeof(1:10)

# 2. Its length, which you can determine with length()

x <- list("a", "b", 1:10)
length(x)

# Vectors can also contain arbitrary additional metadata in the form
# of attributes. These attributes are used to create augmented vectors,
# which build on additional behavior. There are four important types
# of augmented vector:
  # Factors are built on top of integer vectors.
  # Dates and date-times are built on top of numeric vectors.
  # Data frames and tibbles are built on top of lists.


# ---- IMPORTANT TYPES OF ATOMIC VECTOR ------------------------------------------- #

## LOGICAL
# Logical vectors take three types of values: TRUE, FALSE and NA
# They are usually constructed with comparison operators

1:10 %% 3 == 0
c(TRUE, FALSE, TRUE, TRUE, NA)


## NUMERIC
# Integer and double vectors are known collectively as numeric vec-
# tors. In R, numbers are doubles by default. To make an integer, place
# a L after the number:

typeof(1)
typeof(1L)
1.5L

# Doubles are approximations. Doubles represent floating-point
# numbers that cannot always be precisely represented with a
# fixed amount of memory. This means that you should consider
# all doubles to be approximations. For example, what is square of
# the square root of two?

x <- sqrt(2) ^ 2
x
x - 2

# Integers have one special value, NA, while doubles have four, NA,
# NaN, Inf, and -Inf. All three special values can arise during
# division:

c(-1, 0 , 1) / 0

# Avoid using == to check for these other special values. Instead
# use the helper functions is.finite(), is.infinite(), and
# is.nan():



## CHARACTER

# R uses a global string pool. This means
# that each unique string is only stored in memory once, and every
# use of the string points to that representation. This reduces the
# amount of memory needed by duplicated strings. You can see this
# behavior in practice with pryr::object_size()

x <- "This is a reasonably long string."
pryr::object_size(x)

y <- rep(x, 1000)
pryr::object_size(y)



## MISSING VALUES
# Note that each type of atomic vector has its own missing value:

NA # logical
NA_integer_ # integer
NA_real_ # double
NA_character_ # character





# ---- USING ATOMIC VECTORS -------------------------------------------------------- #


## COERCION
# There are two ways to convert, or coerce, one type of vector to
# another:
  # 1. Explicitly: as.logical(), as.integer(), as.double(), as.character()
  # 2. Implicit coercion happens when you use a vector in a specific
  # context that expects a certain type of vector. For example, when
  # you use a logical vector with a numeric summary function, or
  # when you use a double vector where an integer vector is
  # expected.

x <- sample(20, 100, replace = TRUE)
y <- x > 10
sum(y) # how many are greater than 10?
mean(y) # what proportion are greater than 10?


# You may see some code (typically older) that relies on implicit coer-
# cion in the opposite direction, from integer to logical:
  if (length(x)) {
    # do something
  }

# In this case, 0 is converted to FALSE and everything else is converted
# to TRUE. I think this makes it harder to understand your code, and I
# don't recommend it. Instead be explicit: length(x) > 0.

# It's also important to understand what happens when you try and
# create a vector containing multiple types with c()-the most com-
# plex type always wins:

typeof(c(TRUE, 1L))
typeof(c(1L, 1.5))
typeof(c(1.5, "a"))

# An atomic vector cannot have a mix of different types because the
# type is a property of the complete vector, not the individual ele-
# ments. If you need to mix multiple types in the same vector, you
# should use a list, which you'll learn about shortly





# ---- TEST FUNCTIONS --------------------------------------------------------- #

# The base R functions like typeof() often return misleading results
# It's better to use the is_* functions of the purr package

# is_logical()
# is_integer()
# is_double()
# is_numeric()
# is_character()
# is_atomic()
# is_list()
# is_vector()

# Each predicate also comes with a "scalar" version, like
# is_scalar_atomic(), which checks that the length is 1. This is use-
# ful, for example, if you want to check that an argument to your func-
# tion is a single logical value.




# ---- SCALARS AND RECYCLING RULES --------------------------------------------- #

# As well as implicitly coercing the types of vectors to be compatible,
# will also implicitly coerce the length of vectors. This is called vec-
# tor recycling, because the shorter vector is repeated, or recycled, to
# the same length as the longer vector.

# This is generally most useful when you are mixing vectors and
# "scalars." I put scalars in quotes because R doesn't actually have
# scalars: instead, a single number is a vector of length 1. Because
# there are no scalars, most built-in functions are vectorized, meaning
# that they will operate on a vector of numbers. That's why, for exam-
# ple, this code works:

sample(10) + 100
runif(10) > 0.5

# Recycling:
1:10 + 1:2
1:10 + 1:3 # 10 is not a multiple of 3, so recycling doesn't work

# the vectorized functions in tidyverse will throw errors when you recycle
# anything other than a scalar
# If you do want to recycle, you'll need todo it yourself with rep()

tibble(x = 1:4, y = 1:2)
tibble(x = 1:4, rep(1:2, 2))




# ---- NAMING VECTORS ---------------------------------------------------------- #

# All types of vectors can be named. You can name them during cre-
# ation with c():

c(x = 1, y = 2, z = 4)

# ... or afterwards wir purrr::set_names()

purrr::set_names(1:3, c("a", "b", "c"))







# ---- SUBSETTING ---------------------------------------------------------------- #

# dplyr::filter only works with a tibble, so we need something else for vectors
# There are four types of things that you can subset a vector with:
  # A numeric vector containing only integers. The integers must
  # either be all positive, all negative, or zero.
  
  # Subsetting with positive integers keeps the elements at those
  # positions:

x <- c("one", "two", "three", "four", "five")
x[c(3, 2, 5)]

# By repeating a position, you can actually make a longer output than input:

x[c(1, 1, 5, 5, 5, 2)]

# Negative values drop the elements at the specified positions:
x[c(-1, -3, -5)]

# It's an error to mix positive and negative values:
x[c(-1, 1)]

# The error message mentions subsetting with zero, which returns no values:
x[0]

# Subsetting with a logical vector keeps all values corresponding
# to a TRUE value. This is most often useful in conjunction with
# the comparison functions:

x <- c(10, 3, NA, 5, 8, 1, NA)

# All non-missing values of x
x[!is.na(x)]

# All even (or missing!) values of x
x[x %% 2 == 0]

# If you have a named vector, you can subset it with a character vector:
x <- c(abc = 1, def = 2, xyz = 5)
x[c("abc", "xyz")]

# The simplest type of subsetting is nothing, x[], which returns
# the complete x. This is not useful for subsetting vectors, but it is
# useful when subsetting matrices (and other high-dimensional
# structures) because it lets you select all the rows or all the col-
# umns, by leaving that index blank.




# ---- RECURSIVE VECTORS (LISTS) ---------------------------------------------------- #

# Lists are a step up in complexity from atomic vectors, because lists
# can contain other lists. This makes them suitable for representing
# hierarchical or tree-like structures. You create a list with list():

x <- list(1, 2, 3)
x

# A very useful tool for working with lists is str() because it focuses
# on the structure, not the contents:

str(x)

x_named <- list(a = 1, b = 2, c = 3)
str(x_named)

# Unlike atomic vectors, lists() can contain a mix of objects:
y <- list("a", 1L, 1.5, TRUE)
str(y)

# Lists can even contain other lists!
z <- list(list(1, 2), list(3, 4))
str(z)





# ---- SUBSETTING LISTS ------------------------------------------------------------ #

# There are three ways to subset a list, which I'll illustrate with a:
a <- list(a = 1:3, b = "a string", c = pi, d = list(-1, -5))
a

# [ extracts a sublist. The result will always be a list:

str(a[1:2])

# [[ extracts a single component from a list. It removes a level of
# hierarchy from the list:

str(y[[1]])
str(y[[4]])

# $ is a shorthand for extracting named elements of a list. It works
# similarly to [[ except that you don't need to use quotes:

a$a
a[["a"]]

# The distinction between [ and [[ is really important for lists,
# because [[ drills down into the list while [ returns a new, smaller list.




# ---- LIST ATTRIBUTES --------------------------------------------------------------- #

# Any vector can contain arbitrary additional metadata through its
# attributes. You can think of attributes as a named list of vectors that
# can be attached to any object. You can get and set individual
# attribute values with attr() or see them all at once with attributes():

x <- 1:10
attr(x, "greeting")
attr(x, "greeting") <- "Hi!"
attr(x, "farewell") <- "Bye!"
attributes(x)
x

# There are three very important attributes that are used to implement
# fundamental parts of R:
  # Names are used to name the elements of a vector
  # Dimensions (dims, for short) make a vector behave like a matrix or array
  # Class is used to implement the S3 object-oriented system.

# You've seen names earlier, and we won't cover dimensions because
# we don't use matrices in this book. It remains to describe the class,
# which controls how generic functions work. Generic functions are
# key to object-oriented programming in R, because they make func-
# tions behave differently for different classes of input. A detailed dis-
# cussion of object-oriented programming is beyond the scope of this
# book, but you can read more about it in Advanced R.

# Here's what a typical generic function looks like:
as.Date

# The call to "UseMethod" means that this is a generic function, and it
# will call a specific method, a function, based on the class of the first
# argument. (All methods are functions; not all functions are meth-
# ods.) You can list all the methods for a generic with methods():

methods("as.Date")

# For example, if x is a character vector, as.Date() will call
# as.Date.character(); if it's a factor, it'll call as.Date.factor().

# You can see the specific implementation of a method with
# getS3method():

getS3method("as.Date", "default")
getS3method("as.Date", "numeric")

# The most important S3 generic is print(): it controls how the
# object is printed when you type its name at the console. Other
# important generics are the subsetting functions [, [[, and $.

















# ---- AUGMENTED VECTORS ---------------------------------------------------- #

# factors and dates are called augmented vectors, because they have additional
# attributes, including class. Because augmented vectors have a class, they behave
# differently to the atomic vector on which they are built. In this book, we make use
# of four important augmented vectors:


## FACTORS
# Factors are designed to represent categorical data that can take a
# fixed set of possible values. Factors are built on top of integers, and
# have a levels attribute:

x <- factor(c("ab", "cd", "ab"), levels = c("ab", "cd", "ef"))
typeof(x)
attributes(x)


## DATES AND DATE-TIMES
# Dates in R are numeric vectors that represent the number of days since
# 1 January 1970

x <- as.Date("1971-01-01")
unclass(x)
typeof(x)
attributes(x)

# Date-times are numeric vectors with class POSIXct that represent
# the number of seconds since 1 January 1970. (In case you were won-
# dering, "POSIXct" stands for "Portable Operating System Interface,"
# calendar time.)

x <- lubridate::ymd_hm("1970-01-01 01:00")
unclass(x)

# The tzone attribute is optional. It controls how the time is printed,
# not what absolute time it refers to:

attr(x, "tzone") <- "US/Pacific"
x
attr(x, "tzone") <- "US/Eastern"
x

# There is another type of date-times called POSIXlt. These are built
# on top of named lists:

y <- as.POSIXlt(x)
typeof(y)
attributes(y)

# POSIXlts are rare inside the tidyverse. They do crop up in base R,
# because they are needed to extract specific components of a date,
# like the year or month. Since lubridate provides helpers for you to
# do this instead, you don't need them. POSIXct's are always easier to
# work with, so if you find you have a POSIXlt, you should always
# convert it to a regular date-time with lubridate::as_date_time().




# ---- TIBBLES ----------------------------------------------------------- #

# Tibbles are augmented lists. They have three classes: tbl_df, tbl,
# and data.frame. They have two attributes: (column) names and
# row.names.

tb <- tibble::tibble(x = 1:5, y = 5:1)
typeof(tb)
attributes(tb)

# Traditional data.frames have a very similar structure:
df <- data.frame(x = 1.5, y = 5:1)
typeof(df)
attributes(df)

# The main difference is the class. The class of tibble includes
# "data.frame," which means tibbles inherit the regular data frame
# behavior by default.

# The difference between a tibble or a data frame and a list is that all
# of the elements of a tibble or data frame must be vectors with the
# same length. All functions that work with tibbles enforce this con-
# straint.

