rm(list = ls())

# R Markdown provides a unified authoring framework for data sci-
# ence, combining your code, its results, and your prose commentary.
# R Markdown documents are fully reproducible and support dozens
# of output formats, like PDFs, Word files, slideshows, and more.

# R Markdown files are designed to be used in three ways:

  # For communicating to decision makers, who want to focus on
  # the conclusions, not the code behind the analysis.

  # For collaborating with other data scientists (including future
  # you!), who are interested in both your conclusions, and how
  # you reached them (i.e., the code).

  # As an environment in which to do data science, as a modern day
  # lab notebook where you can capture not only what you did, but
  # also what you were thinking.

  # As an environment in which to do data science, as a modern day
  # lab notebook where you can capture not only what you did, but
  # also what you were thinking.

# R Markdown integrates a number of R packages and external tools.
# This means that help is, by and large, not available through ?.

# Instead, as you work through this chapter, and use R Markdown in
# the future, keep these resources close to hand:
  # R Markdown Cheat Sheet: available in the RStudio IDE under
  # Help -> Cheatsheets -> R Markdown Cheat Sheet

# RStudio already has the rmarkdown package installed



# ---- R MARKDOWN BASICS -------------------------------------------------------- #

# This is an R Markdown file, a plain-text file that has the extension .Rmd:

# When you open an .Rmd, you get a notebook interface where code
# and output are interleaved. You can run each code chunk by clicking
# the Run icon (it looks like a play button at the top of the chunk), or
# by pressing Cmd/Ctrl-Shift-Enter. RStudio executes the code and
# displays the results inline with the code:

# To produce a complete report containing all text, code, and results,
# click "Knit" or press Cmd/Ctrl-Shift-K. You can also do this pro-
# grammatically with rmarkdown::render("1-example.Rmd"). This
# will display the report in the viewer pane, and create a self-contained
# HTML file that you can share with others.

# knitting to pdf:
# install.packages("tinytex")
tinytex::install_tinytex()







# ---- CHUNK OPTIONS ------------------------------------------------------------- #

# Shortcut for code chunks: Ctrl + Alt + I

# Chunk output can be customized with options, arguments supplied
# to the chunk header. knitr provides almost 60 options that you can
# use to customize your code chunks. Here we'll cover the most
# important chunk options that you'll use frequently. You can see the
# full list at http://yihui.name/knitr/options/







# ---- TABLE --------------------------------------------------------------------- #

# By default, R Markdown prints data frames and matrices as you'd see
# them in the console:

mtcars[1:5, 1:10]

# If you prefer that data be displayed with additional formatting you
# can use the knitr::kable function. The following code generates Table 21-1:

knitr::kable(
  mtcars[1:5, ],
  caption = "A knitr table")

# further customization options:

?knitr::kable









# ---- GLOBAL OPTIONS -------------------------------------------------------------- #

# As you work more with knitr, you will discover that some of the
# default chunk options don't fit your needs, and want to change
# them. You can do that by calling knitr::opts_chunk$set() in a
# code chunk. For example, when writing books and tutorials I set:

knitr::opts_chunk$set(
  comment = "#>",
  collapse = TRUE)

# This uses my preferred comment formatting, and ensures that the
# code and output are kept closely entwined. On the other hand, if
# you were preparing a report, you might set:

knitr::opts_chunk$set(
  echo = FALSE)

# That will hide the code by default, only showing the chunks you
# deliberately choose to show (with echo = TRUE). You might con-
# sider setting message = FALSE and warning = FALSE, but that
# would make it harder to debug problems because you wouldn't see
# any messages in the final document.

?knitr::opts_chunk
str(knitr::opts_chunk$get())

knitr::opts_chunk$set(
  comment = "#",
  collapse = TRUE)





# ---- YAML HEADER -------------------------------------------------------------------- #

# You can control many other "whole document" settings by tweaking
# the parameters of the YAML header. You might wonder what YAML
# stands for: it's "yet another markup language," which is designed for
# representing hierarchical data in a way that's easy for humans to
# read and write. R Markdown uses it to control many details of the
# output. Here we'll discuss two: document parameters and bibliographies.







# ---- LEARNING MORE ------------------------------------------------------------------- #

# R Markdown is still relatively young, and is still growing rapidly.
# The best place to stay on top of innovations is the official R Mark-
# down website: http://rmarkdown.rstudio.com.

# There are two important topics that we haven't covered here: collab-
# oration, and the details of accurately communicating your ideas to
# other humans. Collaboration is a vital part of modern data science,
# and you can make your life much easier by using version control
# tools, like Git and GitHub. We recommend two free resources that
# will teach you about Git:

  # "Happy Git with R": a user-friendly introduction to Git and Git-
  # Hub from R users, by Jenny Bryan. The book is freely available online.

  # The "Git and GitHub" chapter of R Packages, by Hadley. You can
  # also read it for free online: http://r-pkgs.had.co.nz/git.html.

