#' tidy up the model summary of rpart
#'
#' tidy returns a tibble of variable importance for the rpart pacakge
#'
#' @param x An `rpart` model
#' @param ... extra functions or arguments
#'
#' @return A tibble containing the importance score for each variable
#'
#' @examples
#'
#' # retrieve a tibble of the variable importance from an rpart model
#'
#' library(rpart)
#' fit_rpart <- rpart(Kyphosis ~ Age + Number + Start, data = kyphosis)
#'
#' tidy(fit_rpart)
#'
#' @export
tidy.rpart <- function(x, ...){

  # Some trees are stumps, we need to skip those that are NULL (stumps)
  # so here we say, "If variable importance is NOT NULL, do the following"
  # Another option would be to only include those models which are not null.

  if (is.null(x$variable.importance) == FALSE) {

    x$variable.importance %>%
      tibble::tibble(variable = names(x$variable.importance),
                     importance = as.vector(x$variable.importance),
                     row.names = NULL) %>%
      dplyr::select(variable,
                    importance)

    # if rpart_frame just contains a decision stump, make NULL datasets.
  } else {

    tibble::tibble(variable = NULL,
                  importance = NULL,
                  row.names = NULL)

  } # end else

}