## This is only for the app. It does not work for training models, but it could
## Adapted a bit

getmatrix2 <- function(hu1){
  
  ft <- fft(hu1)
  real <- Re(ft)
  im <- Im(ft)
  
  real <- real[3:(nrow(real)-2),3:(ncol(real)-2)]
  im <- im[3:(nrow(im)-2),3:(ncol(im)-2)]
  
  totrow <- length(as.vector(hu1[3:(nrow(hu1)-2),3:(ncol(hu1)-2)]))
  
  newmat <- matrix(nrow = totrow, ncol = 30)
  
  expg <- expand.grid(3:(nrow(hu1)-2), 3:(ncol(hu1)-2))
  
  #newmat[,26] <- as.vector(hu1[3:nrow(hu1),3:ncol(hu1)])
  newmat[,29] <-expg$Var1 ##Row number index
  newmat[,30] <- expg$Var2 ## Column Number index
  
  v1a <- newmat[,29] - 1
  v1b <- newmat[,30] - 1
  v1c <-  hu1[cbind(v1a, v1b)] ## Apparently, cbind here gets all the indices!
  
  v2a <- newmat[,29] - 1
  v2b <- newmat[,30]
  v2c <-  hu1[cbind(v2a, v2b)]
  
  v3a <- newmat[,29] - 1
  v3b <- newmat[,30] + 1
  v3c <-  hu1[cbind(v3a, v3b)]
  
  v4a <- newmat[,29] 
  v4b <- newmat[,30] - 1
  v4c <-  hu1[cbind(v4a, v4b)]
  
  v5a <- newmat[,29] 
  v5b <- newmat[,30] + 1
  v5c <-  hu1[cbind(v5a, v5b)]
  
  v6a <- newmat[,29] + 1
  v6b <- newmat[,30] - 1
  v6c <-  hu1[cbind(v6a, v6b)]
  
  v7a <- newmat[,29] + 1
  v7b <- newmat[,30] 
  v7c <-  hu1[cbind(v7a, v7b)]
  
  v8a <- newmat[,29] + 1
  v8b <- newmat[,30] + 1
  v8c <-  hu1[cbind(v8a, v8b)]
  
  v9a <- newmat[,29] 
  v9b <- newmat[,30] 
  v9c <-  hu1[cbind(v9a, v9b)]
  
  v10a <- newmat[,29] - 2
  v10b <- newmat[,30] - 2
  v10c <-  hu1[cbind(v10a, v10b)]
  
  v11a <- newmat[,29] - 2
  v11b <- newmat[,30] - 1
  v11c <-  hu1[cbind(v11a, v11b)]
  
  v12a <- newmat[,29] - 2
  v12b <- newmat[,30] 
  v12c <-  hu1[cbind(v12a, v12b)]
  
  v13a <- newmat[,29] - 2
  v13b <- newmat[,30] + 1
  v13c <-  hu1[cbind(v13a, v13b)]
  
  v14a <- newmat[,29] - 2
  v14b <- newmat[,30] + 2
  v14c <-  hu1[cbind(v14a, v14b)]
  
  v15a <- newmat[,29] - 1
  v15b <- newmat[,30] - 2
  v15c <-  hu1[cbind(v15a, v15b)]
  
  v16a <- newmat[,29] - 1
  v16b <- newmat[,30] +2
  v16c <-  hu1[cbind(v16a, v16b)]
  
  v17a <- newmat[,29] 
  v17b <- newmat[,30] - 2
  v17c <-  hu1[cbind(v17a, v17b)]
  
  v18a <- newmat[,29] 
  v18b <- newmat[,30] +2
  v18c <-  hu1[cbind(v18a, v18b)]
  
  v19a <- newmat[,29] + 1
  v19b <- newmat[,30] - 2
  v19c <-  hu1[cbind(v19a, v19b)]
  
  v20a <- newmat[,29] + 1
  v20b <- newmat[,30] + 2
  v20c <-  hu1[cbind(v20a, v20b)]
  
  v21a <- newmat[,29] + 2
  v21b <- newmat[,30] - 2
  v21c <-  hu1[cbind(v21a, v21b)]
  
  v22a <- newmat[,29] + 2
  v22b <- newmat[,30] - 1
  v22c <-  hu1[cbind(v22a, v22b)]
  
  v23a <- newmat[,29] + 2
  v23b <- newmat[,30] 
  v23c <-  hu1[cbind(v23a, v23b)]
  
  v24a <- newmat[,29] + 2
  v24b <- newmat[,30] + 1
  v24c <-  hu1[cbind(v24a, v24b)]
  
  v25a <- newmat[,29] + 2
  v25b <- newmat[,30] + 2
  v25c <-  hu1[cbind(v25a, v25b)]
  
  v26 <- as.vector(real)
  v27 <- as.vector(im)
  
  newmat[,1  ] <- v1c
  newmat[,2  ] <- v2c
  newmat[,3  ] <- v3c
  newmat[,4  ] <- v4c
  newmat[,5  ] <- v5c
  newmat[,6  ] <- v6c
  newmat[,7  ] <- v7c
  newmat[,8  ] <- v8c
  newmat[,9  ] <- v9c
  newmat[,10 ] <- v10c
  newmat[,11 ] <- v11c
  newmat[,12 ] <- v12c
  newmat[,13 ] <- v13c
  newmat[,14 ] <- v14c
  newmat[,15 ] <- v15c
  newmat[,16 ] <- v16c
  newmat[,17 ] <- v17c
  newmat[,18 ] <- v18c
  newmat[,19 ] <- v19c
  newmat[,20 ] <- v20c
  newmat[,21 ] <- v21c
  newmat[,22 ] <- v22c
  newmat[,23 ] <- v23c
  newmat[,24 ] <- v24c
  newmat[,25 ] <- v25c
  newmat[,26 ] <- v26
  newmat[,27 ] <- v27
  newmat[,28 ] <- v9c
  
  return(newmat[,c(1,2,3,4,5,6,7,8,9,26,27,28)])
  
}


