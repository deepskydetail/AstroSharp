

First3BetasMC <- function(NNModeltemp,
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
                        seg
                        ){
  if(NNModeltemp() == "Second Beta"| NNModeltemp() == "PSF Model (Pre-Beta)" |  NNModeltemp() == "AstroClean"){ #NNModeltemp() == "Linear PSF (Pre-Beta)" |
    
    if(NNModeltemp() == "Second Beta"){
      new_model <- readRDS("81In1OutSimple2.RDS")
      # if(NNModeltemp() == "Linear PSF (Pre-Beta)"){
      #   PSFval = PSFval()
      #   modelname <- paste0("Unstretched/81_1_FWHM_", PSFval ,".RDS")
      #   new_model <- readRDS(modelname)
      # }
      
    }
    if(NNModeltemp() == "AstroClean"){
      new_model <- readRDS("AstroCleanv2NoBeta.RDS")
    }
    
    if(NNModeltemp() =="PSF Model (Pre-Beta)"){
      PSFval = PSFval()
      modelname <- paste0("PSF/81_1_FWHM_", PSFval ,".RDS")
      new_model <- readRDS(modelname)
    }
    
    file_to_read1 = input_file()
    cleanvalnr = Cleanval()
    
    if(Clr() == "Color"){
      #tif2 <- readTIFF(file_to_read1$datapath)
      
      if(Preview() == "Preview"){
        tif2 <- readTIFF(file_to_read1$datapath)
        tif2 <- readTIFF(file_to_read1$datapath)
        r1 <- round((prevx()-0.05)*nrow(tif2),0)
        r2 <- round((prevx()+0.05)*nrow(tif2), 0)
        c1 <- round((prevy()-0.05)*ncol(tif2), 0)
        c2 <- round((prevy()+0.05)*ncol(tif2), 0)
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
        r1 <- round((prevx()-0.05)*nrow(tif1),0)
        r2 <- round((prevx()+0.05)*nrow(tif1), 0)
        c1 <- round((prevy()-0.05)*ncol(tif1), 0)
        c2 <- round((prevy()+0.05)*ncol(tif1), 0)
        tif1 <- tif1[r1:r2, c1:c2]
      } else{
        tif1 <- readTIFF(file_to_read1$datapath)
      }
    )
    
    
    tifimg <- matrix(0, nrow = nrow(tif1) + 8,
                     ncol = ncol(tif1) + 8)
    tifimg[5:(nrow(tifimg)-4 ), 5:(ncol(tifimg)-4 )] <- tif1 ## Do some padding
    
    
    
    nseg <- as.numeric(seg()) ## figure out how many segments
    
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
    

    numclusters <- parallel::detectCores()
    cl <- makeCluster(numclusters-1)
    registerDoSNOW(cl)
    
    withProgress(message = "Processing...", detail = "Note: Progress Bar won't update with multicore...", 
                 value = 0.25,{
                   
    oper <- foreach(
      i = 2:length(colseq), .combine = "rbind", .inorder = FALSE
    ) %dopar% {
      library(shiny)
      source('GetMatrixFun9x9.R')
      source('GetMatrixFun.R')
       
       for(j in 2:length(rowseq)){
        

         invisible(gc())
         
         if((colseq[i-1]) == 1 & (rowseq[j-1])==1){
           chunk <- tifimg[rowseq[j-1]:(rowseq[j]-1), colseq[i-1]:(colseq[i]-1)] ## Get Matrix for Chunk
           chunkmat <- getmatrix9(chunk)
           
           tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
           tempvals<- cleanvalnr*as.vector(tempvals$net.result) + as.numeric(1-cleanvalnr)*chunkmat[,9]
           
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
             tempvals<- cleanvalnr*as.vector(tempvals$net.result) + as.numeric(1-cleanvalnr)*chunkmat[,9]
             
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
               tempvals<- cleanvalnr*as.vector(tempvals$net.result) + as.numeric(1-cleanvalnr)*chunkmat[,9]
               
               tempcols <- as.vector(colmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
               temprows <- as.vector(rowmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
               
               predvals <- c(predvals, tempvals)
               colvals <- c(colvals, tempcols)
               rowvals <- c(rowvals, temprows)
               
               
             } else{
               chunk <- tifimg[(rowseq[j-1]-12):(rowseq[j]-1), (colseq[i-1]-12):(colseq[i]-1)]
               chunkmat <- getmatrix9(chunk)
               
               tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
               tempvals<- cleanvalnr*as.vector(tempvals$net.result) + as.numeric(1-cleanvalnr)*chunkmat[,9]
               
               tempcols <- as.vector(colmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
               temprows <- as.vector(rowmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
               
               predvals <- c(predvals, tempvals)
               colvals <- c(colvals, tempcols)
               rowvals <- c(rowvals, temprows)
               
               
               
             }
           }
         }
         
       }
      data.frame(predvals,colvals, rowvals)
     } })
                   
                   
    stopCluster(cl)             
                 
                 
    
    
    testsamp <- fill_matrix(oper$predvals, oper$rowvals, oper$colvals) 
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
        r1 <- round((prevx()-0.05)*nrow(tif2),0)
        r2 <- round((prevx()+0.05)*nrow(tif2), 0)
        c1 <- round((prevy()-0.05)*ncol(tif2), 0)
        c2 <- round((prevy()+0.05)*ncol(tif2), 0)
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
        r1 <- round((prevx()-0.05)*nrow(tif1),0)
        r2 <- round((prevx()+0.05)*nrow(tif1), 0)
        c1 <- round((prevy()-0.05)*ncol(tif1), 0)
        c2 <- round((prevy()+0.05)*ncol(tif1), 0)
        tif1 <- tif1[r1:r2, c1:c2]
      } else{
        tif1 <- readTIFF(file_to_read1$datapath)
      }
    )
    
    tifimg <- matrix(0, nrow = nrow(tif1) + 4,
                     ncol = ncol(tif1) + 4)
    tifimg[3:(nrow(tifimg)-2 ), 3:(ncol(tifimg)-2 )] <- tif1 ## Do some padding
    
    
    nseg <- as.numeric(seg())
    
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
    
    numclusters <- parallel::detectCores()
    cl <- makeCluster(numclusters-1)
    registerDoSNOW(cl)
    
    withProgress(message = "Processing...", detail = "Note: Progress Bar won't update with multicore...", 
                 value = 0.25,{
    
    oper <- foreach(
      i = 2:length(colseq), .combine = "rbind", .inorder = FALSE
    ) %dopar% {             
     #for(i in 2:length(colseq)){
      library(shiny)
      source('GetMatrixFun9x9.R')
      source('GetMatrixFun.R')
       
       for(j in 2:length(rowseq)){
        
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
      data.frame(predvals, colvals, rowvals) 
     }
                   
                  
                 } )
                 
                 
    
    
    
    stopCluster(cl)
    
    testsamp <- fill_matrix(oper$predvals, oper$rowvals, oper$colvals)
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
}
  # session$onSessionEnded(function() {
  #   stopApp()
  #   #q("no")
  # })
  # 




  

