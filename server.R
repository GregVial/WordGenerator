## Initialize environment
library(lattice)
library(lubridate)
library(shiny)

#Define palette
rgb.palette <- colorRampPalette(c("blue", "yellow","red"), space = "rgb")

t <- now()
seed <- hour(t)*minute(t)*floor(second(t))
set.seed(seed)

## Read source data fr
probFinal_fr <- readRDS("probFinal_fr.rds")
ps_fr <- readRDS("ps_fr.rds")
## Read source data ru
probFinal_ru <- readRDS("probFinal_ru.rds")
ps_ru <- readRDS("ps_ru.rds")

## Define increment function
`%+=%` = function(e1,e2) eval.parent(substitute(e1 <- e1 + e2))

shinyServer(
  function(input,output) {
    
    output$oid4 <- renderPrint({
      ## setup appropriate source and other options
      if (input$select == 1) {
        ps <- ps_fr
        probFinal <- probFinal_fr
        dim <- 256
        chr <- function(n) { rawToChar(as.raw(n)) }
        Sys.setlocale("LC_CTYPE", "french")
      } else if (input$select == 2) {
        dim <- 44
        ps <- ps_ru
        probFinal <- probFinal_ru
        chr <- function(n) { 
          if (n == 43) {
            n <- n+1
          } 
          intToUtf8(n+(1029+32))
        }
        Sys.setlocale("LC_CTYPE", "russian")
        
      }
      
      ## Word generator 
      generateWord <- function(smin,smax,totwords) {
        curword <- 0
        while (curword < totwords) {
          res=""
          i<-1
          j<-1
          while (j!=10) {
            k <- sample(1:dim,1,prob=ps[i,j,])
            res <- paste0(res,chr(k))
            i <- j
            j <- k
          }
          if (input$select == 1){ Encoding(res) <- "latin1"}
          else if (input$select == 2){ res <- enc2utf8(res)}
          res <- substr(res, 1, nchar(res)-1) # remove the final \n
          if (nchar(res) >= smin && nchar(res) <= smax) {
            print(res)
            curword %+=% 1
          }
        }
      }
      
      
      if(input$action == 0) "Make a selection and press the Generate! button"
      else {   
        
        isolate(generateWord(input$min,input$max,input$num))
      }
    })
    
    output$matrix <- renderPlot({
      if (input$select == 1){
        levelplot(probFinal_fr,main="Letters sequence frequencies",xlab="This letter is followed ...",ylab="... by this letter",col.regions=rgb.palette(120))
      } else if (input$select == 2) {
        levelplot(probFinal_ru,main="Letters sequence frequencies",xlab="This letter is followed ...",ylab="... by this letter",col.regions=rgb.palette(120))
      }
    })
  }
)
