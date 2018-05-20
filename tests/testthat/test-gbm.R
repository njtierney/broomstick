context("gbm tidy")

library(gbm)
library(MASS)
fit_gbm <- gbm(calories ~., data = UScereal)

tidy_fit_gbm <- tidy(fit_gbm)

summary_gbm <- summary(fit_gbm, plotit = FALSE)

test_that("tidy.gbm return same values as summary.gbm", {
  expect_equal(tidy_fit_gbm$importance,
               summary_gbm$rel.inf)
})
