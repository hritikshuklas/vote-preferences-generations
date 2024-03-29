#### Preamble ####
# Purpose: Models voter preference as an outcome of generation and gender
# Author: Hritik Shukla
# Date: 12 March 2024 
# Contact: hritik.shukla@mail.utoronto.ca
# License: MIT

#### Workspace setup ####
library(tidyverse)
library(rstanarm)
library(arrow)
library(modelsummary)

#### Read data ####
analysis_data <- read_parquet("data/analysis_data/cleaned_data.parquet")

set.seed(853)

### Convert Variables to Factors ####
analysis_data <- analysis_data |>
  mutate(
    voted_for = factor(
      voted_for,
      levels = c("Biden", "Trump")
    ),
    gender = factor(
      gender,
      levels = c("Female", "Male")
    ),
    generation = factor(
      generation,
      levels = c(
        "Silent Generation",
        "Baby Boomer",
        "Generation X",
        "Millennial",
        "Generation Z"
      )
    )
  )

### Model Data ####
generation_gender_model <-
  stan_glm(
    formula = voted_for ~ generation + gender,
    data = analysis_data,
    family = binomial(link="logit"),
    prior = normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_intercept = normal(location = 0, scale = 2.5, autoscale = TRUE),
    prior_aux = exponential(rate = 1, autoscale = TRUE),
    seed = 853
  )


#### Save model ####
saveRDS(
  generation_gender_model,
  file = "models/generation_gender_model.rds"
)

