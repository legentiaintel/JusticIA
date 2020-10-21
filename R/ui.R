#
#    http://shiny.rstudio.com/
#

library(shiny)
shinyUI(fluidPage(
#shinyUI(fluidPage(theme = "bootstrap.min.css",
#    setBackgroundColor(
#        color = c("#F7FBFF", "#2171B5","#2171B8"),
#        #gradient = c("linear", "radial"),
#        #direction = c("bottom", "top", "right", "left"),
#        direction = c("top"),
#        shinydashboard = FALSE
#    ),
titlePanel("JusticIA"),
sidebarLayout(
 sidebarPanel(
 fileInput("files",label="Upload do arquivo de dados CSV",
            accept=c("txt/csv", "text/comma-separated-values,text/plain", ".csv"),
            multiple = TRUE),

  # graus selecionados e Varas selecionadas
  fluidRow(column(6,verbatimTextOutput('x01')),column(6,verbatimTextOutput('x1')),

  actionButton("do_grau", "2 Confirma grau"),
  actionButton("do_serventia", "4 Confirma serventia"),
  actionButton("do", "8 Análise de agrupamentos"),

  sliderInput("corte", "Ponto de Corte",  
              min = 5, max = 30, value = 1),
  
  sliderInput("cluster", "Agrupamentos",  
                  min = 2, max = 20, value = 1),
  
 ),
 ),
 mainPanel(
   tabsetPanel(
     tabPanel("1 Selecione grau",plotOutput("plotprograu"),DT::dataTableOutput("tablegrau")),
     tabPanel("3 Selecione serventia",plotlyOutput("plot1"),DT::dataTableOutput("tableselec"),DT::dataTableOutput("table1")),
     tabPanel("5 Status",plotOutput("plotstatus"),plotlyOutput("plotstatusx")),
     tabPanel("6 Classes e Assuntos",plotlyOutput("plotprocclasse"),plotlyOutput("plotprocassunto")),
     tabPanel("7 Perfis",plotOutput("plot2classe"),plotOutput("plot3classeall"),plotOutput("plot4assunto"),plotOutput("plot5assuntoall"),plotlyOutput("plot6")),
     tabPanel("9 Agrupamentos",plotOutput("plotca"),plotOutput("plotresumoclasse1"),DT::dataTableOutput("table2"),plotOutput("plotresumoclasse2"),plotOutput("plotresumoclasse3"),DT::dataTableOutput("table3"),plotOutput("plotcaclusters")),
     tabPanel("10 Durações",plotOutput("plotresumoduracao1"),plotOutput("plotresumoduracao2"),plotOutput("plotresumoduracao3"),plotOutput("scatterplotdura"),DT::dataTableOutput("tabledura")),     
     tabPanel("11 Metas por serventias",plotlyOutput("plotmetas"),DT::dataTableOutput("tablemetas")),     
     tabPanel("12 Exporta CSV",downloadButton("downloadDataGlobal",label="Download")),
     tabPanel("ReadMe",tags$iframe(src="readme.pdf", width="100%", height="600px"))
   )
 )
)
))