library(smapr)

context("Fetching data")

test_that("Filenames are properly constructed for the SM_AP data product",
          {
            expect_equal(smap.filename("2015-06-16"),
                         "SMAP_L3_SM_AP_20150616_R12170_002.h5")
            expect_equal(smap.url("2015-06-16"),
                         "ftp://n5eil01u.ecs.nsidc.org/SAN/SMAP/SPL3SMAP.002/2015.06.16/SMAP_L3_SM_AP_20150616_R12170_002.h5")
          })

test_that("Filenames are properly constructed for the SM_P data product",
          {
            expect_equal(smap.filename("2015-06-16", dataset.id = "SM_P"),
                         "SMAP_L3_SM_P_20150616_R12170_002.h5")
            expect_equal(smap.url("2015-06-16", dataset.id = "SM_P"),
                         "ftp://n5eil01u.ecs.nsidc.org/SAN/SMAP/SPL3SMP.002/2015.06.16/SMAP_L3_SM_P_20150616_R12170_002.h5")
          })

test_that("Downloaded data is read correctly",
          {
## not sure how to provide test data here.
#            expect_equal(read.smap.l3("2015-06-16")[1, 3],
#                         0.1633545)
          })


