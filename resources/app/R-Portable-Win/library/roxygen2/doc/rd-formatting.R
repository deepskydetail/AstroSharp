## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(comment = "#>", collapse = TRUE)

## ----echo=FALSE---------------------------------------------------------------
simple_fenced <- "#' @title Title
#' @details Details
#' ```{r lorem}
#' 1+1
#' ```
#' @md
foo <- function() NULL
"

## ----code=simple_fenced-------------------------------------------------------
#' @title Title
#' @details Details
#' ```{r lorem}
#' 1+1
#' ```
#' @md
foo <- function() NULL


## ----lorem--------------------------------------------------------------------
1+1

## ---- echo=FALSE, results="asis"----------------------------------------------
cat(
  "\x60\x60\x60rd\n",
  format(roxygen2:::roc_proc_text(roxygen2::rd_roclet(), simple_fenced)[[1]]),
  "\n\x60\x60\x60"
)

