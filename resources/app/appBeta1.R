#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
source('GetMatrixFun.R')
library(shinycssloaders)
#library(devtools)
#library(reticulate)
#library(keras)
#library(tensorflow)
library(neuralnet)
library(dplyr)
library(tiff)
#library(raster)
#library(ggplot2)
library(htmltools)
library(reshape2)
#library(shinycssloaders)
library(waveslim)
library(imager)
#library(rasterVis)

# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Application title
  titlePanel("Deep Sky Detail"),
  # Horizontal line ----
  tags$hr(),
  
  sliderInput(
    inputId = "seg",
    label = "Processing Chunk Size",
    min = 10,
    max = 750,
    value = 325,
    step = 1
  ),
  # Horizontal line ----
  
  tags$hr(),
  # Input File
  fileInput("file1", "Choose tif/tiff File",
            multiple = TRUE,
            accept = c(".tif", ".tiff")),
  
  # Show a plot 
  mainPanel(" ",
            fluidRow(
              plotOutput("p1", height = 500)),
            fluidRow(
              plotOutput("p2", height = 500)%>% withSpinner(color="grey")
            ),
            
            fluidRow(
              tags$h5("Keep this tool working"),
              HTML("<p>If you enjoyed this tool, please consider <a href='https://www.gofundme.com/f/help-create-an-accessible-astro-sharpening-tool'>donating</a>!</p>")
            ),
            fluidRow(
              tags$div("
                        1) You can only upload TIFF files", tags$br(),
                       "2) Because this is in beta stage, the files cannot be larger than...?", tags$br(),
                       "3) The image should be in black and white",tags$br(),
                       "4) The image cannot have an alpha channel", tags$br(),
                       "5) Do not sharpen your image before uploading it. Just upload a calibrated, stretched image tags", tags$br(),
                       
                       "With more development, I hope to make the app accept color images, large files etc. Help make astronomy accessible!")
            ),
            downloadButton('downloadTiff', "Download Sharpened File"))
) 



