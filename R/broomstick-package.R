#' @title Convert Decision Tree Analysis Objects into Tidy Data Frames
#' @name broomstick
#' @description Convert decision tree analysis objects from R into tidy data
#'   frames, so that they can more easily be combined, reshaped and otherwise
#'   processed with tools like dplyr, tidyr and ggplot2. The package provides
#'   three S3 generics: tidy, which summarizes a model's statistical findings
#'   such as coefficients of a regression; augment, which adds columns to the
#'   original data such as predictions, residuals and cluster assignments; and
#'   glance, which provides a one-row summary of model-level statistics.
#'
#' @importFrom stats AIC coef confint fitted logLik model.frame na.omit
#' @importFrom stats predict qnorm qt residuals setNames var
#' @importFrom utils head
#' @importFrom stats na.pass
#'
#' @docType package
#' @aliases broomstick broomstick-package
#'
NULL

if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
globalVariables(c("rowname",
                  ".oob_times",
                  ".fitted",
                  "term",
                  "MeanDecreaseAccuracy",
                  "MeanDecreaseGini",
                  "MeanDecreaseAccuracy_sd",
                  "classwise_MeanDecreaseAccuracy",
                  "classwise_MeanDecreaseAccuracy_sd",
                  "variable",
                  "importance"
))
