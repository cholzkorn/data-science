rm(list=ls())

# ------------- STRINGS WITH stringr ---------------------------------------------- #

# This chapter introduces string manipulation with R and talks
# about regular expressions or regexps

# regexps are a concise language for describing patterns in strings

# Prerequisites
library(tidyverse)

# install.packages("stringr")

library(stringr)




# ------------- STRING BASICS ---------------------------------------------- #

# You can create a string with " or with ', but " is recommended

string1 <- "This is a string"
string2 <- 'To put a "quote" inside a string, use single quotes'

# To include a literal single or double quote in a string you can use \
# to "escape" it

double_quote <- "\"" # or '"'
single_quote <- '\'' # or "'"

# To see the raw contents of the string, use writeLines():

x <- c("\"", "\\")
writeLines(x)

# Other characters
x <- "\u00b5"
x

# Multiple strings are often stored in a character vector, which you
# can create with c():

c("one", "two", "three")

# String length
str_length(c("a", "R for data science", NA))

# Combining Strings
str_c("x", "y")
str_c("x", "y", "z")
str_c("x", "y", sep = ", ")

# Like most other functions in R, missing values are contagious. If you
# want them to print as "NA", use str_replace_na():

x <- c("abc", NA)

str_c("|-", x, "-|")
str_c("|-", str_replace_na(x), "-|")

# As shown in the preceding code, str_c() is vectorized, and it auto-
# matically recycles shorter vectors to the same length as the longest:

str_c("prefix-", c("a", "b", "c"), "-suffix")

# Objects of length 0 are silently dropped. This is particularly useful in
# conjunction with if:

name <- "Hadley"
time_of_day <- "morning"
birthday <- FALSE

str_c(
  "Good ", time_of_day, " ", name,
  if (birthday) " and HAPPY BIRTHDAY",
  ".")

# To collapse a vector of strings into a single string, use collapse:
str_c(c("x", "y", "z"), collapse = ", ")





# ------------- SUBSETTING STRINGS ---------------------------------------------- #

# You can extract parts of a string using str_sub(). As well as the
# string, str_sub() takes start and end arguments that give the
# (inclusive) position of the substring:

x <- c("Apple", "Banana", "Pear")
str_sub(x, 1, 3)

# negative numbers count backwards from end
str_sub(x, -3, -1)

# Note that str_sub() won't fail if the string is too short; it will just
# return as much as possible:
str_sub("a", 1, 3)

# You can also use the assignment form of str_sub() to modify
# strings:
str_sub(x, 1, 1) <- str_to_lower(str_sub(x, 1, 1))
x


# ------------- LOCALES -------------------------------------------------------- #

# Turkish has two i's: with and without a dot, and it
# has a different rule for capitalizing them:
str_to_upper(c("i", "i"))
str_to_upper(c("i", "i"), locale = "tr")

# The base R order() and sort() functions sort strings using the cur-
# rent locale. If you want robust behavior across different computers,
# you may want to use str_sort() and str_order(), which take an
# additional locale argument:

x <- c("apple", "eggplant", "banana")

str_sort(x, locale = "en")
str_sort(x, locale = "haw") # Hawaiian


# ------------ MATCHING PATTERNS WITH REGULAR EXPRESSIONS ----------------------- #

# To learn regular expressions, we'll use str_view() and
# str_view_all(). These functions take a character vector and a reg-
# ular expression, and show you how they match.

## BASIC MATCHES
x <- c("apple", "banana", "pear")
str_view(x, "an")

# The next step up in complexity is ., which matches any character
# (except a newline):
str_view(x, ".a.")

## But how do you match a .?
# To create the regular expression, we need \\
dot <- "\\."

# But the expression itself only contains one:
writeLines(dot)

# And this tells R to look for an explicit .
str_view(c("abc", "a.c", "bef"), "a\\.c")

## If \ is used as an escape character in regular expressions, how do
# you match a literal \?

x <- "a\\b"
writeLines(x)

# To match one \ we need FOUR \\\\!
str_view(x, "\\\\")

# In this book, I'll write regular expressions as \. and strings that rep-
# resent the regular expression as "\\.".


