#' @title optimizes the radius of a TPI used to to predict another variable
#' @description Uses Bayesian optimization and sampling of single pixels at certain using different radii
#' @param raster_dsm terra::SpatRaster. The Digital Elevation Model that will be used to compute TPI. Both rasters (raster_dsm, raster_target) should have the same grid, resolution, crs and unit.
#' @param raster_target terra::SpatRaster. The target raster to correlate against, e.g. NDVI, soil moisture, snow depth, If the target variable is only available as a SpatVect, please rasterize. Both rasters (raster_dsm, raster_target) should have the same grid, resolution, crs and unit.
#' @param sample_num Numeric. Number of pixels for which the TPI get calculated. Increasing n_sample increases computational effort and accuracy.
#' @param radius Numeric. The radius used to compute TPI
#' @param relationship String. The type of correlation to use (e.g., "pearson", "spearman", "rsme_linear", "r2_linear", "rsme_quad", "r2_quad", "rmse_cubic", "r2_cubic").
#' @export



# the tpi funtion itself

# this function basically computes the tpi for a given radius for a random set of points.
# afterwards, the relationship between the tpi at the points and the target raster
# will be evaluated using spearman, pearson, or linear, quadratic or cubic regression (R-squared as well as RSME are possible)
# sample_num defines how many random points are used,
#radius is the radius of a tpi, it always uses a circle for the tpi computation

# this function can be used on its on to determine how well a tpi at a certain radius works
# but its also necessary to find the best radius using the bayesian opitmisation

# if you have a spatVector instead of a raster, you can rasterize it at a certain resolution at set the other values to NA
# only points who are not NAs get sampled anyways.

tpi_sample <- function(raster_dsm, raster_target, sample_num, radius, relationship = "spearman") {

  raster_target_masked <- terra::mask(raster_target, raster_dsm) # to prevent to have no elevation information in the target_raster, we mask here

  random_points <- smart_sample(raster_target_masked, sample_num)

  ele <- terra::extract(raster_dsm, random_points)# extracting elevation into the random points
  random_points_ele <- random_points
  random_points_ele$elevation <- ele[, 2]

  random_points_buffer <- terra::buffer(random_points_ele, radius)
  # This is functionally the same as focal() but only calculated at these spots
  random_points_meanele <- random_points_buffer
  random_points_meanele$mean_elevation <- terra::extract(raster_dsm, random_points_buffer, fun = "mean",
                                                  method = "simple", na.rm = TRUE)[, 2]

  random_points_tpi <- random_points_meanele
  random_points_tpi$tpi <- random_points_meanele$elevation - random_points_meanele$mean_elevation
  random_points_df <- as.data.frame(random_points_tpi)
  names(random_points_df)[2] <- "snow_depth"

  # spearman block
  if(relationship == "spearman"){
    spearman <- cor(random_points_df$snow_depth, random_points_df$tpi, method = "spearman")
    print(paste("spearman correlation between tpi at scale ", radius, " = ", spearman))
    spearman_abs <- abs(spearman)
    spearman_list <- list(Score = as.numeric(spearman_abs), Preds = 0)
    return(spearman_list)}

  # pearson block
  if(relationship == "pearson"){
    pearson <- cor(random_points_df$snow_depth, random_points_df$tpi, method = "pearson")
    print(paste("pearson correlation between tpi at scale ", radius, " = ", pearson))
    pearson_abs <- abs(pearson)
    pearson_list <- list(Score = as.numeric(pearson_abs), Preds = 0)
    return(pearson_list)}

  # regression linear block
  if(relationship == "rsme_linear" | relationship == "r2_linear"){
    model <- lm(snow_depth ~ tpi, data = random_points_df)
    if(relationship == "rsme_linear"){
      rsme <- sqrt(mean(model$residuals^2))
      print(paste("linear rsme  between tpi at scale ", radius, " = ", rsme))
      rsme_list <- list(Score = as.numeric(-rsme), Preds = 0)
      return(rsme_list)}
    if(relationship == "r2_linear"){
      r2 <- summary(model)$r.squared
      print(paste("linear R squared between tpi at scale ", radius, " = ", r2))
      r2_list <- list(Score = as.numeric(r2), Preds = 0)
      return(r2_list)}}

  # regression quadratic block
  if(relationship == "rsme_quad" | relationship == "r2_quad"){
    model <- lm(snow_depth ~ poly(tpi, 2, raw = TRUE), data = random_points_df)
    if(relationship == "rsme_quad"){
      rsme <- sqrt(mean(model$residuals^2))
      print(paste("quadratic RMSE between tpi at scale ", radius, " = ", rsme))
      return(list(Score = as.numeric(-rsme), Preds = 0))}
    if(relationship == "r2_quad"){
      r2 <- summary(model)$r.squared
      print(paste("quadratic R squared between tpi at scale ", radius, " = ", r2))
      return(list(Score = as.numeric(r2), Preds = 0))}}

  if(relationship == "rsme_cubic" | relationship == "r2_cubic"){
    model <- lm(snow_depth ~ poly(tpi, 3, raw = TRUE), data = random_points_df)
    if(relationship == "rsme_cubic"){
      rsme <- sqrt(mean(model$residuals^2))
      print(paste("cubic RMSE between tpi at scale ", radius, " = ", rsme))
      return(list(Score = as.numeric(-rsme), Preds = 0))}
    if(relationship == "r2_cubic"){
      r2 <- summary(model)$r.squared
      print(paste("cubic R squared between tpi at scale ", radius, " = ", r2))
      return(list(Score = as.numeric(r2), Preds = 0))}}}

