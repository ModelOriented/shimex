The shimex package - Shiny Models Explorer
==================================================================================================================

[![Build Status](https://travis-ci.org/ModelOriented/shimex.svg?branch=master)](https://travis-ci.org/ModelOriented/shimex)
[![Codecov test coverage](https://codecov.io/gh/modeloriented/shimex/branch/master/graph/badge.svg)](https://codecov.io/gh/modeloriented/shimex?branch=master)


The `shimex` package enables interactive exploration of machine learning predictive models using the `shiny` application.
Thanks to the graphical interface, the application streamlines the process of model exploration. 

The Explainers presented in the app:
- [Ceteris Paribus](https://pbiecek.github.io/PM_VEE/ceterisParibus.html) from [`ingredients`](https://github.com/ModelOriented/ingredients),
- [BreakDown](https://pbiecek.github.io/PM_VEE/breakDown.html) from [`iBreakDown`](https://github.com/ModelOriented/iBreakDown),
- [LIME](https://pbiecek.github.io/PM_VEE/LIME.html) from [`DALEXtra`](https://github.com/ModelOriented/DALEXtra), [`iml`](https://github.com/christophM/iml), [`localmodel`](https://github.com/ModelOriented/localModel),
- [SHAP](https://pbiecek.github.io/PM_VEE/shapley.html) from [`iBreakDown`](https://github.com/ModelOriented/iBreakDown), [`shapper`](https://github.com/ModelOriented/shapper), [`iml`](https://github.com/christophM/iml).


## Installation

```{r}
# Development version from GitHub:
# install.packages("devtools")
devtools::install_github("ModelOriented/shimex")
```

## Demo

```{r}
library(randomForest)

# Create a model
model_rm <- randomForest(life_length ~., data = DALEX::dragons, ntree = 200)

# Wrap it into an explainer 
explainer <- DALEX::explain(model_rm)

# Choose an observation (it is possible to modify it through the app)
observation <- DALEX::dragons[1, ]

# Create shimex app for observation
shimex::create_shimex(explainer, observation)
```

Results can be found following the [link](https://chudekm.shinyapps.io/shimex/).
