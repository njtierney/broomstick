# Tidy ----

#' Tidying methods for a randomForest model
#'
#' These methods tidy the variable importance of a random forest model summary,
#' augment the original data with information on the fitted
#' values/classifications and error, and construct a one-row glance of the
#' model's statistics.
#'
#' @return All tidying methods return a `data.frame` without rownames. The
#'   structure depends on the method chosen.
#'
#' @name rf_tidiers
#'
#' @param x randomForest object
#' @param data Model data for use by [augment.randomForest()].
#' @param ... Additional arguments (ignored)
NULL

#' @rdname rf_tidiers
#'
#' @return `tidy.randomForest` returns one row for each model term, with the following columns:
#'   \item{term}{The term in the randomForest model}
#'   \item{MeanDecreaseAccuracy}{A measure of variable importance. See [randomForest::randomForest()] for more information. Only present if the model was created with `importance = TRUE`}
#'   \item{MeanDecreaseGini}{A measure of variable importance. See [randomForest::randomForest()] for more information.}
#'   \item{MeanDecreaseAccuracy_sd}{Standard deviation of `MeanDecreaseAccuracy`. See [randomForest::randomForest()] for more information. Only present if the model was created with `importance = TRUE`}
#'   \item{classwise_importance}{Classwise variable importance for each term, stored as data frames in a nested list-column, with one row per class. Only present if the model was created with `importance = TRUE`}
#'
#' @export
tidy.randomForest <- function(x, ...) {
  tidy.randomForest.method <- switch(x[["type"]],
                                     "classification" = tidy.randomForest.classification,
                                     "regression" = tidy.randomForest.regression,
                                     "unsupervised" = tidy.randomForest.unsupervised)
  tidy.randomForest.method(x, ...)
}

tidy.randomForest.formula <- tidy.randomForest

tidy.randomForest.classification <- function(x, ...) {
  imp_m <- rf_term_column(x[["importance"]])

  # When run with importance = FALSE, randomForest() does not calculate
  # importanceSD. Issue a warning.
  if (is.null(x[["importanceSD"]])) {
    warning("Only MeanDecreaseGini is available from this model. Run randomforest(..., importance = TRUE) for more detailed results")
    imp_m
  } else {
    imp_sd <- rf_term_column(x[["importanceSD"]])

    # Gather variable importances and standard deviations, then nest into a list column
    gathered_imp <- imp_m %>%
      tidyr::gather(
        key = "class",
        value = "classwise_MeanDecreaseAccuracy",
        -term, -MeanDecreaseAccuracy, -MeanDecreaseGini)

    gathered_imp_sd <- imp_sd %>%
      dplyr::rename(MeanDecreaseAccuracy_sd = MeanDecreaseAccuracy) %>%
      tidyr::gather(
        key = "class",
        value = "classwise_MeanDecreaseAccuracy_sd",
        -term, -MeanDecreaseAccuracy_sd)

    dplyr::bind_cols(
      gathered_imp,
      gathered_imp_sd %>% dplyr::select(-term, -class)
    ) %>%
      tidyr::nest(class, classwise_MeanDecreaseAccuracy, classwise_MeanDecreaseAccuracy_sd,
           .key = "classwise_importance")
  }
}

tidy.randomForest.regression <- function(x, ...) {
  imp_m <- as.data.frame(x[["importance"]])
  imp_m <- broom::fix_data_frame(imp_m)
  imp_sd <- x[["importanceSD"]]

  if (is.null(imp_sd))
    warning("Only IncNodePurity is available from this model. Run randomforest(..., importance = TRUE) for more detailed results")

  imp_m$imp_sd <- imp_sd
  imp_m
}

tidy.randomForest.unsupervised <- function(x, ...) {
  # This can be passed through directly to the classification method
  tidy.randomForest.classification(x, ...)
}

