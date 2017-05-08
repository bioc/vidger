% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/vsFourWay.R
\name{vsFourWay}
\alias{vsFourWay}
\title{Four-Way plot for comparison of log fold changes in a multiple factor RNA seq
experiment from different analytical objects}
\usage{
vsFourWay(x, y, control, data, d.factor = NULL, type, padj = 0.1,
  x.lim = NULL, y.lim = NULL, lfc = NULL, legend = TRUE, title = TRUE,
  grid = TRUE, data.return = FALSE)
}
\arguments{
\item{x}{treatment `x` for comparison (log2(x/control)).}

\item{y}{treatment `y` for comparison (log2(y/control)).}

\item{control}{`control` treatment for comparisons of the x and y axes.}

\item{data}{a cuffdiff, DESeq2, or edgeR object.}

\item{d.factor}{a specified factor; for use with DESeq2 objects only. Defaults to `NULL`}

\item{type}{an analysis classifier to tell the function how to process the data. Must be either `cuffdiff`, `deseq`, or `edgeR`.}

\item{padj}{a user defined adjusted p-value cutoff point. Defaults to `0.1`.}

\item{x.lim}{set manual limits to the x axis. Defaults to `NULL`.}

\item{y.lim}{set manual limits to the y axis. Defaults to `NULL`.}

\item{lfc}{log fold change level for setting conditonals. If no user input is added (`NULL`), value defaults to `1`.}

\item{legend}{shows legend of plot. Defaults to `TRUE`.}

\item{title}{show title of plot. Defaults to `TRUE`.}

\item{grid}{show major and minor axis lines. Defaults to `TRUE`.}

\item{data.return}{returns data output of plot if set to `TRUE`. Defaults to `FASLSE`.}
}
\description{
This function allows you to extract necessary results-based data from a 
DESeq object class to create a four-way plot to compare log fold changes in 
various treatments using ggplot2 aesthetics.
}
\details{
This function allows the user to extract various elements from a different 
analytical object class which in turn, creates a temporary data frame to plot 
the necessary ggplot aesthetics. In order for this function to work, RNA seq 
experiments must have multiple factors (i.e. two treatments and a control) 
and levels including treatments and controls. By having the recommended 
criteria, this function will extract the necessary data dependent on the 
analysis performed. Data points with 'extreme' values that exceed the default 
viewing frame of the plot will change character classes (i.e. points of 
interest a substantially large log fold change).
}
\examples{
# Cuffdiff example
load('df.cuff.RData')
vsFourWay(x = 'hESC', y = 'iPS', control = 'Fibroblasts', data = df.cuff, 
          d.factor = NULL, type = 'cuffdiff', padj = 0.05, x.lim = NULL, 
          y.lim = NULL, lfc = 2, title = TRUE, grid = TRUE, 
          data.return = FALSE)

# DESeq2 example
load('df.deseq.RData')
vsFourWay(x = 'N61311', y = 'N052611', control = 'N061011', data = df.deseq, 
          d.factor = 'cell', type = 'deseq', padj = 0.05, x.lim = NULL, 
          y.lim = NULL, lfc = 2, title = TRUE, grid = TRUE, 
          data.return = FALSE)

# edgeR example
load('df.edger.RData')
vsFourWay(x = 'WM', y = 'WW', control = 'MM', data = df.edger, 
          d.factor = NULL, type = 'edger', padj = 0.05, x.lim = NULL, 
          y.lim = NULL, lfc = 2, title = TRUE, grid = TRUE, 
          data.return = FALSE)
                
# Extract data frame from visualization
load('df.cuff.RData')
tmp <- vsFourWay(x = 'WM', y = 'WW', control = 'MM', data = df.edger, 
                 d.factor = NULL, type = 'edger', padj = 0.05, x.lim = NULL, 
                 y.lim = NULL, lfc = 2, title = TRUE, grid = TRUE, 
                 data.return = FALSE)
df.four <- tmp[[1]]
head(df.four)
Configure data
Conditional plot components
ggplot x and y limits to objects
See ranker functions
See counting function
See component functions
Plot layers
}
\author{
Brandon Monier, \email{brandon.monier@sdstate.edu}
}