getmatrix3 <- function(hu1){
  
  ft <- fft(hu1)
  real <- Re(ft)
  im <- Im(ft)
  
  real <- real[3:(nrow(real)-2),3:(ncol(real)-2)]
  im <- im[3:(nrow(im)-2),3:(ncol(im)-2)]
  
  totrow <- length(as.vector(hu1[3:(nrow(hu1)-2),3:(ncol(hu1)-2)]))
  
  newmat <- matrix(nrow = totrow, ncol = 30)
  
  expg <- expand.grid(3:(nrow(hu1)-2), 3:(ncol(hu1)-2))
  
  #newmat[,26] <- as.vector(hu1[3:nrow(hu1),3:ncol(hu1)])
  newmat[,29] <-expg$Var1 ##Row number index
  newmat[,30] <- expg$Var2 ## Column Number index
  
  v1a <- newmat[,29] - 1
  v1b <- newmat[,30] - 1
  v1c <-  hu1[cbind(v1a, v1b)] ## Apparently, cbind here gets all the indices!
  
  v2a <- newmat[,29] - 1
  v2b <- newmat[,30]
  v2c <-  hu1[cbind(v2a, v2b)]
  
  v3a <- newmat[,29] - 1
  v3b <- newmat[,30] + 1
  v3c <-  hu1[cbind(v3a, v3b)]
  
  v4a <- newmat[,29] 
  v4b <- newmat[,30] - 1
  v4c <-  hu1[cbind(v4a, v4b)]
  
  v5a <- newmat[,29] 
  v5b <- newmat[,30] + 1
  v5c <-  hu1[cbind(v5a, v5b)]
  
  v6a <- newmat[,29] + 1
  v6b <- newmat[,30] - 1
  v6c <-  hu1[cbind(v6a, v6b)]
  
  v7a <- newmat[,29] + 1
  v7b <- newmat[,30] 
  v7c <-  hu1[cbind(v7a, v7b)]
  
  v8a <- newmat[,29] + 1
  v8b <- newmat[,30] + 1
  v8c <-  hu1[cbind(v8a, v8b)]
  
  v9a <- newmat[,29] 
  v9b <- newmat[,30] 
  v9c <-  hu1[cbind(v9a, v9b)]
  
  v10a <- newmat[,29] - 2
  v10b <- newmat[,30] - 2
  v10c <-  hu1[cbind(v10a, v10b)]
  
  v11a <- newmat[,29] - 2
  v11b <- newmat[,30] - 1
  v11c <-  hu1[cbind(v11a, v11b)]
  
  v12a <- newmat[,29] - 2
  v12b <- newmat[,30] 
  v12c <-  hu1[cbind(v12a, v12b)]
  
  v13a <- newmat[,29] - 2
  v13b <- newmat[,30] + 1
  v13c <-  hu1[cbind(v13a, v13b)]
  
  v14a <- newmat[,29] - 2
  v14b <- newmat[,30] + 2
  v14c <-  hu1[cbind(v14a, v14b)]
  
  v15a <- newmat[,29] - 1
  v15b <- newmat[,30] - 2
  v15c <-  hu1[cbind(v15a, v15b)]
  
  v16a <- newmat[,29] - 1
  v16b <- newmat[,30] +2
  v16c <-  hu1[cbind(v16a, v16b)]
  
  v17a <- newmat[,29] 
  v17b <- newmat[,30] - 2
  v17c <-  hu1[cbind(v17a, v17b)]
  
  v18a <- newmat[,29] 
  v18b <- newmat[,30] +2
  v18c <-  hu1[cbind(v18a, v18b)]
  
  v19a <- newmat[,29] + 1
  v19b <- newmat[,30] - 2
  v19c <-  hu1[cbind(v19a, v19b)]
  
  v20a <- newmat[,29] + 1
  v20b <- newmat[,30] + 2
  v20c <-  hu1[cbind(v20a, v20b)]
  
  v21a <- newmat[,29] + 2
  v21b <- newmat[,30] - 2
  v21c <-  hu1[cbind(v21a, v21b)]
  
  v22a <- newmat[,29] + 2
  v22b <- newmat[,30] - 1
  v22c <-  hu1[cbind(v22a, v22b)]
  
  v23a <- newmat[,29] + 2
  v23b <- newmat[,30] 
  v23c <-  hu1[cbind(v23a, v23b)]
  
  v24a <- newmat[,29] + 2
  v24b <- newmat[,30] + 1
  v24c <-  hu1[cbind(v24a, v24b)]
  
  v25a <- newmat[,29] + 2
  v25b <- newmat[,30] + 2
  v25c <-  hu1[cbind(v25a, v25b)]
  
  v26 <- as.vector(real)
  v27 <- as.vector(im)
  
  newmat[,1  ] <- v1c
  newmat[,2  ] <- v2c
  newmat[,3  ] <- v3c
  newmat[,4  ] <- v4c
  newmat[,5  ] <- v5c
  newmat[,6  ] <- v6c
  newmat[,7  ] <- v7c
  newmat[,8  ] <- v8c
  newmat[,9  ] <- v9c
  newmat[,10 ] <- v10c
  newmat[,11 ] <- v11c
  newmat[,12 ] <- v12c
  newmat[,13 ] <- v13c
  newmat[,14 ] <- v14c
  newmat[,15 ] <- v15c
  newmat[,16 ] <- v16c
  newmat[,17 ] <- v17c
  newmat[,18 ] <- v18c
  newmat[,19 ] <- v19c
  newmat[,20 ] <- v20c
  newmat[,21 ] <- v21c
  newmat[,22 ] <- v22c
  newmat[,23 ] <- v23c
  newmat[,24 ] <- v24c
  newmat[,25 ] <- v25c
  newmat[,26 ] <- v26
  newmat[,27 ] <- v27
  newmat[,28 ] <- v9c
  
  #return(newmat[,c(17,4,9,5,18,12,2,7,23,26,27,28)])
  return(newmat[,c(17,4,9,5,18,12,2,7,23,26,27,28)])
}
