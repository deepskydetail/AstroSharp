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



# Define UI for application that draws a histogram
ui <- fluidPage(
  theme = bs_theme(version = 4, bootswatch = "darkly"),
  
  # Application title
  titlePanel("AstroSharp by Deep Sky Detail"),
  # Horizontal line ----
  tags$hr(),
  
  fluidRow(
    column(6,
           fileInput("file1", "Choose tif/tiff File",
                     multiple = TRUE,
                     accept = c(".tif", ".tiff")),
           radioButtons("NNModel", "Choose Model",
                        c("First Beta",
                          "Second Beta",
                          "PSF Model (Pre-Beta)"),
                        selected = list("PSF Model (Pre-Beta)")),
           
           radioButtons("Color", "Type of Image",
                        c("Color",
                          "Black and White"),
                        selected = list("Color")) ,
           radioButtons("Preview", "Preview?",
                        c("Preview",
                          "Full Image"),
                        selected = list("Preview"))
           ),
  column(6,
         #tags$hr(),
         # Input File
         sliderInput(
           inputId = "seg",
           label = "Processing Chunk Size (does NOT affect output)",
           min = 10,
           max = 750,
           value = 325,
           step = 1
         ),
         sliderInput(
           inputId = "PSF",
           label = "PSF in Sigma (FWHM/2.35), measured in Pixels",
           min = 1,
           max = 8,
           value = 3,
           step = 0.25
         ),
         actionButton("Process", label = "Update PSF", icon =  icon("refresh")),
         tags$hr(),
         downloadButton('downloadTiff', "Download Sharpened File")),
                  ),
  
  
  
  # Horizontal line ----
  

  
  # Show a plot 
  mainPanel(" ", width = 12,
            fluidRow(
              column(width = 6, plotOutput("p1"), offset = 0, style='padding:1px;'),
              column(width = 6, plotOutput("p2"), offset = 0, style='padding:1px;')
              # splitLayout(
              #   cellWidths = c("45%", "45%"),
              #   column(width = 1),
              #   plotOutput("p1", width = 500),
              #  plotOutput("p2", width = 500) %>% 
              #   withSpinner(color="grey")
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
  #library(rasterVis)
  par(mar = c(1,1,1,1))
  
  
  
  
  
  
  input_file <- reactive({
    file <- input$file1
  })
  
  

  
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
  
  PSFval <- eventReactive(input$Process,{
    isolate(input$PSF)
  })
  
  Preview <- reactive({
    input$Preview
  })
    
    preproc <- reactive({
      
      
      if(NNModeltemp() == "Second Beta"| NNModeltemp() == "PSF Model (Pre-Beta)"){
        
        if(NNModeltemp() == "Second Beta"){
          new_model <- readRDS("81In1OutSimple2.RDS")
        } else{
          PSFval = PSFval()
          modelname <- paste0("PSF/81_1_FWHM_", PSFval ,".RDS")
          new_model <- readRDS(modelname)
        }
       
        file_to_read1 = input_file()

      if(Clr() == "Color"){
        #tif2 <- readTIFF(file_to_read1$datapath)
        
        if(Preview() == "Preview"){
          tif2 <- readTIFF(file_to_read1$datapath)
          tif2 <- readTIFF(file_to_read1$datapath)
          r1 <- round(0.45*nrow(tif2),0)
          r2 <- round(0.55*nrow(tif2), 0)
          c1 <- round(0.45*ncol(tif2), 0)
          c2 <- round(0.55*ncol(tif2), 0)
          tif2 <- tif2[r1:r2, c1:c2, ]
        } else{
          tif2 <- readTIFF(file_to_read1$datapath)
        }
        
        RGBdf <- data.frame(R = as.vector(tif2[,,1]),
                            G = as.vector(tif2[,,2]),
                            B = as.vector(tif2[,,3]))
        
        LuvDF <- convertColor(RGBdf, from = "sRGB", to = "Luv")
        
        tif1 <- matrix(LuvDF[,1], nrow = nrow(tif2))/100
        
        
      } else(
        #tif1 <- readTIFF(file_to_read1$datapath)
        if(Preview() == "Preview"){
          tif1 <- readTIFF(file_to_read1$datapath)
          r1 <- round(0.45*nrow(tif1),0)
          r2 <- round(0.55*nrow(tif1), 0)
          c1 <- round(0.45*ncol(tif1), 0)
          c2 <- round(0.55*ncol(tif1), 0)
          tif1 <- tif1[r1:r2, c1:c2]
        } else{
          tif1 <- readTIFF(file_to_read1$datapath)
        }
      )
      
      
      tifimg <- matrix(0, nrow = nrow(tif1) + 8,
                       ncol = ncol(tif1) + 8)
      tifimg[5:(nrow(tifimg)-4 ), 5:(ncol(tifimg)-4 )] <- tif1 ## Do some padding
      
      
      
      nseg <- as.numeric(input$seg) ## figure out how many segments
      
      colmat <- col(tifimg)
      rowmat <- row(tifimg)
      
      
      colseq <- seq(1, ncol(tifimg), nseg)
      
      if(colseq[length(colseq)] != ncol(tifimg)){
        colseq <- c(colseq, ncol(tifimg))
      } else{colseq <- colseq}
      
      rowseq <- seq(1, nrow(tifimg), nseg)
      
      if(rowseq[length(rowseq)] != nrow(tifimg)){
        rowseq <- c(rowseq, nrow(tifimg))
      } else{rowseq <- rowseq}
      
      nr <- nrow(tifimg)
      nc <- ncol(tifimg)
      
      predvals <- vector()
      colvals <- vector()
      rowvals <- vector()
      
      # n.cores <- parallel::detectCores() - 1
      # cl <- makeCluster(n.cores)
      # registerDoSNOW(cl)
      
      withProgress(message = "Sharpening Pixels", detail = "This will take some time...", 
                   value = 0.25,{
                     
                     for(i in 2:length(colseq)){
                     # foreach(
                     #     i = 2:length(colseq),
                     #     .combine = "c",
                     #     .multicombine = TRUE,
                     #     .export = c("predvals", "colvals", "rowvals"),
                     #     .verbose = TRUE
                     #   ) %dopar% {
                     #     source('GetMatrixFun9x9.R')
                     #     source('GetMatrixFun.R')
                       
                       for(j in 2:length(rowseq)){
                         incProgress(amount = 1/(length(rowseq)*length(colseq)) )
                       #incProgress(amount = 1/length(colseq))
                       # foreach(
                       #   j = 2:length(rowseq),
                       #   .combine = "c",
                       #   .multicombine = TRUE
                       # ) %dopar% {
                       #   source('GetMatrixFun9x9.R')
                       #   source('GetMatrixFun.R')
                         invisible(gc())
                         
                         if((colseq[i-1]) == 1 & (rowseq[j-1])==1){
                           chunk <- tifimg[rowseq[j-1]:(rowseq[j]-1), colseq[i-1]:(colseq[i]-1)] ## Get Matrix for Chunk
                           chunkmat <- getmatrix9(chunk)
                           
                           tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
                           tempvals<- as.vector(tempvals$net.result)
                           
                           ## The model only computed the innermost values of the chunk (hu1[5:(nrow(hu1)-4),5:(ncol(hu1)-4)])
                           ## Need to show this in the tempcols and temprows for the location values
                           tempcols <- as.vector(colmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
                           temprows <- as.vector(rowmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
                           
                           predvals <- c(predvals, tempvals)
                           colvals <- c(colvals, tempcols)
                           rowvals <- c(rowvals, temprows)
                           
                           
                         }else{
                           
                           if(colseq[i-1] == 1 & rowseq[j-1] >1 ){
                             
                             ##this chunk needs to start 12 rows above chunk
                             ## this will make sure it gets what 1st chunk missed
                             ## and takes into account the fact that it needs to process
                             chunk <- tifimg[(rowseq[j-1]-12):(rowseq[j]-1), colseq[i-1]:(colseq[i]-1)]
                             chunkmat <- getmatrix9(chunk)
                             
                             tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
                             tempvals<- as.vector(tempvals$net.result)
                             
                             tempcols <- as.vector(colmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
                             temprows <- as.vector(rowmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
                             
                             predvals <- c(predvals, tempvals)
                             colvals <- c(colvals, tempcols)
                             rowvals <- c(rowvals, temprows)
                             
                             
                             
                           } else{
                             if((colseq[i-1]) > 1 & (rowseq[j-1])==1){
                               ##this chunk needs to start 12 columns behind chunk
                               ## this will make sure it gets what 1st chunk missed
                               ## and takes into account the fact that it needs to process
                               chunk <- tifimg[rowseq[j-1]:(rowseq[j]-1), (colseq[i-1]-12):(colseq[i]-1)]
                               chunkmat <- getmatrix9(chunk)
                               
                               tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
                               tempvals<- as.vector(tempvals$net.result)
                               
                               tempcols <- as.vector(colmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
                               temprows <- as.vector(rowmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
                               
                               predvals <- c(predvals, tempvals)
                               colvals <- c(colvals, tempcols)
                               rowvals <- c(rowvals, temprows)
                               
                               
                             } else{
                               chunk <- tifimg[(rowseq[j-1]-12):(rowseq[j]-1), (colseq[i-1]-12):(colseq[i]-1)]
                               chunkmat <- getmatrix9(chunk)
                               
                               tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
                               tempvals<- as.vector(tempvals$net.result)
                               
                               tempcols <- as.vector(colmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
                               temprows <- as.vector(rowmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
                               
                               predvals <- c(predvals, tempvals)
                               colvals <- c(colvals, tempcols)
                               rowvals <- c(rowvals, temprows)
                               
                               
                               
                             }
                           }
                         }
                         
                       }
                     }
                     
                     
                   }
                   
                   
      )
      
      
      testsamp <- fill_matrix(predvals, rowvals, colvals) 
      testsammat <- testsamp[5:(nrow(testsamp)), 5:(ncol(testsamp))] # This is lined up with original image, but is missing last column/row, and first/last four rows/columns are junk
      testsammat <- testsammat[-c(1:4), -c(1:4)]
      testsammat <- testsammat[-c((nrow(testsammat)-3):nrow(testsammat)), -c((ncol(testsammat)-3):ncol(testsammat))]
      testsamp2 <- tif1
      testsamp2[5:(nrow(testsamp2)-5),  5:(ncol(testsamp2)-5)] <- testsammat
      if(Clr() == "Color"){
        LuvDF[,1] <- as.vector(testsamp2)*100
        
        RGB2df <- convertColor(LuvDF, from = "Luv", to = "sRGB")
        
        Rmat <- matrix(RGB2df[,1], nrow = nrow(testsamp2))
        Gmat <- matrix(RGB2df[,2], nrow = nrow(testsamp2))
        Bmat <- matrix(RGB2df[,3], nrow = nrow(testsamp2))
        
        testsamp2 <- array(c(Rmat, Gmat, Bmat), dim = c(nrow(Rmat), 
                                           ncol(Rmat),
                                           3))
        return(testsamp2)
        
      }
      else(return(testsamp2))
      
      }
      
      else{
        

          file_to_read1 = input_file()
        
          #file_to_read1 = input_file()
          if(Clr() == "Color"){
            #tif2 <- readTIFF(file_to_read1$datapath)
            if(Preview() == "Preview"){
              tif2 <- readTIFF(file_to_read1$datapath)
              r1 <- round(0.45*nrow(tif2),0)
              r2 <- round(0.55*nrow(tif2), 0)
              c1 <- round(0.45*ncol(tif2), 0)
              c2 <- round(0.55*ncol(tif2), 0)
              tif2 <- tif2[r1:r2, c1:c2,]
            } else{
              tif2 <- readTIFF(file_to_read1$datapath)
            }
            
            RGBdf <- data.frame(R = as.vector(tif2[,,1]),
                                G = as.vector(tif2[,,2]),
                                B = as.vector(tif2[,,3]))
            
            LuvDF <- convertColor(RGBdf, from = "sRGB", to = "Luv")
            
            tif1 <- matrix(LuvDF[,1], nrow = nrow(tif2))/100
            
            
          } else(
            #tif1 <- readTIFF(file_to_read1$datapath)
            if(Preview() == "Preview"){
              tif1 <- readTIFF(file_to_read1$datapath)
              r1 <- round(0.45*nrow(tif1),0)
              r2 <- round(0.55*nrow(tif1), 0)
              c1 <- round(0.45*ncol(tif1), 0)
              c2 <- round(0.55*ncol(tif1), 0)
              tif1 <- tif1[r1:r2, c1:c2]
            } else{
              tif1 <- readTIFF(file_to_read1$datapath)
            }
          )
          
          tifimg <- matrix(0, nrow = nrow(tif1) + 4,
                           ncol = ncol(tif1) + 4)
          tifimg[3:(nrow(tifimg)-2 ), 3:(ncol(tifimg)-2 )] <- tif1 ## Do some padding
          
          
          nseg <- as.numeric(input$seg)
          
          colmat <- col(tifimg)
          rowmat <- row(tifimg)
          
          
          colseq <- seq(1, ncol(tifimg), nseg)
          
          if(colseq[length(colseq)] != ncol(tifimg)){
            colseq <- c(colseq, ncol(tifimg))
          } else{colseq <- colseq}
          
          rowseq <- seq(1, nrow(tifimg), nseg)
          
          if(rowseq[length(rowseq)] != nrow(tifimg)){
            rowseq <- c(rowseq, nrow(tifimg))
          } else{rowseq <- rowseq}
          
          nr <- nrow(tifimg)
          nc <- ncol(tifimg)
          
          predvals <- vector()
          colvals <- vector()
          rowvals <- vector()
          
          withProgress(message = "Sharpening Pixels", detail = "This will take some time...", 
                       value = 0.25,{
                         
                         for(i in 2:length(colseq)){
                         # foreach(
                         #   i = 2:length(colseq),
                         #   .combine = "c",
                         #   .multicombine = TRUE,
                         #   .export = c("predvals", "colvals", "rowvals"),
                         #   .verbose = TRUE
                         # ) %dopar% {
                         #   source('GetMatrixFun9x9.R')
                         #   source('GetMatrixFun.R')
                           
                           for(j in 2:length(rowseq)){
                             incProgress(amount = 1/(length(rowseq)*length(colseq)) )
                             #incProgress(amount = 1/length(colseq))
                             # foreach(
                             #   j = 2:length(rowseq),
                             #   .combine = "c",
                             #   .multicombine = TRUE
                             # ) %dopar% {
                             #   source('GetMatrixFun9x9.R')
                             #   source('GetMatrixFun.R')
                             invisible(gc())
                             if((colseq[i-1]) == 1 & (rowseq[j-1])==1){
                               chunk <- tifimg[rowseq[j-1]:(rowseq[j]-1), colseq[i-1]:(colseq[i]-1)]
                               chunkmat <- getmatrix(chunk)
                               
                               tempvals1 <- neuralnet::compute(old_model, as.matrix(chunkmat[,1:27]))
                               tempvals1 <- as.vector(tempvals1$net.result)
                               
                               tempvals2 <- neuralnet::compute(keras_model, as.matrix(chunkmat[,1:27]))
                               tempvals2 <- as.vector(tempvals2$net.result)
                               
                               tempvals3 <- neuralnet::compute(NoNoiseNN, as.matrix(chunkmat[,1:27]))
                               tempvals3 <- as.vector(tempvals3$net.result)
                               
                               tempvals4 <- neuralnet::compute(KerasMoreNoise, as.matrix(chunkmat[,1:27]))
                               tempvals4 <- as.vector(tempvals4$net.result)
                               
                               tempvals <- 0.70*tempvals1 + 0.1*tempvals2 + 
                                 0.1*tempvals3 + 0.1*tempvals4
                               
                               
                               tempcols <- as.vector(colmat[(rowseq[j-1]+2):(rowseq[j]-3), (colseq[i-1]+2):(colseq[i]-3)])
                               temprows <- as.vector(rowmat[(rowseq[j-1]+2):(rowseq[j]-3), (colseq[i-1]+2):(colseq[i]-3)])
                               
                               predvals <- c(predvals, tempvals)
                               colvals <- c(colvals, tempcols)
                               rowvals <- c(rowvals, temprows)
                               
                               
                             }else{
                               
                               if(colseq[i-1] == 1 & rowseq[j-1] >1 ){
                                 chunk <- tifimg[(rowseq[j-1]-4):(rowseq[j]-1), colseq[i-1]:(colseq[i]-1)]
                                 chunkmat <- getmatrix(chunk)
                                 
                                 tempvals1 <- neuralnet::compute(old_model, as.matrix(chunkmat[,1:27]))
                                 tempvals1 <- as.vector(tempvals1$net.result)
                                 
                                 tempvals2 <- neuralnet::compute(keras_model, as.matrix(chunkmat[,1:27]))
                                 tempvals2 <- as.vector(tempvals2$net.result)
                                 
                                 tempvals3 <- neuralnet::compute(NoNoiseNN, as.matrix(chunkmat[,1:27]))
                                 tempvals3 <- as.vector(tempvals3$net.result)
                                 
                                 tempvals4 <- neuralnet::compute(KerasMoreNoise, as.matrix(chunkmat[,1:27]))
                                 tempvals4 <- as.vector(tempvals4$net.result)
                                 
                                 tempvals <- 0.70*tempvals1 + 0.1*tempvals2 + 
                                   0.1*tempvals3 + 0.1*tempvals4
                                 
                                 tempcols <- as.vector(colmat[(rowseq[j-1]-2):(rowseq[j]-3), (colseq[i-1]+2):(colseq[i]-3)])
                                 temprows <- as.vector(rowmat[(rowseq[j-1]-2):(rowseq[j]-3), (colseq[i-1]+2):(colseq[i]-3)])
                                 
                                 predvals <- c(predvals, tempvals)
                                 colvals <- c(colvals, tempcols)
                                 rowvals <- c(rowvals, temprows)
                                 
                                 
                                 
                               } else{
                                 if((colseq[i-1]) > 1 & (rowseq[j-1])==1){
                                   chunk <- tifimg[rowseq[j-1]:(rowseq[j]-1), (colseq[i-1]-4):(colseq[i]-1)]
                                   chunkmat <- getmatrix(chunk)
                                   
                                   tempvals1 <- neuralnet::compute(old_model, as.matrix(chunkmat[,1:27]))
                                   tempvals1 <- as.vector(tempvals1$net.result)
                                   
                                   tempvals2 <- neuralnet::compute(keras_model, as.matrix(chunkmat[,1:27]))
                                   tempvals2 <- as.vector(tempvals2$net.result)
                                   
                                   tempvals3 <- neuralnet::compute(NoNoiseNN, as.matrix(chunkmat[,1:27]))
                                   tempvals3 <- as.vector(tempvals3$net.result)
                                   
                                   tempvals4 <- neuralnet::compute(KerasMoreNoise, as.matrix(chunkmat[,1:27]))
                                   tempvals4 <- as.vector(tempvals4$net.result)
                                   
                                   tempvals <- 0.70*tempvals1 + 0.1*tempvals2 + 
                                     0.1*tempvals3 + 0.1*tempvals4
                                   
                                   tempcols <- as.vector(colmat[(rowseq[j-1]+2):(rowseq[j]-3), (colseq[i-1]-2):(colseq[i]-3)])
                                   temprows <- as.vector(rowmat[(rowseq[j-1]+2):(rowseq[j]-3), (colseq[i-1]-2):(colseq[i]-3)])
                                   
                                   predvals <- c(predvals, tempvals)
                                   colvals <- c(colvals, tempcols)
                                   rowvals <- c(rowvals, temprows)
                                   
                                   
                                 } else{
                                   chunk <- tifimg[(rowseq[j-1]-4):(rowseq[j]-1), (colseq[i-1]-4):(colseq[i]-1)]
                                   chunkmat <- getmatrix(chunk)
                                   
                                   tempvals1 <- neuralnet::compute(old_model, as.matrix(chunkmat[,1:27]))
                                   tempvals1 <- as.vector(tempvals1$net.result)
                                   
                                   tempvals2 <- neuralnet::compute(keras_model, as.matrix(chunkmat[,1:27]))
                                   tempvals2 <- as.vector(tempvals2$net.result)
                                   
                                   tempvals3 <- neuralnet::compute(NoNoiseNN, as.matrix(chunkmat[,1:27]))
                                   tempvals3 <- as.vector(tempvals3$net.result)
                                   
                                   tempvals4 <- neuralnet::compute(KerasMoreNoise, as.matrix(chunkmat[,1:27]))
                                   tempvals4 <- as.vector(tempvals4$net.result)
                                   
                                   tempvals <- 0.70*tempvals1 + 0.1*tempvals2 + 
                                     0.1*tempvals3 + 0.1*tempvals4
                                   
                                   tempcols <- as.vector(colmat[(rowseq[j-1]-2):(rowseq[j]-3), (colseq[i-1]-2):(colseq[i]-3)])
                                   temprows <- as.vector(rowmat[(rowseq[j-1]-2):(rowseq[j]-3), (colseq[i-1]-2):(colseq[i]-3)])
                                   
                                   predvals <- c(predvals, tempvals)
                                   colvals <- c(colvals, tempcols)
                                   rowvals <- c(rowvals, temprows)
                                   
                                   
                                   
                                 }
                               }
                             }
                             
                           }
                         }
                         
                         
                       }
                       
                       
          )
          
          
          
          #stopCluster(cl)
          
          testsamp <- fill_matrix(predvals, rowvals, colvals)
          testsammat <- testsamp[3:(nrow(testsamp)), 3:(ncol(testsamp))] # This is lined up with original image, but is missing last column/row, and first two rows/columns are junk
          testsammat <- testsammat[-c(1:2), -c(1:2)]
          testsammat <- testsammat[-c((nrow(testsammat)-1):nrow(testsammat)), -c((ncol(testsammat)-1):ncol(testsammat))]
          testsamp2 <- tif1
          testsamp2[3:(nrow(testsamp2)-3),  3:(ncol(testsamp2)-3)] <- testsammat
          
          
          if(Clr() == "Color"){
            LuvDF[,1] <- as.vector(testsamp2)*100
            
            RGB2df <- convertColor(LuvDF, from = "Luv", to = "sRGB")
            
            Rmat <- matrix(RGB2df[,1], nrow = nrow(testsamp2))
            Gmat <- matrix(RGB2df[,2], nrow = nrow(testsamp2))
            Bmat <- matrix(RGB2df[,3], nrow = nrow(testsamp2))
            
            testsamp2 <- array(c(Rmat, Gmat, Bmat), dim = c(nrow(Rmat), 
                                                            ncol(Rmat),
                                                            3))
            return(testsamp2)
            
          }
          else(return(testsamp2))
          
        
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
        r1 <- round(0.45*nrow(file1),0)
        r2 <- round(0.55*nrow(file1), 0)
        c1 <- round(0.45*ncol(file1), 0)
        c2 <- round(0.55*ncol(file1), 0)
        
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
      plot(imrotate(as.cimg(file2), angle = rot), main = "Sample Sharpened Image", axes = FALSE)
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
      plot(imrotate(as.cimg(file2),angle = rot), main = "Your Sharpened Image", axes = FALSE)
    }
    
  }, res = 150)
  
  output$downloadTiff <- downloadHandler({
    filename = 	function(){
      
      paste( "Sharpened", Sys.Date(),".tif", sep = "." )
    }},
    
    {content = function(file){
      
      writeTIFF(preproc(), file, bits.per.sample = 16)
    }}
    
    
    
  )
  
  
  
  
  session$onSessionEnded(function() {
    stopApp()
	q("no") 
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
