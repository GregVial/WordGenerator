## Initialize environment
library(lattice)
library(lubridate)
library(shiny)

t <- now()
seed <- hour(t)*minute(t)*floor(second(t))
set.seed(seed)

## Read source data
probFinal <- readRDS("probFinal.rds")
ps <- readRDS("ps.rds")

## Define a function that will convert character to ASCII and vice versa
asc <- function(x) { strtoi(charToRaw(x),16L) }
chr <- function(n) { rawToChar(as.raw(n)) }

## Define increment function
`%+=%` = function(e1,e2) eval.parent(substitute(e1 <- e1 + e2))

## Word generator 
generateWord <- function(smin,smax,totwords) {
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
}
  


shinyServer(
  function(input,output) {
    output$oid4 <- renderPrint({
      if(input$action == 0) "Make a selection and press the Generate! button"
      else {
        isolate(generateWord(input$min,input$max,input$num))
      }
    })
    output$matrix <- renderPlot({
      rgb.palette <- colorRampPalette(c("blue", "yellow","red"), space = "rgb")
      levelplot(probFinal,main="Letters sequence frequencies",xlab="This letter is followed ...",ylab="... by this letter",col.regions=rgb.palette(120))
    })
  }
)
