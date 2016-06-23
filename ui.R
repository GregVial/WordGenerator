library(shiny)
shinyUI(pageWithSidebar(
  headerPanel("French words generator"),
  sidebarPanel(
    h3('Selections'),
    numericInput('min','Minimum word length',4,min=4,max=6,step=1),
    numericInput('max','Maximum word length',12,min=6,max=12,step=1),
    numericInput('num','Number of words to be generated',5,min=1,max=10,step=1),
    #submitButton('Generate!')
    actionButton("action", label = "Generate!")
  ),
  mainPanel(
    h3("Words randomly generated"),
    verbatimTextOutput("oid4"),
    h3('Frequency matrix'),
    plotOutput('matrix'),
    p('This graph shows how frequently the letter on the x axis is followed by the letter on the y axis in the french language.'),
    p('White means the sequence does not exist, blue means low frequency, red means high frequency.'),
    p('Dashes represent the beginning of a word on the x axis, the end of a word on the y axis.')
  )
))