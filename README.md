The shimex package - Shiny Models Explorer
==================================================================================================================

[![Build Status](https://travis-ci.org/monikachudek/shimex.svg?branch=master)](https://travis-ci.org/monikachudek/shimex)

The `shimex` package enables creating an interactive shiny application, which collects local explainers such as: CeterisParibus, BreakDown, Shap, LocalModel and Lime.

## Installation

```{r}
# Development version from GitHub:
# install.packages("devtools")
devtools::install_github("monikachudek/shimex")
```

## Demo

```{r}
library(randomForest)
model_rm <- randomForest(life_length ~., data = DALEX::dragons, ntree = 200)
explainer <- DALEX::explain(model_rm)
create_shiny(explainer)
```
