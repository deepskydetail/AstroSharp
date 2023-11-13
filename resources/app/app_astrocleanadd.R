#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source('GetMatrixFun9x9.R')
source('GetMatrixFun.R')
library(shinycssloaders)
library(neuralnet)
library(dplyr)
library(ggthemes)
library(tiff)
library(htmltools)
library(reshape2)
library(shinycssloaders)
library(waveslim)
library(imager)
library(bslib)
library(parallel)
library(foreach)
library(doParallel)
library(doSNOW)
library(shinyWidgets)



# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = bs_theme(version = 4, bootswatch = "darkly"),
  
  # Application title
  titlePanel("Deep Sky DeTools by Deep Sky Detail"),
  # Horizontal line ----
  tags$hr(),
  
  fluidRow(
    column(6,
           fileInput("file1", "Choose tif/tiff File",
                     multiple = TRUE,
                     accept = c(".tif", ".tiff")),
           selectInput("NNModel", "Choose Model",
                          c("First Beta",
                            "Second Beta",
                            "PSF Model (Pre-Beta)",
                            "Hybrid Model",
                            #"Linear PSF (Pre-Beta)",
                            "AstroClean"),
                          selected = list("PSF Model (Pre-Beta)")),
           #actionButton("SelectModel", label = "Update Model", icon =  icon("refresh")),
           tags$hr(),
           # radioButtons("NNModel", "Choose Model",
           #              c("First Beta",
           #                "Second Beta",
           #                "PSF Model (Pre-Beta)",
           #                "Linear PSF (Pre-Beta)"),
           #              selected = list("PSF Model (Pre-Beta)")),
           
           radioButtons("Color", "Type of Image",
                        c("Color",
                          "Black and White"),
                        selected = list("Color")) ,
           radioButtons("Preview", "Preview?",
                        c("Preview",
                          "Full Image"),
                        selected = list("Preview")),
           tags$hr(),
           tags$hr(),
           tags$hr(),
           downloadButton('downloadTiff', "Download Processed File")
           ),
  column(6,
         #tags$hr(),
         # Input File
         radioButtons("MC", "Multicore CPU Processing?",
                      c("Single Core",
                        "Multicore"),
                      selected = list("Single Core")),
         sliderInput(
           inputId = "seg",
           label = "Processing Chunk Size (does NOT affect output)",
           min = 50,
           max = 750,
           value = 325,
           step = 1
         ),
         sliderInput(
           inputId = "PSF",
           label = "70% of PSF in FWHM (pixels)",
           min = 1,
           max = 8,
           value = 3,
           step = 0.25
         ),
         #actionButton("Process", label = "Update PSF", icon =  icon("refresh")),
         #tags$hr(),
         sliderInput(
           inputId = "Clean",
           label = "Aggressiveness",
           min = 0.01,
           max = 1,
           value = 0.66,
           step = 0.01
         ),
         actionButton("Cleaning", label = "Update Sliders", icon =  icon("refresh")),
         )
                  ),
  
  
  
  # Horizontal line ----
  

  
  # Show a plot 
  mainPanel(" ", width = 12,
            fluidRow(
              column(width = 5, plotOutput("p1"), offset = 0, style='padding:1px;'),
              column(width = 1, noUiSliderInput(
                inputId = "prev_y", label = "",
                min = .2, max = .9, step = .01,
                value = c(.5),
                color = "#006999",
                orientation = "vertical",
                width = "1px", height = "300px",
                padding = 0,
                update_on = "end"
              ), offset = 0, style='padding:10px;'),
              column(width = 5, plotOutput("p2"), offset = 0, style='padding:1px;'),
              column(width = 1)
              # splitLayout(
              #   cellWidths = c("45%", "45%"),
              #   column(width = 1),
              #   plotOutput("p1", width = 500),
              #  plotOutput("p2", width = 500) %>% 
              #   withSpinner(color="grey")
              ),
            fluidRow(
              column(width = 6, noUiSliderInput(
                inputId = "prev_x", label = "",
                min = .2, max = .9, step = .01,
                value = c(.5),
                color = "#006999",
                orientation = "horizontal",
                width = "80%", height = "20px",
                padding = 0,
                update_on = "end"
              ), offset = 0, style='padding:0px;'),
              column(width = 2)
            )),
              
            # fluidRow(
            #   plotOutput("p2", height = 500)%>% withSpinner(color="grey")
            # ),
            
              column(width = 12,
                tags$h5("Keep this tool working"),
              #HTML("<p>If you enjoyed this tool, please consider <a href='https://www.gofundme.com/f/help-create-an-accessible-astro-sharpening-tool'>donating</a>!</p>")
              HTML("<p>If you enjoyed this tool, please consider donating at https://www.gofundme.com/f/help-create-an-accessible-astro-sharpening-tool</p>")
            ),
              tags$div("
                         1) You can only upload TIF/TIFF files", tags$br(),
                       " 2) Please email me feedback at deepskydetail@gmail.com.", tags$br(),
                       " 3) Sample Images are given as examples.",tags$br(),
                       " 4) The image should be a flattened image (no alpha channel; only one layer)", tags$br(),
                       " 5) The PSF function only affects the PSF model. Measure the FWHM of a smallish, non-saturated star and divide by 2.35", tags$br(),
                       
                       "With more development, I hope to make the app accept color images, large files etc. Help make astronomy accessible!")
) 



