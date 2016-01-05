## TODO: write geom for this. may need to sit down with a beer for this.

## resources

## creating global EASE grid in R:
## http://stackoverflow.com/questions/22785860/how-to-create-global-ease-grid-from-1d-array-using-r

## format description:
## https://nsidc.org/data/ease/ease_grid.html


## writing a new geom:
## https://github.com/hadley/ggplot2/wiki/Creating-a-new-geom

## design- use like geom_raster / geom_tile. may not be necessary to write a custom geom:
## ggplot(smap_data, aes(lon, lat)) + geom_ease(aes(fill=soil.moisture))
