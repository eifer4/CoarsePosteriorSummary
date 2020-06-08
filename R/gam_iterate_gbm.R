gam_iterate <- function(formula, y, x, extract, time, nT, which.gam = c("gam","qgam"),...) {

  covar_vals_raw <- list()
  covar_vals <- array(NA, dim = c(nT, 7, ncol(y)))
  which.gam <- match.arg(which.gam)
  args <- list(formula = formula,
               data = NULL,
               qu = 0.5,
               ...)
  if(which.gam == "qgam") names(args)[1] <- "form"
  argn <- lapply(names(args), as.name)
  names(argn) <- names(args)
  fun.call <- as.call(c(list(as.name(which.gam)), argn))
  # foreach(s = 1:ncol(y)) %doPar% {
  # }
  for(s in 1:ncol(y)) {
    args$data   <- data.frame(y = y[,s], x, time = time)

    gamFit   <- eval(fun.call, envir = args)
    covar_vals_raw[[1]] <- predict(gamFit, newdata = extract, type = "terms")
    covar_vals[,,s] <- covar_vals_raw[[1]][1:nT,2:8]
    covar_vals[,5,s] <- covar_vals[,5,s] + covar_vals_raw[[1]][1:nT,1]
    covar_vals[,6,s] <- rowSums(covar_vals_raw[[1]][extract$Resection=="Sub",])
    covar_vals[,7,s] <- rowSums(covar_vals_raw[[1]][extract$Resection=="Gross",])
  }
  return(covar_vals)
}