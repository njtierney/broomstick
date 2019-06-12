test_if_any_data <- function(data, newdata){

  if (is.null(data) && is.null(newdata)) {
    stop("Must specify either `data` or `newdata` argument.", call. = FALSE)
    }
}
