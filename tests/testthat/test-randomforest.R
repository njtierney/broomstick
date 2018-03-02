# test tidy, augment, and glance methods from rf_tidiers.r

context("randomForest tidiers")
suppressPackageStartupMessages(library(randomForest))

if (require(randomForest, quietly = TRUE)) {
    set.seed(100)

    # Salt vector with NAs
    v_salt_na <- function(x, m) {
        i <- sample.int(length(x), size = m, replace = FALSE)
        x[i] <- NA
        x
    }

    # Add NAs to test dataset so that na.action can be tested
    df_salt_na <- function(df, frac, col_names) {
        m <- round(nrow(df) * frac)
        dplyr::mutate_at(df, .funs = dplyr::funs(v_salt_na(., m)), .cols = col_names)
    }

    salted_iris <- df_salt_na(iris, 0.1, c("Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width"))

    # Classification rf
    crf <- randomForest(Species ~ ., data = salted_iris, localImp = TRUE, na.action = na.omit)
    crf_fix <- randomForest(Species ~ ., data = salted_iris, localImp = TRUE, na.action = na.roughfix)

    crf_cats <- levels(salted_iris[["Species"]])
    crf_vars <- names(salted_iris[, -5])

    crf_noimp <- randomForest(Species ~ ., data = salted_iris, importance = FALSE, na.action = na.omit)

    # Regression rf
    rrf <- randomForest(Ozone ~ ., data = airquality, mtry = 3,
                        localImp = TRUE, na.action = na.omit)
    rrf_vars <- names(airquality[, -1])

    rrf_noimp <- randomForest(Ozone ~ ., data = airquality, mtry = 3,
                        importance = FALSE, na.action = na.omit)

    # Unsupervised rf
    urf <- randomForest(iris[, -5], importance = TRUE)
    urf_vars <- names(iris[, -5])
    urf_cats <- c("1", "2")
    urf_noimp <- randomForest(iris[, -5], importance = FALSE)

    # Tidy ----
    tidy_names <- c("term", "MeanDecreaseAccuracy", "MeanDecreaseGini", "MeanDecreaseAccuracy_sd", "classwise_importance")
    classwise_names <- c("class", "classwise_MeanDecreaseAccuracy", "classwise_MeanDecreaseAccuracy_sd")

    test_that("tidy works on randomForest models", {
        tdc <- tidy(crf)
        expect_equal(tdc[["term"]], crf_vars)
        expect_equal(colnames(tdc), tidy_names)
        expect_equal(colnames(tdc[["classwise_importance"]][[1]]), classwise_names)
        expect_equal(tdc[["classwise_importance"]][[1]][["class"]], crf_cats)

        tdc_fix <- tidy(crf_fix)
        expect_equal(colnames(tdc_fix), tidy_names)
        expect_equal(tdc_fix[["term"]], crf_vars)
        expect_equal(colnames(tdc_fix[["classwise_importance"]][[1]]), classwise_names)
        expect_equal(tdc_fix[["classwise_importance"]][[1]][["class"]], crf_cats)

        expect_warning(tdc_noimp <- tidy(crf_noimp), "Only MeanDecreaseGini")
        expect_equal(colnames(tdc_noimp), c("term", "MeanDecreaseGini"))
        expect_equal(tdc_noimp[["term"]], crf_vars)

        tdr <- tidy(rrf)
        expect_equal(colnames(tdr), c("term", "X.IncMSE", "IncNodePurity", "imp_sd"))
        expect_equal(tdr[["term"]], rrf_vars)

        expect_warning(tdr_noimp <- tidy(rrf_noimp))
        expect_equal(colnames(tdr_noimp), c("term", "IncNodePurity"))
        expect_equal(tdr_noimp[["term"]], rrf_vars)

        udr <- tidy(urf)
        expect_equal(udr[["term"]], urf_vars)
        expect_equal(colnames(udr), tidy_names)
        expect_equal(colnames(udr[["classwise_importance"]][[1]]), classwise_names)
        expect_equal(udr[["classwise_importance"]][[1]][["class"]], urf_cats)

        expect_warning(udr_noimp <- tidy(urf_noimp))
        expect_equal(colnames(udr_noimp), c("term", "MeanDecreaseGini"))
        expect_equal(udr_noimp[["term"]], crf_vars)
    })

    # Glance ----
    test_that("glance works on randomForest models", {
        glance_names_classification <- c("class", "precision", "recall", "accuracy", "f_measure")
        glance_names_regression <- c("mean_mse", "mean_rsq")

        glc <- glance(crf)
        expect_equal(colnames(glc), glance_names_classification)
        expect_equal(glc[["class"]], crf_cats)

        glc_fix <- glance(crf_fix)
        expect_equal(colnames(glc_fix), glance_names_classification)
        expect_equal(glc_fix[["class"]], crf_cats)

        glc_noimp <- glance(crf_noimp)
        expect_equal(colnames(glc_fix), glance_names_classification)
        expect_equal(glc_noimp[["class"]], crf_cats)

        glr <- glance(rrf)
        expect_equal(colnames(glr), glance_names_regression)

        glr_noimp <- glance(rrf_noimp)
        expect_equal(colnames(glr_noimp), glance_names_regression)

        expect_error(glu <- glance(urf))
        expect_error(glu_noimp <- glance(urf_noimp))
    })

    # Augment ----
    test_that("augment works on randomForest models", {
        augment_names <- c(".oob_times", ".fitted")
        augment_names_classification_noimp <- c(augment_names, ".votes")
        augment_names_classification <- c(augment_names_classification_noimp, ".local_var_imp")
        augment_names_regression <- c(augment_names, ".local_var_imp")

        auc <- augment(crf)
        expect_equal(colnames(auc), c(names(iris), augment_names_classification))
        expect_equal(nrow(auc), nrow(iris))
        expect_equal(colnames(auc[[".votes"]][[1]]), crf_cats)
        expect_equal(colnames(auc[[".local_var_imp"]][[1]]), crf_vars)

        auc_fix <- augment(crf_fix)
        expect_equal(colnames(auc_fix), c(names(iris), augment_names_classification))
        expect_equal(nrow(auc_fix), nrow(iris))
        expect_equal(colnames(auc_fix[[".votes"]][[1]]), crf_cats)
        expect_equal(colnames(auc_fix[[".local_var_imp"]][[1]]), crf_vars)

        expect_warning(auc_noimp <- augment(crf_noimp))
        expect_equal(colnames(auc_noimp), c(names(iris), augment_names_classification_noimp))
        expect_equal(nrow(auc_noimp), nrow(iris))
        expect_equal(colnames(auc_noimp[[".votes"]][[1]]), crf_cats)

        aur <- augment(rrf)
        expect_equal(colnames(aur), c(names(airquality), augment_names_regression))
        expect_equal(nrow(aur), nrow(airquality))
        expect_equal(colnames(auc_fix[[".local_var_imp"]][[1]]), crf_vars)


        expect_warning(aur_noimp <- augment(rrf_noimp))
        expect_equal(colnames(aur_noimp), c(names(airquality), augment_names))
        expect_equal(nrow(aur_noimp), nrow(airquality))

        # Currently, it's impossible to run randomForest unsuprvised with
        # localImp = TRUE - causes a segfault
        auu <- augment(urf)
        expect_equal(colnames(auu), c(names(iris), augment_names_classification_noimp))
        expect_equal(nrow(auu), nrow(iris))

        auu_noimp <- augment(urf_noimp)
        expect_equal(colnames(auu_noimp), c(names(iris), augment_names_classification_noimp))
        expect_equal(nrow(auu_noimp), nrow(iris))
        expect_equal(colnames(auu_noimp[[".votes"]][[1]]), c("1", "2"))
    })
}
