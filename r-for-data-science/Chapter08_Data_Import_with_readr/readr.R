rm(list=ls())

# readr is part of the tidyverse
library(tidyverse)

## CSV FILES
# read_csv() reads comma-delimited files, read_csv2() reads
# semicolon-separated files (common in countries where , is used
# as the decimal place), read_tsv() reads tab-delimited files, and
# read_delim() reads in files with any delimiter.

## FIXED WIDTH FILES
# read_fwf() reads fixed-width files. You can specify fields either
# by their widths with fwf_widths() or their position with
# fwf_positions(). read_table() reads a common variation of
# fixed-width files where columns are separated by white space.

## WEB FILES
# read_log() reads Apache style log files. (But also check out
# webreadr, which is built on top of read_log() and provides
# many more helpful tools.)

# The first argument to read_csv() is the most important; it's the path
# to the file to read:

heights <- read_csv("C:\\Users\\Clem\\Documents\\R_for_Data_Science\\Chapter08_Data_Import_with_readr\\heights.csv")
heights

# When you run read_csv() it prints out a column specification that
# gives the name and type of each column. That's an important part of
# readr, which we'll come back to in "Parsing a File" on page 137

# You can also supply an inline CSV file. This is useful for experi-
# menting with readr and for creating reproducible examples to share
# with others:

