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
    p('This useless though entertaining application generates french look-alike words.'),
    verbatimTextOutput("oid4"),
    h3('Frequency matrix'),
    plotOutput('matrix'),
    p('This graph shows how frequently the letter on the x axis is followed by the letter on the y axis in the french language.'),
    p('White means the sequence does not exist, blue means low frequency, red means high frequency.'),
    p('Dashes represent the beginning of a word on the x axis, the end of a word on the y axis.'),
    h3('Concept description'),
    p('The concept is simple. The application reads a corpus of 300k+ words collected from french books and records the frequency of each 2 letter sequence (as shown in matrix above) as well as 3 letters sequence (not shown)'),
    p('The application then runs a markov chain to build words that look french. Since the initial corpus is based on book extracts and not a standard dictionnary, nouns are not necessary in singular for or verbs in infinitive form.'),
    h3('Version'),
    p('Grégory Vial, 2016, June 23rd'),
    p('Sources: https://github.com/GregVial/WordGenerator'),
    p('The inspiration for this application comes from David Louapre: sciencetonnante@gmail.com')
  )
))