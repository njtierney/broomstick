
<!-- README.md is generated from README.Rmd. Please edit that file -->

# broomstick

<!-- badges: start -->

[![R build
status](https://github.com/njtierney/broomstick/workflows/R-CMD-check/badge.svg)](https://github.com/njtierney/broomstick/actions)
[![Codecov test
coverage](https://codecov.io/gh/njtierney/broomstick/branch/master/graph/badge.svg)](https://codecov.io/gh/njtierney/broomstick?branch=master)
[![R-CMD-check](https://github.com/njtierney/broomstick/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/njtierney/broomstick/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

Convert decision tree objects into tidy data frames with `broomstick`.

The goal of broomstick is to extend the
[`broom`](https://github.com/tidyverse/broom) package to work with
decision trees. It is currently borrowing heavily from the prototype
package [`treezy`](https://github.com/njtierney/treezy).

## Installation

You can install broomstick from github with:

``` r
# install.packages("remotes")
remotes::install_github("njtierney/broomstick")
```

## Examples

## rpart

``` r
library(rpart)
library(broomstick)

fit_rpart <- rpart(Kyphosis ~ Age + Number + Start, 
                   data = kyphosis)

tidy(fit_rpart)
#> # A tibble: 3 × 2
#>   variable importance
#>   <chr>         <dbl>
#> 1 Start          8.20
#> 2 Age            3.10
#> 3 Number         1.52
augment(fit_rpart)
#> # A tibble: 81 × 6
#>    Kyphosis   Age Number Start .fitted[,"absent"] [,"present"] .resid[,"absent"]
#>    <fct>    <int>  <int> <int>              <dbl>        <dbl>             <dbl>
#>  1 absent      71      3     5              0.421        0.579            -0.579
#>  2 absent     158      3    14              0.857        0.143            -0.143
#>  3 present    128      4     5              0.421        0.579            -1.58 
#>  4 absent       2      5     1              0.421        0.579            -0.579
#>  5 absent       1      4    15              1            0                 0    
#>  6 absent       1      2    16              1            0                 0    
#>  7 absent      61      2    17              1            0                 0    
#>  8 absent      37      3    16              1            0                 0    
#>  9 absent     113      2    16              1            0                 0    
#> 10 present     59      6    12              0.429        0.571            -1.57 
#> # ℹ 71 more rows
#> # ℹ 1 more variable: .resid[2] <dbl>
```

## gbm (Boosted Regression Tree)

``` r
library(gbm)
#> Loaded gbm 2.1.8.1
library(MASS)
fit_gbm <- gbm(calories ~., data = UScereal)
#> Distribution not specified, assuming gaussian ...

tidy(fit_gbm)
#> # A tibble: 10 × 2
#>    variable importance
#>    <chr>         <dbl>
#>  1 1             25.4 
#>  2 2             22.2 
#>  3 3             17.5 
#>  4 4             11.3 
#>  5 5              8.36
#>  6 6              8.13
#>  7 7              4.99
#>  8 8              2.13
#>  9 9              0   
#> 10 10             0
```

## random forest

``` r
library(randomForest)
#> randomForest 4.7-1.1
#> Type rfNews() to see new features/changes/bug fixes.
ozone_rf <- randomForest(Ozone ~ ., 
                         data = airquality, 
                         importance = TRUE,
                         na.action = na.omit)
tidy(ozone_rf)
#> Warning: This function is deprecated as of broom 0.7.0 and will be removed from
#> a future release. Please see tibble::as_tibble().
#> # A tibble: 5 × 4
#>   term    X.IncMSE IncNodePurity imp_sd
#>   <chr>      <dbl>         <dbl>  <dbl>
#> 1 Solar.R    165.         18373.  10.8 
#> 2 Wind       326.         31790.  17.2 
#> 3 Temp       471.         35042.  17.6 
#> 4 Month      109.         10771.   8.90
#> 5 Day         57.7        15353.   9.13
glance(ozone_rf)
#>   mean_mse  mean_rsq
#> 1 336.4239 0.6934116
augment(ozone_rf)
#> Warning in augment.randomForest.method(x, data, ...): casewise importance
#> measures are not available. Run randomForest(..., localImp = TRUE) for more
#> detailed results.
#> # A tibble: 153 × 8
#>    Ozone Solar.R  Wind  Temp Month   Day .oob_times .fitted
#>    <int>   <int> <dbl> <int> <int> <int>      <int>   <dbl>
#>  1    41     190   7.4    67     5     1        191    40.7
#>  2    36     118   8      72     5     2        177    24.0
#>  3    12     149  12.6    74     5     3        191    27.9
#>  4    18     313  11.5    62     5     4        200    24.3
#>  5    NA      NA  14.3    56     5     5         NA    NA  
#>  6    28      NA  14.9    66     5     6         NA    NA  
#>  7    23     299   8.6    65     5     7        186    28.9
#>  8    19      99  13.8    59     5     8        201    19.6
#>  9     8      19  20.1    61     5     9        178    16.1
#> 10    NA     194   8.6    69     5    10         NA    NA  
#> # ℹ 143 more rows
```
