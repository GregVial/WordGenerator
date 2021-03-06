## Word generator
## Gregory Vial - 2016, June 25th
## R version of the generator designed by David Louapre sciencetonnante@gmail.com
## See https://goo.gl/g0ULlN for more info on original idea

## Run this program as many times as you want to generate new words!

## Initialize environment
# Set working directory (set your own for this to work!)
dir <- "C:/Users/vialgre/Desktop/DataScience/Building Data Products/WordGenerator"
setwd(dir)
# Set min and max words length
smin <- 4 # min number of letters
smax <- 12 # max number of letters
totwords <- 10 # number of words to be generated
# Load packages
library(lubridate)
# Set the seed
t <- now()
seed <- hour(t)*minute(t)*floor(second(t))
set.seed(seed)

## Define a function that will convert Unicode code to character 
chr <- function(n) { 
  if (n == 43) {
    n <- n+1
  } 
  intToUtf8(n+(1029+32))
}

## Define increment function
`%+=%` = function(e1,e2) eval.parent(substitute(e1 <- e1 + e2))

## Generate words
# Read frequency array
if (!exists("ps_ru")) {
  if (!file.exists("ps_ru.rds")){
    warning("File ps.rds is not present in the working directly, ensure that you run WordGeneratorPreProcessing.R before running this program")
  } else {
    ps <- readRDS("ps_ru.rds")
  }
}

# Run the markov chain
curword <- 0
while (curword < totwords) {
  res=""
  i<-1
  j<-1
  while (j!=10) {
    test <- 
    k <- sample(1:44,1,prob=ps[i,j,])
    res <- paste0(res,chr(k))
    i <- j
    j <- k
  }
  res <- substr(res, 1, nchar(res)-1) # remove the final \n
  if (nchar(res) >= smin && nchar(res) <= smax) {
    print(res)
    curword %+=% 1
  }
}