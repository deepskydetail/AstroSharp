## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(comment = "#>", collapse = TRUE)

## ---- echo = FALSE------------------------------------------------------------
example <- "#' Add together two numbers
#'
#' @param x A number.
#' @param y A number.
#' @return A number.
#' @examples
#' add(1, 1)
#' add(10, 1)
add <- function(x, y) {
  x + y
}
"

## ----code=example-------------------------------------------------------------
#' Add together two numbers
#'
#' @param x A number.
#' @param y A number.
#' @return A number.
#' @examples
#' add(1, 1)
#' add(10, 1)
add <- function(x, y) {
  x + y
}


## ---- echo=FALSE, results="asis"----------------------------------------------
cat(
  "\x60\x60\x60rd\n",
  format(roxygen2::roc_proc_text(roxygen2::rd_roclet(), example)[[1]]),
  "\n\x60\x60\x60", sep = ""
)

## ---- eval = FALSE------------------------------------------------------------
#  #' Do values in a numeric vector fall in specified range?
#  #'
#  #' This is a shortcut for `x >= left & x <= right`, implemented
#  #' efficiently in C++ for local values, and translated to the
#  #' appropriate SQL for remote tables.
#  #'
#  #' @param x A numeric vector of values.
#  #' @param left,right Boundary values.
#  #' @export
#  #' @examples
#  #' between(1:12, 7, 9)
#  #'
#  #' x <- rnorm(1e2)
#  #' x[between(x, -1, 1)]
#  between <- function(x, left, right) {
#  }

