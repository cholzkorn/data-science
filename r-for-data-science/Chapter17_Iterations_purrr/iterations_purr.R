rm(list=ls())

library(tidyverse)

# Reducing code duplication has three main benefits:
  # 1. easier to see intent of code
  # 2. easier to respond to changes
  # 3. fewer bugs

# one tool to reduce repition is using functions
# another would be iteration
  # imperative programming: for loops, while loops
  # functional programming: each common for loop gets its own function


# ---- FOR LOOP ------------------------------------------------------------------ #

# Imagine we have this simple tibble:
  
df <- tibble(
    a = rnorm(10),
    b = rnorm(10),
    c = rnorm(10),
    d = rnorm(10))

# We want to compute the median of each column. You could do it
# with copy-and-paste:
median(df$a)
median(df$b)
median(df$c)
median(df$d)

# ... or with a for-loop
output <- vector("double", ncol(df))
for (i in seq_along(df)){
  output[[i]] <- median(df[[i]])
}
output

# Every for loop has three components:
  # output output <- vector("double", length(x))
    # Before you start the loop, you must always allocate sufficient
    # space for the output. This is very important for efficiency: if you
    # grow the for loop at each iteration using c() (for example), your
    # for loop will be very slow.

  # sequence i in seq_along(df)
    # This determines what to loop over: each run of the for loop will
    # assign i to a different value from seq_along(df). It's useful to
    # think of i as a pronoun, like "it."

    # You might not have seen seq_along() before. It's a safe version
    # of the familiar 1:length(l), with an important difference; if
    # you have a zero-length vector, seq_along() does the right thing:

y <- vector("double", 0)
seq_along(y)

  # body output[[i]] <- median(df[[i]])
    # This is the code that does the work. It's run repeatedly, each time
    # with a different value for i. The first iteration will run out
    # put[[1]] <- median(df[[1]]), the second will run out
    # put[[2]] <- median(df[[2]]), and so on.

## EXERCISES
# Write a loop to compute the mean of every column in mtcars
str(mtcars)
mtcars_output <- vector("double", ncol(mtcars))
for (i in seq_along(mtcars)){
  mtcars_output[[i]] <- mean(mtcars[[i]])
}
mtcars_output


# Determine the type of each column in nyc flights13::flights.
library(nycflights13)
str(flights)

flights_coltypes <- vector("character", ncol(flights))

for (i in seq_along(flights)){
  flights_coltypes[[i]] <- paste(colnames(flights)[i], "is of type", typeof(flights[[i]]))
}

flights_coltypes







# ---- FOR LOOP VARIATIONS ------------------------------------------------------------- #

# There are four variations on the basic theme of the for loop:
  # 1. Modifying an existing object, instead of creating a new object.
  # 2. Looping over names or values, instead of indices.
  # 3. Handling outputs of unknown length.
  # 4. Handling sequences of unknown length.

## MODIFYING AN EXISTING OBJECT

# We want to rescale every column in a data frame:
df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10))

rescale01 <- function(x){
  rng <- range(x, na.rm = TRUE)
}

df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)

for (i in seq_along(df)){
  df[[i]] <- rescale01(df[[i]])
}


## LOOPING PATTERNS

# If you're creating named output, make sure to name the results
# vector like so:

results <- vector("list", length(x))
names(results) <- names(x)

# Iteration over the numeric indices is the most general form, because
# given the position you can extract both the name and the value:

for (i in seq_along(x)){
  name <- names(x)[[i]]
  value <- x[[i]]
}


## UNKNOWN OUTPUT LENGTH

# Sometimes you might not know how long the output will be. For
# example, imagine you want to simulate some random vectors of
# random lengths. You might be tempted to solve this problem by
# progressively growing the vector:

means <- c(0, 1, 2)

output <- double()
for (i in seq_along(means)){
  n <- sample(100, 1)
  output <- c(output, rnorm(n, means[[i]]))
}
output

# But this is not very efficient because in each iteration, R has to copy
# all the data from the previous iterations. In technical terms you get
# "quadratic" (O(n^2)) behavior, which means that a loop with three
# times as many elements would take nine (3^2) times as long to run.

# A better solution is to save the results in a list, and then combine
# into a single vector after the loop is done:

out <- vector("list", length(means))
for (i in seq_along(means)){
  n <- sample(100, 1)
  out[[i]] <- rnorm(n, means[[i]])
}
out

# flatten list out to single vector:
unlist(out)

# stricter option, only working with doubles:
purrr::flatten_dbl(out)


