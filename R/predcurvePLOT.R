

predcurvePLOT_gg <-
  function(x, ci, ci.bounds, get.F, fixed.values, conf.bands, rho, trt.names, xlab, ylab, xlim, ylim, main, show.marker.axis, offset = .01){ 
    
    
    fittedrisk.t0 <- x$derived.data$fittedrisk.t0
    fittedrisk.t1 <- x$derived.data$fittedrisk.t1
    # browser()
    if(length(x$model.fit$marker.names)==1){
      marker <- x$derived.data[, x$model.fit$marker]
      if(is.null(xlab)) xlab <- "% population below marker value"
      if(is.null(ylab)) ylab <- "risk given marker"
    }else{
      marker <- x$derived.data$trt.effect #if risks are provided, there is no marker so we use trt.effect
      if(is.null(xlab)) xlab <- "% population below treatment effect"
      if(is.null(ylab)) ylab <- "risk given treatment effect"
    }
 
    if(x$model.fit$family$family == "time-to-event"){
      event = 0
    }else{
      event <- x$derived.data[[as.character(x$formula[[2]])]]
    }
    
    trt <- x$derived.data[[x$treatment.name]]
    
    F.Y <- get.F(marker, event, trt, rho = rho)*100
    n = length(fittedrisk.t0)
    mydata <- data.frame(risk = c(fittedrisk.t0, fittedrisk.t1),
                         trt = c(rep(1, n ), rep(0,n)), 
                         Fy = rep(F.Y,2))
    #mydata <- mydata[with(mydata, order(risk)),]
    mydata <- mydata[!duplicated(mydata),]
    #to appease check 
    Fy <- risk <- NULL
    
    #legend(x=xlim[2]+diff(xlim)/15, y = quantile(ylim, prob = .75), legend = trt.names, lty = c(2, 1),lwd=c(2,2), bty="n", cex = 1, xpd = TRUE)
    
    #x.t0 <- stepF.Y
    #x.t1 <- stepF.Y  
    
    #y.t0 <- fittedrisk.t0[rep(order(F.Y),c(1, rep(2, n-1)))]
    #y.t1 <- fittedrisk.t1[rep(order(F.Y),c(1, rep(2, n-1)))]
    
    if(!is.null(ci.bounds)){
      
      ci.bounds <- matrix(ci.bounds, ncol=length(fixed.values), nrow = 4)
      
      if(substr(ci, 1,1)=="h"){
        width = .05
        #the indices of fixed values that fall between min(fittedrisk.t0) and max(fittedrisk.t0) ...same for t1
        index.fix.t0   <- (fixed.values<= max(fittedrisk.t0[trt==0]) & fixed.values >= min(fittedrisk.t0[trt==0])) 
        index.fix.t1   <- (fixed.values<= max(fittedrisk.t1[trt==1]) & fixed.values >= min(fittedrisk.t1[trt==1])) 
        
      }else{
        width = 5
        index.fix.t0   <- (fixed.values<= max(F.Y[trt==0]) & fixed.values >= min(F.Y[trt==0])) 
        index.fix.t1   <- (fixed.values<= max(F.Y[trt==1]) & fixed.values >= min(F.Y[trt==1])) 
      }
      
      
      p <- shade_gg(ggplot(mydata), ci.bounds[1:2,index.fix.t0], fixed.values[index.fix.t0], type = substr(ci, 1, 1), bands = conf.bands, width = width)
      p <- shade_gg(p, ci.bounds[3:4,index.fix.t1], fixed.values[index.fix.t1] +offset, type = substr(ci, 1, 1), bands = conf.bands, lty = 2, width = width)
      
    }else{
      p <- ggplot(mydata)
    }
    
    
    if(is.null(xlim)) xlim <- c(0,100)
    if(is.null(ylim)) ylim <- c(0,1)
    if(is.null(main)) main <- "Risk curves by treatment"
    breaks = seq(xlim[1], xlim[2], length.out = 5)
    
    
    
    p <- p+geom_step(data = mydata, aes(x = Fy, y = risk, linetype = factor(trt)), direction = "vh")#, size = 1)
    
    #add x/y labels and main
    p <- p + xlab(xlab) + ylab(ylab) + ylim(ylim[1], ylim[2]) + ggtitle(main) 
    #change the names for the legend
    p <- p + scale_linetype_manual(values = c(2, 1), labels = trt.names)+
      theme(legend.title = element_blank(), #,  text = element_text(size=14), 
            legend.key.size = unit(1.5, "lines")) #, 
    #legend.text = element_text(size = 16))
    p <- p + scale_x_continuous(breaks = breaks, limits = xlim)
    if(show.marker.axis){
      p <- p + theme(plot.margin = unit(c(1,1,4,1), "lines"))
      
      p <- p + annotation_custom(grob = xaxisGrob( at = breaks, label = round(quantile(marker, prob = breaks/100), 1)), #, gp = gpar( fontsize=11.5)), #col = gray(.55),
                                 xmin = 0, xmax = 1, ymin = ylim[1]-diff(ylim)*.25, ymax = ylim[1]-diff(ylim)*.25)
      p <- p + annotation_custom(grob = textGrob( label = "marker value"), #, #gp = gpar( fontsize=14)), 
                                 xmin = mean(xlim), xmax = mean(xlim), ymin = ylim[1]-diff(ylim)*.4, ymax = ylim[1]-diff(ylim)*.4)
      
      
      plot.new()
      # Code to override clipping
      gt <- ggplotGrob((p))
      gt$layout$clip[gt$layout$name=="panel"] <- "off"
      grid.draw(gt)
    }else{
      print(p)
    }
    
    
    list(p=p)
  }



