rm(list=ls())

# The pipe, %>%, comes from the magrittr package by Stefan Milton
# Bache. Packages in the tidyverse load %>% for you automatically, so
# you don't usually load magrittr explicitly. Here, however, we're
# focusing on piping, and we aren't loading any other packages, so we
# will load it explicitly.

# we can read the pipe as "THEN"

# install.packages("magrittr")
# install.packages("pryr")

library(tidyverse)
library(magrittr)
library(pryr)

# The pipe sends objects to the next function, thus making our code easier
# to write and read. It also saves space:

diamonds <- ggplot2::diamonds
diamonds2 <- diamonds %>%
  dplyr::mutate(price_per_carat = price / carat)

pryr::object_size(diamonds)
pryr::object_size(diamonds2)
pryr::object_size(diamonds, diamonds2) # no need to duplicate data

# These variables will only get copied if you modify one of them.

diamonds$carat[1] <- NA

pryr::object_size(diamonds)
pryr::object_size(diamonds2)
pryr::object_size(diamonds, diamonds2) # collective size increases

# the pipe won't work for two classes of functions:
  # 1. Functions that use the current environment. For example,
  # assign() will create a new variable with the given name in the
  # current environment:

assign("x", 10)
x

"x" %>% assign(100)
x

  # The use of assign with the pipe does not work because it
  # assigns it to a temporary environment used by %>%. If you do
  # want to use assign with the pipe, you must be explicit about the
  # environment:

  # Other functions with this problem include get() and load().

env <- environment()
"x" %>% assign(100, envir = env)
x

  # 2. Functions that use lazy evaluation. In R, function arguments are
  # only computed when the function uses them, not prior to calling
  # the function. The pipe computes each element in turn, so
  # you can't rely on this behavior.
  
  # One place that this is a problem is tryCatch(), which lets you
  # capture and handle errors:

  # There are a relatively wide class of functions with this behavior,
  # including try(), suppressMessages(), and suppressWarn
  # ings() in base R.

tryCatch(stop("!"), error = function(e) "An error")

stop("!") %>%
  tryCatch(error = function(e) "An error")




# ----- WHEN NOT TO USE THE PIPE ----------------------------------------------- #

# The pipe is a powerful tool, but it's not the only tool at your disposal,
# and it doesn't solve every problem! Pipes are most useful for rewrit-
# ing a fairly short linear sequence of operations. I think you should
# reach for another tool when:

  # Your pipes are longer than (say) 10 steps. In that case, create
  # intermediate objects with meaningful names

  # You have multiple inputs or outputs. If there isn't one primary
  # object being transformed, but two or more objects being com-
  # bined together, don't use the pipe.

  # You are starting to think about a directed graph with a complex
  # dependency structure. Pipes are fundamentally linear and
  # expressing complex relationships with them will typically yield
  # confusing code.



# ---- OTHER TOOLS FROM magrittr ------------------------------------------------ #

# All packages in the tidyverse automatically make %>% available for
# you, so you don't normally load magrittr explicitly. However, there
# are some other useful tools inside magrittr that you might want to
# try out:

# When working with more complex pipes, it's sometimes useful
# to call a function for its side effects. Maybe you want to print
# out the current object, or plot it, or save it to disk. Many times,
# such functions don't return anything, effectively terminating the
# pipe.

rnorm(100) %>%
  matrix(ncol = 2) %>%
  plot() %>%
  str()

# To work around this problem, you can use the "tee" pipe. %T>%
# works like %>% except that it returns the lefthand side instead of
# the righthand side. It's called "tee" because it's like a literal Tshaped pipe:

rnorm(100) %>%
  matrix(ncol = 2) %T>%
  plot() %>%
  str()

# If you're working with functions that don't have a data frame-
# based API (i.e., you pass them individual vectors, not a data
# frame and expressions to be evaluated in the context of that data
# frame), you might find %$% useful. It "explodes" out the variables
# in a data frame so that you can refer to them explicitly. This is
# useful when working with many functions in base R:

mtcars %$%
  cor(disp, mpg)