## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
#' Power
#' @param x base
#' @param exp exponent
power <- function(x, exp) x ^ exp

#' @describeIn power Square a number
square <- function(x) power(x, 2)

#' @describeIn power Cube a number
cube <- function(x) power(x, 3)

## -----------------------------------------------------------------------------
#' @rdname arith
#' @order 2
add <- function(x, y) x + y

#' @rdname arith
#' @order 1
times <- function(x, y) x * y

## ----include = FALSE----------------------------------------------------------
roxygen2:::markdown_on()

simple_inline <- "#' Title `r 1 + 1`
#'
#' Description `r 2 + 2`
foo <- function() NULL
"

## ----code=simple_inline-------------------------------------------------------
#' Title `r 1 + 1`
#'
#' Description `r 2 + 2`
foo <- function() NULL


## ----code = roxygen2:::markdown(simple_inline)--------------------------------
#' Title 2
#'
#' Description 4
foo <- function() NULL

## -----------------------------------------------------------------------------
alphabet <- function(n) {
  paste0("`", letters[1:n], "`", collapse = ", ")
}

## ----echo=FALSE---------------------------------------------------------------
env <- new.env()
env$alphabet <- alphabet
roxygen2:::roxy_meta_set("evalenv", env)

backtick <- "#' Title
#' 
#' @param x A string. Must be one of `r alphabet(5)`
foo <- function(x) NULL
"

## ----code = backtick----------------------------------------------------------
#' Title
#' 
#' @param x A string. Must be one of `r alphabet(5)`
foo <- function(x) NULL


## ----code = roxygen2:::markdown_pass1(backtick)-------------------------------
#' Title
#' 
#' @param x A string. Must be one of `a`, `b`, `c`, `d`, `e`
foo <- function(x) NULL


