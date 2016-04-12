TreatmentSelection
==================

This R package includes a suite of descriptive and inferential methods designed to evaluate
individual treatment selection markers and to compare candidate markers.  

functions included are:

- `trtsel` for creating trtsel objects
- `plot.trtsel` for plotting risk curves and more
- `eval.trtsel` for evaluating marker performance
- `calibrate.trtsel` for assessing model calibration
- `compare.trtsel` to compare two trtsel objects. 

To dowload the package from CRAN, type:

```r
install.packages("TreatmentSelection")
```

To download and install the most recent version of the package directly from github, type:

```r
if (!require("devtools")) install.packages("devtools")
devtools::install_github("TreatmentSelection", "mdbrown")

```

A manuscript describing the methods employed in the package can be found [here](http://www.ncbi.nlm.nih.gov/pmc/articles/PMC4341986/)  and a brief tutorial is available [here](http://rpubs.com/mdbrown/TreatmentSelection).
