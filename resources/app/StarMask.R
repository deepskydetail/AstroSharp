

starmask <- function(thresh,
                     mix,
                     mix2,
                     StarNoise,
                     input_file,
                     prevx,
                     prevy,
                     seg,
                     Preview,
                     Clr,
                     sensi){
  
  file_to_read1 = input_file()
  thresh = thresh()
  mix = mix()
  mix2 = mix2()
  StarNoise = StarNoise()
  
  
  if(Clr() == "Color"){
    #tif2 <- readTIFF(file_to_read1$datapath)
    
    if(Preview() == "Preview"){
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
    LuvDF[,2] = 0
    LuvDF[,3] = 0
    
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
  
  
  # tifimg <- matrix(0, nrow = nrow(tif1) + 8,
  #                  ncol = ncol(tif1) + 8)
  # tifimg[5:(nrow(tifimg)-4 ), 5:(ncol(tifimg)-4 )] <- tif1 ## Do some padding

                 
                 
   hessdet <- function(im,scale=1) isoblur(im,scale) %>% imhessian %$% { scale^2*(xx*yy - xy^2) }
   
   scales <- seq(2,20,l=10)
   
   d.max <- map_il(scales,function(scale) hessdet(as.cimg(tif1),scale)) %>% parmax()
   
   i.max <- map_il(scales,function(scale) hessdet(as.cimg(tif1),scale)) %>% which.parmax()
   
   sensi <- paste0(sensi(), "%")
   
   labs <- d.max %>% threshold(sensi) %>% label %>% as.data.frame
   #Add scale indices
   labs <- mutate(labs,index=as.data.frame(i.max)$value)
   regs <- dplyr::group_by(labs,value) %>% dplyr::summarise(mx=mean(x),my=mean(y),scale.index=mean(index))
   
   tifimgstars <- matrix(labs$value, nrow = nrow(tif1))
   
   tifimgstars <- ifelse(tifimgstars > StarNoise, 1,0) 
   binarystars <- tifimgstars
   
   tifimgstars <- isoblur(as.cimg(tifimgstars), thresh) #%>%
   tifimgstars <- matrix(tifimgstars, nrow = nrow(tif1))
   
   #tifimgstars <- matrix(ecdf(tifimgstars)(tifimgstars), nrow = nrow(tifimgstars))
               
                 

  testsamp2 <- tifimgstars
  testsamp2 <- matrix(pbeta(tifimgstars, mix, mix2), nrow = nrow(tifimgstars))
  #testsamp2 <- (testsamp2 + binarystars)/2
  
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