#Server
server <- function(input, output, session) {
  options(shiny.maxRequestSize=10000*1024^2,
          digits = 12)
  #library(devtools)
  #library(reticulate)
  #library(keras)
  #library(kerasR)
  #library(tensorflow)
  library(dplyr)
  library(tiff)
  #library(raster)
  #library(ggplot2)
  library(reshape2)
  library(shinycssloaders)
  library(parallel)
  library(foreach)
  library(doParallel)
  library(doSNOW)
  source('First3BetasFun.R')
  source('Combined_Sharpen_and_Clean.R')
  source('Combined_Sharpen_and_Clean_Multicore.R')
  source('First3BetasFunMultiCore.R')
  #library(rasterVis)
  par(mar = c(1,1,1,1))
  
  
  
  

  input_file <- reactive({
    file <- input$file1
  })
  
  
  prevx <- reactive({
    filetoread <- input_file()
    if(ncol(readTIFF(filetoread$datapath)) > nrow(readTIFF(filetoread$datapath))){
      input$prev_y} else{
        input$prev_x
      }
  })
  
  prevy <- reactive({
    filetoread <- input_file()
    if(ncol(readTIFF(filetoread$datapath)) > nrow(readTIFF(filetoread$datapath))){
      (1.1)- input$prev_x} else{
        input$prev_y
      }
  })
  
  seg <- eventReactive(input$Cleaning,{
    isolate(input$seg)
  })
  
  hy <- reactive({
    input$HybridVal
  })
  
  MC <- eventReactive(input$Cleaning,{
    isolate(input$MC)
  })
  
  # NNModeltemp <- eventReactive(input$SelectModel,{
  #   isolate(input$NNModel)
  # })
  
  NNModeltemp <- reactive({
    input$NNModel
  })
  
  old_model <- readRDS("FourierNN1New_App.RDS") #load_model_tf('saved_model/10000_model_blurry')
  keras_model <- readRDS("NeuralNetKerasWeights_App.RDS") #load keras model but with NN
  NoNoiseNN <- readRDS("FourierNNPointNoNoiseNew1.5_App.RDS") 
  KerasMoreNoise <- readRDS("MoreBlurryAddedNoiseNN_App.RDS")
  
  
  Clr <- reactive({
    input$Color
  })
  
  PSFval <- eventReactive(input$Cleaning,{
    isolate(input$PSF)
  })
  
  Cleanval <- eventReactive(input$Cleaning,{
    isolate(input$Clean)
  })
  
  Preview <- reactive({
    input$Preview
  })
    
    preproc <- reactive({
      
      if(MC() == "Single Core"){
        if(NNModeltemp() != "Hybrid Model"){
          First3Betas(NNModeltemp,
                      PSFval,
                      Clr,
                      Preview,
                      input_file,
                      Cleanval,
                      input,
                      old_model,
                      keras_model,
                      NoNoiseNN,
                      KerasMoreNoise,
                      prevx,
                      prevy,
                      seg)
        } else{
          MixedPSFModel(NNModeltemp,
                        PSFval,
                        Clr,
                        Preview,
                        input_file,
                        Cleanval,
                        input,
                        hy,
                        prevx,
                        prevy,
                        seg)
        }
      } else{
        if(NNModeltemp() != "Hybrid Model"){
          First3BetasMC(NNModeltemp,
                      PSFval,
                      Clr,
                      Preview,
                      input_file,
                      Cleanval,
                      input,
                      old_model,
                      keras_model,
                      NoNoiseNN,
                      KerasMoreNoise,
                      prevx,
                      prevy,
                      seg)
        } else{
          MixedPSFModelMC(NNModeltemp,
                        PSFval,
                        Clr,
                        Preview,
                        input_file,
                        Cleanval,
                        input,
                        hy,
                        prevx,
                        prevy,
                        seg)
        }
      }
      
      
      


    })
    
  
  
  
  
  #})
  
  
  output$p1 <-renderPlot({
    file_to_read = input_file()
    if(is.null(file_to_read)){
      if(input$Color == "Color"){
        file2 = readTIFF("CT1.tif")
      }
      else(file2 = readTIFF("T1.tif"))
      par(bg ="dark grey", mar=c(0,0,1,0))
      if(ncol(file2) > nrow(file2)){
        rot <- 90
      }else(
        rot <- 0
      )
      plot(imrotate(as.cimg(file2), angle = rot), main = "Sample Blurred Image", axes = FALSE)

    }
    else{
      if(Preview() == "Preview"){
        file1 = readTIFF(file_to_read$datapath)
        r1 <- round((prevx()-0.05)*nrow(file1),0)
        r2 <- round((prevx()+0.05)*nrow(file1), 0)
        c1 <- round((prevy()-0.05)*ncol(file1), 0)
        c2 <- round((prevy()+0.05)*ncol(file1), 0)
        
        if(input$Color == "Color"){
          file2 <- file1[r1:r2, c1:c2,]
        } else{
          file2 <- file1[r1:r2, c1:c2]
        }
        
        
      } else{
        file2 = readTIFF(file_to_read$datapath)
      }
      
      par(bg ="dark grey", mar=c(0,0,1,0))
      if(ncol(file2) > nrow(file2)){
        rot <- 90
      }else(
        rot <- 0
      )
      plot(imrotate(as.cimg(file2), angle = rot), main = "Your Original Image", axes = FALSE)
      
    }
  }, res = 150)
  
  output$p2 <-renderPlot({  
    file_to_read = input_file()
    if(is.null(file_to_read)){
      if(input$Color == "Color"){
        file2 = readTIFF("CR1.tif")
      }
      else(file2 = readTIFF("R1.tif"))
      par(bg ="dark grey", mar=c(0,0,1,0))
      
      if(ncol(file2) > nrow(file2)){
        rot <- 90
      }else(
        rot <- 0
      )
      plot(imrotate(as.cimg(file2), angle = rot), main = "Sample Processed Image", axes = FALSE)
    }
    else{
      file2 = preproc()
      temp = file2
      par(bg ="dark grey", mar=c(0,0,1,0))
      if(ncol(file2) > nrow(file2)){
        rot <- 90
      }else(
        rot <- 0
      )
      plot(imrotate(as.cimg(file2),angle = rot), main = "Your Processed Image", axes = FALSE)
    }
    
  }, res = 150)
  
  output$downloadTiff <- downloadHandler({
    filename = 	function(){
      
      paste0( "Processed_", Sys.Date(),".tif")
    }},
    
    {content = function(file){
      
      writeTIFF(preproc(), file, bits.per.sample = 16)
    }}
    
    
    
  )
  
  
  
  
  session$onSessionEnded(function() {
    stopApp()
    #q("no") 
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
