#' @title optimizes the radius of a TPI used to to predict another variable
#' @description Uses Bayesian optimization and sampling of single pixels at certain using different radii
#' @param min_range Numeric. The minimum tpi - radius for optimization. The function will only find the optimal radius above this value.
#' @param max_range Numeric. The maximum tpi-radius for optimization.The function will only find the optimal radius smaller than this value.
#' @param dem terra::SpatRaster. The Digital Elevation Model that will be used to compute TPI
#' @param raster terra::SpatRaster. The target raster to correlate against, e.g. NDVI, soil moisture, snow depth, If the target variable is only available as a SpatVect, please rasterize.
#' @param n_sample Numeric. Number of pixels for which the TPI get calculated at each step. Increasing n_sample increases computational effort and accuracy
#' @param n_bayesianiterations Numeric. Number of iterations for the optimizer, increasing n_bayesianiterations increases computational effort and accuracy
#' @param kappa_bayesian Numeric. The kappa parameter for the acquisition function. Higher kappa makes the optimizer more explorativ and less likely to miss out a maxima.
#' @param correlation_coefficient String. The type of correlation to use (e.g., "pearson", "spearman", "rsme_linear", "r2_linear", "rsme_quad", "r2_quad", "rmse_cubic", "r2_cubic").
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
