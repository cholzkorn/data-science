rm(list=ls())

# ---- INTRODUCTION --------------------------------------------------------- #

# Writing a function function has three big advantages over using copy-and-paste:
  # 1. You can give a function a good name to make code easier to understand
  # 2. As requirements change, you only need to update code in one place
  # 3. You eliminate the chance of making identical mistakes

# You should consider writing a function whenever you've copied and
# pasted a block of code more than twice

df <- tibble::tibble(
  a = rnorm(10),
  b = rnorm(10),
  c = rnorm(10),
  d = rnorm(10)
)

df$a <- (df$a - min(df$a, na.rm = TRUE)) /
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$b <- (df$b - min(df$b, na.rm = TRUE)) /
  (max(df$b, na.rm = TRUE) - min(df$a, na.rm = TRUE))
df$c <- (df$c - min(df$c, na.rm = TRUE)) /
  (max(df$c, na.rm = TRUE) - min(df$c, na.rm = TRUE))
df$d <- (df$d - min(df$d, na.rm = TRUE)) /
  (max(df$d, na.rm = TRUE) - min(df$d, na.rm = TRUE))

# You might be able to puzzle out that this rescales each column to
# have a range from 0 to 1.

# To write a function, first analyze the code:

(df$a - min(df$a, na.rm = TRUE)) /
  (max(df$a, na.rm = TRUE) - min(df$a, na.rm = TRUE))

# Then we try dumbing it down
x <- df$a
(x - min(x, na.rm = TRUE)) /
  (max(x, na.rm = TRUE) - min(x, na.rm = TRUE))

# There is some duplication in this code. We're computing the range
# of the data three times, but it makes sense to do it in one step:

rng <- range(x, na.rm = TRUE)
(x - rng[1]) / (rng[2] - rng[1])

# turn it into a function:

rescale01 <- function(x){
  rng <- range(x, na.rm = TRUE)
  (x - rng[1]) / (rng[2] - rng[1]) 
}

rescale01(c(0, 5, 10))

# Note the overall process: I only made the function after I'd figured
# out how to make it work with a simple input. It's easier to start with
# working code and turn it into a function; it's harder to create a func-
# tion and then try to make it work.

# Try a few different inputs:
rescale01(c(-10, 0, 10))
rescale01(c(1, 2, 3, NA, 5))

# Now we can simplify our first process:
# Note that there is still duplication -> we will address that later

df$a <- rescale01(df$a)
df$b <- rescale01(df$b)
df$c <- rescale01(df$c)
df$d <- rescale01(df$d)

# With infinite numbers, our function fails:

x <- c(1:10, Inf)
rescale01(x)

# Because we've extracted the code into a function, we only need to
# make the fix in one place:

rescale01 <- function(x) {
  rng <- range(x, na.rm = TRUE, finite = TRUE)
  (x - rng[1]) / (rng[2] - rng[1])
}

rescale01(x)

# DRY principle - Do not Repeat Yourself!





# ---- FUNCTIONS ARE FOR HUMANS AND COMPUTERS --------------------------------- #

# Generally, function names should be verbs, and arguments should
# be nouns.

## EXAMPLES:
# Too short
f()

# Not a verb, or descriptive
my_awesome_function()

# Long, but clear
impute_missing()
collapse_years()

# Never do this!
col_mins <- function(x, y) {}
rowMaxes <- function(y, x) {}

# Good
input_select()
input_checkbox()
input_text()

# Not so good
select_input()
checkbox_input()
text_input()

# Where possible, avoid overriding existing functions and variables
# Don't do this!
T <- FALSE
c <- 10
mean <- function(x) sum(x)




# ----- CONDITIONAL EXECUTION ------------------------------------------------ #

# An if statement allows you to conditionally execute code. It looks
# like this:

if (condition) {
  # code executed when condition is TRUE
} else {
  # code executed when condition is FALSE
}

# Here's a simple function that uses an if statement. 

has_name <- function(x){
  nms <- names(x)
  if(is.null(nms)){
    rep(FALSE, length(x))}
    else{
      !is.na(nms) & nms != ""
    }
}


## CONDITIONS

# The condition must evaluate to either TRUE or FALSE. If it's a vector,
# you'll get a warning message; if it's an NA, you'll get an error. Watch
# out for these messages in your own code:

if(c(TRUE, FALSE)){}
if(NA){}
if(TRUE){}

# You can use || (or) and && (and) to combine multiple logical
# expressions. These operators are "short-circuiting": as soon as ||
# sees the first TRUE it returns TRUE without computing anything else.
# As soon as && sees the first FALSE it returns FALSE. You should never
# use | or & in an if statement: these are vectorized operations that
# apply to multiple values (that's why you use them in filter()). If
# you do have a logical vector, you can use any() or all() to collapse
# it to a single value.

# Be careful when testing for equality. == is vectorized, which means
# that it's easy to get more than one output. Either check the length is
# already 1, collapse with all() or any(), or use the nonvectorized
# identical(). identical() is very strict: it always returns either a
# single TRUE or a single FALSE, and doesn't coerce types. This means
# that you need to be careful when comparing integers and doubles:

identical(0L, 0)

# You also need to be wary of floating-point numbers:

x <- sqrt(2) ^ 2
x
x == 2
x - 2
near(x, 2)




# ---- MULTIPLE CONDITIONS -------------------------------------------------- #

# You can chain multiple if statements together:

if (this) {
  # do that
} else if (that) {
  # do something else
} else {
  #
}

# But if you end up with a very long series of chained if statements,
# you should consider rewriting. One useful technique is the
# switch() function. It allows you to evaluate selected code based on
# position or name:

opurrators <- function(x, y, op){
  switch(op,
         plus = x + y,
         minus = x - y,
         times = x * y,
         divide = x / y,
         stop("Unknown op!"))
}

opurrators(2, 3, "plus")
opurrators(2, 3, "times")

# Another useful function that can often eliminate long chains of if
# statements is cut(). It's used to discretize continuous variables




# ---- FUNCTION ARGUMENTS ---------------------------------------------------- #

# The arguments to a function typically fall into two broad sets: one
# set supplies the data to compute on, and the other supplies argu-
# ments that control the details of the computation. For example:
  # In log(), the data is x, and the detail is the base of the
  # logarithm.

  # In mean(), the data is x, and the details are how much data to
  # trim from the ends (trim) and how to handle missing values
  # (na.rm).

  # In t.test(), the data are x and y, and the details of the test are
  # alternative, mu, paired, var.equal, and conf.level.

  # In str_c() you can supply any number of strings to ..., and
  # the details of the concatenation are controlled by sep and
  # collapse

# Generally, data arguments should come first. Detail arguments
# should go on the end, and usually should have default values. You
# specify a default value in the same way you call a function with a
# named argument:

# Compute confidence interval around
# mean using normal approximation

mean_ci <- function(x, conf = 0.95) {
  se <- sd(x) / sqrt(length(x))
  alpha <- 1 - conf
  mean(x) + se * qnorm(c(alpha / 2, 1 - alpha / 2))
}

x <- runif(100)
mean_ci(x)
mean_ci(x, conf = 0.99)

# The default value should almost always be the most common value

# When you call a function, you typically omit the names of the data
# arguments, because they are used so commonly. If you override the
# default value of a detail argument, you should use the full name:

# Good
mean(1:10, na.rm = TRUE)

# Bad
mean(x = 1:10, , FALSE)
mean(, TRUE, x = c(1:10, NA))




# ----- CHECKING VALUES ---------------------------------------------------------- #

# As you start to write more functions, you'll eventually get to the
# point where you don't remember exactly how your function works.
# At this point it's easy to call your function with invalid inputs. To
# avoid this problem, it's often useful to make constraints explicit. For
# example, imagine you've written some functions for computing
# weighted summary statistics:

wt_mean <- function(x, w) {
  sum(x * w) / sum(x)
}
wt_var <- function(x, w) {
  mu <- wt_mean(x, w)
  sum(w * (x - mu) ^ 2) / sum(w)
}
wt_sd <- function(x, w) {
  sqrt(wt_var(x, w))
}

# What happens if x and w are not the same length?

wt_mean(1:6, 1:3)

# In this case, because of R's vector recycling rules, we don't get an
# error.

# It's good practice to check important preconditions, and throw an
# error (with stop()) if they are not true:

wt_mean <- function(x, w) {
  if (length(x) != length(w)) {
    stop("`x` and `w` must be the same length", call. = FALSE)
  }
  sum(w * x) / sum(x)
}

wt_mean(1:6, 1:3)