# ------------ CHARACTER CLASSES AND ALTERNATIVES ----------------------- #

# There are a number of special patterns that match more than one
# character. You've already seen ., which matches any character apart
# from a newline. There are four other useful tools:
  # \d matches any digit
  # \s matches any whitespace (e.g., space, tab, newline)
  # [abc] matches a, b, or c
  # [^abc] matches anything except a, b, or c

# Remember, to create a regular expression containing \d or \s, you'll
# need to escape the \ for the string, so you'll type "\\d" or "\\s".

# Using OR:
str_view(c("grey", "gray"), "gr(e|a)y")



# ------------ ANCHORS ------------------------------------------------- #

x <- c("apple", "banana", "pear")

# write ^ to match the start of the string.
str_view(x, "^a")

# write $ to match the end of the string.
str_view(x, "a$")

# to force a regular expression to only match a complete string,
# anchor it with both ^ and $:

x <- c("apple pie", "apple", "apple cake")
str_view(x, "apple", match = TRUE)
str_view(x, "^apple$", match = TRUE)



## EXERCISES

# Create a regular expression that finds all words that start with vowels

str_view(c("apple", "melon", "orange"), "^[aeiou]", match = TRUE)

# Create a regular expression that only contains consonants
str_view(c("apple", "melon", "orange"), "[^aeiou]")

# End with ed, but not with eed.
str_view(c("paved", "creed", "described"), "ed$")

# End with ing or ize.
str_view(c("breathing", "colorize", "laughing", "now"), "ing$|ize$")





# -------- REPITION ------------------------------------------------------ #

# The next step up in power involves controlling how many times a
# pattern matches:
    # ?: 0 or 1
    # *: 0 or more
    # +: 1 or more

x <- "1888 is the longest year in Roman numerals: MDCCCLXXXVIII"
str_view(x, "CC?")
str_view(x, "CC+")
str_view(x, 'C[LX]+')

# Note that the precedence of these operators is high, so you can write
# colou?r to match either American or British spellings. That means
# most uses will need parentheses, like bana(na)+.

# You can also specify the number of matches precisely:
  # {n} exactly n
  # {n,} n or more
  # {,m} at most m
  # {n,m} between n and m

str_view(x, "C{2}")
str_view(x, "C{2,}")
str_view(x, "C{2,3}")

# By default these matches are "greedy": they will match the longest
# string possible. You can make them "lazy," matching the shortest
# string possible, by putting a ? after them.

str_view(x, 'C{2,3}?')





# -------- GROUPING AND BACKREFERENCES ------------------------------------- #

fruit

# Find all fruit with repeated pairs of letters

str_view(fruit, "(..)\\1", match = TRUE)





# -------- TOOLS ----------------------------------------------------------- #

# Now that you've learned the basics of regular expressions, it's time to
# learn how to apply them to real problems. In this section you'll learn
# a wide array of stringr functions that let you:
    # determine which strings match a pattern
    # find the positions of matches
    # extract the content of matches
    # replace matches with new values
    # split a string based on a match




# ------ DETECT MATCHES ----------------------------------------------------- #

x <- c("apple", "banana", "pear")
str_detect(x, "e")

# How many common words start with t?
words
sum(str_detect(words, "^t"))

# What proportion of common words end with a vowel?
mean(str_detect(words, "[aeiou]$"))

# Find all words containing at least one vowel, and negate
no_vowels1 <- !str_detect(words, "[aeiou]")
no_vowels1

# Find all words consisting only of consonants (non-vowels)
no_vowels2 <- str_detect(words, "^[^aeiou]+$")
no_vowels2

identical(no_vowels1, no_vowels2)

# A common use of str_detect() is to select the elements that match
# a pattern. You can do this with logical subsetting, or the convenient
# str_subset() wrapper:

words[str_detect(words, "x$")]
str_subset(words, "x$")

# Typically, however, your strings will be one column of a data frame,
# and you'll want to use filter instead:

df <- tibble(
  word = words,
  i = seq_along(word))
df

df %>%
  filter(str_detect(words, "x$"))