## UNKNOWN SEQUENCE LENGTH

# A while loop is simpler than a for loop because it only
# has two components, a condition and a body:

while (condition) {
  # body
}

# A while loop is also more general than a for loop, because you can
# rewrite any for loop as a while loop, but you can't rewrite every
# while loop as a for loop:

for (i in seq_along(x)) {
  # body
}

# ... is equivalent to:

i <- 1
while (i <= length(x)) {
  # body
  i <- i + 1
}

# Here's how we could use a while loop to find how many tries it takes
# to get three heads in a row:

flip <- function() sample(c("T", "H"), 1)

flips <- 0
nheads <- 0

while(nheads < 3){
  if(flip() == "H"){
    nheads <- nheads + 1
  }
  else {
    nheads <- 0
  }
  flips <- flips + 1
}

flips

# I mention while loops only briefly, because I hardly ever use them.
# They're most often used for simulation, which is outside the scope
# of this book. However, it is good to know they exist so that you're
# prepared for problems where the number of iterations is not known
# in advance.









# ---- FOR LOOPS VERSUS FUNCTIONALS ------------------------------------------------- #

# For loops are not as important in R as they are in other languages
# because R is a functional programming language. This means that
# it's possible to wrap up for loops in a function, and call that function
# instead of using the for loop directly.

# To see why this is important, consider (again) this simple data
# frame:

df <- tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

# Imagine you want to compute the mean of every column. You could
# do that with a for loop:

output <- vector("double", length(df))
for (i in seq_along(df)){
  output[[i]] <- mean(df[[i]])
}
output

# You realize that you're going to want to compute the means of every
# column pretty frequently, so you extract it out into a function:

col_mean <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- mean(df[[i]])
  }
  output
}

# But then you think it'd also be helpful to be able to compute the
# median, and the standard deviation, so you copy and paste your
# col_mean() function and replace the mean() with median() and sd():

col_median <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- median(df[[i]])
  }
  output
}

col_sd <- function(df) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- sd(df[[i]])
  }
  output
}

# We copy-and-pasted twice so we should think about how to generalize this
# function.

col_summary <- function(df, fun) {
  output <- vector("double", length(df))
  for (i in seq_along(df)) {
    output[i] <- fun(df[[i]])
  }
  output
}

col_summary(df, median)

# The idea of passing a function to another function is an extremely
# powerful idea, and it's one of the behaviors that makes R a func-
# tional programming language.







# ---- THE MAP FUNCTIONS in purrr ------------------------------------------------ #

# The pattern of looping over a vector, doing something to each ele-
# ment, and saving the results is so common that the purrr package
# provides a family of functions to do it for you. There is one function
# for each type of output:
  # map() makes a list
  # map_lgl() makes a logical vector
  # map_int() makes an integer vector
  # map_dbl() makes a double vector
  # map_chr() makes a character vector

# Each function takes a vector as input, applies a function to each
# piece, and then returns a new vector that's the same length (and has
# the same names) as the input. The type of the vector is determined
# by the suffix to the map function.

# Some people will tell you to avoid for loops because they are slow.
# They're wrong! (Well at least they're rather out of date, as for loops
# haven't been slow for many years). The chief benefit of using func-
# tions like map() is not speed, but clarity: they make your code easier
# to write and to read.

# We can use these functions to perform the same computations as the
# last for loop. Those summary functions returned doubles, so we
# need to use map_dbl()

map_dbl(df, mean)
map_dbl(df, median)
map_dbl(df, sd)

# Compared to using a for loop, focus is on the operation being per-
# formed (i.e., mean(), median(), sd()), not the bookkeeping required
# to loop over every element and store the output. This is even more
# apparent if we use the pipe:

df %>% map_dbl(mean)
df %>% map_dbl(median)
df %>% map_dbl(sd)

# There are a few differences between map_*() and col_summary():
  # All purrr functions are implemented in C. This makes them a
  # little faster at the expense of readability.
  
  # The second argument, .f, the function to apply, can be a for-
  # mula, a character vector, or an integer vector. You'll learn about
  # those handy shortcuts in the next section.

  # map_*() uses ... ("Dot-Dot-Dot (.)" on page 284) to pass along
  # additional arguments to .f each time it's called:

map_dbl(df, mean, trim = 0.5)
z <- list(x = 1:3, y = 4:5)
map_int(z, length)


## SHORTCUTS

