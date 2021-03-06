library(shiny)
library(shinyalert)
library(shinyjs)
library(shinyMatrix)
library(shinyBS)
library(SemNeT)

# Interface for SemNeT----
ui <- (
  
  navbarPage(title = "Semantic Network Analysis with SemNeT", id = "tabs",
             
             # Load Data Panel
             tabPanel(
               "Load Data",
               
               # Input
               sidebarPanel(
                 
                 # Environment objects
                 uiOutput("clean_ui"), uiOutput("group_ui"),
                 
                 # Data upload
                 tags$div(fileInput("data", label = "Upload Preprocessed (Binary) Response Matrix",
                                    accept = c(".rds", ".csv", ".xls", ".xlsx", ".txt")), id = "data"),
                 
                 # Group variable upload
                 tags$div(fileInput("group", label = "Upload Group Variable"), id = "group"),
                 
                 # Data Example
                 actionButton("data_example", label = "See Response Matrix Example", inline = TRUE),
                 
                 # Group Example
                 actionButton("group_example", label = "See Group Variable Example", inline = TRUE),
                 
                 br(), br(),
                 
                 actionButton("load_data", label = "Load Data")
                 
               ),
               
               # Output
               tagList(
                 
                 mainPanel(
                   
                   tableOutput("example_data_response"),
                   
                   tableOutput("example_data_binary"),
                   
                   tableOutput("example_group")
                   
                 ),
                 
                 tags$footer(htmlOutput("SEMNA_cite"), align = "left", style = "position:absolute; top:0; width:30%; height:50px; color: black; margin-left: 20px; margin-top: 500px; z-index: 1000;")
                 
               )
               
             ),
             
             # Network Estimation Panel
             tabPanel(
               "Network Estimation",
               
               # Input
               sidebarPanel(
                 
                 # Network estimation method
                 selectInput("estimation", "Network Estimation Method", c("Community Network (CN)",
                                                                          "Naive Random Walk (NRW)",
                                                                          "Pathfinder Network (PN)",
                                                                          "Triangulated Maximally Filtered Graph (TMFG)"
                 )),
                 
                 
                 uiOutput("network_options_1"),
                 
                 uiOutput("network_options_2"),
                 
                 actionButton("run_est", label = "Estimate Networks"),
                 
                 actionButton("reset", label = "Clear Results")
                 
               ),
               
               # Output
               tagList(
                 
                 mainPanel(
                   
                   plotOutput("viz"),
                   tableOutput("measures")
                   
                 ),
                 
                 tags$footer(htmlOutput("net_cite"), align = "left", style = "position:absolute; top:0; width:30%; height:50px; color: black; margin-left: 20px; margin-top: 500px; z-index: 1000;")
                 
               )
               
             ),
             
             # Random Network Analyses Panel
             tabPanel(
               "Random Network Analyses",
               
               # Input
               sidebarPanel(
                 
                 numericInput("iters_rand", label = "Number of Iterations", value = 1000, min = 0, step = 100),
                 
                 uiOutput("cores_rand"),
                 
                 actionButton("run_rand", label = "Run Random Network Analyses")
                 
               ),
               
               # Output
               tagList(
                 
                 mainPanel(
                   
                   tableOutput("randnet")
                   
                 ),
                 
                 tags$footer(htmlOutput("randnet_cite"), align = "left", style = "position:absolute; top:0; width:30%; height:50px; color: black; margin-left: 20px; margin-top: 500px; z-index: 1000;")
                 
               )
               
             ),
             
             # Bootstrap Network Analyses Panel
             tabPanel(
               "Bootstrap Network Analyses",
               
               # Input
               sidebarPanel(
                 
                 uiOutput("type"),
                 
                 numericInput("iters_boot", label = "Number of Iterations", value = 1000, min = 0, step = 100),
                 
                 uiOutput("cores_boot"),
                 
                 actionButton("run_boot", label = "Run Bootstrap Analyses"),
                 
                 actionButton("run_plot", label = "Generate Bootstrap Plots")
                 
               ),
               
               # Output
               tagList(
                 
                 mainPanel(
                   tableOutput("aspl"),
                   tableOutput("cc"),
                   tableOutput("q"),
                   tableOutput("tab"),
                   plotOutput("asplPlot"),
                   plotOutput("ccPlot"),
                   plotOutput("qPlot")
                 ),
                 
                 tags$footer(htmlOutput("partial_cite"), align = "left", style = "position:absolute; top:0; width:30%; height:50px; color: black; margin-left: 20px; margin-top: 500px; z-index: 1000;")
                 
               )
               
             ),
             
             # Random Walk Analyses Panel
             tabPanel(
               "Random Walk Analyses",
               
               # Input
               sidebarPanel(
                 
                 uiOutput("A"),
                 
                 uiOutput("B"),
                 
                 numericInput("steps", label = "Starting Number of Steps", value = 10, min = 0, max = Inf, step = 1),
                 
                 numericInput("reps", label = "Number of Repetitions (Each Repetition Increases Number of Steps by 10)", value = 20, min = 0, max = Inf, step = 5),
                 
                 numericInput("iters_walk", label = "Number of Iterations", value = 10000, min = 0, max = Inf, step = 1000),
                 
                 uiOutput("cores_walk"),
                 
                 actionButton("run_walk", label = "Run Random Walk Analyses")
                 
               ),
               
               # Output
               tagList(
                 
                 mainPanel(
                   
                   tableOutput("walk_rand")
                   
                 ),
                 
                 tags$footer(htmlOutput("randwalk_cite"), align = "left", style = "position:absolute; top:0; width:30%; height:50px; color: black; margin-left: 20px; margin-top: 650px; z-index: 1000;")
                 
               )
               
             ),
             
             # Spreading Activation Analyses Panel
             tabPanel(
               "Spreading Activation Analyses",
               
               # Input
               sidebarPanel(
                 
                 uiOutput("network_select"),
                 
                 numericInput("retention", label = "Retention (proportion of activation that remains in spreading node)", value = 0.5, min = 0, max = 1, step = .10),
                 
                 numericInput("time", label = "Number of Time Steps", value = 10, min = 0, max = Inf, step = 1),
                 
                 numericInput("decay", label = "Decay (activation lost at each time step)", value = 0, min = 0, max = 1, step = .10),
                 
                 numericInput("suppress", label = "Suppress (activation less than value is set to zero)", value = 0, min = 0, max = Inf, step = 1),
                 
                 actionButton("set_act", label = "Set Activations"),
                 
                 shinyBS::bsModal("node_pop", title = "Node Activation Table", trigger = "set_act", size = "large",
                                  uiOutput("node_select")
                 ),
                 
                 actionButton("run_spr_act", label = "Run Spreading Activation Analyses"),
                 
                 selectInput("animate_size", label = "Plot Size",
                             choices = c("Small (500 x 500)", "Medium (900 x 900)", "Large (1400 x 1400)"),
                             selected = "Medium (900 x 900)"),
                 
                 actionButton("animate", label = "Generate Spreading Activation Plot"),
                 
                 actionButton("reset_act", label = "Reset Spreading Activation")
                 
               ),
               
               # Output
               tagList(
                 
                 mainPanel(
                   
                   uiOutput("animate_slider"),
                   
                   plotOutput("spreadr_animate")
                   
                 ),
                 
                 tags$footer(htmlOutput("spreadr_cite"), align = "left", style = "position:absolute; top:0; width:30%; height:50px; color: black; margin-left: 20px; margin-top: 525px; z-index: 1000;")
                 
               )
               
             ),
             
             # Use shinyalert
             shinyalert::useShinyalert(),
             
             # Use shinyjs
             shinyjs::useShinyjs()
             
  )
)