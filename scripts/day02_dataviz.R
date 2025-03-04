## --------------------------------------------------------
## Day 2 - A grammar for graphics

# In this tutorial we will explore how to build visualizations
# using the ggpplot2 package, part of the tidyverse (https://www.tidyverse.org/)

# We will cover the following topics

# * ggplot2 basics
# * Aesthetics
# * Geometric shapes
# * Scales
# * Themes

# * Facets


## --------------------------------------------------------
## libraries

# here we load the libraries required for the analyses

library(tidyverse)
library(viridis)
library(scales)


## --------------------------------------------------------
## dataset

# we will use a subset of the complete COVID-19 dataset from Our World in Data
# https://catalog.ourworldindata.org/garden/covid/latest/compact/compact.csv

covid_data_subset <- read_csv("https://github.com/GeoGenetics/data-analysis-2025/raw/refs/heads/main/data/owd_covid_subset.csv")


## --------------------------------------------------------
## ggplot2 basics

# the most basic ggplot2 visualizations are built
# using the following minimal syntax:

# ggplot(data=<DATA>) +
#   <GEOM_FUNCTION>(mapping = aes(<MAPPINGS>))

# Try to use this syntax to create simple scatter plots
# comparing two variables in the dataset

# total vaccinations over time
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = total_vaccinations
    ))

# rate of people fully vaccinated per people vaccinated
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = people_vaccinated_per_hundred,
        y = people_fully_vaccinated_per_hundred
    ))


## --------------------------------------------------------
## Aesthetics

## Mapping variables to aesthetics

# Aesthetics are visual properties of the plot objects, onto which the
# variables in our dataset can be mapped.
# In the simple scatter plot example above, we mapped two variables
# `date` and `total_vaccinations` onto two different aesthetics:
# the positions of the points alond the X and Y axis

# We can visualize additional variables in the same plot by
# mapping them onto other properties of the points, such as
# shape, size or color

# map color to daily vaccinations (`new_vaccinations`)
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = total_vaccinations,
        color = new_vaccinations
    ))

# map aesthetics `size` and `transparency` to daily vaccinations
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = total_vaccinations,
        size = new_vaccinations,
        alpha = new_vaccinations
    ))

# *Mapping* an aesthetic is different from *setting* an aesthetic,
# which is done outside of the `aes()` mapping function.

## set aesthetic `color` to `blue`
ggplot(covid_data_subset) +
    geom_point(
        mapping = aes(
            x = date,
            y = total_vaccinations
        ),
        color = "blue"
    )

## Q:
# The following code highlights a common pitfall of aesthetic mapping.
# Why do all countries have the same color?

ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = total_vaccinations,
        color = "country"
    ))

## try experimenting with other variables and aestehtic mappings 


## --------------------------------------------------------
## Geometric shapes

## Simple point geom

# In ggplot2 language, a *geom* refers to the geometrical objects
# that are used to represent the data in the plot.
# We have already used `geom_point()` to use points to visualise the data

ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = total_vaccinations
    ))

# Points have a number of different aesthetics that we can map variables to.
# The following code shows examples setting some of those.

# Note that the `tibble()` function in the `data` argument of the `ggplot2()` call
# is used here to create the table (a `tibble` in `tidyverse` terminology)
# with plot data on the fly.

## geom_point aesthetics
ggplot(tibble(x = factor(0:25), y = 1)) +
    geom_point(
        mapping = aes(
            x = x,
            y = y
        ),
        shape = 0:25,
        color = 1:26,
        fill = "grey",
        stroke = 1,
        size = 4
    )


## Other geoms

# Lines are another frequently used type of geom.
# Here we use `geom_segment()` to plot some of the available linetype aesthetics

ggplot(data = tibble(x = 0:5, xend = 0:5, y = 0, yend = 10)) +
    geom_segment(
        mapping = aes(
            x = x,
            xend = xend,
            y = y,
            yend = yend
        ),
        size = 3,
        linetype = 1:6
    )

# We can use lines to plot vaccination progress over time.

## geom_path
ggplot(covid_data_subset) +
    geom_path(mapping = aes(
        x = date,
        y = total_vaccinations
    ))

## geom_line
ggplot(covid_data_subset) +
    geom_line(mapping = aes(
        x = date,
        y = total_vaccinations
    ))

## Q:
# Why do we get different plot results for `geom_path()` and `geom_line()`?


## Positional adjustments

# An example of positional adjustments is to use `position_jitter()`
# to avoid overplotting when many data points are shown

