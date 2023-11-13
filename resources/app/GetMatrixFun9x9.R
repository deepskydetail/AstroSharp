## This is only for the app. It does not work for training models, but it could
## Adapted a bit

getmatrix9 <- function(hu1){
  
  
  totrow <- length(as.vector(hu1[5:(nrow(hu1)-4),5:(ncol(hu1)-4)]))
  
  newmat <- matrix(nrow = totrow, ncol = 83)
  
  expg <- expand.grid(5:(nrow(hu1)-4), 5:(ncol(hu1)-4))
  
  #newmat[,26] <- as.vector(hu1[3:nrow(hu1),3:ncol(hu1)])
  newmat[,82] <-expg$Var1 ##Row number index
  newmat[,83] <- expg$Var2 ## Column Number index
  
  v1a <- newmat[,82] - 1
  v1b <- newmat[,83] - 1
  v1c <-  hu1[cbind(v1a, v1b)] ## Apparently, cbind here gets all the indices!
  
  v2a <- newmat[,82] - 1
  v2b <- newmat[,83]
  v2c <-  hu1[cbind(v2a, v2b)]
  
  v3a <- newmat[,82] - 1
  v3b <- newmat[,83] + 1
  v3c <-  hu1[cbind(v3a, v3b)]
  
  v4a <- newmat[,82] 
  v4b <- newmat[,83] - 1
  v4c <-  hu1[cbind(v4a, v4b)]
  
  v5a <- newmat[,82] 
  v5b <- newmat[,83] + 1
  v5c <-  hu1[cbind(v5a, v5b)]
  
  v6a <- newmat[,82] + 1
  v6b <- newmat[,83] - 1
  v6c <-  hu1[cbind(v6a, v6b)]
  
  v7a <- newmat[,82] + 1
  v7b <- newmat[,83] 
  v7c <-  hu1[cbind(v7a, v7b)]
  
  v8a <- newmat[,82] + 1
  v8b <- newmat[,83] + 1
  v8c <-  hu1[cbind(v8a, v8b)]
  
  v9a <- newmat[,82] 
  v9b <- newmat[,83] 
  v9c <-  hu1[cbind(v9a, v9b)]
  
  v10a <- newmat[,82] - 2
  v10b <- newmat[,83] - 2
  v10c <-  hu1[cbind(v10a, v10b)]
  
  v11a <- newmat[,82] - 2
  v11b <- newmat[,83] - 1
  v11c <-  hu1[cbind(v11a, v11b)]
  
  v12a <- newmat[,82] - 2
  v12b <- newmat[,83] 
  v12c <-  hu1[cbind(v12a, v12b)]
  
  v13a <- newmat[,82] - 2
  v13b <- newmat[,83] + 1
  v13c <-  hu1[cbind(v13a, v13b)]
  
  v14a <- newmat[,82] - 2
  v14b <- newmat[,83] + 2
  v14c <-  hu1[cbind(v14a, v14b)]
  
  v15a <- newmat[,82] - 1
  v15b <- newmat[,83] - 2
  v15c <-  hu1[cbind(v15a, v15b)]
  
  v16a <- newmat[,82] - 1
  v16b <- newmat[,83] +2
  v16c <-  hu1[cbind(v16a, v16b)]
  
  v17a <- newmat[,82] 
  v17b <- newmat[,83] - 2
  v17c <-  hu1[cbind(v17a, v17b)]
  
  v18a <- newmat[,82] 
  v18b <- newmat[,83] +2
  v18c <-  hu1[cbind(v18a, v18b)]
  
  v19a <- newmat[,82] + 1
  v19b <- newmat[,83] - 2
  v19c <-  hu1[cbind(v19a, v19b)]
  
  v20a <- newmat[,82] + 1
  v20b <- newmat[,83] + 2
  v20c <-  hu1[cbind(v20a, v20b)]
  
  v21a <- newmat[,82] + 2
  v21b <- newmat[,83] - 2
  v21c <-  hu1[cbind(v21a, v21b)]
  
  v22a <- newmat[,82] + 2
  v22b <- newmat[,83] - 1
  v22c <-  hu1[cbind(v22a, v22b)]
  
  v23a <- newmat[,82] + 2
  v23b <- newmat[,83] 
  v23c <-  hu1[cbind(v23a, v23b)]
  
  v24a <- newmat[,82] + 2
  v24b <- newmat[,83] + 1
  v24c <-  hu1[cbind(v24a, v24b)]
  
  v25a <- newmat[,82] + 2
  v25b <- newmat[,83] + 2
  v25c <-  hu1[cbind(v25a, v25b)]
  
  v26a <- newmat[,82] - 4
  v26b <- newmat[,83] - 4
  v26c <-  hu1[cbind(v26a, v26b)]
  
  v27a <- newmat[,82] - 3
  v27b <- newmat[,83] - 4
  v27c <-  hu1[cbind(v27a, v27b)]
  
  v28a <- newmat[,82] - 2
  v28b <- newmat[,83] - 4
  v28c <-  hu1[cbind(v28a, v28b)]
  
  v29a <- newmat[,82] - 1
  v29b <- newmat[,83] - 4
  v29c <-  hu1[cbind(v29a, v29b)]
  
  v30a <- newmat[,82] 
  v30b <- newmat[,83] - 4
  v30c <-  hu1[cbind(v30a, v30b)]
  
  v31a <- newmat[,82] + 1
  v31b <- newmat[,83] - 4
  v31c <-  hu1[cbind(v31a, v31b)]
  
  v32a <- newmat[,82] + 2
  v32b <- newmat[,83] - 4
  v32c <-  hu1[cbind(v32a, v32b)]
  
  v33a <- newmat[,82] + 3
  v33b <- newmat[,83] - 4
  v33c <-  hu1[cbind(v33a, v33b)]
  
  v34a <- newmat[,82] + 4
  v34b <- newmat[,83] - 4
  v34c <-  hu1[cbind(v34a, v34b)]
  
  v35a <- newmat[,82] - 4
  v35b <- newmat[,83] - 3
  v35c <-  hu1[cbind(v35a, v35b)]
  
  v36a <- newmat[,82] - 3
  v36b <- newmat[,83] - 3
  v36c <-  hu1[cbind(v36a, v36b)]
  
  v37a <- newmat[,82] - 2
  v37b <- newmat[,83] - 3
  v37c <-  hu1[cbind(v37a, v37b)]
  
  v38a <- newmat[,82] - 1
  v38b <- newmat[,83] - 3
  v38c <-  hu1[cbind(v38a, v38b)]
  
  v39a <- newmat[,82] 
  v39b <- newmat[,83] - 3
  v39c <-  hu1[cbind(v39a, v39b)]
  
  v40a <- newmat[,82] + 1
  v40b <- newmat[,83] - 3
  v40c <-  hu1[cbind(v40a, v40b)]
  
  v41a <- newmat[,82] + 2
  v41b <- newmat[,83] - 3
  v41c <-  hu1[cbind(v41a, v41b)]
  
  v42a <- newmat[,82] + 3
  v42b <- newmat[,83] - 3
  v42c <-  hu1[cbind(v42a, v42b)]
  
  v43a <- newmat[,82] + 4
  v43b <- newmat[,83] - 3
  v43c <-  hu1[cbind(v43a, v43b)]
  
  v44a <- newmat[,82] - 4 
  v44b <- newmat[,83] - 2
  v44c <-  hu1[cbind(v44a, v44b)]
  
  v45a <- newmat[,82] - 3 
  v45b <- newmat[,83] - 2
  v45c <-  hu1[cbind(v45a, v45b)]
  
  v46a <- newmat[,82] + 3 
  v46b <- newmat[,83] - 2
  v46c <-  hu1[cbind(v46a, v46b)]
  
  v47a <- newmat[,82] + 4
  v47b <- newmat[,83] - 2
  v47c <-  hu1[cbind(v47a, v47b)]
  
  v48a <- newmat[,82] - 4
  v48b <- newmat[,83] - 1
  v48c <-  hu1[cbind(v48a, v48b)]
  
  v49a <- newmat[,82] - 3
  v49b <- newmat[,83] - 1
  v49c <-  hu1[cbind(v49a, v49b)]
  
  v50a <- newmat[,82] + 3
  v50b <- newmat[,83] - 1
  v50c <-  hu1[cbind(v50a, v50b)]
  
  v51a <- newmat[,82] + 4
  v51b <- newmat[,83] - 1
  v51c <-  hu1[cbind(v51a, v51b)]
  
  v52a <- newmat[,82] - 4
  v52b <- newmat[,83] 
  v52c <-  hu1[cbind(v52a, v52b)]
  
  v53a <- newmat[,82] - 3
  v53b <- newmat[,83] 
  v53c <-  hu1[cbind(v53a, v53b)]
  
  v54a <- newmat[,82] + 3
  v54b <- newmat[,83] 
  v54c <-  hu1[cbind(v54a, v54b)]
  
  v55a <- newmat[,82] + 4
  v55b <- newmat[,83] 
  v55c <-  hu1[cbind(v55a, v55b)]
  
  v57a <- newmat[,82] - 4
  v57b <- newmat[,83] + 1
  v57c <-  hu1[cbind(v57a, v57b)]
  
  v58a <- newmat[,82] - 3
  v58b <- newmat[,83] + 1
  v58c <-  hu1[cbind(v58a, v58b)]
  
  v59a <- newmat[,82] + 3
  v59b <- newmat[,83] + 1
  v59c <-  hu1[cbind(v59a, v59b)]
  
  v60a <- newmat[,82] + 4
  v60b <- newmat[,83] + 1
  v60c <-  hu1[cbind(v60a, v60b)]
  
  v61a <- newmat[,82] - 4
  v61b <- newmat[,83] + 2
  v61c <-  hu1[cbind(v61a, v61b)]
  
  v62a <- newmat[,82] - 3
  v62b <- newmat[,83] + 2
  v62c <-  hu1[cbind(v62a, v62b)]
  
  v63a <- newmat[,82] + 3
  v63b <- newmat[,83] + 2
  v63c <-  hu1[cbind(v63a, v63b)]
  
  v64a <- newmat[,82] + 4
  v64b <- newmat[,83] + 2
  v64c <-  hu1[cbind(v64a, v64b)]
  
  v65a <- newmat[,82] - 4
  v65b <- newmat[,83] + 3
  v65c <-  hu1[cbind(v65a, v65b)]
  
  v66a <- newmat[,82] - 3
  v66b <- newmat[,83] + 3
  v66c <-  hu1[cbind(v66a, v66b)]
  
  v67a <- newmat[,82] - 2
  v67b <- newmat[,83] + 3
  v67c <-  hu1[cbind(v67a, v67b)]
  
  v68a <- newmat[,82] - 1
  v68b <- newmat[,83] + 3
  v68c <-  hu1[cbind(v68a, v68b)]
  
  v69a <- newmat[,82] 
  v69b <- newmat[,83] + 3
  v69c <-  hu1[cbind(v69a, v69b)]
  
  v70a <- newmat[,82] + 1
  v70b <- newmat[,83] + 3
  v70c <-  hu1[cbind(v70a, v70b)]
  
  v71a <- newmat[,82] + 2
  v71b <- newmat[,83] + 3
  v71c <-  hu1[cbind(v71a, v71b)]
  
  v72a <- newmat[,82] + 3
  v72b <- newmat[,83] + 3
  v72c <-  hu1[cbind(v72a, v72b)]
  
  v73a <- newmat[,82] + 4
  v73b <- newmat[,83] + 3
  v73c <-  hu1[cbind(v73a, v73b)]
  
  v74a <- newmat[,82] - 4
  v74b <- newmat[,83] + 4
  v74c <-  hu1[cbind(v74a, v74b)]
  
  v75a <- newmat[,82] - 3
  v75b <- newmat[,83] + 4
  v75c <-  hu1[cbind(v75a, v75b)]
  
  v76a <- newmat[,82] - 2
  v76b <- newmat[,83] + 4
  v76c <-  hu1[cbind(v76a, v76b)]
  
  v77a <- newmat[,82] - 1
  v77b <- newmat[,83] + 4
  v77c <-  hu1[cbind(v77a, v77b)]
  
  v78a <- newmat[,82] 
  v78b <- newmat[,83] + 4
  v78c <-  hu1[cbind(v78a, v78b)]
  
  v79a <- newmat[,82] + 1
  v79b <- newmat[,83] + 4
  v79c <-  hu1[cbind(v79a, v79b)]
  
  v80a <- newmat[,82] + 2
  v80b <- newmat[,83] + 4
  v80c <-  hu1[cbind(v80a, v80b)]
  
  v81a <- newmat[,82] + 3
  v81b <- newmat[,83] + 4
  v81c <-  hu1[cbind(v81a, v81b)]
  
  v56a <- newmat[,82] + 4
  v56b <- newmat[,83] + 4
  v56c <-  hu1[cbind(v56a, v56b)]
  
  
  
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
  
  newmat[,26 ] <- v26c
  newmat[,27 ] <- v27c
  newmat[,28 ] <- v28c
  
  newmat[,29 ] <- v29c
  newmat[,30 ] <- v30c
  newmat[,31 ] <- v31c
  newmat[,32 ] <- v32c
  newmat[,33 ] <- v33c
  newmat[,34 ] <- v34c
  newmat[,35 ] <- v35c
  newmat[,36 ] <- v36c
  newmat[,37 ] <- v37c
  newmat[,38 ] <- v38c
  
  newmat[,39 ] <- v39c
  newmat[,40 ] <- v40c
  newmat[,41 ] <- v41c
  newmat[,42 ] <- v42c
  newmat[,43 ] <- v43c
  newmat[,44 ] <- v44c
  newmat[,45 ] <- v45c
  newmat[,46 ] <- v46c
  newmat[,47 ] <- v47c
  newmat[,48 ] <- v48c
  
  
  newmat[,49 ] <- v49c
  newmat[,50 ] <- v50c
  newmat[,51 ] <- v51c
  newmat[,52 ] <- v52c
  newmat[,53 ] <- v53c
  newmat[,54 ] <- v54c
  newmat[,55 ] <- v55c
  newmat[,56 ] <- v56c
  newmat[,57 ] <- v57c
  newmat[,58 ] <- v58c
  
  newmat[,59 ] <- v59c
  newmat[,60 ] <- v60c
  newmat[,61 ] <- v61c
  newmat[,62 ] <- v62c
  newmat[,63 ] <- v63c
  newmat[,64 ] <- v64c
  newmat[,65 ] <- v65c
  newmat[,66 ] <- v66c
  newmat[,67 ] <- v67c
  newmat[,68 ] <- v68c

  
  newmat[,69 ] <- v69c
  newmat[,70 ] <- v70c
  newmat[,71 ] <- v71c
  newmat[,72 ] <- v72c
  newmat[,73 ] <- v73c
  newmat[,74 ] <- v74c
  newmat[,75 ] <- v75c
  newmat[,76 ] <- v76c
  newmat[,77 ] <- v77c
  newmat[,78 ] <- v78c
  
  newmat[,79 ] <- v79c
  newmat[,80 ] <- v80c
  newmat[,81 ] <- v81c

  
  return(newmat[,1:81])
  
}

