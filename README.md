
<!-- README.md is generated from README.Rmd. Please edit that file -->

broomstick
==========

<!-- badges: start -->

[![R build
status](https://github.com/njtierney/broomstick/workflows/R-CMD-check/badge.svg)](https://github.com/njtierney/broomstick/actions)
[![Codecov test
coverage](https://codecov.io/gh/njtierney/broomstick/branch/master/graph/badge.svg)](https://codecov.io/gh/njtierney/broomstick?branch=master)
<!-- badges: end -->

Convert decision tree objects into tidy data frames with `broomstick`.

The goal of broomstick is to extend the
[`broom`](https://github.com/tidyverse/broom) package to work with
decision trees. It is currently borrowing heavily from the prototype
package [`treezy`](https://github.com/njtierney/treezy).

Installation
------------

You can install broomstick from github with:

    # install.packages("remotes")
    remotes::install_github("njtierney/broomstick")

Examples
--------

rpart
-----

    library(rpart)
    library(broomstick)

    fit_rpart <- rpart(Kyphosis ~ Age + Number + Start, 
                       data = kyphosis)

    tidy(fit_rpart)
    #> # A tibble: 3 x 2
    #>   variable importance
    #>   <chr>         <dbl>
    #> 1 Start          8.20
    #> 2 Age            3.10
    #> 3 Number         1.52
    augment(fit_rpart)
    #> # A tibble: 81 x 6
    #>    Kyphosis   Age Number Start .fitted[,"absen… [,"present"] .resid[,"absent…
    #>    <fct>    <int>  <int> <int>            <dbl>        <dbl>            <dbl>
    #>  1 absent      71      3     5            0.421        0.579           -0.579
    #>  2 absent     158      3    14            0.857        0.143           -0.143
    #>  3 present    128      4     5            0.421        0.579           -1.58 
    #>  4 absent       2      5     1            0.421        0.579           -0.579
    #>  5 absent       1      4    15            1            0                0    
    #>  6 absent       1      2    16            1            0                0    
    #>  7 absent      61      2    17            1            0                0    
    #>  8 absent      37      3    16            1            0                0    
    #>  9 absent     113      2    16            1            0                0    
    #> 10 present     59      6    12            0.429        0.571           -1.57 
    #> # … with 71 more rows, and 1 more variable: [,"present"] <dbl>

gbm (Boosted Regression Tree)
-----------------------------

    library(gbm)
    #> Loaded gbm 2.1.8
    library(MASS)
    fit_gbm <- gbm(calories ~., data = UScereal)
    #> Distribution not specified, assuming gaussian ...

    tidy(fit_gbm)
    #> # A tibble: 10 x 2
    #>    variable importance
    #>    <chr>         <dbl>
    #>  1 1            30.7  
    #>  2 2            23.5  
    #>  3 3            14.3  
    #>  4 4            11.5  
    #>  5 5             8.14 
    #>  6 6             6.75 
    #>  7 7             2.96 
    #>  8 8             1.95 
    #>  9 9             0.198
    #> 10 10            0

random forest
-------------

    library(randomForest)
    #> randomForest 4.6-14
    #> Type rfNews() to see new features/changes/bug fixes.
    ozone_rf <- randomForest(Ozone ~ ., 
                             data = airquality, 
                             importance = TRUE,
                             na.action = na.omit)
    tidy(ozone_rf)
    #> Warning: This function is deprecated as of broom 0.7.0 and will be removed from
    #> a future release. Please see tibble::as_tibble().
    #> # A tibble: 5 x 4
    #>   term    X.IncMSE IncNodePurity imp_sd
    #>   <chr>      <dbl>         <dbl>  <dbl>
    #> 1 Solar.R    151.         18103.   11.0
    #> 2 Wind       326.         29153.   17.6
    #> 3 Temp       485.         35513.   18.6
    #> 4 Month      107.         10803.   10.4
    #> 5 Day         62.5        16332.   10.6
    glance(ozone_rf)
    #>   mean_mse  mean_rsq
    #> 1 342.6329 0.6877532
    augment(ozone_rf)
    #> Warning in augment.randomForest.method(x, data, ...): casewise importance
    #> measures are not available. Run randomForest(..., localImp = TRUE) for more
    #> detailed results.
    #>     Ozone Solar.R Wind Temp Month Day .oob_times   .fitted
    #> 1      41     190  7.4   67     5   1        188  42.25838
    #> 2      36     118  8.0   72     5   2        197  26.11229
    #> 3      12     149 12.6   74     5   3        197  24.96252
    #> 4      18     313 11.5   62     5   4        168  24.20249
    #> 5      NA      NA 14.3   56     5   5         NA        NA
    #> 6      28      NA 14.9   66     5   6         NA        NA
    #> 7      23     299  8.6   65     5   7        180  29.26588
    #> 8      19      99 13.8   59     5   8        181  18.78945
    #> 9       8      19 20.1   61     5   9        184  14.48941
    #> 10     NA     194  8.6   69     5  10         NA        NA
    #> 11      7      NA  6.9   74     5  11         NA        NA
    #> 12     16     256  9.7   69     5  12        160  20.25724
    #> 13     11     290  9.2   66     5  13        164  22.67090
    #> 14     14     274 10.9   68     5  14        174  22.40194
    #> 15     18      65 13.2   58     5  15        199  13.99352
    #> 16     14     334 11.5   64     5  16        202  23.91045
    #> 17     34     307 12.0   66     5  17        185  19.91413
    #> 18      6      78 18.4   57     5  18        194  18.64684
    #> 19     30     322 11.5   68     5  19        175  19.05428
    #> 20     11      44  9.7   62     5  20        175  11.79332
    #> 21      1       8  9.7   59     5  21        183  13.96870
    #> 22     11     320 16.6   73     5  22        174  24.16417
    #> 23      4      25  9.7   61     5  23        190  14.33131
    #> 24     32      92 12.0   61     5  24        176  18.18554
    #> 25     NA      66 16.6   57     5  25         NA        NA
    #> 26     NA     266 14.9   58     5  26         NA        NA
    #> 27     NA      NA  8.0   57     5  27         NA        NA
    #> 28     23      13 12.0   67     5  28        180  20.88715
    #> 29     45     252 14.9   81     5  29        189  46.32726
    #> 30    115     223  5.7   79     5  30        191  55.56009
    #> 31     37     279  7.4   76     5  31        186  46.92523
    #> 32     NA     286  8.6   78     6   1         NA        NA
    #> 33     NA     287  9.7   74     6   2         NA        NA
    #> 34     NA     242 16.1   67     6   3         NA        NA
    #> 35     NA     186  9.2   84     6   4         NA        NA
    #> 36     NA     220  8.6   85     6   5         NA        NA
    #> 37     NA     264 14.3   79     6   6         NA        NA
    #> 38     29     127  9.7   82     6   7        188  27.59685
    #> 39     NA     273  6.9   87     6   8         NA        NA
    #> 40     71     291 13.8   90     6   9        191  49.68501
    #> 41     39     323 11.5   87     6  10        168  54.05047
    #> 42     NA     259 10.9   93     6  11         NA        NA
    #> 43     NA     250  9.2   92     6  12         NA        NA
    #> 44     23     148  8.0   82     6  13        188  34.53176
    #> 45     NA     332 13.8   80     6  14         NA        NA
    #> 46     NA     322 11.5   79     6  15         NA        NA
    #> 47     21     191 14.9   77     6  16        179  26.24771
    #> 48     37     284 20.7   72     6  17        171  22.30556
    #> 49     20      37  9.2   65     6  18        191  15.30853
    #> 50     12     120 11.5   73     6  19        170  22.07452
    #> 51     13     137 10.3   76     6  20        183  22.79000
    #> 52     NA     150  6.3   77     6  21         NA        NA
    #> 53     NA      59  1.7   76     6  22         NA        NA
    #> 54     NA      91  4.6   76     6  23         NA        NA
    #> 55     NA     250  6.3   76     6  24         NA        NA
    #> 56     NA     135  8.0   75     6  25         NA        NA
    #> 57     NA     127  8.0   78     6  26         NA        NA
    #> 58     NA      47 10.3   73     6  27         NA        NA
    #> 59     NA      98 11.5   80     6  28         NA        NA
    #> 60     NA      31 14.9   77     6  29         NA        NA
    #> 61     NA     138  8.0   83     6  30         NA        NA
    #> 62    135     269  4.1   84     7   1        184  71.89886
    #> 63     49     248  9.2   85     7   2        167  64.37778
    #> 64     32     236  9.2   81     7   3        187  45.91065
    #> 65     NA     101 10.9   84     7   4         NA        NA
    #> 66     64     175  4.6   83     7   5        174  75.24531
    #> 67     40     314 10.9   83     7   6        183  49.88416
    #> 68     77     276  5.1   88     7   7        200  85.00543
    #> 69     97     267  6.3   92     7   8        173  86.20607
    #> 70     97     272  5.7   92     7   9        173  87.64815
    #> 71     85     175  7.4   89     7  10        153  73.97870
    #> 72     NA     139  8.6   82     7  11         NA        NA
    #> 73     10     264 14.3   73     7  12        178  28.75746
    #> 74     27     175 14.9   81     7  13        164  39.57709
    #> 75     NA     291 14.9   91     7  14         NA        NA
    #> 76      7      48 14.3   80     7  15        187  25.77671
    #> 77     48     260  6.9   81     7  16        184  46.63660
    #> 78     35     274 10.3   82     7  17        194  37.74192
    #> 79     61     285  6.3   84     7  18        192  69.86593
    #> 80     79     187  5.1   87     7  19        184  73.84940
    #> 81     63     220 11.5   85     7  20        195  51.65887
    #> 82     16       7  6.9   74     7  21        187  27.20911
    #> 83     NA     258  9.7   81     7  22         NA        NA
    #> 84     NA     295 11.5   82     7  23         NA        NA
    #> 85     80     294  8.6   86     7  24        197  58.13895
    #> 86    108     223  8.0   85     7  25        177  72.65444
    #> 87     20      81  8.6   82     7  26        181  45.41705
    #> 88     52      82 12.0   86     7  27        176  43.16430
    #> 89     82     213  7.4   88     7  28        178  73.00805
    #> 90     50     275  7.4   86     7  29        190  73.45676
    #> 91     64     253  7.4   83     7  30        188  62.06175
    #> 92     59     254  9.2   81     7  31        169  52.61721
    #> 93     39      83  6.9   81     8   1        171  40.68605
    #> 94      9      24 13.8   81     8   2        181  27.34251
    #> 95     16      77  7.4   82     8   3        184  37.33898
    #> 96     78      NA  6.9   86     8   4         NA        NA
    #> 97     35      NA  7.4   85     8   5         NA        NA
    #> 98     66      NA  4.6   87     8   6         NA        NA
    #> 99    122     255  4.0   89     8   7        179  91.82286
    #> 100    89     229 10.3   90     8   8        191  66.99773
    #> 101   110     207  8.0   90     8   9        200  75.82581
    #> 102    NA     222  8.6   92     8  10         NA        NA
    #> 103    NA     137 11.5   86     8  11         NA        NA
    #> 104    44     192 11.5   86     8  12        208  56.88581
    #> 105    28     273 11.5   82     8  13        193  38.49338
    #> 106    65     157  9.7   80     8  14        195  30.41331
    #> 107    NA      64 11.5   79     8  15         NA        NA
    #> 108    22      71 10.3   77     8  16        200  21.41058
    #> 109    59      51  6.3   79     8  17        193  37.36250
    #> 110    23     115  7.4   76     8  18        184  29.75137
    #> 111    31     244 10.9   78     8  19        196  34.67882
    #> 112    44     190 10.3   78     8  20        206  34.74004
    #> 113    21     259 15.5   77     8  21        176  25.74759
    #> 114     9      36 14.3   72     8  22        181  16.11446
    #> 115    NA     255 12.6   75     8  23         NA        NA
    #> 116    45     212  9.7   79     8  24        203  56.69674
    #> 117   168     238  3.4   81     8  25        194  67.14026
    #> 118    73     215  8.0   86     8  26        166  85.68238
    #> 119    NA     153  5.7   88     8  27         NA        NA
    #> 120    76     203  9.7   97     8  28        191  74.62102
    #> 121   118     225  2.3   94     8  29        182 104.91248
    #> 122    84     237  6.3   96     8  30        186  90.26471
    #> 123    85     188  6.3   94     8  31        192  81.15797
    #> 124    96     167  6.9   91     9   1        181  72.59516
    #> 125    78     197  5.1   92     9   2        179  81.48244
    #> 126    73     183  2.8   93     9   3        183  93.03619
    #> 127    91     189  4.6   93     9   4        173  77.15980
    #> 128    47      95  7.4   87     9   5        181  52.03776
    #> 129    32      92 15.5   84     9   6        174  37.75896
    #> 130    20     252 10.9   80     9   7        184  40.05420
    #> 131    23     220 10.3   78     9   8        196  35.00435
    #> 132    21     230 10.9   75     9   9        188  28.14067
    #> 133    24     259  9.7   73     9  10        187  28.94787
    #> 134    44     236 14.9   81     9  11        174  29.27522
    #> 135    21     259 15.5   76     9  12        183  22.60115
    #> 136    28     238  6.3   77     9  13        193  46.98184
    #> 137     9      24 10.9   71     9  14        200  16.55020
    #> 138    13     112 11.5   71     9  15        173  21.91143
    #> 139    46     237  6.9   78     9  16        186  33.19160
    #> 140    18     224 13.8   67     9  17        181  22.12481
    #> 141    13      27 10.3   76     9  18        190  16.28911
    #> 142    24     238 10.3   68     9  19        181  22.70507
    #> 143    16     201  8.0   82     9  20        170  43.56690
    #> 144    13     238 12.6   64     9  21        178  22.78182
    #> 145    23      14  9.2   71     9  22        196  15.44979
    #> 146    36     139 10.3   81     9  23        171  25.90560
    #> 147     7      49 10.3   69     9  24        187  20.33940
    #> 148    14      20 16.6   63     9  25        188  21.48303
    #> 149    30     193  6.9   70     9  26        175  36.76303
    #> 150    NA     145 13.2   77     9  27         NA        NA
    #> 151    14     191 14.3   75     9  28        181  25.86641
    #> 152    18     131  8.0   76     9  29        188  32.89799
    #> 153    20     223 11.5   68     9  30        174  34.24170
