#'-----------------------------------------------------#
#' Title:  ggviseq - House Keeping - volcano matrix    #
#' Author: Brandon Monier (brandon.monier@sdstate.edu) #
#' Date:   04.27.17                                    #
#'-----------------------------------------------------#

#'---------
#' Preamble
#'---------

#'...



#'--------------------------
#' Volcano matrix components
#'--------------------------

#' @export
vomat.comp <- function(padj, lfc) {
  # Color
  gry <- paste0('padj > ', padj)
  blu <- paste0('padj < ', padj, ' & |lfc| > ', lfc)
  grn <- paste0('padj < ', padj, ' & |lfc| < ', lfc)
  
  # Lines and labels
  vline1 <- geom_vline(xintercept = 0, color = 'red3', size = 0.5, 
                       alpha = 0.8, linetype = 'longdash')
  vline2 <- geom_vline(xintercept = -lfc, color = 'grey32', size = 0.5, 
                       alpha = 0.8, linetype = 'dashed')
  vline3 <- geom_vline(xintercept = lfc, color = 'grey32', size = 0.5,
                       alpha = 0.8, linetype = 'dashed')
  hline1 <- geom_hline(yintercept = -log10(padj), color = 'grey32', size = 0.5, 
                       alpha = 0.8, linetype = 'dashed')
  x.lab <- xlab(expression(paste('log'['2'], ' fold change')))
  y.lab <- ylab(expression(paste('-log'['10'], '(p-value)')))
  comp.l <- list(gry = gry, blu = blu, grn = grn,
                 vline1 = vline1, vline2 = vline2, vline3 = vline3, 
                 hline1 = hline1, x.lab = x.lab, y.lab = y.lab)
}

#' @export
vomat.ranker <- function(data, padj, lfc, x.lim) {
  dat <- data
  # Color
  dat$color <- 'grey'
  dat$color[dat$padj <= padj & abs(dat$logFC) > lfc] <- 'blue'
  dat$color[dat$padj <= padj & abs(dat$logFC) < lfc] <- 'green'
  # Size
  dat$size <- vo.out.ranker(dat$logFC, x.lim[2])
  # Shape
  dat$shape <- 'circle'
  dat$shape[dat$logFC < x.lim[1]] <- 'l.triangle'
  dat$shape[dat$logFC > x.lim[2]] <- 'r.triangle'
  return(dat)
}

#' @export
vomat.col.count <- function(data) {
  tab <- as.data.frame(t(table(data$color, paste(data$id_x, data$id_y))))
  b.l <- tab[which(tab$Var2 == 'blue'), ]
  g.l <- tab[which(tab$Var2 == 'green'), ]
  col.l <- list(blue = b.l, green = g.l)
  return(col.l)
}



#'------------------------
#' Volcano plot extraction
#'------------------------

#' edgeR - REQUIRES `getEdgeScatter()`
#' @export
getEdgeVolcanoMatrix <- function(data) {
  v_1 <- as.vector(unique(data$sample$group))
  m_a <- expand.grid(v_1, v_1)
  m_a <- as.matrix(m_a[which(m_a$Var1 != m_a$Var2), ])
  l_a <- split(m_a, row(m_a))
  
  l1 <- list()
  for(i in 1:length(l_a)){
    l1[[i]] <- getEdgeVolcano(l_a[[i]][1], l_a[[i]][2], data)
    l1[[i]]$id_x <- l_a[[i]][1]
    l1[[i]]$id_y <- l_a[[i]][2]
  }
  dat1 <- do.call('rbind', l1)
  dat1 <- dat1[, c(6:7, 1:2, 3:5)]
  dat1$id_x <- as.factor(dat1$id_x)
  dat1$id_y <- as.factor(dat1$id_y)
  return(dat1)
}


#' cuffdiff - NO PREREQUISITES
#' @export
getCuffVolcanoMatrix <- function(data) {
  dat <- data
  v_1 <- union(dat$sample_1, dat$sample_2)
  m_a <- expand.grid(v_1, v_1)
  m_a <- as.matrix(m_a[which(m_a$Var1 != m_a$Var2), ])
  l_a <- split(m_a, row(m_a))
  
  l1 <- list()
  for(i in 1:length(l_a)){
    l1[[i]] <- getCuffVolcano(l_a[[i]][1], l_a[[i]][2], data)
    l1[[i]]$id_x <- l_a[[i]][1]
    l1[[i]]$id_y <- l_a[[i]][2]
  }
  dat1 <- do.call('rbind', l1)
  dat1 <- dat1[, c(1, 7:8, 2:6)]
  dat1$id_x <- as.factor(dat1$id_x)
  dat1$id_y <- as.factor(dat1$id_y)
  return(dat1)
}


#' DESeq2 - NO PREREQUISITES
#' @export
getDeseqVolcanoMatrix <- function(data, d.factor) {
  if(is.null(d.factor)) {
    stop('This appears to be a DESeq object. Please state d.factor variable.')
  }
  dat <- as.data.frame(colData(data))
  v_1 <- as.vector(unique(dat[[d.factor]]))
  m_a <- expand.grid(v_1, v_1)
  m_a <- as.matrix(m_a[which(m_a$Var1 != m_a$Var2), ])
  l_a <- split(m_a, row(m_a))
  
  l1 <- list()
  for(i in 1:length(l_a)){
    l1[[i]] <- getDeseqVolcano(l_a[[i]][1], l_a[[i]][2], data, d.factor)
    l1[[i]]$id_x <- l_a[[i]][1]
    l1[[i]]$id_y <- l_a[[i]][2]
  }
  dat1 <- do.call('rbind', l1)
  dat1 <- dat1[, c(1:2, 6:7, 3:5)]
  dat1$id_x <- as.factor(dat1$id_x)
  dat1$id_y <- as.factor(dat1$id_y)
  return(dat1)
}