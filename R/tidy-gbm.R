#' tidy up the model summary of gbm
#'
#' tidy returns a tibble of variable importance for the rpart pacakge
#'
#' @param x A `gbm` model
#' @param n_trees integer. (optional) Number of trees to use for computing
#'     relative importance. Default is the number of trees in x$n.trees. If
#'     not provided, a guess is made using the heuristic: If a test set was
#'     used in fitting, the number of trees resulting in lowest test set error
#'     will be used; else, if cross-validation was performed, the number of
#'     trees resulting in lowest cross-validation error will be used;
#'     otherwise, all trees will be used.
#' @param scale (optional) Should importance be scaled? Default is FALSE
#' @param sort (optional) Should results be sorted? Default is TRUE
#' @param normalise (optional) Should results be normalised to sum to 100? Default is TRUE
#' @param ... extra functions or arguments
#'
#' @return A tibble containing the importance score for each variable
#'
#' @examples
#'
#' # retrieve a tibble of the variable importance from an gbm model
#'
#' library(gbm)
#' library(MASS)
#' fit_gbm <- gbm(calories ~., data = UScereal)
#'
#' tidy(fit_gbm)
#'
#' @export
tidy.gbm <- function(x,
                     n_trees = x$n.trees,
                     scale = FALSE,
                     sort = TRUE,
                     normalise = TRUE,
                     ...){

  if (n_trees < 1) {
    stop("n_trees must be greater than 0.")
  }

  if (n_trees > x$n.trees) {
    warning("Exceeded total number of GBM terms. Results use n.trees=",
            x$n.trees, " terms.\n")
    n_trees <- x$n.trees
  }

  imp_df <- gbm::relative.influence(object = x,
                                    n.trees = n_trees,
                                    scale. = scale,
                                    sort. = sort
                                    )

  imp_df[imp_df < 0] <- 0

  imp_df <- tibble::as_tibble(imp_df) %>%
    tibble::rownames_to_column() %>%
    rlang::set_names(c("variable", "importance"))

  if (sort) {
  # arrange the rows by importance
  imp_df <- imp_df[order(imp_df$importance, decreasing = TRUE), ]
  }

  if (normalise) {
      imp_df$importance <- 100 * imp_df$importance/sum(imp_df$importance)
  }

  return(tibble::as_tibble(imp_df))


}
