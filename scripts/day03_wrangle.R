## --------------------------------------------------------
## Day 3 - Data wrangling

# In this tutorial we will explor data wrangling, or how to get your data
# into R and transform them for visualization and modeling.

# The workhorse for these tasks is the package
# dplyr (https://dplyr.tidyverse.org/),
# part of the tidyverse(https://www.tidyverse.org/) suite.

# In the interactive tutorial part, we will cover

# * Selecting variables with `select()`
# * Arranging observations with `arrange()`
# * Filtering observations with `filter()`
# * Creating new variables with `mutate()`
# * Chaining operations with the pipe `%>%`
# * Grouping and summarising data with `group_by()` and `summarise()`
# * Reshaping data (tidy data)
# * Combining data


## --------------------------------------------------------
## libraries

library(tidyverse)


## --------------------------------------------------------
## dataset

# we will use the complete COVID-19 dataset from Our World in Data
# https://catalog.ourworldindata.org/garden/covid/latest/compact/compact.csv


covid_data <- read_csv("https://catalog.ourworldindata.org/garden/covid/latest/compact/compact.csv")


# First, let's have another look at the data
covid_data

# This COVID19 epidemiological dataset contains 
# 479,146 observations (rows) of
# 61 variables (columns)


## --------------------------------------------------------
## Select variables

# To pick variables of this data, we can use the `select()` function

# by variable name
select(covid_data, country)
select(covid_data, total_cases, country)

# by variable column index
select(covid_data, 1, 5)

# by variable column index and name
select(covid_data, 1, country)


## Helper functions

# A range of consecutive columns can be selected by using the `:` operator
# with the first and last variable to be included.

# Multiple ranges can also be specified this way,
# and both variable names and column indexes can be used.

# by variable name
select(covid_data, new_cases:total_cases_per_million)
select(covid_data, icu_patients:hosp_patients, total_tests:new_tests)

# by variable column index
select(covid_data, 6:11)


# Other useful selection helpers include:

# variable name pattern matching (# e.g. `starts_with()` or `contains()`),
# functions for variable names stored in strings (`all_of()` or `any_of()`)
# convenience functions for useful ranges (e.g. `everything()` or `last_col()`)

# pattern matching
select(covid_data, starts_with("new"))
select(covid_data, ends_with("rate"))
select(covid_data, contains("case"))

# all columns helper
select(covid_data, everything())
select(covid_data, country, everything()) ## `everything()` selects all remaining columns


## Arrange observations

# We can sort the rows of our data using the `arrange()` function.
# The default sorting order is from low to high, and can be reversed
# by using `desc()`.

# If more than one variables are provided, `arrange()` will sort
# by all of them in sequential order.

# sorting
arrange(covid_data, new_cases)
arrange(covid_data, desc(new_cases))
arrange(covid_data, desc(date), desc(new_cases))

## Q:
# What was the most recent day with 0 new cases recorded in the dataset?


## --------------------------------------------------------
## Filter observations

## Basic filters

# The `filter()` function allows to create subsets of the data
# by picking rows based on the values of one or more variables.

# We can use basic logical operators such as `==`, `>` or `%in%` t
# to define filtering criteria.

# filter by single variable
filter(covid_data, country == "Denmark")
filter(covid_data, continent != "Europe")
filter(covid_data, total_cases < 100)
filter(covid_data, new_cases > 1000)
filter(covid_data, date %in% c(ymd(20200301), ymd(20200302)))


# As with other wrangling functions, we can provide multiple arguments
# to the `filter()` function to subset our data based on multiple variables.
# By default, `filter()` combines these arguments using logical "and",
# so that only rows fulfilling all arguments are returned.

# filter by multiple variables
filter(covid_data, country == "Denmark", date == "2020-03-01")
filter(covid_data, country == "Denmark" | date == "2020-03-01")


## Useful helper functions

# As with the variable selection functions,
# `dplyr` provides also a number of helper functions
# for some commonly used functionality when subsetting rows of a table:

# `slice()` picks rows based on their row number
# `distinct()` finds all unique combinations of variable values
# `slice_min()` and `slice_max()` functions return rows with
# the N lowest or highest values of a variable.


# select observations by row index
slice(covid_data, 10)
slice(covid_data, 1:10)

# select rows with distinct observations for selected variables
distinct(covid_data, country)
distinct(covid_data, country, continent)

# select rows with top N values of variable
slice_max(covid_data, new_cases, n = 10)
slice_min(covid_data, date, n = 10)

## Q:
# In which countries were the days with the 10 highest rates of new cases per million people 


## --------------------------------------------------------
## Create variables

# The `mutate()` function is used to create new variables
# as new columns add the end of the existing dataset.

# To help illustrate, we first create a smaller subset of the data
# picking specific variables and filtering observations for a specific date

covid_data_small <- covid_data %>%
  select(date, country, total_cases, population, total_cases_per_million) %>%
  filter(date == "2022-01-01")


# A common use case for `mutate()` is to create new variables as functions
# of some existing variables. In the example below, we calculate
# total number of cases per 1,000 people and add a new variable with the result
# to the table.

# We can reuse newly created variables within the same `mutate()` function call
# to create more variables.
# If we only want to keep the newly created variables, we can use `transmute()`

