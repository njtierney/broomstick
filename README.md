
<!-- README.md is generated from README.Rmd. Please edit that file -->
broomstick
==========

The goal of broomstick is to extend the [`broom`](https://github.com/tidyverse/broom) package to work with decision trees. It is currently borrowing heavily from the prototype package [`treezy`](https://github.com/njtierney/treezy), and will undergo much more development in the coming months.

Installation
------------

You can install broomstick from github with:

``` r
# install.packages("devtools")
devtools::install_github("njtierney/broomstick")
```

Example
-------

``` r
library(rpart)
library(broomstick)
#> Loading required package: broom

fit_rpart <- rpart(Kyphosis ~ Age + Number + Start, 
                   data = kyphosis)

tidy(fit_rpart)
#> # A tibble: 3 x 2
#>   variable importance
#>     <fctr>      <dbl>
#> 1    Start   8.198442
#> 2      Age   3.101801
#> 3   Number   1.521863
```
