# Augment ----

#' @rdname rf_tidiers
#'
#' @return `augment.rpart` returns the original data with additional columns:
#'   - `.fitted`: The fitted value or class.
#'
#'
#' @examples
#' library(rpart)
#' rpart_fit <- rpart(Sepal.Width ~ ., iris)
#' augment(rpart_fit)
#' @export
augment.rpart <- function(x, data = NULL, ...) {
  # Extract data from model
  if (is.null(data)) {
    if (is.null(x$call$data)) {
      list <- lapply(all.vars(x$call), as.name)
      data <- eval(as.call(list(quote(data.frame),list)), parent.frame())
    } else {
      data <- eval(x$call$data, parent.frame())
    }
  }

  data %>%
    dplyr::mutate(.fitted = predict(x))

}