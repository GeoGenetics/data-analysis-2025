## Q:
# What was the most recent day with 0 new cases recorded in the dataset?

arrange(covid_data, new_cases, desc(date))

# 2025-02-16


## Q:
# In which countries were the days with the 10 highest rates of new cases per million people

slice_max(covid_data, new_cases_per_million, n = 10)

# Wallis and Futuna; Falkland Islands; Saint Helena; Nauru;
# Saint Pierre and Miquelon; Tuvalu; Pitcairn; Saint Martin (French part)


## Q:
# Using the `covid_data_small` subset, create two new variables showing:
# - total number of cases per million people, calculated from `total_cases` and population
# - absolute difference between the newly calculated variable and `total_cases_per_million`

mutate(covid_data_small,
  total_cases_per_1M = total_cases / population * 1e6,
  tc_diff = abs(total_cases_per_1M - total_cases_per_million)
)

## Q:
# Using the `covid_data_small` subset with the two new variables from above
# - filter the resulting data to contain only days where the absolute difference exceeds 1
# - sort the resulting subset by descending absolute difference

# which country and day has the highest difference?
covid_data_small %>%
  mutate(
    total_cases_per_1M = total_cases / population * 1e6,
    tc_diff = abs(total_cases_per_1M - total_cases_per_million)
  ) %>%
  filter(tc_diff > 1) %>%
  arrange(desc(tc_diff))

# Cyprus, 2022-01-01; 51838 difference


## Q:
# For each continent and country:
# Filter to keep only days with the 100 highest number of new cases
# Compute the minimum, maximum and mean number new cases per 100,000 inhabitants
# return a table with the newly calculated summaries as the first three columns
# sort by average new case rate

# Which country had the highest average new case rates in in their 100 days with most cases?

covid_data %>%
  group_by(continent, country) %>%
  slice_max(new_cases, n = 100) %>%
  mutate(nc_100k = new_cases / population * 1e5) %>%
  summarise(
    nc_100k_min = min(nc_100k),
    nc_100k_max = max(nc_100k),
    nc_100k_mean = mean(nc_100k),
  ) %>%
  select(nc_100k_min:nc_100k_mean, everything()) %>%
  arrange(desc(nc_100k_mean))

# Brunei


## --------------------------------------------------------
## Larger Exercise

# Using the full `covid_data` dataset as starting point:

# calculate test positivity rate, averaged per month for each year and country,
# save the output to a new table

res <- covid_data %>%
  select(date, country, new_cases, new_tests) %>%
  separate(date, into = c("year", "month", "day")) %>%
  group_by(country, month, year) %>%
  summarise(
    cases_per_test = sum(new_cases) / sum(new_tests),
    .groups = "drop"
  ) %>%
  mutate(pos_rate = cases_per_test * 100)

# Examining the resulting table, answer the following questions:

# Which 5 months had the highest positivity rate in Denmark?
res %>%
  filter(country == "Denmark") %>%
  slice_max(pos_rate, n = 5)

# Feb, Mar, Apr, Jan, May 2022

# Which countries were included in the five months with
# the overall highest positivity rates?
# Is there anything else notable about the result?",

arrange(res, desc(pos_rate))
