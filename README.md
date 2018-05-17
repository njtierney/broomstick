
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

## Example

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
