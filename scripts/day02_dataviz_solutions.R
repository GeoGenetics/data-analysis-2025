## --------------------------------------------------------
## Larger exercises

## Exercise 1

# Create a scatter plot showing the relationship between
# number of hospital patients vs ICU patients.
# The visualization should include

# * aestehtic mappings to differentiate countries and dates

# Post your code and figure to the padlet, and 
# Note down an insight you have gained from this visualization


ggplot(covid_data, mapping = aes(
    x = hosp_patients,
    y = icu_patients
)) +
    geom_point(aes(
        shape = country, 
        color = date
    ))

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

ggplot(covid_data, mapping = aes(
    x = people_vaccinated_per_hundred,
    y = people_fully_vaccinated_per_hundred
)) +
    geom_point(aes(color = country)) +
    geom_line(aes(color = country)) +
    geom_abline(linetype = "dashed") +
    coord_fixed()


## Exercise 3

# Create a figure including the following information for each country

# * Distributions of daily vaccination rates per million people
# * Summaries for vaccination rates (e.g. median, quartiles)
# * Variation of rates throug time

# Try to polish your figure to be publication ready,
# and post your code and figure to the padlet for discussion

ggplot(covid_data, mapping = aes(
    y = country,
    x = new_vaccinations_smoothed_per_million
)) +
    geom_violin(
        scale = "width",
        fill = "gainsboro",
        draw_quantiles = c(0.25, 0.5, 0.75),
        linewidth = 0.25,
        color = "black"
    ) +
    geom_point(aes(fill = date),
        color = "white",
        size = 1.5,
        position = position_jitter(height = 0.1),
        shape = 21,
        alpha = 0.9
    ) +
    scale_x_continuous(label = label_comma()) +
    scale_fill_viridis(
        name = "Date",
        option = "B",
        trans = "date"
    ) +
    xlab("Daily vaccinations per million") +
    ylab("Country") +
    theme_classic() +
    theme(
        axis.line.y = element_blank(),
        axis.ticks.y = element_blank()
    )
