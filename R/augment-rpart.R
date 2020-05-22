#' Augment your model object
#' @param x rpart model
#' @param data data.frame from the model
#' @param newdata new data to use for predictions, residuals, etc.
#' @param ... extra arguments to pass
#'
#' @return `augment.rpart` returns the original data with additional columns:
#'   - `.fitted`: The fitted value or class.
#'   - `.resid`: only given when the same data as was used for the model is
#'     provided.
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

  data <- if (passed_newdata) newdata else data

  if (passed_newdata) {
    data$.fitted <- predict(x, newdata = newdata, na.action = na.pass, ...)
  } else {
    data$.fitted <- predict(x, na.action = na.pass, ...)
    data$.resid <- data$.fitted - x$y
  }

  return(data)

}