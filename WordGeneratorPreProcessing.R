## Word generator Preprocessing
## Gregory Vial - 2016, June 24rd
## R version of the generator designed by David Louapre sciencetonnante@gmail.com
## See https://goo.gl/g0ULlN for more info on original idea

## Run this only the first time. Then only run WordGenerator.R

## Initialize environment
# Set working directory (set your own for this to work!)
dir <- "C:/Users/vialgre/Desktop/DataScience/Building Data Products/WordGenerator"
setwd(dir)
# Load packages
library(lattice)

## Load input
inputSource <- "http://www.pallier.org/ressources/dicofr/liste.de.mots.francais.frgut.txt"
inputName <- "liste.de.mots.francais.frgut.txt"
if (!file.exists(inputName)){
  download.file(url=inputSource,destfile=inputName)
}
input <- read.table(inputName,stringsAsFactors =  FALSE)
inputLen <-  dim(input)[1]

## Define functions that will convert character to ASCII code
asc <- function(x) { strtoi(charToRaw(x),16L) }

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

## Display matrix
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
## Save th chart to file 
dev.copy(png,file="matrix.png")
dev.off()