read_csv("a, b, c
         1, 2, 3
         4, 5, 6")

# In both cases read_csv() uses the first line of the data for the col-
# umn names, which is a very common convention. There are two
# cases where you might want to tweak this behavior

# Sometimes there are a few lines of metadata at the top of
# the file. You can use skip = n to skip the first n lines; or use
# comment = "#" to drop all lines that start with (e.g.) #

read_csv("The first line of metadata
The second line of metadata
x,y,z
1,2,3", skip = 2)

read_csv("# A comment I want to skip
         x, y, z
         1, 2, 3", comment = "#")

# The data might not have column names. You can use col_names
# = FALSE to tell read_csv() not to treat the first row as headings,
# and instead label them sequentially from X1 to Xn:

read_csv("1,2,3\n4, 5, 6", col_names = FALSE)

# Alternatively you can pass col_names a character vector, which
# will be used as the column names:

read_csv("1,2,3\n4, 5, 6", col_names = c("A", "B", "C"))

# Another option that commonly needs tweaking is na. This specifies
# the value (or values) that are used to represent missing values in
# your file:

read_csv("a,b,c\n1,2,.", na =".")

####### WHY USE readr instead of BASE R? #########

# around 10x faster
# they produce tibbles
# they are better reproducible




# -------------------------- PARSING A VECTOR ------------------------------- #

# parse_*() functions take a character vector and return a more specialized
# vector like a logical, integer, or date

str(parse_logical(c("TRUE", "FALSE", "NA")))
str(parse_integer(c("1", "2", "3")))
str(parse_date(c("2010-01-01", "1979-10-14")))

# Handling NA with parse_*

parse_integer(c("1", "231", ".", "456"), na = ".")

# If parsing fails, we get a warning

x <- parse_integer(c("123", "345", "abc", "123.45"))
# failures will be missing in the output
x

# If there are many parsing failures, you'll need to use problems() to
# get the complete set. This returns a tibble, which you can then
# manipulate with dplyr:

problems(x)

# Using parsers is mostly a matter of understanding what's available
# and how they deal with different types of input. There are eight par-
# ticularly important parsers:
    # 1. parse_logical() and parse_integer()

    # 2. parse_double() is a strict numeric parser, and parse_number()
    # is a flexible numeric parser. These are more complicated than
    # you might expect because different parts of the world write
    # numbers in different ways.

    # 3. parse_character() seems so simple that it shouldn't be neces-
    # sary. But one complication makes it quite important: character
    # encodings.

    # 4. parse_factor() creates factors, the data structure that R uses to
    # represent categorical variables with fixed and known values.

    # 5. parse_datetime(), parse_date(), and parse_time() allow
    # you to parse various date and time specifications. These are the
    # most complicated because there are so many different ways of
    # writing dates

###### PARSING NUMBERS #############

# Problem 1: People write numbers different in different parts of the world
# readr's default locale is US-centric, because generally R is US-centric

parse_double("1.23")
parse_double("1,23", locale = locale(decimal_mark = ","))

# Problem 2: non-numeric characters before and after the number
# solution: parse_number()

parse_number("$100")
parse_number("20%")
parse_number("It cost $123.54")

# Problem 3: Grouping marks - like for 1,000
# solution: argument grouping_mark

parse_number(
  "123.456.789",
  locale = locale(grouping_mark = "."))

parse_number(
  "123'456'789",
  locale = locale(grouping_mark = "'"))



###### PARSING STRINGS #############

# In R, we can get at the underlying representation of a string using charToRaw()
# This returns hexadecimal numbers, which are encoded (ASCII)
# ASCII is great for American Characters, but things get more complicated if we
# deal with other languages

charToRaw("Hadley")

# UTF-8 is nowadays very common and supports almost all characters and emojis
# UTF-8 is the readr standard encoding

# But sometimes even UTF-8 fails:

x1 <- "El Ni\xf1o was particularly bad this year"
x2 <- "\x82\xb1\x82\xf1\x82\xc9\x82\xbf\x82\xcd"

parse_character(x1, locale = locale(encoding = "Latin1"))
parse_character(x2, locale = locale(encoding = "Shift-JIS"))

# How do you find the correct encoding? If you're lucky, it'll be
# included somewhere in the data documentation. Unfortunately,
# that's rarely the case, so readr provides guess_encoding() to help
# you figure it out. It's not foolproof, though.

guess_encoding(charToRaw(x1))
guess_encoding(charToRaw(x2))




###### PARSING FACTORS #############

# R uses factors to represent categorical variables that have a known
# set of possible values. Give parse_factor() a vector of known
# levels to generate a warning whenever an unexpected value is
# present:

fruit <- c("apple", "banana")
parse_factor(c("apple", "banana", "banana"), levels = fruit)
parse_factor(c("apple", "banana", "bananana"), levels = fruit)






###### PARSING DATES, DATE-TIMES AND TIMES #############

# date means the number of days since 1970-01-01
# date-time means the number of seconds since midnight 1970-01-01
# time means the number of seconds since midnight

# parse_datetime() expects an ISO8601 date-time. ISO8601 is
# an international standard in which the components of a date are
# organized from biggest to smallest: year, month, day, hour,
# minute, second:

# If the time is omitted, it will be set to midnight

parse_datetime("2010-10-01T2010")
parse_datetime("20101010")

# parse_date() expects a four-digit year, a - or /, the month, a -
# or /, then the day:

parse_date("2010-10-01")

# parse_time() expects the hour, :, minutes, optionally : and
# seconds, and an optional a.m./p.m. specifier:

library(hms)
parse_time("01:10 am")
parse_time("20:10:01")

# Base R doesn't have a great built-in class for time data, so we use
# the one provided in the hms package

# If these defaults don't work for your data you can supply your own
# date-time format, built up of the following pieces:

###### DATE AND TIME FORMATS
# Year
  # %Y (4 digits).
  # %y (2 digits; 00-69 => 2000-2069, 70-99 => 1970-1999).

# Day
  # %d (2 digits).
  # %e (optional leading space).

# Time
  # %H (0-23 hour format).
  # %I (0-12, must be used with %p).
  # %p (a.m./p.m. indicator).
  # %M (minutes).
  # %S (integer seconds).
  # %OS (real seconds).
  # %Z (time zone [a name, e.g., America/Chicago]). Note: beware
  # of abbreviations. If you're American, note that "EST" is a Cana-
  # dian time zone that does not have daylight saving time. It is
  # Eastern Standard Time! We'll come back to this in "Time
  # Zones" on page 254.
  # %z (as offset from UTC, e.g., +0800).

# Nondigits
  # %. (skips one nondigit character).
  # %* (skips any number of nondigits).

# EXAMPLES:

parse_date("01/02/15", "%m/%d/%y")
parse_date("01/02/15", "%d/%m/%y")
parse_date("01/02/15", "%y/%m/%d")

# If you're using %b or %B with non-English month names, you'll need
# to set the lang argument to locale()

# See the list of built-in languages in date_names_langs(), or if your
# language is not already included, create your own with date_names()

date_names_langs()

parse_date("1 janvier 2015", "%d %B %Y", locale = locale("fr"))
parse_date("1. Januar 2018", "%d. %B %Y", locale = locale("de"))



# ------------ PARSING A FILE ------------------------------------ #

###### STRATEGY ##########

# readr uses a heuristic to figure out the type of each column: it reads
# the first 1000 rows and uses some (moderately conservative) heuris-
# tics to figure out the type of each column. You can emulate this process
# with a character vector using guess_parser(), which returns
# readr's best guess, and parse_guess(), which uses that guess to
# parse the column:

guess_parser("2010-01-01")
guess_parser("15:01")
guess_parser(c("TRUE", "FALSE"))
guess_parser(c("1", "2", "3"))
guess_parser("123,456,789")

str(parse_guess("2010-01-01"))

###### PROBLEMS ##########

# These defaults don't always work for larger files. There are two basic
# problems:
  # 1. The first thousand rows might be a special case, and readr
  # guesses a type that is not sufficiently general. For example, you
  # might have a column of doubles that only contains integers in
  # the first 1000 rows.

  # 2. The column might contain a lot of missing values. If the first
  # 1000 rows contain only NAs, readr will guess that it's a character
  # vector, whereas you probably want to parse it as something
  # more specific.

# readr contains a challenging CSV that illustrates both of these problems:

challenge <- read_csv(readr_example("challenge.csv"))

# explore problems:
problems(challenge)

# the x column causes problems!
# there are trailing characters after the integer value

# To fix the call, start by copying and pasting the column specification
# into your original call:

challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_integer(),
    y = col_character()
  )
)

# Then you can tweak the type of the x column:

challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_character()
  )
)