# add random jitter to point positions
ggplot(covid_data_subset) +
    geom_point(
        mapping = aes(
            x = date,
            y = total_vaccinations
        ),
        size = 1,
        position = position_jitter(
            height = 5e7,
            width = 0.2
        ),
        alpha = 0.5
    )

## Different data set for geoms

# Each geom has a `data=` argument which allows it to use its own dataset.

# We create a table `covid_data_subset_last` containing only the
# last vaccination day for each country as an example to plot
# a point geom with a different shape on the vaccination progress plot

covid_data_subset_last <- covid_data_subset %>%
    filter(!is.na(total_vaccinations)) %>%
    group_by(country) %>%
    slice_max(date, n = 1)
covid_data_subset_last

## plot last recorded day of total vaccinations with a different, larger shape
ggplot(covid_data_subset) +
    geom_point(
        mapping = aes(
            x = date,
            y = total_vaccinations
        ),
        size = 1
    ) +
    geom_point(
        mapping = aes(
            x = date,
            y = total_vaccinations
        ),
        size = 4,
        shape = 17,
        data = covid_data_subset_last
    )

## try experimenting visualizing variables in the dataset with other geoms


## --------------------------------------------------------
## Scales

## color scales

# Scales in ggplot2 perform a fundamental role in building a data visualization,
# determining how the variables are mapped to aesthetics.
# Color scales are among the most typical use cases.
# As with other plot characteristics, ggplot2 will choose
# a default color scale depending on whether the variable mapped
# to the aesthetic is discrete or continuous.

# The following examples explicitly specify specfic continuous color scales

# two color gradient
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        color = new_vaccinations
    )) +
    scale_color_gradient(low = "blue", high = "red")

# multicolor gradient
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        color = new_vaccinations
    )) +
    scale_color_gradientn(colors = rainbow(100))


# For discrete variables it is often useful to manaully specify the scale
# using a named vector with the desired values for each observation

colors <- c("burlywood", "steelblue", "gold", "tomato", "mediumseagreen")
names(colors) <- countries

ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        color = country
    )) +
    scale_color_manual(values = colors)


## Specialized color palettes

# A variety of pre-built specialized color schemes are avaible as R packages.
# Some of the most useful ones include:

# * ColorBrewer (https://colorbrewer2.org)
# * viridis (https://cran.r-project.org/web/packages/viridis/vignettes/intro-to-viridis.html).

# Both of them have versions for discrete and continous variables.

# Discrete ColorBrewer
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        color = country
    )) +
    scale_color_brewer(palette = "Set1")

# ColorBrewer palettes for continous variables
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        color = new_vaccinations
    )) +
    scale_color_distiller(palette = "Spectral")

## viridis
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        color = new_vaccinations
    )) +
    scale_color_viridis()

## discrete versions of viridis
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        color = country
    )) +
    scale_color_viridis_d()


## Adjusting scales

# All scales can be further customized.
# In this example we transform the Y axis onto a logarithmic scale

## set up a values for a discrete scale of shapes
shapes <- 21:25
names(shapes) <- countries

ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        shape = country,
        color = new_vaccinations
    )) +
    scale_color_viridis() +
    scale_shape_manual(values = shapes) +
    scale_y_continuous(trans = "log10")


# We can also limit the range of data values included in the scale
# using the `limits =` argument.

ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = total_vaccinations,
        shape = country,
        color = new_vaccinations
    )) +
    scale_color_viridis() +
    scale_shape_manual(values = shapes) +
    scale_y_continuous(limits = c(0, 1e8))

ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = total_vaccinations,
        shape = country,
        color = new_vaccinations
    )) +
    scale_color_viridis() +
    scale_shape_manual(values = shapes) +
    coord_cartesian(ylim = c(0, 1e8))

## Q:
# Do we get the same result when zooming in using `coord_cartesian()`?
# Why / why not?


## --------------------------------------------------------
## Themes and polishing plots

# The previous sections of this tutorial have all dealt with
# the variety of ways ggplot2 can be used to visually represent
# and summarise the data points in our dataset.
# To provide further control on non data-related properties of the plot such as
# font, background color etc, ggplot2 has a *theme* system.

# As always, if no theme is specified ggplot2 will
# automatically use a default (`theme_gray()`).
# Other built in themes are available, and individual theme elements
# are highly customizable to polish visualizations for publications.


## Examples of pre-built themes

# gray theme
ggplot(covid_data_subset) +
    geom_hline(
        yintercept = c(0, 100),
        size = 0.25
    ) +
    geom_point(
        mapping = aes(
            x = date,
            y = people_vaccinated_per_hundred,
            color = country,
            shape = country
        ),
        size = 1
    ) +
    scale_color_manual(
        name = "Country",
        values = colors
    ) +
    scale_shape_manual(
        name = "Country",
        values = shapes
    ) +
    theme_gray()