#Server
server <- function(input, output, session) {
  options(shiny.maxRequestSize=10000*1024^2)
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
  #library(rasterVis)
  par(mar = c(1,1,1,1))
  
  
  
  
  new_model <- readRDS("FourierNN1New_App.RDS") #load_model_tf('saved_model/10000_model_blurry')
  keras_model <- readRDS("NeuralNetKerasWeights_App.RDS") #load keras model but with NN
  NoNoiseNN <- readRDS("FourierNNPointNoNoiseNew1.5_App.RDS") 
  KerasMoreNoise <- readRDS("MoreBlurryAddedNoiseNN_App.RDS")
  
  input_file <- reactive({
    file <- input$file1
  })
  
  preproc <- reactive({
    
    file_to_read1 = input_file()
    tifimg <- readTIFF(file_to_read1$datapath)
    
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
                     
                     for(j in 2:length(rowseq)){
                       incProgress(amount = 1/(length(rowseq)*length(colseq)) )
                       
                       invisible(gc())
                       
                       if((colseq[i-1]) == 1 & (rowseq[j-1])==1){
                         chunk <- tifimg[rowseq[j-1]:(rowseq[j]-1), colseq[i-1]:(colseq[i]-1)]
                         chunkmat <- getmatrix(chunk)
                         
                         tempvals1 <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:27]))
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
                           
                           tempvals1 <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:27]))
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
                             
                             tempvals1 <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:27]))
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
                             
                             tempvals1 <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:27]))
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
    
    
    
    
    
    
    # withProgress(message = "Reading File", min = 0.1,{
    #   tifimg <- readTIFF(file_to_read1$datapath)
    #   mine1 = file_to_read1$datapath
    # })
    # 
    # 
    # # withProgress(message = "Analyzing Pixels", min = 0.3,{
    # #   mine2.1 <- getmatrix(tifimg)
    # #   #mine2.1 <- as.data.frame(mine2.1)
    # #   })
    # 
    # withProgress(message = "Sharpening Pixels", detail = "This will take a while", min = 0.5,{
    #   
    #   expg <- expand.grid(3:(nrow(tifimg)-2), 3:(ncol(tifimg)-2))
    #   
    #   for(i in 1:length(expg$Var1)){
    #     
    #     
    #     
    #     
    #   }
    #   
    #   pred <- data.frame(y = predict(new_model, as.matrix(mine2.1[,1:27])))
    #   #pred = as.numeric(keras_predict(new_model, mine2.1[,1:27], batch_size = 16 ))
    #   
    # })
    # 
    # 
    # withProgress(message = "Combining Image", min = 0.7,{
    # testsamp <- as.numeric(pred)
    # 
    # ncol1 <- ncol(tifimg)
    
    testsamp <- fill_matrix(predvals, rowvals, colvals)
    
    #testsamp <- denoise.modwt.2d(testsamp, wf="d4", rule = "hard", J = 1)
    
    #testsamp <- ifelse(testsamp > 1, 1, testsamp)
    
    return(testsammat <- testsamp[3:nrow(testsamp), 3:ncol(testsamp)])
  })
  
  #})
  
  
  output$p1 <-renderPlot({
    file_to_read = input_file()
    if(is.null(file_to_read)){
      file2 = readTIFF("T1.tif")
      #file3 = melt(file2)
      plot(as.cimg(file2), main = "Original Preview")
      # ggplot(file3, aes(x = (Var2), y = rev(Var1))) + 
      #   geom_tile(aes(fill = value)) +
      #   scale_fill_gradient(low = 'black', high = 'white', breaks = seq(0,1,.001)) + coord_equal() + theme_void() + theme(legend.position = "none", axis.title = element_blank(), axis.text = element_blank(), plot.title = element_text(size = 4, face = "bold")) + ggtitle("Blurry Image Preview")
    }
    else{
      file2 = readTIFF(file_to_read$datapath)
      #file3 = melt(file2)
      plot(as.cimg(file2), main = "Original Preview")
      # ggplot(file3, aes(x = (Var2), y = rev(Var1))) + 
      #   geom_tile(aes(fill = value)) +
      #   scale_fill_gradient(low = 'black', high = 'white', breaks = seq(0,1,.001)) + coord_equal() + theme_void() + theme(legend.position = "none", axis.title  = element_blank(), axis.text = element_blank(), plot.title = element_text(size = 4, face = "bold"))+ ggtitle("Blurry Image Preview")  
      
    }
  }, res = 75, width  = 500)
  
  output$p2 <-renderPlot({  
    file_to_read = input_file()
    if(is.null(file_to_read)){
      file2 = readTIFF("R1.tif")
      #file3 = melt(file2)
      plot(as.cimg(file2), main = "Sharpened Preview")
      # ggplot(file3, aes(x = (Var2), y = rev(Var1))) + 
      #   geom_tile(aes(fill = value)) +
      #   scale_fill_gradient(low = 'black', high = 'white', breaks = seq(0,1,.001)) + coord_equal() + theme_void() + theme(legend.position = "none", axis.title = element_blank(), axis.text = element_blank(), plot.title = element_text(size = 4, face = "bold"))+ ggtitle("Sharpened Image Preview")
    }
    else{
      file2 = preproc()
      temp = file2
      #file3 = melt(file2)
      plot(as.cimg(file2), main = "Sharpened Preview")
      # ggplot(file3, aes(x = (Var2), y = rev(Var1))) + 
      #   geom_tile(aes(fill = value)) +
      #   scale_fill_gradient(low = 'black', high = 'white', breaks = seq(0,1,.001)) + coord_equal() + theme_void() + theme(legend.position = "none", axis.title = element_blank(), axis.text = element_blank(), plot.title = element_text(size = 4, face = "bold"))+ ggtitle("Sharpened Image Preview")
    }
    
  }, res = 75, width  = 500)
  
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
  })
}

# Run the application 
shinyApp(ui = ui, server = server)
