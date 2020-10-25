# Glance ----

#' @rdname rf_tidiers
#'
#' @return `glance.randomForest` returns a data.frame with the following
#'   columns for regression trees:
#'   \item{mse}{The average mean squared error across all trees.}
#'   \item{rsq}{The average pesudo-R-squared across all trees. See [randomForest::randomForest()] for more information.}
#'   For classification trees: one row per class, with the following columns:
#'   \item{precision}{}
#'   \item{recall}{}
#'   \item{accuracy}{}
#'   \item{f_measure}{}
#'
#' @export
glance.randomForest <- function(x, ...) {

  glance.method <- switch(x[["type"]],
                          "classification" = glance.randomForest.classification,
                          "regression" = glance.randomForest.regression,
                          "unsupervised" = glance.randomForest.unsupervised)

  glance.method(x, ...)
}

glance.randomForest.formula <- glance.randomForest

glance.randomForest.classification <- function(x, ...) {
  actual <- x[["y"]]
  predicted <- x[["predicted"]]

  per_level <- function(l) {
    tp <- sum(actual == l & predicted == l)
    tn <- sum(actual != l & predicted != l)
    fp <- sum(actual != l & predicted == l)
    fn <- sum(actual == l & predicted != l)

    precision <- tp / (tp + fp)
    recall <- tp / (tp + fn)
    accuracy <- (tp + tn) / (tp + tn + fp + fn)
    f_measure <- 2 * ((precision * recall) / (precision + recall))

    tibble::tibble(
      precision,
      recall,
      accuracy,
      f_measure)
  }

  purrr::set_names(levels(actual)) %>%
    purrr::map_df(per_level, .id = "class") %>%
    dplyr::select(class, dplyr::everything())
}

glance.randomForest.regression <- function(x, ...) {
  mean_mse <- mean(x[["mse"]])
  mean_rsq <- mean(x[["rsq"]])
  data.frame(mean_mse = mean_mse, mean_rsq = mean_rsq)
}

glance.randomForest.unsupervised <- function(x, ...) {
  stop("glance() is not implemented for unsupervised randomForest models")
}

# Internal helpers ----

# Retrieve names of terms used for randomForest
rf_terms <- function(x) {
  attr(x$terms, "term.labels")
}

# Retrieve predicted classes for randomForest. Returns an error if randomForest type does not equal "classification"
rf_classes <- function(x) {
  rf_type <- x[["type"]]
  if (rf_type == "unsupervised") {
    c("1", "2")
  } else if (rf_type == "classification") {
    levels(x$predicted)
  } else {
    stop("x is not a classification randomForest model.")
  }
}

# Take importance matrix from a randomForest and return a tibble with "term" column
rf_term_column <- function(x) {
  tibble::rownames_to_column(as.data.frame(x), var = "term")
}