# A variation on str_detect() is str_count(): rather than a simple
# yes or no, it tells you how many matches there are in a string:

x <- c("apple", "banana", "pear")
str_count(x, "a")

# On average, how many vowels per word?
mean(str_count(words, "[aeiou]"))

# It's natural to use str_count() with mutate():
df %>%
  mutate(vowels = str_count(word, "[aeiou]"),
         consonants = str_count(word, "[^aeiou]"),
         length = str_length(word))

# Note that matches never overlap
str_count("abababa", "aba")
str_view_all("abababa", "aba")







# ---------- EXTRACT MATCHES ----------------------------------------------- #

# To extract the actual text of a match, use str_extract().

head(sentences)
length(sentences)

# Imagine we want to find all sentences that contain a color. We first
# create a vector of color names, and then turn it into a single regular
# expression:

colors <- c("red", "orange", "yellow", "green", "blue", "purple")

color_match <- str_c(colors, collapse = "|")
color_match

has_color <- str_subset(sentences, color_match)
matches <- str_extract(has_color, color_match)
head(matches)

# Note that str_extract() only extracts the first match. We can see
# that most easily by first selecting all the sentences that have more
# than one match:

more <- sentences[str_count(sentences, color_match) > 1]
str_view_all(more, color_match)
str_extract(more, color_match)

# This is a common pattern for stringr functions, because working
# with a single match allows you to use much simpler data structures.
# To get all matches, use str_extract_all(). It returns a list:

str_extract_all(more, color_match)

# If you use simplify = TRUE, str_extract_all() will return a
# matrix with short matches expanded to the same length as the
# longest:

str_extract_all(more, color_match, simplify = TRUE)

x <- c("a", "a b", "a b c")
str_extract_all(x, "[a-z]", simplify = TRUE)



# ----- GROUPED MATCHES ----------------------------------------------- #

noun <- "(a|the) ([^ ]+)"

has_noun <- sentences %>%
  str_subset(noun) %>%
  head(10)

has_noun %>%
  str_extract(noun)

# str_extract() gives us the complete match; str_match() gives
# each individual component. Instead of a character vector, it returns
# a matrix, with one column for the complete match followed by one
# column for each group

has_noun %>%
  str_match(noun)

# If your data is in a tibble, it's often easier to use tidyr::extract().
# It works like str_match() but requires you to name the matches,
# which are then placed in new columns:

tibble(sentence = sentences) %>%
  tidyr::extract(sentence, c("article", "noun"), "(a|the) ([^ ]+)", remove = FALSE)




# ------ REPLACING MATCHES ---------------------------------------------- #

# str_replace() and str_replace_all() allow you to replace
# matches with new strings. The simplest use is to replace a pattern
# with a fixed string:

x <- c("apple", "pear", "banana")
str_replace(x, "[aeiou]", "-")
str_replace_all(x, "[aeiou]", "-")

# With str_replace_all() you can perform multiple replacements
# by supplying a named vector:

x <- c("1 house", "2 cars", "3 people")
str_replace_all(x, c("1" = "one", "2" = "two", "3" = "three"))

# Instead of replacing with a fixed string you can use backreferences
# to insert components of the match. In the following code, I flip the
# order of the second and third words:

sentences %>%
  str_replace("([^ ]+) ([^ ]+) ([^ ]+)", "\\1 \\3 \\2") %>%
  head(5)





# ------- SPLITTING ------------------------------------------------------ #

# Use str_split() to split a string up into pieces. For example, we
# could split sentences into words:

sentences %>%
  head(5) %>%
  str_split(" ")

# Because each component might contain a different number of
# pieces, this returns a list. If you're working with a length-1 vector,
# the easiest thing is to just extract the first element of the list:

"a|b|c|d" %>%
  str_split("\\|") %>%
  .[[1]]

# Otherwise, like the other stringr functions that return a list, you can
# use simplify = TRUE to return a matrix:

sentences %>%
  head(5) %>%
  str_split(" ", simplify = TRUE)

# You can also request a maximum number of pieces:

fields <- c("Name: Hadley", "Country: NZ", "Age: 35")
fields

fields %>% str_split(": ", n = 2, simplify = TRUE)

# Instead of splitting up strings by patterns, you can also split up by
# character, line, sentence, and word boundary()s:

x <- "This is a sentence. This is another sentence."
x
str_view_all(x, boundary("word"))

str_split(x, " ")[[1]]
str_split(x, boundary("word"))[[1]]


#### EXERCISES

# Split up a string like "apples, pears, and bananas" into indi-
# vidual components

x <- c("apples, pears, bananas")
str_split(x, ", ", simplify = TRUE)




# ----- FIND MATCHES ----------------------------------------------------------- #

# str_locate() and str_locate_all() give you the starting and
# ending positions of each match. These are particularly useful when
# none of the other functions does exactly what you want. You can use
# str_locate() to find the matching pattern, and str_sub() to
# extract and/or modify them.






# ----- OTHER TYPES OF PATTERNS ------------------------------------------------- #

# When you use a pattern that's a string, it's automatically wrapped
# into a call to regex():

# The regular call:
str_view(fruit, "nana")

# Is shorthand for
str_view(fruit, regex("nana"))

# You can use the other arguments of regex() to control details of the
# match:

bananas <- c("banana", "Banana", "BANANA")
str_view(bananas, "banana")
str_view(bananas, regex("banana", ignore_case = TRUE))

x <- "Line 1\nLine 2\nLine 3"
str_extract_all(x, "^Line")[[1]]
str_extract_all(x, regex("^Line", multiline = TRUE))

phone <- regex("
\\(? # optional opening parens
               (\\d{3}) # area code
               [)- ]? # optional closing parens, dash, or space
               (\\d{3}) # another three numbers
               [ -]? # optional space or dash
               (\\d{3}) # three more numbers
               ", comments = TRUE)

str_match("514-791-8141", phone)


## There are three other functions you can use instead of regex():

# fixed() atches exactly the specified sequence of bytes.
# It ignores all special regular expressions and operates at a very low
# level. This allows you to avoid complex escaping and can be
# much faster than regular expressions. The following microbe-
# nchmark shows that it's about 3x faster for a simple example:

# install.packages("microbenchmark")

library(microbenchmark)

microbenchmark::microbenchmark(
  fixed = str_detect(sentences, fixed("the")),
  regex = str_detect(sentences, "the"),
  times = 20
)

# Beware using fixed() with non-English data.
a1 <- "\u00e1"
a2 <- "a\u0301"
c(a1, a2)

str_detect(a1, fixed(a2))
str_detect(a1, coll(a2))

# coll() compares strings using standard collation rules. This is
# useful for doing case-insensitive matching.
# Note that coll() takes a locale parameter that controls which rules are used for
# comparing characters. Unfortunately different parts of the
# world use different rules!

# That means you also need to be aware of the difference
# when doing case-insensitive matches:
i <- c("I", "I", "i", "i")
i

str_subset(i, coll("i", ignore_case = TRUE))

str_subset(i,
          coll("i", ignore_case = TRUE, locale = "tr"))

# Our local info:
stringi::stri_locale_info()





# ----- OTHER USES OF REGULAR EXPRESSIONS ------------------------------------- #

# There are two useful functions in base R that also use regular
# expressions:

# apropos() searches all objects available from the global envi-
# ronment. This is useful if you can't quite remember the name of
# the function:

apropos("replace")

# dir() lists all the files in a directory.

head(dir(pattern = "\\.Rmd$"))




# ----- stringi ---------------------------------------------------------------- #

# stringr is built on top of the stringi package. stringr is useful when
# you're learning because it exposes a minimal set of functions, which
# have been carefully picked to handle the most common string
# manipulation functions. stringi, on the other hand, is designed to be
# comprehensive. It contains almost every function you might ever
# need: stringi has 234 functions to stringr's 42.
# If you find yourself struggling to do something in stringr, it's worth
# taking a look at stringi. The packages work very similarly, so you
# should be able to translate your stringr knowledge in a natural way.
# The main difference is the prefix: str_ versus stri_.

