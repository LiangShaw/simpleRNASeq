#' Title
#' @description transfer readcount matrix into TPM
#' @param gene.readcount.tab readcount table contains at 3 columns. Geneid, Length, and other sample count columns, like output from featureCounts
#'
#' @return TPM matrix. rownames are gene ids
#' @import tidyverse dplyr
readcount_to_TPM <- function(gene.readcount.tab){
  gene.count.tab <-
    gene.readcount.tab %>%
    column_to_rownames(var = 'Geneid') %>%
    dplyr::mutate(rowsum=rowSums(across(everything()))) %>%
    filter(rowsum>Length) %>%
    dplyr::select(!rowsum)

  gene.length.tab <- gene.count.tab$Length
  gene.count.tab <- gene.count.tab %>% dplyr::select(!(Length))

  gene.count.RPK <- DelayedArray::sweep(
    gene.count.tab,1,gene.length.tab/1000,FUN = '/')

  column_sums <- colSums(gene.count.RPK)

  gene.TPM <- DelayedArray::sweep(
    gene.count.RPK,2,
    column_sums/1000000,FUN = '/')
  return(gene.TPM)
}
