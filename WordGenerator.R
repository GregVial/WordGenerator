## Word generator
## Gregory Vial - 2016, June 23rd
## R version of the generator designed by David Louapre sciencetonnante@gmail.com
## See https://goo.gl/g0ULlN for more info on original idea

## Initialize environment
# Set working directory (set your own for this to work!)
dir <- "C:/Users/vialgre/Desktop/DataScience/Building Data Products/WordGenerator"
setwd(dir)
# Load packages
library(lattice)
library(lubridate)
# Set the seed
t <- now()
seed <- hour(t)*minute(t)*floor(second(t))
set.seed(seed)
# Set min and max words length
smin <- 4 # min number of letters
smax <- 12 # max number of letters
totwords <- 10 # number of words to be generated

## Load input
#inputName <- "input.txt"
inputSource <- "http://www.pallier.org/ressources/dicofr/liste.de.mots.francais.frgut.txt"
inputName <- "liste.de.mots.francais.frgut.txt"
if (!file.exists(inputName)){
  download.file(url=inputSource,destfile=inputName)
}
input <- read.table(inputName,stringsAsFactors =  FALSE)
inputLen <-  dim(input)[1]

## Define functions that will convert character to ASCII and vice versa
asc <- function(x) { strtoi(charToRaw(x),16L) }
chr <- function(n) { rawToChar(as.raw(n)) }

## Define increment function
`%+=%` = function(e1,e2) eval.parent(substitute(e1 <- e1 + e2))

## Compute letter sequences occurences
zeros <- rep(0, 256*256*256)
prob <- array(data=zeros,dim=c(256,256,256))

for (wordInd in 1:inputLen) {
  i<-1 # last but one letter before k
  j<-1 # last letter before k
  k<-1 # current letter
  print(paste(wordInd,"out of 336531"))
  word <- paste0(input[wordInd,1],"\n")
  wordLen <- nchar(word)
  for (letterN in 1:wordLen) {
    letter <- substr(word,letterN,letterN)
    k <- asc(letter)
    #print(paste(letter,k))
    prob[i,j,k] %+=% 1
    i <- j
    j <- k
  }
}

## Display bigram
# Convert to two dimension by collapsing dimension i
prob2d <- apply(prob,c(2,3),sum)
# Extract only letters a to z and show word beginning/end as a dash
prob2dreduced <- prob2d[c(1,97:122),c(10,97:122)]
names <- c("-",letters)
colnames(prob2dreduced) <- names
rownames(prob2dreduced) <- names
# Use log of matrix so zero occurences are more visible (in white)
probFinal <- log(prob2dreduced)
probFinal <- probFinal/max(probFinal)
# Save the matrix to be reused later in shiny
saveRDS(probFinal,"probFinal.rds")
# Select palette and plot
rgb.palette <- colorRampPalette(c("blue", "yellow","red"), space = "rgb")
levelplot(probFinal,main="Letters sequence frequencies",xlab="This letter is followed ...",ylab="... by this letter",col.regions=rgb.palette(120))

## Generate words
# Normalize the array
s <- apply(prob,c(1,2),sum)
r = array(data = rep(s,256),dim = c(256,256,256))
ps <- prob/r
ps[is.na(ps)] <- 0
# Save the array to be reused later in shiny
saveRDS(ps,"ps.rds")
# Run the markov chain
curword <- 0
while (curword < totwords) {
  res=""
  i<-1
  j<-1
  while (j!=10) {
    k <- sample(1:256,1,prob=ps[i,j,])
    res <- paste0(res,chr(k))
    i <- j
    j <- k
  }
  Encoding(res) <- "latin1"
  res <- substr(res, 1, nchar(res)-1) # remove the final \n
  if (nchar(res) >= smin && nchar(res) <= smax) {
    print(res)
    curword %+=% 1
  }
}