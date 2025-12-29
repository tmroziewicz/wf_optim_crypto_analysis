if (!require("pacman")) install.packages("pacman", repos = "http://cran.us.r-project.org")
pacman::p_load(testthat)

test_file("tests/TestDataCollector.r")