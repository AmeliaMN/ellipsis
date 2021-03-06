#' Check that all dots in current environment have been used
#'
#' Automatically sets exit handler to run when function terminates, checking
#' that all elements of `...` have been evaluated. Because the highest
#' level function can give the user the most informative error message,
#' activating in one function, will suppress any warnings by from other
#' functions.
#'
#' @param env Environment in which to look for `...` and to set up handler.
#' @export
#' @examples
#' f <- function(...) {
#'   check_dots_used()
#'   g(...)
#' }
#'
#' g <- function(x, y, ...) {
#'   x + y
#' }
#' f(x = 1, y = 2)
#'
#' f(x = 1, y = 2, z = 3)
#' f(x = 1, y = 2, 3, 4, 5)
check_dots_used <- function(env = caller_env()) {
  if (isTRUE(dots_handler$on)) {
    return()
  }

  dots_handler$on <- TRUE

  exit_handler <- expr(
    on.exit({
      (!!check_dots)(environment())

      env <- (!!dots_handler)
      env$on <- FALSE
    }, add = TRUE)
  )
  eval_bare(exit_handler, env)

  invisible()
}

dots_handler <- env(emptyenv(), on = FALSE)

check_dots <- function(env = caller_env()) {
  proms <- env_dots_promises(env)
  used <- vapply(proms, promise_forced, logical(1))

  if (all(used)) {
    return(invisible())
  }

  unnused <- names(proms)[!used]
  warning(
    "Some components of ... were not used: ",
    paste0(unnused, collapse = ", "),
    call. = FALSE,
    immediate. = TRUE
  )
}
