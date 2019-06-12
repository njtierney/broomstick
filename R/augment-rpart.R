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
augment.rpart <- function(x, data = NULL, newdata = NULL, ...) {

  # test_if_any_data(data, newdata)

  passed_newdata <- !is.null(newdata)

  # Extract data from model
  if (!passed_newdata) {
    if (is.null(x$call$data)) {
      list <- lapply(all.vars(x$call), as.name)
      data <- eval(as.call(list(quote(data.frame),list)), parent.frame())
    } else {
      data <- eval(x$call$data, parent.frame())
    }
  }

  df <- if (passed_newdata) newdata else data

  if (passed_newdata) {
    df$.fitted <- predict(x, newdata = newdata, na.action = na.pass, ...)
  } else {
    df$.fitted <- predict(x, na.action = na.pass, ...)
    df$.resid <- df$.fitted - x$y
  }

  df

}