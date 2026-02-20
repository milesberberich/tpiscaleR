#' @export
## small helper function, help sampling points insinde the raster
smart_sample <- function(r, n) {
  valid_indices <- which(!is.na(terra::values(r, dataframe=FALSE)))
  selected_indices <- sample(valid_indices, size = n)
  pts <- terra::vect(terra::xyFromCell(r, selected_indices), crs = terra::crs(r))
  terra::values(pts) <- terra::extract(r, pts)
  return(pts)}