# stopifnot() checks that each argument is
# TRUE, and produces a generic error message if not:

wt_mean <- function(x, w, na.rm = FALSE) {
  stopifnot(is.logical(na.rm), length(na.rm) == 1)
  stopifnot(length(x) == length(w))
  if (na.rm) {
    miss <- is.na(x) | is.na(w)
    x <- x[!miss]
    w <- w[!miss]
  }
  sum(w * x) / sum(x)
}

wt_mean(1:6, 6:1, na.rm = "foo")

# Note that when using stopifnot() you assert what should be true
# rather than checking for what might be wrong.





# ---- DOT DOT DOT (...) -------------------------------------------------- #

# Many functions in R take an arbitrary number of inputs:

sum(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
stringr::str_c("a", "b", "c", "d", "e", "f")

# How do these functions work? They rely on a special argument: ...
# (pronounced dot-dot-dot). This special argument captures any
# number of arguments that aren't otherwise matched.

commas <- function(...) stringr::str_c(..., collapse = ", ")
commas(letters[1:10])

rule <- function(..., pad = "-"){
  title <- paste0(...)
  width <- getOption("width") - nchar(title) - 5
  cat(title, " ", stringr::str_dup(pad, width), "\n", sep = "")
}

rule("Important output")





# ----- LAZY EVALUATION ---------------------------------------------------- #

# Arguments in R are lazily evaluated: they're not computed until
# they're needed. That means if they're never used, they're never
# called. This is an important property of R as a programming lan-
# guage, but is generally not important when you're writing your own
# functions for data analysis. You can read more about lazy evaluation
# at http://adv-r.had.co.nz/Functions.html#lazy-evaluation.







# ----- RETURN VALUES -------------------------------------------------------- #

# Figuring out what your function should return is usually straightfor-
# ward: it's why you created the function in the first place! There are
# two things you should consider when returning a value:
  # Does returning early make your function easier to read?
  # Can you make your function pipeable?

## EXPLICIT RETURN STATEMENTS

# The value returned by the function is usually the last statement it
# evaluates, but you can choose to return early by using return(). I
# think it's best to save the use of return() to signal that you can
# return early with a simpler solution. A common reason to do this is
# because the inputs are empty:

complicated_function <- function(x, y, z) {
  if (length(x) == 0 || length(y) == 0) {
    return(0)
  }
  # Complicated code here
}

# Another reason is because you have a if statement with one com-
# plex block and one simple block. For example, you might write an
# if statement like this:

f <- function() {
  if (x) {
    # Do
    # something
    # that
    # takes
    # many
    # lines
    # to
    # express
  } else {
    # return something short
  }
}

# But if the first block is very long, by the time you get to the else,
# you've forgotten the condition. One way to rewrite it is to use an
# early return for the simple case:

f <- function() {
  if (!x) {
    return(something_short)
  }
}


## WRITING PIPEABLE FUNCTIONS

# If you want to write your own pipeable functions, thinking about
# the return value is important. There are two main types of pipeable
# functions: transformation and sideeffect.

  # 1. In transformation functions, there's a clear "primary" object that is
  # passed in as the first argument, and a modified version is returned
  # by the function.

  # 2. Sidee???ect functions are primarily called to perform an action, like
  # drawing a plot or saving a file, not transforming an object.

show_missings <- function(df) {
  n <- sum(is.na(df))
  cat("Missing values: ", n, "\n", sep = "")
  invisible(df)
}

# If we call it interactively, the invisible() means that the input df
# doesn't get printed out:

show_missings(mtcars)

# But it's still there, it's just not printed by default:

x <- show_missings(mtcars)
class(x)
dim(x)

# And we can still use it in a pipe:

mtcars %>%
  show_missings() %>%
  mutate(mpg = ifelse(mpg < 20, NA, mpg)) %>%
  show_missings()





# ---- ENVIRONMENT ------------------------------------------------------------- #

# The environment of a function controls how R finds the value associated
# with a name. For example, take this function:

f <- function(x) {
  x + y
}

# In many programming languages, this would be an error, because y
# is not defined inside the function. In R, this is valid code because R
# uses rules called lexical scoping to find the value associated with a
# name. Since y is not defined inside the function, R will look in the
# environment where the function was defined:

y <- 100
f(10)

y <- 1000
f(10)
