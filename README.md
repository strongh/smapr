# smapr
R package for working with SMAP soil moisture data. Install using devtools:

```
devtools::install_github("strongh/smapr")
```

# Examples

### Download timerange of data, return as data frame and cache data on disk.

```{r}
timerange.smap.l3("2015-06-17", "2015-06-18")
```

### Launch Shiny map viewer of daily data

```{r}
shiny_smap()
```