getTraining9x9 <- function(hu1){
  
  trainmat <- matrix(as.vector(hu1[5:(nrow(hu1)-4), 5:(ncol(hu1)-4)]), ncol = 1)
  
}

fill_matrix <- function(data, row_vec, col_vec) {
  # Create a matrix of zeros with the same dimensions as the final matrix
  matrix_data <- matrix(0, nrow = max(row_vec), ncol = max(col_vec))
  # Loop through the data vector and fill the matrix with the correct values
  for (i in seq_along(data)) {
    matrix_data[row_vec[i], col_vec[i]] <- data[i]
  }
  # Return the filled matrix
  return(matrix_data)
}



get_surrounding_values <- function(matrix, center_row, center_col) {
  # Calculate the indices of the 25 neighboring values
  row_indices <- (center_row - 2):(center_row + 2)
  col_indices <- (center_col - 2):(center_col + 2)
  
  # Subset the matrix to get the neighboring values
  surrounding_values <- matrix[row_indices, col_indices]
  
  # Convert the matrix to a vector and return
  return(as.vector(surrounding_values))
}

getsmallmat <- function(bigmat, r, c, rm, im){
  
  sm <- get_surrounding_values(bigmat, r, c)
  
  re <- get_surrounding_values(rm, r, c)
  
  im <- get_surrounding_values(im, r, c)
  
  
}
