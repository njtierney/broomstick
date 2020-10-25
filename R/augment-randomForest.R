# Augment ----

#' @rdname rf_tidiers
#'
#' @return `augment.randomForest` returns the original data with additional columns:
#'   \item{.oob_times}{The number of trees for which the given case was "out of bag". See [randomForest::randomForest()] for more details.}
#'   \item{.fitted}{The fitted value or class.}
#'   `augment` returns additional columns for classification and usupervised trees:
#'   \item{.votes}{For each case, the voting results, with one column per class.}
#'   \item{.local_var_imp}{The casewise variable importance, stored as data frames in a nested list-column, with one row per variable in the model. Only present if the model was created with `importance = TRUE`}
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

  dplyr::bind_cols(data, d) %>%
    tibble::as_tibble()
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

  dplyr::bind_cols(data, d) %>%
    tibble::as_tibble()
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