mutate(covid_data_small,
  total_cases_1k = total_cases / 1000
)
mutate(covid_data_small,
  total_cases_1k = total_cases / 1000,
  total_cases_10k = total_cases_1k * 10
)
transmute(covid_data_small,
  total_cases_1k = total_cases / 1000,
  total_cases_10k = total_cases_1k * 10
)

## Q:
# Using the `covid_data_small` subset, create two new variables showing:
# - total number of cases per million people, calculated from `total_cases` and population 
# - absolute difference between the newly calculated variable and `total_cases_per_million` 



## --------------------------------------------------------
## The pipe

# The pipe operator `%>%` (or `|>` in the newer and future versions of R)
# is one of the most powerful tools in the `tidyverse`.
# Using the pipe allows us to chain together multiple functions
# to perform a sequence of operations on a dataset.

# The resulting code is much easier to read and understand,
# emphasizing the actions to be carried out rather than
# the objects they are performed on.

# In the following example, we:

# filter our data for country "Sweden"
# arrange it by descending numnber of new cases
# create a new variable showing percent new cases of total populations
# select relevant variables for final table

covid_data %>%
  filter(country == "Sweden") %>%
  arrange(desc(new_cases)) %>%
  mutate(new_cases_percent_pop = new_cases / population * 100) %>%
  select(country, date, new_cases, new_cases_percent_pop)


## Q:
# Using the `covid_data_small` subset with the two new variables from above
# - filter the resulting data to contain only days where the absolute difference exceeds 1  
# - sort the resulting subset by descending absolute difference

# which country and day has the highest difference?


## --------------------------------------------------------
## Group and summarise

# Many tasks in exploratory data analysis follow a
# ***split-apply-combine***
# strategy. We

# ***split*** a larger dataset into smaller chunks,
# ***apply*** some summary operations on each chunk independently,
# ***combine*** each chunk back together into one result table.

# In `dplyr` this strategy is easy to implement using the
# `group_by()` and `summarise()` functions.

# simple summarise
covid_data %>%
  summarise(max_new_cases = max(new_cases, na.rm = TRUE))

# group and summarise
covid_data %>%
  group_by(country) %>%
  summarise(max_new_cases = max(new_cases, na.rm = TRUE))

covid_data %>%
  group_by(country) %>%
  summarise(
    max_new_cases = max(new_cases, na.rm = TRUE),
    days_without_new_case_data = sum(is.na(new_cases))
  )

# Counting the number of distinct observations for one or more variables
# is a common analysis task, with its own convenience function `count()`

covid_data %>%
  count(continent, country)


## Q:
# For each continent and country:
# Filter to keep only days with the 100 highest number of new cases
# Compute the minimum, maximum and mean number new cases per 100,000 inhabitants
# return a table with the newly calculated summaries as the first three columns
# sort by average new case rate

# Which country had the highest average new case rates in in their 100 days with most cases?


## --------------------------------------------------------
## Reshaping

## Tidy data

# A central concept in working with data in the `tidyverse` is **tidy data**.
# A tidy dataset generally follows three rules:

# 1. Each variable has its own column
# 2. Each observation has its own row
# 3. Each value has its own cell

# We will use a table with United Nations current and future population projections
# per country for this part of the tutorial.

un_pop <- read_csv("https://github.com/GeoGenetics/data-analysis-2025/raw/refs/heads/main/data/un_pop.csv")
un_pop

## Q:
# What makes this dataset "untidy"?

## Pivot tables longer or wider

# The two main functions for reshaping tables in the `tidyverse` are
# `pivot_longer()` and `pivot_wider()`.

# Our example table encodes a single variable (the population for a country)
# across multiple columns with names containing information
# of another variable (age class).

# To reshape this table into a tidy format, we have to convert it from the current
# ***wide*** format into ***long*** format.

# This is accomplished by using the `pivot_longer()` function,
# with the variable names to be reshaped as argument.
# We can use the additional arguments `names_to=` and `values_to=`
# to specify names for the resulting columns.

un_pop %>%
  pivot_longer(pop_65_plus:pop_12_24,
    names_to = "age_group",
    values_to = "population"
  )


# To reshape a table into ***wide*** format, we can use the
# `pivot_wider()` function.
# The arguments for this function are the names of the two variables
# that contain the new variable names (`names_from=`) and values (`values_from=`).

# The following code produces a wide format table with one line per country,
# and a separate variable for each year.

un_pop %>%
  select(country, year, pop_65_plus) %>%
  pivot_wider(
    names_from = "year",
    values_from = "pop_65_plus"
  )

## Separate or unite values

# Our example table contains multiple values of a variable
# (lower and upper bound of age class)
# encoded in the variable names.

# We can extract those values and assign them to new separate columns using the
# `separate()` function.

un_pop %>%
  select(country, year, pop_6_11, pop_12_24, pop_25_64) %>%
  pivot_longer(-country:-year) %>%
  mutate(name = gsub("pop_", "", name)) %>%
  separate(name, into = c("age_low", "age_high"))


## --------------------------------------------------------
## Exercise 

# Using the full `covid_data` dataset as starting point:

# calculate test positivity rate, averaged per month for each year and country,
# save the output to a new table

# Examining the resulting table, answer the following questions:

# Which month had the highest positivity rate in Denmark? 

# Which countries were included in the five months with 
# the overall highest positivity rates?
# Is there anything else notable about the result?",