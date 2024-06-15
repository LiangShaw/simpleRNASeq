#' DESeq2 result to volcano plot
#' @author Shaobo Liang
#' @description provide a DESeq2 result, return a table with 'inc', 'dec', 'n.s.' state and a volcano plot.
#' @param tab differential expression table containing pvalue, padj and log2FoldChange.
#' @param pvalue.thres pvalue threshold for significant change.
#' @param padj.thres padj threshold for significant change.
#' @param log2fc.thres log2FC threshold for significant change.
#' @param ylimit volcano plot y axis range. default c(0,20).
#' @param xlimit volcano plot y axis range. default c(-10,10).
#' @param volcano.title volcano plot title.
#' @param yaxis y axis type. padj or pvalue.
#' @param inc.color color for increased point. Default 'red'.
#' @param dec.color color for decreased point. Default 'blue'.
#' @param ns.color color for not significantly changed point. Dafault 'grey60'.
#' @import tidyverse dplyr
#' @return a list containing table with change and volcano plot
#' @export
#'
#' @examples DESeq_to_volcano_plot(tab,pvalue.thres=1,padj.thres=0.05,log2fc.thres=1,ylimit=c(0,20),xlimit=c(-10,10),volcano.title='Gene expression change (treat vs ctrl)',yaxis='padj', inc.color='red',dec.color='blue',ns.color='grey60')
DESeq_to_volcano_plot <- function(
    tab,pvalue.thres=1,padj.thres=0.05,log2fc.thres=1,
    ylimit=c(0,20),xlimit=c(-10,10),
    volcano.title='Gene expression change (treat vs ctrl)',
    yaxis='padj', inc.color='red',dec.color='blue',ns.color='grey60'){
  if (yaxis=='padj'){
    modify.tab <- tab %>%
      mutate(
        change=
          ifelse(padj>=padj.thres | pvalue>=pvalue.thres | is.na(padj),'n.s.',
                 ifelse(log2FoldChange>=log2fc.thres, 'inc',
                        ifelse(log2FoldChange<=-log2fc.thres, 'dec', 'n.s.') ) ),
        yvalue=ifelse(-log10(padj)>ylimit[2],ylimit[2],-log10(padj))
      )
    y.axis.label <- '-log10(Padj)'
  } else {
    modify.tab <- tab %>%
      mutate(
        change=
          ifelse(pvalue>=pvalue.thres ,'n.s.',
                 ifelse(log2FoldChange>=log2fc.thres, 'inc',
                        ifelse(log2FoldChange<=-log2fc.thres, 'dec', 'n.s.') ) ),
        yvalue=ifelse(-log10(pvalue)>ylimit[2],ylimit[2],-log10(pvalue))
      )
    y.axis.label <- '-log10(PValue)'
  }

  increase.num <- modify.tab %>% filter(change=='inc') %>% nrow()
  decrease.num <- modify.tab %>% filter(change=='dec') %>% nrow()

  vol.plot <- modify.tab %>%
    ggplot(aes(x=log2FoldChange ,y=yvalue, color=change)) +
    geom_point(size=0.8) +
    theme_bw(base_size = 7) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(hjust = 0.5, size=8)
    ) +
    scale_color_manual(
      values = c('inc'=inc.color,
                 'dec'=dec.color,
                 'n.s.'=ns.color)) +
    scale_x_continuous(limits = xlimit, expand = c(0,0)) +
    scale_y_continuous(limits = ylimit, expand = c(0,0)) +
    labs(x=paste0('log2FoldChange\n(pvalue:',pvalue.thres,
                  '; padj:', padj.thres,
                  '; log2FC:',log2fc.thres,')'),
         y=y.axis.label,
         title = volcano.title) +
    annotate('text',x=-xlimit[2]/2,y=ylimit[2]/2, label=decrease.num) +
    annotate('text',x=xlimit[2]/2,y=ylimit[2]/2, label=increase.num)

  return( list(modify.tab, vol.plot) )
}
