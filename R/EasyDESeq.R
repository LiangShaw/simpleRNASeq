#' EasyDESeq
#' @author Shaobo Liang
#' @param count_tab count table containing control and treatment samples. First control, second treatment.
#' @param tlabel label for treatment group
#' @param clabel label for control group
#' @param tRepN treatment replicates
#' @param cRepN control replicates
#' @param pthre padj threshold for summary output in console
#' @param foldchange fold change threshold for summary output in console
#'
#' @import DESeq2 tidyverse
#' @return a list containg DESeq2 result table and scale factor dataframe
#' @export
#'
#'
#' @examples deseq(count_tab,'treatment','ctrl',3,3,0.05,2)
EasyDESeq <- function(count_tab,tlabel,clabel,tRepN,cRepN,pthre=0.05,foldchange=1){
  countcol <- count_tab[rowSums(count_tab)>1,]
  #colnames(countcol) <- c('ctrl1','ctrl2','ctrl3','treat1','treat2','treat3')
  condition <- factor(c(rep(clabel,cRepN),rep(tlabel,tRepN)),levels = c(clabel,tlabel))
  dds <- DESeqDataSetFromMatrix(countData = countcol,colData = DataFrame(condition),design = ~condition)
  suppressMessages(result <- DESeq(dds))

  scalefactor.df <- data.frame(
    sample = names(result$sizeFactor),
    scalefactor = as.numeric(result$sizeFactor)
  )

  res <- results(result, contrast = c('condition', tlabel, clabel))

  print(paste0('Padj: ',pthre,' ; foldChange: ', foldchange))
  print('increase:')
  increase <- subset(res,padj<pthre & log2FoldChange >= log2(foldchange))
  print(nrow(increase))
  print('decrease:')
  decrease <- subset(res,padj<pthre & log2FoldChange <= log2(1/foldchange))
  print(nrow(decrease))

  print('Summary from DESeq2:')
  summary(res)
  return(list(res,scalefactor.df))
}