# There are a few shortcuts that you can use with .f in order to save a
# little typing. Imagine you want to fit a linear model to each group in
# a dataset. The following toy example splits up the mtcars dataset
# into three pieces (one for each value of cylinder) and fits the same
# linear model to each piece:

models <- mtcars %>%
  split(.$cyl) %>%
  map(function(df) lm(mpg ~ wt, data = df))

# Here I've used . as a pronoun: it refers to the current list element (in
# the same way that i referred to the current index in the for loop).

# When you're looking at many models, you might want to extract a
# summary statistic like the R2. To do that we need to first run sum
# mary() and then extract the component called r.squared. We could
# do that using the shorthand for anonymous functions:

models %>%
  map(summary) %>%
  map_dbl(~.$r.squared)

# But extracting named components is a common operation, so purrr
# provides an even shorter shortcut: you can use a string.

models %>%
  map(summary) %>%
  map_dbl("r.squared")

# You can also use an integer to select elements by position:
x <- list(list(1, 2, 3), list(4, 5, 6), list(7, 8, 9))
x %>% map_dbl(2)

###### SIMILAR FUNTIONS IN BASE R: apply(), sapply(), lapply() ########



# ---- DEALING WITH FAILURE ------------------------------------------------------ #

# When you use the map functions to repeat many operations, the
# chances are much higher that one of those operations will fail.
# When this happens, you'll get an error message, and no output.

# In this section you'll learn how to deal with this situation with a new
# function: safely(). safely() is an adverb: it takes a function (a
# verb) and returns a modified version. In this case, the modified
# function will never throw an error. Instead, it always returns a list
# with two elements:
  # result: the original result. If there was an error, this will be NULL
  # error: an error object. If the operation was successful, this will be NULL

# Let's illustrate this with a simple example, log():

safe_log <- safely(log)
str(safe_log(10))
str(safe_log("a"))

# safely() is designed to work with map:
x <- list(1, 10, "a")
y <- x %>% map(safely(log))
str(y)

# This would be easier to work with if we had two lists: one of all the
# errors and one of all the output. That's easy to get with
# purrr::transpose()

y <- y %>% transpose()
str(y)

# It's up to you how to deal with the errors, but typically you'll either
# look at the values of x where y is an error, or work with the values of
# y that are OK:

is_ok <- y$error %>% map_lgl(is_null)
x[!is_ok]

y$result[is_ok] %>% flatten_dbl()

# purrr provides two other useful adverbs:

  # Like safely(), possibly() always succeeds. It's simpler than
  # safely(), because you give it a default value to return when
  # there is an error:

x <- list(1, 10, "a")
x %>% map_dbl(possibly(log, NA_real_))

  # quietly() performs a similar role to safely(), but instead of
  # capturing errors, it captures printed output, messages, and
  # warnings:

x <- list(1, -1)
x %>% map(quietly(log)) %>% str()



# ---- MAPPING OVER MULTIPLE ARGUMENTS ------------------------------------------------ #

# So far we've mapped along a single input. But often you have multi-
# ple related inputs that you need to iterate along in parallel. That's the
# job of the map2() and pmap() functions. For example, imagine you
# want to simulate some random normals with different means. You
# know how to do that with map():

mu <- list(5, 10, -3)
mu %>%
  map(rnorm, n = 5) %>%
  str()

# What if you also want to vary the standard deviation? One way to do
# that would be to iterate over the indices and index into vectors of
# means and sds:

sigma <- list(1, 5, 10)
seq_along(mu) %>%
  map(~ rnorm(5, mu[[.]], sigma[[.]])) %>%
  str()

# But that obfuscates the intent of the code. Instead we could use
# map2(), which iterates over two vectors in parallel:

map2(mu, sigma, rnorm, n = 5) %>%
  str()

# Note that the arguments that vary for each call come before the func-
# tion; arguments that are the same for every call come afer.

# Like map(), map2() is just a wrapper around a for loop:

map2 <- function(x, y, f, ...){
  out <- vector("list", length(x))
  for (i in seq_along(x)){
    out[[i]] <- f(x[[i]], y[[i]], ...)
  }
}

map2(x, y, median)

# You could also imagine map3(), map4(), map5(), map6(), etc., but
# that would get tedious quickly. Instead, purrr provides pmap(),
# which takes a list of arguments. You might use that if you wanted to
# vary the mean, standard deviation, and number of samples:

n <- list(1, 3, 5)
args1 <- list(n, mu, sigma)
args1 %>%
  pmap(rnorm) %>%
  str()