predcurvePLOT_gg_disc <-
  function(x, ci, ci.bounds, get.F,  xlab, ylab, xlim, ylim, main, trt.names){ 
    
    fittedrisk.t0 <- x$derived.data$fittedrisk.t0
    fittedrisk.t1 <- x$derived.data$fittedrisk.t1
    marker <- x$derived.data[,x$model.fit$marker.names]
    trt <- x$derived.data[[x$treatment.name]]
    
    mydata <- data.frame(risk = fittedrisk.t0*(1-trt)+fittedrisk.t1*trt, trt = trt,  marker)
    
    mydata <- unique(mydata)
    mydata$lower <- rep(NA, nrow(mydata))
    mydata$upper <- rep(NA, nrow(mydata))
    mval = sort(unique(marker))
    
    #appease check 
    risk <- lower <- upper <- NULL
    
    if(!is.null(ci.bounds)){
      
      
      
      #order matters here!
      mydata[mydata$trt==0 & mydata$marker==mval[1], 4:5] <- ci.bounds[,1]
      mydata[mydata$trt==1 & mydata$marker==mval[1], 4:5] <- ci.bounds[,2]
      mydata[mydata$trt==0 & mydata$marker==mval[2], 4:5] <- ci.bounds[,3]
      mydata[mydata$trt==1 & mydata$marker==mval[2], 4:5] <- ci.bounds[,4]
      
      
      p <- ggplot(mydata, aes(x = factor(marker), y = risk, ymin = lower, ymax = upper, group = factor(trt), shape = factor(trt), linetype = factor(trt) ))
      p <- p + geom_errorbar(width = .1) + geom_point()
      
      
    }else{
      
      p <- ggplot(mydata, aes(x = factor(marker), y = risk, group = factor(trt), shape = factor(trt), linetype = factor(trt) ))
      p <- p + geom_point()
      
      
    }
    
    if(is.null(xlab)) xlab <- "marker value"
    if(is.null(ylab)) ylab <- "risk given marker"
    if(is.null(xlim)) xlim <- c(0,100)
    if(is.null(ylim)) ylim <- c(0,1)
    if(is.null(main)) main <- "Risk curves by treatment"
    
    #add x/y labels and main
    p <- p + xlab(xlab) + ylab(ylab) + ylim(ylim[1], ylim[2]) + ggtitle(main) 
    #change the names for the legend
    p <- p + scale_shape_discrete(breaks=factor(c(1,0)), labels = trt.names) +
      scale_linetype_discrete(breaks=factor(c(1,0)), labels = trt.names)+
      theme(legend.title = element_blank())#,  text = element_text(size=14))
    #legend.text = element_text(size = 16))
    p <- p + scale_x_discrete(labels = c(paste(mval[1], "\n(", round(mean(marker==mval[1])*100, 1),"%)", sep = ""), 
                                         paste(mval[2], "\n(", round(mean(marker==mval[2])*100, 1),"%)", sep = "")))
    print(p)
    return(list(p, mydata))
  }
