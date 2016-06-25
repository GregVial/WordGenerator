## Word generator Preprocessing
## Gregory Vial - 2016, June 24th
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
inputSource <- "https://cgit.freedesktop.org/libreoffice/dictionaries/plain/ru_RU/ru_RU.dic"
inputName <- "ru_RU.dic"
if (!file.exists(inputName)){
  download.file(url=inputSource,destfile=inputName)
}
input <- read.table(inputName,stringsAsFactors =  FALSE,skip=1)
inputLen <-  dim(input)[1]

## Define functions that will convert character to ASCII code
asc <- function(x) { utf8ToInt(x) }

## Define increment function
`%+=%` = function(e1,e2) eval.parent(substitute(e1 <- e1 + e2))

## Define function converting from KOI8-R to Unicode
conv <- function(x) {
  iconv(x, from="KOI8-R", to="UTF-8")
}

## Define function removing word comments (followed by /)
trimSlash <- function(x) {
  pos <- regexpr('/', x)
  #print(pos[1])
  if (pos[1] > 1) {
    substring(x,1,pos-1)
  } else x
}

## Preprocess input (rmove slash, convert to unicode)
input <- apply(input,1,trimSlash)
input <- lapply(input,conv)

## Compute letter sequences occurences
# Unicode from 1040 to 1071 for upper case
#  from 1072 to 1103 for lower case
#  exception is 1105 for ë
dim <- 44
zeros <- rep(0, dim*dim*dim)
prob <- array(data=zeros,dim=c(dim,dim,dim))

for (wordInd in 1:inputLen) {
  i<-1 # last but one letter before k
  j<-1 # last letter before k
  k<-1 # current letter
  word <- paste0(input[[wordInd]],"\n")
  wordLen <- nchar(word)
  text <- paste("Reading word",wordInd)
  text <- paste(text,"out of")
  text <- paste(text,inputLen)
  text <- paste(text,word,sep=":")
  print(text)
  for (letterN in 1:wordLen) {
    letter <- substr(word,letterN,letterN)
    k <- asc(letter)
    if(k>10) {
      if (k < 1072) {
        k <- k-1029
      } else {
        k <- k-(1029+32)
      }
    }
    #print(paste(letter,k))
    prob[i,j,k] %+=% 1
    i <- j
    j <- k
  }
}

## Normalize the array
s <- apply(prob,c(1,2),sum)
r = array(data = rep(s,dim),dim = c(dim,dim,dim))
ps <- prob/r
ps[is.na(ps)] <- 0

##  Save the array to be reused later in shiny
saveRDS(ps,"ps_ru.rds")

## Display matrix
# Convert to two dimension by collapsing dimension i
prob2d <- apply(prob,c(2,3),sum)
# Extract only letters a to z and show word beginning/end as a dash
prob2dreduced <- prob2d[c(1,11:(dim-2),dim),c(10,11:(dim-2),dim)]
names=""
for (i in c(1072:1103,1105)){
  if (i == 1072) names <- intToUtf8(i)
  else  names <- c(names,intToUtf8(i))
}
names <- c("-",names)
colnames(prob2dreduced) <- names
rownames(prob2dreduced) <- names
# Use log of matrix so zero occurences are more visible (in white)
probFinal <- log(prob2dreduced)
probFinal <- probFinal/max(probFinal)
# Save the matrix to be reused later in shiny
saveRDS(probFinal,"probFinal_ru.rds")
# Select palette and plot
rgb.palette <- colorRampPalette(c("blue", "yellow","red"), space = "rgb")
mat <- levelplot(probFinal,main="Letters sequence frequencies",xlab="This letter is followed ...",ylab="... by this letter",col.regions=rgb.palette(120))
print(mat)
## Save th chart to file 
dev.copy(png,file="matrix_ru.png")
dev.off()