# If you don't name the elements of list, pmap() will use positional
# matching when calling the function. That's a little fragile, and makes
# the code harder to read, so it's better to name the arguments:

args <- list(mean = mu, sd = sigma, n = n)
args %>%
  pmap(rnorm) %>%
  str()

# Since the arguments are all the same length, it makes sense to store
# them in a data frame:

params <- tribble(
  ~mean, ~sd, ~n,
  5, 1, 1,
  10, 5, 3,
  -3, 10, 5)

params %>%
  pmap(rnorm)

# As soon as your code gets complicated, I think a data frame is a
# good approach because it ensures that each column has a name and
# is the same length as all the other columns.










# ---- INVOKING DIFFERENT FUNCTIONS --------------------------------------------------- #

# There's one more step up in complexity-as well as varying the
# arguments to the function you might also vary the function itself:

f <- c("runif", "rnorm", "rpois")
param <- list(
  list(min = -1, max = 1),
  list(sd = 5),
  list(lambda = 10))

# To handle this case, you can use invoke_map():
invoke_map(f, param, n = 5) %>% str()

# The first argument is a list of functions or a character vector of func-
# tion names. The second argument is a list of lists giving the argu-
# ments that vary for each function. The subsequent arguments are
# passed on to every function.

# And again, you can use tribble() to make creating these matching
# pairs a little easier:

sim <- tribble(
  ~f, ~params,
  "runif", list(min = -1, max = 1),
  "rnorm", list(sd = 5),
  "rpois", list(lambda = 10))

sim %>%
  mutate(sim = invoke_map(f, params, n = 10))





# ---- WALK ----------------------------------------------------------------------------- #

# Walk is an alternative to map that you use when you want to call a
# function for its side effects, rather than for its return value. You typi-
# cally do this because you want to render output to the screen or save
# files to disk-the important thing is the action, not the return value.
# Here's a very simple example:

x <- list(1, "a", 3)
x %>%
  walk(print)

# walk() is generally not that useful compared to walk2() or pwalk().
# For example, if you had a list of plots and a vector of filenames, you
# could use pwalk() to save each file to the corresponding location on
# disk:

library(ggplot2)
plots <- mtcars %>%
  split(.$cyl) %>%
  map(~ ggplot(., aes(mpg, wt)) + geom_point())

paths <- stringr::str_c(names(plots), ".pdf")
pwalk(list(paths, plots), ggsave, path = tempdir())

# walk(), walk2(), and pwalk() all invisibly return .x, the first argu-
# ment. This makes them suitable for use in the middle of pipelines.








# ---- OTHER PATTERNS FOR LOOPS ----------------------------------------------------- #

## PREDICATE FUNCTIONS

# A number of functions work with predicate functions that return
# either a single TRUE or FALSE.

# keep() and discard() keep elements of the input where the predi-
# cate is TRUE or FALSE, respectively:

iris %>%
  keep(is.factor) %>%
  str()

iris %>%
  discard(is.factor) %>%
  str()

# some() and every() determine if the predicate is true for any or for
# all of the elements:

x <- list(1:5, letters, list(10))
x %>%
  some(is_character)

x %>%
  every(is_vector)

# detect() finds the first element where the predicate is true;
# detect_index() returns its position:

x <- sample(10)
x

x %>%
  detect(~ . > 5)

x %>%
  detect_index(~ . > 5)

# head_while() and tail_while() take elements from the start or
# end of a vector while a predicate is true:

x %>%
  head_while(~ . > 5)

x %>%
  tail_while(~ . > 5)

## REDUCE AND ACCUMULATE

# Sometimes you have a complex list that you want to reduce to a sim-
# ple list by repeatedly applying a function that reduces a pair to a singleton.

dfs <- list(
  age = tibble(name = "John", age = 30),
  sex = tibble(name = c("John", "Mary"), sex = c("M", "F")),
  trt = tibble(name = "Mary", treatment = "A"))

dfs %>% reduce(full_join)

# Or maybe you have a list of vectors, and want to find the intersection:

vs <- list(
  c(1, 3, 5, 6, 10),
  c(1, 2, 3, 7, 8, 10),
  c(1, 2, 3, 4, 8, 9, 10))

vs %>% reduce(intersect)

# The reduce function takes a "binary" function (i.e., a function with
# two primary inputs), and applies it repeatedly to a list until there is
# only a single element left.

# Accumulate is similar but it keeps all the interim results. You could
# use it to implement a cumulative sum:

x <- sample(10)
x

x %>% accumulate("+")
