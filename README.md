# tpiscaleR

## Terminology 

#### TPI:
The topographic position index is a scale-dependent terrain index. Positiv values indicate a convex and therefore exposed position. 
Negativ values indicate a concave position. Because of its scale dependency, its hard to determine the right radius for the TPI. 
In most cases, the TPI will be used to model another environmental variable like soil moisture.

#### Radius: 
The scale at which the TPI is computed. A radius of 5 e.g. compares the center pixel with the pixels at an 5m radius. 

#### Target Raster:
A one-layered SpatRaster showing the target variable, e.g. soil moisture, NDVI, snow depth. 

#### DSM:
The digital elevation model thats used to calculate the TPI.

## Key features

With this package its possible:

- to evaluate the correlation of TPI at an specific radius to the target raster. Instead of computing the TPI for the whole DSM,
  it only uses a certain number of points to evaluate the correlation. This can safe a lot of time. The function is called tpi_sample.

- to find the "best radius" with the highest correlation to the target raster using a bayesian optimaziation. The function is called tpi_opt.

## Requirements

- terra package (to handle the raster data)
- rBayesianOptimization

## Example 1 (testing one specific scale / tpi_sample)

```{r}
dem <- terra:rast("C:/users/hanspeter/data/fabdem_cropped.tif)
snowdepth <- terra:rast("C:/users/hanspeter/data/snowdepth.tif)



  
