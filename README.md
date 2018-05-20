
<!-- README.md is generated from README.Rmd. Please edit that file -->

# broomstick

[![Travis-CI Build
Status](https://travis-ci.org/njtierney/broomstick.svg?branch=master)](https://travis-ci.org/njtierney/broomstick)
[![AppVeyor Build
Status](https://ci.appveyor.com/api/projects/status/github/njtierney/broomstick?branch=master&svg=true)](https://ci.appveyor.com/project/njtierney/broomstick)

Convert decision tree objects into tidy data frames with `broomstick`.

The goal of broomstick is to extend the
[`broom`](https://github.com/tidyverse/broom) package to work with
decision trees. It is currently borrowing heavily from the prototype
package [`treezy`](https://github.com/njtierney/treezy), and will
undergo much more development in the coming months.

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
#> Loading required package: broom

fit_rpart <- rpart(Kyphosis ~ Age + Number + Start, 
                   data = kyphosis)

tidy(fit_rpart)
#> # A tibble: 3 x 2
#>   variable importance
#>   <fct>         <dbl>
#> 1 Start          8.20
#> 2 Age            3.10
#> 3 Number         1.52
```

## gbm (Boosted Regression Tree)

``` r
library(gbm)
#> Loading required package: survival
#> 
#> Attaching package: 'survival'
#> The following object is masked from 'package:rpart':
#> 
#>     solder
#> Loading required package: lattice
#> Loading required package: splines
#> Loading required package: parallel
#> Loaded gbm 2.1.3
library(MASS)
fit_gbm <- gbm(calories ~., data = UScereal)
#> Distribution not specified, assuming gaussian ...

tidy(fit_gbm)
#> # A tibble: 10 x 2
#>    variable  importance
#>    <chr>          <dbl>
#>  1 potassium      62.5 
#>  2 fat            15.8 
#>  3 carbo           7.27
#>  4 fibre           5.26
#>  5 protein         5.23
#>  6 sugars          2.30
#>  7 sodium          1.69
#>  8 vitamins        0   
#>  9 shelf           0   
#> 10 mfr             0
```
