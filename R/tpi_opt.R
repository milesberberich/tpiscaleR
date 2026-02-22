#' Optimizes the radius of a TPI used to predict another variable
#'
#' Uses Bayesian optimization and sampling of single pixels at certain using different radii.
#'
#' @param min_range Numeric. The minimum tpi-radius for optimization...
#' @param max_range Numeric. The maximum tpi-radius for optimization...
#' @param dem terra::SpatRaster. The Digital Elevation Model...
#' @param raster terra::SpatRaster. The target raster to correlate against...
#' @param n_sample Numeric. Number of pixels for which the TPI get calculated...
#' @param n_bayesianiterations Numeric. Number of iterations for the optimizer...
#' @param kappa_bayesian Numeric. The kappa parameter for the acquisition function...
#' @param correlation_coefficient String. The type of correlation to use...
#' @return A list object of class \code{BayesianOptimization} containing the optimization results.
#' @export

tpi_opt <- function(min_range, max_range, dem, raster, n_sample, n_bayesianiterations, kappa_bayesian, correlation_coefficient = "spearman"){

  limits <- list(radius = c(min_range, max_range))

  tpi_wrapper <- function(radius) {   ## just a wrapper so it can be easily used insiede the bayesian optimization
    cor_value <- tpi_sample(raster_dsm = dem,
                            raster_target = raster,
                            sample_num = n_sample,
                            radius = radius,
                            relationship = correlation_coefficient)
    return(cor_value)}
  print("The value in the following output is the absolute or negative value of the choosen relationship/method (such as pearson, spearman, rsme_linear, r2_quad...)")
  result <- rBayesianOptimization::BayesianOptimization(tpi_wrapper, limits, init_points = 4, n_iter = n_bayesianiterations, kappa = kappa_bayesian, acq = "ucb")
  return(result)
}

# hier will ich den radius bayesian optimisen.. Dazu nutze ich das script tpi_scale bzw. die zwei funktinoen die darin definiert wurden.
