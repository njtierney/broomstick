# Tidy ----

#' Tidying methods for a randomForest model
#'
#' These methods tidy the variable importance of a random forest model summary,
#' augment the original data with information on the fitted
#' values/classifications and error, and construct a one-row glance of the
#' model's statistics.
#'
#' @return All tidying methods return a \code{data.frame} without rownames. The
#'   structure depends on the method chosen.
#'
#' @name rf_tidiers
#'
#' @param x randomForest object
#' @param data Model data for use by \code{\link{augment.randomForest}}.
#' @param ... Additional arguments (ignored)
NULL

#' @rdname rf_tidiers
#'
#' @return \code{tidy.randomForest} returns one row for each model term, with the following columns:
#'   \item{term}{The term in the randomForest model}
#'   \item{MeanDecreaseAccuracy}{A measure of variable importance. See \code{\link[randomForest]{randomForest}} for more information. Only present if the model was created with \code{importance = TRUE}}
#'   \item{MeanDecreaseGini}{A measure of variable importance. See \code{\link[randomForest]{randomForest}} for more information.}
#'   \item{MeanDecreaseAccuracy_sd}{Standard deviation of \code{MeanDecreaseAccuracy}. See \code{\link[randomForest]{randomForest}} for more information. Only present if the model was created with \code{importance = TRUE}}
#'   \item{classwise_importance}{Classwise variable importance for each term, stored as data frames in a nested list-column, with one row per class. Only present if the model was created with \code{importance = TRUE}}
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

# Augment ----

#' @rdname rf_tidiers
#'
#' @return \code{augment.randomForest} returns the original data with additional columns:
#'   \item{.oob_times}{The number of trees for which the given case was "out of bag". See \code{\link[randomForest]{randomForest}} for more details.}
#'   \item{.fitted}{The fitted value or class.}
#'   \code{augment} returns additional columns for classification and usupervised trees:
#'   \item{.votes}{For each case, the voting results, with one column per class.}
#'   \item{.local_var_imp}{The casewise variable importance, stored as data frames in a nested list-column, with one row per variable in the model. Only present if the model was created with \code{importance = TRUE}}
#'
#' @export
augment.randomForest <- function(x, data = NULL, ...) {

  # Extract data from model
  if (is.null(data)) {
    if (is.null(x$call$data)) {
      list <- lapply(all.vars(x$call), as.name)
      data <- eval(as.call(list(quote(data.frame),list)), parent.frame())
    } else {
      data <- eval(x$call$data, parent.frame())
    }
  }

  augment.randomForest.method <- switch(x[["type"]],
                                        "classification" = augment.randomForest.classification,
                                        "regression" = augment.randomForest.regression,
                                        "unsupervised" = augment.randomForest.unsupervised)
  augment.randomForest.method(x, data, ...)
}

augment.randomForest.formula <- augment.randomForest

augment.randomForest.classification <- function(x, data, ..., non_local_imp = FALSE) {

  # When na.omit is used, case-wise model attributes will only be calculated
  # for complete cases in the original data. All columns returned with
  # augment() must be expanded to the length of the full data, inserting NA
  # for all missing values.

  n_data <- nrow(data)
  if (is.null(x[["na.action"]])) {
    na_at <- rep(FALSE, times = n_data)
  } else {
    na_at <- seq_len(n_data) %in% as.integer(x[["na.action"]])
  }

  oob_times <- rep(NA_integer_, times = n_data)
  oob_times[!na_at] <- x[["oob.times"]]

  predicted <- rep(NA, times = n_data)
  predicted[!na_at] <- x[["predicted"]]
  predicted <- factor(predicted, labels = levels(x[["y"]]))

  votes <- x[["votes"]]
  full_votes <- matrix(data = NA, nrow = n_data, ncol = ncol(votes))
  full_votes[which(!na_at),] <- votes
  colnames(full_votes) <- colnames(votes)
  full_votes <- as.data.frame(full_votes)

  d <- data.frame(.oob_times = oob_times, .fitted = predicted) %>%
    dplyr::bind_cols(full_votes) %>%
    tibble::rownames_to_column() %>%
    tidyr::nest(-rowname, -.oob_times, -.fitted, .key = ".votes") %>%
    dplyr::select(-rowname)

  local_imp <- x[["localImportance"]]
  full_imp <- NULL

  if (!is.null(local_imp)) {
    full_imp <- matrix(data = NA_real_, nrow = nrow(local_imp), ncol = n_data)
    full_imp[, which(!na_at)] <- local_imp
    rownames(full_imp) <- rownames(local_imp)
    full_imp <- as.data.frame(t(full_imp))
    full_imp <- tibble::rownames_to_column(full_imp) %>%
      tidyr::nest(-rowname, .key = ".local_var_imp") %>%
      dplyr::select(-rowname)
    d <- dplyr::bind_cols(d, full_imp)
  } else if (non_local_imp == FALSE) {
    warning("casewise importance measures are not available. Run randomForest(..., localImp = TRUE) for more detailed results.")
  }

  dplyr::bind_cols(data, d)
}

augment.randomForest.regression <- function(x, data, ...) {

  n_data <- nrow(data)
  na_at <- seq_len(n_data) %in% as.integer(x[["na.action"]])

  oob_times <- rep(NA_integer_, times = n_data)
  oob_times[!na_at] <- x[["oob.times"]]

  predicted <- rep(NA_real_, times = n_data)
  predicted[!na_at] <- x[["predicted"]]

  d <- data.frame(.oob_times = oob_times, .fitted = predicted)

  local_imp <- x[["localImportance"]]
  full_imp <- NULL

  if (!is.null(local_imp)) {
    full_imp <- matrix(data = NA_real_, nrow = nrow(local_imp), ncol = n_data)
    full_imp[, which(!na_at)] <- local_imp
    rownames(full_imp) <- rownames(local_imp)
    full_imp <- as.data.frame(t(full_imp))
    full_imp <- tibble::rownames_to_column(full_imp) %>%
      tidyr::nest(-rowname, .key = ".local_var_imp") %>%
      dplyr::select(-rowname)
    d <- dplyr::bind_cols(d, full_imp)
  } else {
    warning("casewise importance measures are not available. Run randomForest(..., localImp = TRUE) for more detailed results.")
  }

  dplyr::bind_cols(data, d)
}

augment.randomForest.unsupervised <- function(x, data, ...) {

 # Generate dummy `predicted` and a `y` values for the unsupervised random
 # forest, then pass to augment.randomForest.classification

  n_data <- nrow(data)
  votes <- x[["votes"]]
  x$predicted <- as.factor(ifelse(votes[,1] > votes[,2], "1", "2"))
  x$y <- factor(rep(NA, times = n_data), levels = c("1", "2"))

  # Mute warnings for no local importance, as local importance cannot currently
  # be run with unsupervised randomForest models
  augment.randomForest.classification(x, data, ..., non_local_imp = TRUE)
}

augment.randomForest <- augment.randomForest.formula

# Glance ----

#' @rdname rf_tidiers
#'
#' @return \code{glance.randomForest} returns a data.frame with the following
#'   columns for regression trees:
#'   \item{mse}{The average mean squared error across all trees.}
#'   \item{rsq}{The average pesudo-R-squared across all trees. See \code{\link[randomForest]{randomForest}} for more information.}
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
