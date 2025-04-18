
corClass <- if (requireNamespace('jmvcore', quietly = TRUE))
  R6::R6Class(
    "corClass",
    inherit = corBase,
    private = list(
      .htmlwidget = NULL,
      # Add instance for HTMLWidget
      
      .init = function() {
        private$.htmlwidget <- HTMLWidget$new() # Initialize the HTMLWidget instance
        if (is.null(self$data) | is.null(self$options$vars)) {
          self$results$instructions$setVisible(visible = TRUE)
          
        }
        self$results$instructions$setContent(private$.htmlwidget$generate_accordion(
          title = "Instructions",
          content = paste(
            '<div style="border: 2px solid #e6f4fe; border-radius: 15px; padding: 15px; background-color: #e6f4fe; margin-top: 10px;">',
            '<div style="text-align:justify;">',
            '<ul>',
            '<li>Computes and visualizes an item correlation matrix, offering several correlation types and clustering methods.</li>',
            '<li>The heatmap is estimated by using <b>ShinyItemAnalysis::plot_corr</b> function.</li>',
            '<li>When clustering method is <b>none</b>, dendrogram will not be drawn.</li>',
            '<li>Feature requests and bug reports can be made on my <a href="https://github.com/hyunsooseol/seolmatrix/issues" target="_blank">GitHub</a>.</li>',
            '</ul></div></div>'
            
          )
        ))
        
        if (isTRUE(self$options$plot)) {
          width <- self$options$width
          height <- self$options$height
          self$results$plot$setSize(width, height)
        }
        
        if (isTRUE(self$options$plot1)) {
          width <- self$options$width5
          height <- self$options$height5
          self$results$plot1$setSize(width, height)
        }
        
        if (isTRUE(self$options$plot2)) {
          width <- self$options$width4
          height <- self$options$height4
          self$results$plot2$setSize(width, height)
        }
        
        if (isTRUE(self$options$plot3)) {
          width <- self$options$width3
          height <- self$options$height3
          self$results$plot3$setSize(width, height)
        }
      },
      
      
      .run = function() {
        if (is.null(self$options$vars))
          return()
        
        vars  <- self$options$vars
        data <- self$data
        data <- na.omit(data)
        
        # pearson and spearman  correlation------
        mat <-  stats::cor(data, method = self$options$type)
        mat1 <- as.dist(1 - mat)
        # heatmap plot----------
        image <- self$results$plot
        image$setState(mat)
        
        # dendrogram plot-------
        if (!self$options$method == 'none') {
          image <- self$results$plot1
          image$setState(mat1)
        }
        
        if (isTRUE(self$options$poly)) {
          #Polychoric correlation------
          corP <- psych::polychoric(data)
          dis <- as.dist(1 - corP$rho)
          # Polychoric heatmap plot---------
          image <- self$results$plot2
          image$setState(data)
          # Polychoric dendrogram plot---------
          if (!self$options$method == 'none') {
            image <- self$results$plot3
            image$setState(dis)
          }
        }
      },
      
      .plot = function(image, ggtheme, theme, ...) {
        if (is.null(image$state))
          return(FALSE)
        mat <- image$state
        plot <- ShinyItemAnalysis::plot_corr(
          mat,
          cor = self$options$type,
          clust_method = self$options$method,
          n_clust = self$options$k,
          labels_size = self$options$size,
          line_col = "red",
          line_size = 1.5,
          labels = TRUE
        )
        print(plot)
        TRUE
      },
      
      .plot1 = function(image, ggtheme, theme, ...) {
        if (is.null(image$state))
          return(FALSE)
        
        mat1 <- image$state
        hc <- stats::hclust(mat1, method = self$options$method)
        if (self$options$horiz == TRUE) {
          plot1 <- ggdendro::ggdendrogram(hc, rotate = TRUE)
          
        } else {
          plot1 <- ggdendro::ggdendrogram(hc)
        }
        print(plot1)
        TRUE
      },
      
      .plot2 = function(image, ggtheme, theme, ...) {
        if (is.null(image$state))
          return(FALSE)
        data <- image$state
        plot2 <- ShinyItemAnalysis::plot_corr(
          data,
          cor = 'polychoric',
          clust_method = self$options$method,
          n_clust = self$options$k,
          labels_size = self$options$size,
          line_col = "red",
          line_size = 1.5,
          labels = TRUE
        )
        print(plot2)
        TRUE
      },
      
      
      .plot3 = function(image, ggtheme, theme, ...) {
        if (is.null(image$state))
          return(FALSE)
        
        dis <- image$state
        hc <- stats::hclust(dis, method = self$options$method)
        if (self$options$horiz1 == TRUE) {
          plot3 <- ggdendro::ggdendrogram(hc, rotate = TRUE)
          
        } else {
          plot3 <- ggdendro::ggdendrogram(hc)
          
        }
        print(plot3)
        TRUE
      }
      
    )
  )
