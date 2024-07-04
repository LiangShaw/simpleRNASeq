#' rmats result to volcano plot
#'
#' @param DAtab Differentially alternative splicing table. PValue, FDR, deltaPSI (IncLevelDifference) are required.
#' @param PValue.thres PValue threshold for significant change.
#' @param FDR.thres FDR threshold for significant change.
#' @param deltaPSI.thres delta PSI threshold for significant change.
#' @param ylimit volcano plot y axis range. default c(0,10).
#' @param xlimit volcano plot y axis range. default c(-1,1).
#' @param volcano.title volcano plot title.
#' @param yaxis y axis type. PValue or FDR.
#' @param inc.color color for increased point. Default 'red'.
#' @param dec.color color for decreased point. Default 'blue'.
#' @param ns.color color for not significantly changed point. Dafault 'grey60'.
#'
#' @import tidyverse dplyr ggsci ggprism
#' @return a list containing table with change and volcano plot, violin plot
#' @export
#'
#' @examples rmats_to_volcano_plot(tab,PValue.thres=1,FDR.thres=0.05,deltaPSI.thres=0.05,ylimit=c(0,10),xlimit=c(-1,1),volcano.title='Differentially AS (treat vs ctrl)',yaxis='FDR', inc.color='red',dec.color='blue',ns.color='grey60')
rmats_to_volcano_plot <- function(
    tab,PValue.thres=1,FDR.thres=0.05,deltaPSI.thres=0.05,
    ylimit=c(0,10),xlimit=c(-1,1),
    volcano.title='PSI change (treat vs ctrl)',
    yaxis='FDR', inc.color='red',dec.color='blue',ns.color='grey60'){
  if (yaxis=='FDR'){
    modify.tab <- tab %>%
      mutate(
        change=
          ifelse(FDR>=FDR.thres | PValue>=PValue.thres | is.na(FDR),'n.s.',
                 ifelse(IncLevelDifference>=deltaPSI.thres, 'inc',
                        ifelse(IncLevelDifference<=-deltaPSI.thres, 'dec', 'n.s.') ) ),
        yvalue=ifelse(-log10(FDR)>ylimit[2],ylimit[2],-log10(FDR))
      )

    y.axis.label <- '-log10(FDR)'
  } else {
    modify.tab <- tab %>%
      mutate(
        change=
          ifelse(PValue>=PValue.thres ,'n.s.',
                 ifelse(IncLevelDifference>=deltaPSI.thres, 'inc',
                        ifelse(IncLevelDifference<=-deltaPSI.thres, 'dec', 'n.s.') ) ),
        yvalue=ifelse(-log10(PValue)>ylimit[2],ylimit[2],-log10(PValue))
      )
    y.axis.label <- '-log10(PValue)'
  }

  increase.num <- modify.tab %>% filter(change=='inc') %>% nrow()
  decrease.num <- modify.tab %>% filter(change=='dec') %>% nrow()

  event.count.tab <- modify.tab %>% select(EventType,change) %>% table() %>% as.data.frame() %>%
    mutate(x=ifelse(change=='dec', -xlimit[2]*0.7, xlimit[2]*0.7),
           y=ylimit[2]*0.7 )

  vol.plot <- modify.tab %>%
    ggplot(aes(x=IncLevelDifference ,y=yvalue, color=change)) +
    geom_point(size=0.1, alpha=0.1) +
    geom_text(data=event.count.tab,mapping=aes(x=x,y=y,label=Freq),
              size=7,size.unit='pt') +
    theme_bw(base_size = 7) +
    scale_x_continuous(limits = xlimit, expand = c(0,0)) +
    scale_y_continuous(limits = ylimit, expand = c(0,0)) +
    labs(x=paste0('deltaPSI\n(PValue:',PValue.thres,
                  '; FDR:', FDR.thres,
                  '; deltaPSI:',deltaPSI.thres,')'),
         y=y.axis.label,
         title = volcano.title) +
    #annotate('text',x=-xlimit[2]*0.75,y=ylimit[2]*0.75, label=decrease.num) +
    #annotate('text',x=xlimit[2]*0.75,y=ylimit[2]*0.75, label=increase.num) +
    facet_grid(.~EventType) +
    theme(
      panel.grid.minor = element_blank(),
      plot.title = element_text(hjust = 0.5, size=8),
      strip.background = element_blank()
    ) +
    scale_color_manual(
      values = c('inc'=inc.color,
                 'dec'=dec.color,
                 'n.s.'=ns.color))

  violin.event.count.tab <- SBZ.HeLa.Cas9_vs_WT.volcano.list[[1]] %>%
  select(EventType,change) %>%
  table() %>% as.data.frame() %>%
  mutate(x=ifelse(change=='dec', -1,1),
         y='1',
         hjust=ifelse(change=='dec',0,1)
         )

  violin.plot <- modify.tab %>%
    ggplot(aes(x=IncLevelDifference,y='1')) +
    geom_point(aes(color=EventType),size=0.3,alpha=0.3,
              position = position_jitter(height = 0.1)) +
    #geom_boxplot(aes(group=change,fill=EventType),outliers = F,width=0.5,
    #             position = position_dodge(width = 0,preserve = 'single')) +
    geom_violin(aes(group=change,fill=EventType),
                position = position_dodge(width = 0)) +
    geom_text(data = violin.event.count.tab,
              mapping = aes(x=x,y=y,hjust=hjust,label=Freq),
              size=7,size.unit='pt') +
    scale_x_continuous(limits = c(-1,1),expand = c(0,0)) +
    scale_y_discrete(expand = c(0,0)) +
    theme_prism(base_size = 8) +
    theme(strip.background = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank(),
          axis.line.y = element_blank()) +
    facet_grid(EventType~.) +
    scale_color_npg() +
    scale_fill_npg()

  return( list(modify.tab, vol.plot, violin.plot) )
}