# That fixes the first problem, but if we look at the last few rows, you'll
# see that they're dates stored in a character vector:

challenge <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(
    x = col_double(),
    y = col_date()
  )
)

challenge
tail(challenge)


##### OTHER STRATEGIES #########

# There are a few other general strategies to help you parse files:

# In the previous example, we just got unlucky: if we look at just
# one more row than the default, we can correctly parse in one
# shot:

challenge2 <- read_csv(
  readr_example("challenge.csv"),
  guess_max = 1001
)

tail(challenge2)

# Sometimes it's easier to diagnose problems if you just read in all
# the columns as character vectors:

challenge2 <- read_csv(
  readr_example("challenge.csv"),
  col_types = cols(.default = col_character())
)

challenge2

# This is particularly useful in conjunction with type_convert(),
# which applies the parsing heuristics to the character columns in
# a data frame:

df <- tribble(
  ~x, ~y,
  "1", "1.21",
  "2", "2.32",
  "3", "4.56"
)

df
type_convert(df)


# If you're reading a very large file, you might want to set n_max to
# a smallish number like 10,000 or 100,000. That will accelerate
# your iterations while you eliminate common problems.

# If you're having major parsing problems, sometimes it's easier to
# just read into a character vector of lines with read_lines(), or
# even a character vector of length 1 with read_file(). Then you
# can use the string parsing skills you'll learn later to parse more
# exotic formats.





# ------------------- WRITING TO A FILE --------------------------------- #

# readr also comes with two useful functions for writing data back to
# disk: write_csv() and write_tsv(). Both functions increase the
# chances of the output file being read back in correctly by:
    # Always encoding strings in UTF-8
    # Saving dates and date-times in ISO8601 format so they are
    # easily parsed elsewhere.

# If you want to export a CSV file to Excel, use write_excel_csv()-
# this writes a special character (a "byte order mark") at the start of
# the file, which tells Excel that you're using the UTF-8 encoding

# The most important arguments are x (the data frame to save) and
# path (the location to save it). You can also specify how missing values
# are written with na, and if you want to append to an existing file:

write_csv(challenge, "challenge.csv")

# Note that the type information is lost when you save to CSV

# This makes CSVs a little unreliable for caching interim results-you
# need to re-create the column specification every time you load in.
# There are two alternatives:

# write_rds() and read_rds() are uniform wrappers around the
# base functions readRDS() and saveRDS(). These store data in
# R's custom binary format called RDS

write_rds(challenge, "challenge.rds")
read_rds("challenge.rds")

# The feather package implements a fast binary file format that
# can be shared across programming languages:

install.packages('feather', repo='http://nbcgib.uesc.br/mirrors/cran/')
library(feather)

write_feather(challenge, "challenge.feather")
read_feather("challenge.feather")


###### OTHER TYPES OF DATA ############

# To get other types of data into R, we recommend starting with the
# tidyverse packages listed next. They're certainly not perfect, but they
# are a good place to start. For rectangular data:

# haven reads SPSS, Stata, and SAS files.
install.packages("haven")
# readxl reads Excel files (both .xls and .xlsx).
install.packages("readxl")
# DBI, along with a database-specific backend (e.g., RMySQL,
# RSQLite, RPostgreSQL, etc.) allows you to run SQL queries
# against a database and return a data frame.
install.packages("DBI")