# black & white theme
ggplot(covid_data_subset) +
    geom_hline(
        yintercept = c(0, 100),
        size = 0.25
    ) +
    geom_point(
        mapping = aes(
            x = date,
            y = people_vaccinated_per_hundred,
            color = country,
            shape = country
        ),
        size = 1
    ) +
    scale_color_manual(
        name = "Country",
        values = colors
    ) +
    scale_shape_manual(
        name = "Country",
        values = shapes
    ) +
    theme_bw()

# classic theme
ggplot(covid_data_subset) +
    geom_hline(
        yintercept = c(0, 100),
        size = 0.25
    ) +
    geom_point(
        mapping = aes(
            x = date,
            y = people_vaccinated_per_hundred,
            color = country,
            shape = country
        ),
        size = 1
    ) +
    scale_color_manual(
        name = "Country",
        values = colors
    ) +
    scale_shape_manual(
        name = "Country",
        values = shapes
    ) +
    theme_classic()


## Customize themes

# We can take one of the built-in themes as starting point for customization. 
# In the first example below we removed the grid lines on the Y axis.

ggplot(covid_data_subset) +
    geom_hline(
        yintercept = c(0, 100),
        size = 0.25
    ) +
    geom_point(
        mapping = aes(
            x = date,
            y = people_vaccinated_per_hundred,
            color = country,
            shape = country
        ),
        size = 1
    ) +
    scale_color_manual(
        name = "Country",
        values = colors
    ) +
    scale_shape_manual(
        name = "Country",
        values = shapes
    ) +
    theme_bw() +
    theme(
        panel.grid.major.y = element_blank(),
        panel.grid.minor.y = element_blank()
    )


# Custom axis titles can be specified using the `xlab()` and `ylab()` functions.
# We can also add a plot title using `ggtitle()`

ggplot(covid_data_subset) +
    geom_hline(
        yintercept = c(0, 100),
        size = 0.25
    ) +
    geom_point(
        mapping = aes(
            x = date,
            y = people_vaccinated_per_hundred,
            color = country,
            shape = country
        ),
        size = 1
    ) +
    scale_color_manual(
        name = "Country",
        values = colors
    ) +
    scale_shape_manual(
        name = "Country",
        values = shapes
    ) +
    theme_bw() +
    theme(
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank()
    ) +
    xlab("Date") +
    ylab("People vaccinated per hundred") +
    ggtitle("COVID19 vaccination progress")



## --------------------------------------------------------
## Facets

# Using facets it is possible to split the plot area into panels
# that each display a subplot of the data defined by
# one ore more variables in the dataset.

# To split into subplots by a single variable, we can use `facet_wrap()`
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        shape = country,
        color = new_vaccinations
    )) +
    facet_wrap(~country)


# To arrange subplots on a grid, we use `facet_grid()`.
ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        shape = country,
        color = new_vaccinations
    )) +
    facet_grid(country ~ .) ## `country` used for rows, no variable for columns

# The `space =` and `scales =` arguments can be used
# to adjust the appearance of the individual panels

ggplot(covid_data_subset) +
    geom_point(mapping = aes(
        x = date,
        y = people_vaccinated_per_hundred,
        shape = country,
        color = new_vaccinations
    )) +
    facet_grid(country ~ .,
        space = "free_y",
        scales = "free_y"
    )


## --------------------------------------------------------
## Larger exercises

## Exercise 1

# Create a scatter plot showing the relationship between
# number of hospital patients vs ICU patients.
# The visualization should include

# * aestehtic mappings to differentiate countries and dates

# Post your code and figure to the padlet, and 
# Note down an insight you have gained from this visualization


## Exercise 2

# Visualize the relationship between the rate of people vaccinated
# and the rate of people fully vaccinated. The visualization should include

# * Points and lines as geoms
# * Aesthetic mapping to differentiate countries
# * A dashed line to highlight x=y
# * Fixed ratio coordinate system with equal units

# Post your code and figure to the padlet, and answer the following questions:

# Which country has the highest vaccination rate?
# Note down another insight/observation you have gained from this visualization


## Exercise 3

# Create a figure including the following information for each country

# * Distributions of daily vaccination rates per million people
# * Summaries for vaccination rates (e.g. median, quartiles)
# * Variation of rates throug time

# Try to polish your figure to be publication ready,
# and post your code and figure to the padlet for discussion
