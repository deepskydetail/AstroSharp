MixedPSFModelMC <- function(NNModeltemp,
                          PSFval,
                          Clr,
                          Preview,
                          input_file,
                          Cleanval,
                          input,
                          hy,
                          prevx,
                          prevy,
                          seg){
  
  hy = hy()
  PSFval = PSFval()
  modelname <- paste0("PSF/81_1_FWHM_", PSFval ,".RDS")
  new_model <- readRDS(modelname)
  
  
  Beta2 <- readRDS("AstroCleanv2NoBeta.RDS") ## Change hybrid model to clean instead of 2nd Beta
  
  
  file_to_read1 = input_file()
  
  
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
  btwovals <- vector()
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
    library(shiny)
    source('GetMatrixFun9x9.R')
    source('GetMatrixFun.R')
    
    #for(i in 2:length(colseq)){
    
    for(j in 2:length(rowseq)){
      #foreach(j = 2:length(rowseq), .combine = "rbind", .inorder = FALSE) %dopar% {
      #incProgress(amount = 1/(length(rowseq)*length(colseq)) )
      
      invisible(gc())
      
      if((colseq[i-1]) == 1 & (rowseq[j-1])==1){
        chunk <- tifimg[rowseq[j-1]:(rowseq[j]-1), colseq[i-1]:(colseq[i]-1)] ## Get Matrix for Chunk
        chunkmat <- getmatrix9(chunk)
        
        tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
        tempvals <- as.numeric(as.vector(tempvals$net.result))
        
        chunk2 <- chunk
        chunk2[5:(nrow(chunk2)-4),  5:(ncol(chunk2)-4)] <- matrix(tempvals, nrow = nrow(chunk2)-8)
        
        chunk2mat <- getmatrix9(chunk2)
        
        betavals <- neuralnet::compute(Beta2, as.matrix(chunk2mat[,1:81]))
        betavals<- as.numeric(as.vector(betavals$net.result))
        
        
        ## The model only computed the innermost values of the chunk (hu1[5:(nrow(hu1)-4),5:(ncol(hu1)-4)])
        ## Need to show this in the tempcols and temprows for the location values
        tempcols <- as.vector(colmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
        temprows <- as.vector(rowmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
        
        predvals <- c(predvals, tempvals)
        btwovals <- c(btwovals, betavals)
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
          tempvals <- as.numeric(as.vector(tempvals$net.result))
          
          chunk2 <- chunk
          chunk2[5:(nrow(chunk2)-4),  5:(ncol(chunk2)-4)] <- matrix(tempvals, nrow = nrow(chunk2)-8)
          
          chunk2mat <- getmatrix9(chunk2)
          
          betavals <- neuralnet::compute(Beta2, as.matrix(chunk2mat[,1:81]))
          betavals<- as.numeric(as.vector(betavals$net.result))
          
          tempcols <- as.vector(colmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
          temprows <- as.vector(rowmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]+4):(colseq[i]-5)])
          
          predvals <- c(predvals, tempvals)
          btwovals <- c(btwovals, betavals)
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
            tempvals <- as.numeric(as.vector(tempvals$net.result))
            
            chunk2 <- chunk
            chunk2[5:(nrow(chunk2)-4),  5:(ncol(chunk2)-4)] <- matrix(tempvals, nrow = nrow(chunk2)-8)
            
            chunk2mat <- getmatrix9(chunk2)
            
            betavals <- neuralnet::compute(Beta2, as.matrix(chunk2mat[,1:81]))
            betavals<- as.numeric(as.vector(betavals$net.result))
            
            tempcols <- as.vector(colmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
            temprows <- as.vector(rowmat[(rowseq[j-1]+4):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
            
            predvals <- c(predvals, tempvals)
            btwovals <- c(btwovals, betavals)
            colvals <- c(colvals, tempcols)
            rowvals <- c(rowvals, temprows)
            
            
          } else{
            chunk <- tifimg[(rowseq[j-1]-12):(rowseq[j]-1), (colseq[i-1]-12):(colseq[i]-1)]
            chunkmat <- getmatrix9(chunk)
            
            tempvals <- neuralnet::compute(new_model, as.matrix(chunkmat[,1:81]))
            tempvals <- as.numeric(as.vector(tempvals$net.result))
            
            chunk2 <- chunk
            chunk2[5:(nrow(chunk2)-4),  5:(ncol(chunk2)-4)] <- matrix(tempvals, nrow = nrow(chunk2)-8)
            
            chunk2mat <- getmatrix9(chunk2)
            
            betavals <- neuralnet::compute(Beta2, as.matrix(chunk2mat[,1:81]))
            betavals<- as.numeric(as.vector(betavals$net.result))
            
            tempcols <- as.vector(colmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
            temprows <- as.vector(rowmat[(rowseq[j-1]-8):(rowseq[j]-5), (colseq[i-1]-8):(colseq[i]-5)])
            
            predvals <- c(predvals, tempvals)
            btwovals <- c(btwovals, betavals)
            colvals <- c(colvals, tempcols)
            rowvals <- c(rowvals, temprows)
            
            
            
          }
        }
      }
      
      #}
      
      #setTxtProgressBar(pb,i)
    }
    data.frame(predvals, btwovals, colvals, rowvals)
  }
  
               })
  
  
  stopCluster(cl)
  
  betasamp2 <- tif1
  # bweights <- matrix(ecdf(betasamp2)(betasamp2), nrow = nrow(betasamp2))
  # bweights <- pbeta(bweights, hy, 30)
  
  betasamp <- fill_matrix(oper$btwovals, oper$rowvals, oper$colvals)
  betasammat <- betasamp[5:(nrow(betasamp)), 5:(ncol(betasamp))] # This is lined up with original image, but is missing last column/row, and first/last four rows/columns are junk
  betasammat <- betasammat[-c(1:4), -c(1:4)]
  betasammat <- betasammat[-c((nrow(betasammat)-3):nrow(betasammat)), -c((ncol(betasammat)-3):ncol(betasammat))]
  betasamp2[5:(nrow(betasamp2)-5),  5:(ncol(betasamp2)-5)] <- betasammat
  
  testsamp <- fill_matrix(oper$predvals, oper$rowvals, oper$colvals) 
  testsammat <- testsamp[5:(nrow(testsamp)), 5:(ncol(testsamp))] # This is lined up with original image, but is missing last column/row, and first/last four rows/columns are junk
  testsammat <- testsammat[-c(1:4), -c(1:4)]
  testsammat <- testsammat[-c((nrow(testsammat)-3):nrow(testsammat)), -c((ncol(testsammat)-3):ncol(testsammat))]
  testsamp2 <- tif1
  testsamp2[5:(nrow(testsamp2)-5),  5:(ncol(testsamp2)-5)] <- testsammat
  
  testsamp2 <- (Cleanval()*betasamp2) + (testsamp2*(1-Cleanval()))   #(testsamp2*2 + betasamp2)/3
  
  testsamp2 <- ifelse(testsamp2 > 1, 1, testsamp2)
  testsamp2 <- ifelse(testsamp2 < 0, 0, testsamp2)
  
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