#' @title merge similar GO term for dataframe output from gprofiler2
#' @details none
#' @param gostres.tab result table from gprofiler2::gost. intersection column is required in dataframe. intersection is gene list.
#' @author Shaobo Liang
#' @export
#' @return a subset dataframe of input
#' @import tidyverse
#' @examples merge_similar_terms(gostres)


merge_similar_terms <- function(gostres.tab){

  # compulsory columns: term_name, intersection,
  # step1: remove completely same term
  gostres.dedup.tab <-
    gostres.tab[!duplicated(gostres.tab$intersection), ]

  # step2: pick up terms with max gene list among similar term groups
  gostres.dedup.prepare.tab <- gostres.dedup.tab %>%
    mutate(intersection.list = str_split(intersection, '\\,'),
           pseudo.group = str_split(term_name, '\\ ', simplify = T)[,1]
    ) %>%
    select(term_name, intersection_size, intersection.list, pseudo.group)

  gostres.dedup.1nd.merge.tab <- gostres.dedup.prepare.tab %>%
    group_by(pseudo.group) %>%
    dplyr::summarise(max.list = max(intersection_size)) %>%
    merge(gostres.dedup.prepare.tab,by = 'pseudo.group') %>%
    filter(max.list==intersection_size)

  # step3: abandon terms whose all genes belongs to any other term
  term.list <- c()

  for (i in seq(1,nrow(gostres.dedup.1nd.merge.tab))){
    i.term.name <- gostres.dedup.1nd.merge.tab[i,'term_name']
    i.term.genes <- gostres.dedup.1nd.merge.tab[i,'intersection.list']

    a.list <- c()
    for (j in seq(1,nrow(gostres.dedup.tab))){
      j.term.name <- gostres.dedup.tab[j,'term_name']
      j.term.genes <- gostres.dedup.tab[j,'intersection.list']

      a <- all(i.term.genes %in% j.term.genes) & (i.term.name != j.term.name)
      a.list <- c(a.list, a)
    }

    if( any(a.list) ){
    } else {
      term.list <- c(term.list,i.term.name)
    }
  }

  gostres.dedup.tab %>%
    filter(term_name %in% term.list) %>%
    return()
}
