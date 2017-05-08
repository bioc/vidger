#' @title 
#' Volcano plot from log2 fold changes and -log10(p-values)
#'   
#' @author 
#' Brandon Monier, \email{brandon.monier@sdstate.edu}
#' 
#' @description
#' This function allows you to extract necessary results-based data from a 
#' DESEq object class to create a volcano plot (i.e. a scatter plot) of the
#' negative log of the p-value versus the log of the fold change while
#' implementing ggplot2 aesthetics. 
#'  
#' @param x treatment `x` for comparison (log2(y/x)).
#' @param y treatment `y` for comparison (log2(y/x)).
#' @param data a cuffdiff, DESeq2, or edgeR object.
#' @param d.factor a specified factor; for use with DESeq2 objects only. Defaults to `NULL`
#' @param type an analysis classifier to tell the function how to process the data. Must be either `cuffdiff`, `deseq`, or `edgeR`.
#' @param padj a user defined adjusted p-value cutoff point. Defaults to `0.1`.
#' @param x.lim set manual limits to the x axis. Defaults to `NULL`.
#' @param lfc log fold change level for setting conditonals. If no user input is added (`NULL`), value defaults to `1`.
#' @param title show title of plot. Defaults to `TRUE`.
#' @param legend shows legend of plot. Defaults to `TRUE`.
#' @param grid show major and minor axis lines. Defaults to `TRUE`.
#' @param data.return returns data output of plot if set to `TRUE`. Defaults to `FASLSE`.
#' 
#' @export
#' 
#' @examples
#' # Cuffdiff example
#' load('df.cuff.RData')
#' vsVolcano(x = 'hESC', y = 'iPS', data = df.cuff, d.factor = NULL, 
#'           type = 'cuffdiff', padj = 0.05, x.lim = NULL, lfc = 2, 
#'           title = TRUE, grid = TRUE, data.return = FALSE)
#' 
#' # DESeq2 example
#' load('df.deseq.RData')
#' vsVolcano(x = 'trt', y = 'untrt', data = df.deseq, d.factor = 'dex', 
#'           type = 'deseq', padj = 0.05, x.lim = NULL, lfc = NULL, 
#'           title = TRUE, grid = TRUE, data.return = FALSE)
#' 
#' # edgeR example
#' load('df.edger.RData')
#' vsVolcano(x = 'WM', y = 'MM', data = df.edger, d.factor = NULL, 
#'           type = 'edger', padj = 0.1, x.lim = NULL, lfc = 2, 
#'           title = FALSE, grid = TRUE, data.return = FALSE)
#'                 
#' # Extract data frame from visualization
#' load('df.cuff.RData')
#' tmp <- vsVolcano(x = 'hESC', y = 'iPS', data = df.cuff, 
#'                  d.factor = NULL, type = 'cuffdiff', padj = 0.05, 
#'                  x.lim = NULL, lfc = 2, title = TRUE, grid = TRUE, 
#'                  data.return = TRUE)
#' df.volcano <- tmp[[1]]
#' head(df.volcano)

vsVolcano <- function(x, y, data, d.factor = NULL, type, padj = 0.1, 
                      x.lim = NULL, lfc = NULL, title = TRUE, legend = TRUE, 
                      grid = TRUE, data.return = FALSE){
  if (missing(type)) {
    stop('Please specify analysis type ("cuffdiff", "deseq", or "edger")')
  }
  if(type == 'cuffdiff'){
    dat <- getCuffVolcano(x, y, data)
  } else if (type == 'deseq') {
    dat <- getDeseqVolcano(x, y, data, d.factor)
  } else if (type == 'edger') {
    dat <- getEdgeVolcano(x, y, data)
  } else {
    stop('Please enter correct analysis type.')
  }
  if (!isTRUE(title)) {
    m.lab <- NULL
  } else {
    m.lab  <- ggtitle(paste(y, 'vs.', x))
  }
  if (!isTRUE(legend)) {
    leg <- theme(legend.position = 'none')
  } else {
    leg <- guides(colour = guide_legend(override.aes = list(size = 3)),
                  shape = guide_legend(override.aes = list(size = 3)))
  }
  if (!isTRUE(grid)) {
    grid <- theme_classic()
  } else {
    grid <- theme_bw()
  }
  
  
  #' Configure data
  dat$isDE <- ifelse(dat$padj <= padj, TRUE, FALSE)
  px <- dat$logFC
  p <- padj
  
  #' Conditional plot components
  if (is.null(x.lim)) {
    x.lim = c(-1, 1) * quantile(abs(px[is.finite(px)]), probs = 0.99)
  }
  if (is.null(lfc)) {
    lfc = 1
  }
  
  dat <- vo.ranker(dat, padj, lfc, x.lim)
  
  #' See ranker functions
  tmp.size <- vo.out.ranker(px, x.lim[2])
  tmp.col <- vo.col.ranker(dat$isDE, px, lfc)
  tmp.shp <- vo.shp.ranker(px, x.lim)
  
  #' See counting function
  tmp.cnt <- vo.col.counter(dat, lfc)
  b <- tmp.cnt[[1]]
  g <- tmp.cnt[[2]]
  
  #' See component functions
  comp1 <- vo.comp1(x.lim, padj, lfc, b, g)
  point <- geom_point(
    alpha = 0.7, 
    aes(color = tmp.col, shape = tmp.shp, size = tmp.size)
  )
  comp2 <- vo.comp2(comp1[[4]], comp1[[6]], comp1[[5]], comp1[[1]], comp1[[2]], 
                    comp1[[3]])
  
  #' Plot layers
  tmp.plot <- ggplot(dat, aes(x = pmax(x.lim[1], pmin(x.lim[2], px)), 
                              y = -log10(pval) )) +
    point + comp2$color + comp2$shape + comp1$vline1 + comp1$vline2 + comp1$vline3 + 
    comp1$x.lab + comp1$y.lab + comp1$hline1 + grid  + m.lab + xlim(x.lim) + 
    comp2$size + leg
  
  if (isTRUE(data.return)) {
    plot.l <- list(data = dat, plot = tmp.plot)
  } else {
    print(tmp.plot)
  }
}