glance.rpart <- function(x, ...) {

  glance_method <- switch(
    x[["method"]],
    "class" = glance.rpart.class,
    "anova" = glance.rpart.anova,
    "poisson" = stop("method 'poisson' not available yet"),
    "exp" = stop("method 'poisson' not available yet")
    )

  glance_method(x, ...)
}
