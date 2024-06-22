# simpleRNASeq 
Let RNA-seq analysis simple and easy to repeat!

# Description
simpleRNASeq mainly consists of differentially gene expression (DEG) analysis and alternative splicing (DAS) analysis, followed by downstream data visualization and others.

# install
You can use devtools to install `simpleRNASeq`
```r
devtools::install_github('git@github.com:LiangShaw/simpleRNASeq.git')
```

# function Usage
Firstly, import `simpleRNASeq` and other dependent libraries:
```r
library(simpleRNASeq)
library(tidyverse)
library(dplyr)
```
you can type `help(function)` in R console to view the function help document.

## deseq: Differential gene expression (DGE)
`DESeq2` as core function is required, so make sure `DESeq2` is avaliable and loaded:
```r
library(DESeq2)
```

## DESeq_to_volcano_plot


## rmats_to_volcano_plot


## readcount_to_TPM

## merge_similar_terms


# Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.  
Welcome more practical tools to join in `simpleRNASeq`.