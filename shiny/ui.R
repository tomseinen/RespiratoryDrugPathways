library(shinydashboard)
library(shiny)
library(DT)
library(plotly)

addInfo <- function(item, infoId) {
  infoTag <- tags$small(
    class = "badge pull-right action-button",
    style = "padding: 1px 6px 2px 6px; background-color: steelblue;",
    type = "button",
    id = infoId,
    "i"
  )
  item$children[[1]]$children <-
    append(item$children[[1]]$children, list(infoTag))
  return(item)
}

dashboardPage(
  dashboardHeader(title = "Pathways Results"),
  dashboardSidebar(
    sidebarMenu(
      id = "tabs",
      ## Tabs
      addInfo(menuItem("About", tabName = "about"), "aboutInfo"),
      addInfo(menuItem("Databases", tabName = "databases"), "databaseInfo"),
      addInfo(menuItem("Characterization", tabName = "characterization"), "characterizationInfo"),
      addInfo(menuItem("Treatment pathways", tabName = "pathways"), "treatmentPathwaysInfo"),
      # addInfo(menuItem("Analyses", tabName = "results"), "resultsInfo"),
      
      ## Option panel
      conditionalPanel(
        condition = "input.tabs=='pathways' || input.tabs=='characterization' ",
        radioButtons("viewer", label = "Viewer", choices = c("Compare databases", "Compare study populations", "Compare over time"), selected = "Compare databases")
      ),
      
      conditionalPanel(
        condition = "input.tabs=='pathways'",
      htmlOutput("dynamic_input"))
      
    )
    
  ),
  dashboardBody(
    
    tags$body(tags$div(id="ppitest", style="width:1in;visible:hidden;padding:0px")),
    tags$script('$(document).on("shiny:connected", function(e) {
                                    var w = window.innerWidth;
                                    var h = window.innerHeight;
                                    var d =  document.getElementById("ppitest").offsetWidth;
                                    var obj = {width: w, height: h, dpi: d};
                                    Shiny.onInputChange("pltChange", obj);
                                });
                                $(window).resize(function(e) {
                                    var w = $(this).width();
                                    var h = $(this).height();
                                    var d =  document.getElementById("ppitest").offsetWidth;
                                    var obj = {width: w, height: h, dpi: d};
                                    Shiny.onInputChange("pltChange", obj);
                                });
                            '),
    
    tabItems(
      tabItem(
        tabName = "about",
        br(),
        p(
          "This web-based application provides an interactive platform to explore results of Treatment Pathways Study."
        ),
        h3("Rationale and background"),
        p("To be added."),
        h3("Study Limitations"),
        p("First, for this study we will use real world data from electronic health care records. There might exist
        differences between the databases with regard to availability of certain data.
        ...
        Finally, the databases are a subsample of the full population and results should be used with caution
        when attempting to infer the results nation-wide."),
        h3("Development Status"),
        p(
          " The results in this application are currently under review and should be treated as preliminary at this moment."
        )
      )
      ,
      tabItem(
        tabName = "databases",
        includeHTML("./html/databasesInfo.html")
      ),
      tabItem(tabName = "characterization",
              box(
              )
      ),
      tabItem(tabName = "pathways",
              column(width = 6, 
                     box(
                       title = "Treatment Pathways", width = NULL, status = "primary",
                       htmlOutput("sunburstplots"))),
              column(width = 3, tags$img(src = paste0("workingdirectory/plots/legend.png"), height = 400))
      ),
      tabItem(
        tabName = "results",
        
        tabsetPanel(
          id = "resultTabsetPanel",
          
          tabPanel(
            "Tables",
            br(),
            textOutput("tableATitle"),
            br(),
            
            conditionalPanel(condition = "input.analysis != 'Indications' && input.analysis != 'Renal Impairment'",
            ),
            conditionalPanel(condition = "input.analysis == 'Indications'",
            ),
            hr(),
            textOutput("tableBTitle"),
            br(),
            dataTableOutput("TableB")
          ),
          
          tabPanel(
            "Figures",
            br(),
            conditionalPanel(condition = "input.analysis == 'Observation Period'",
                             p("Figure 7: Observation Period per database"),
                             br(),
                             girafeOutput("observationPeriodHistogram", height = "100%")),
            
            
            conditionalPanel(
              condition = "input.analysis != 'Observation Period'",
              
              textOutput("FigureTitle"),
              br(),
              plotOutput("BoxplotBxp", height = 700),
              plotlyOutput("BoxplotPlotly")
            )
            
          )
        )
      )
    )
  )
)