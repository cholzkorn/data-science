rm(list=ls())

# use R as a calculator

1 / 200 * 30
(59 + 73 + 2) / 3
sin(pi / 2)

# create new objects

x <- 3 * 4

# object names must start with a letter and can only contain letters, numbers, _ and .

this_is_a_really_long_name <- 2.5

this_is_a_really_long_name <- 3.5

r_rocks <- 2 ^ 3

# ---------------- CALLING FUNCTIONS ------------------------------------ #

seq(1, 10)
x <- "hello world"

y <- seq(1, 10, length.out = 5)

# directly print to screen
rm(y)
(y <- seq(1, 10, length.out = 5))


################### EXERCISES

# Why does this code not work?

my_variable <- 10
my_variable
# Answer: typo in the second variable name


# Tweak each of the following R commands so that they run correctly

library(tidyverse)

ggplot(data = mpg) +
  geom_point(mapping = aes(x = displ, y = hwy) , data = filter(mpg, cyl == 8))

filter(mpg, cyl == 8)
filter(diamonds, carat > 3)

# R-Markdown: Alt-Shift-K