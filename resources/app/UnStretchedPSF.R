UnstretchedPSF <- function(PSFval,
                        Clr,
                        Preview,
                        input_file,
                        input){
  
  modelname <- paste0("Unstretched/81_1_FWHM_", PSFval ,".RDS")
  new_model <- readRDS(modelname)
  file_to_read1 = input_file
  
    if(Clr == "Color"){
      #tif2 <- readTIFF(file_to_read1$datapath)
      
      if(Preview == "Preview"){
        
        tif2 <- readFITS(file_to_read1$datapath)
        tif2 <- tif2$imDat
        #tif2 <- readFITS(file_to_read1$datapath)
        r1 <- round(0.45*nrow(tif2),0)
        r2 <- round(0.55*nrow(tif2), 0)
        c1 <- round(0.45*ncol(tif2), 0)
        c2 <- round(0.55*ncol(tif2), 0)
        tif2 <- tif2[r1:r2, c1:c2, ]
        #tif2 <- tif2/max(tif2)
        tif2 <- as.cimg(tif2) %>%
          as.matrix()
      } else{
        tif2 <- readFITS(file_to_read1$datapath)
        tif2 <- tif2$imDat
        #tif2 <- tif2/max(tif2)
        tif2 <- as.cimg(tif2) %>%
          as.matrix()
      }
      
      RGBdf <- data.frame(R = as.vector(tif2[,,1]),
                          G = as.vector(tif2[,,2]),
                          B = as.vector(tif2[,,3]))
      
      LuvDF <- convertColor(RGBdf, from = "sRGB", to = "Luv")
      
      tif1 <- matrix(LuvDF[,1], nrow = nrow(tif2))/100
      
      
    } else(
      if(Preview == "Preview"){
        tif1 <- readFITS(file_to_read1$datapath)
        tif1 <- tif1$imDat
        r1 <- round(0.45*nrow(tif1),0)
        r2 <- round(0.55*nrow(tif1), 0)
        c1 <- round(0.45*ncol(tif1), 0)
        c2 <- round(0.55*ncol(tif1), 0)
        tif1 <- tif1[r1:r2, c1:c2]
        #tif1 <- tif1/max(tif1)
        tif1 <- as.cimg(tif1) %>%
          as.matrix()
      } else{
        tif1 <- readFITS(file_to_read1$datapath)
        tif1 <- tif1$imDat
        #tif1 <- tif1/max(tif1)
        tif1 <- as.cimg(tif1) %>%
          as.matrix()
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
    testsamp2 <- (testsamp2 - min(testsamp2))/(max(testsamp2) - min(testsamp2))
    #testsamp2 <- testsamp2/(2^16)
    if(Clr == "Color"){
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
    session$onSessionEnded(function() {
      stopApp()
      #q("no")
    })
  }
  
