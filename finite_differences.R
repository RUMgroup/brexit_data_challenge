finite.differences <- function(x, y) {
  if (length(x) != length(y)) {
    stop('x and y vectors must have equal length')
  }
  n <- length(x)
  # Initialize a vector of length n to enter the derivative approximations
  fdx <- vector(length = n)
  # Iterate through the values using the forward differencing method
  for (i in 2:n-1) {
    fdx[i-1] <- (y[i+1] - y[i-1]) / (x[i+1] - x[i-1])
  }
  # For the last value, since we are unable to perform the forward differencing method 
  # as only the first n values are known, we use the backward differencing approach
  # instead. Note this will essentially give the same value as the last iteration 
  # in the forward differencing method, but it is used as an approximation as we 
  # don't have any more information
  fdx[n] <- (y[n] - y[n - 1]) / (x[n] - x[n - 1])
  return(fdx)
}


wb_ethnicity_brexit$central_finite_diff <- finite.differences(wb_ethnicity_brexit$year, wb_ethnicity_brexit$value)

wb_ethnicity_brexit$central_finite_diff <- ifelse(wb_ethnicity_brexit$central_finite_diff==Inf, 0, wb_ethnicity_brexit$central_finite_diff)


to_cluster <- wb_ethnicity_brexit %>% 
  select(year, central_finite_diff, LAD16CD) %>% 
  spread(year, central_finite_diff)


# Initialize total within sum of squares error: wss
wss <- 0

# Look over 1 to 15 possible clusters
for (i in 1:15) {
  # Fit the model: km.out
  km.out <- kmeans(to_cluster[10:21], centers = i, nstart = 20, iter.max = 50)
  # Save the within cluster sum of squares
  wss[i] <- km.out$tot.withinss
}

# Produce a scree plot

plot(1:15, wss, type = "b", 
     xlab = "Number of Clusters", 
     ylab = "Within groups sum of squares")


# Select number of clusters
k <- 4


library(factoextra)
library(fpc)
library(NbClust)

km.res <- eclust(to_cluster[15:19], "kmeans", k = k,  graph = FALSE)
to_cluster$clust <- km.res$cluster
km_stats <- cluster.stats(to_cluster[15:19],  to_cluster$clust)
km_stats$avg.silwidth
km_stats$dunn


#Silhouette plot
#Recall that the silhouette coefficient (Si) measures how similar an object i is to the the other objects in its own cluster versus those in the neighbor cluster. Si values range from 1 to - 1:

#  A value of Si close to 1 indicates that the object is well clustered. In the other words, the object i is similar to the other objects in its group.
#A value of Si close to -1 indicates that the object is poorly clustered, and that assignment to some other cluster would probably improve the overall results.
#It’s possible to draw silhouette coefficients of observations using the function fviz_silhouette() [factoextra package], which will also print a summary of the silhouette analysis output. To avoid this, you can use the option print.summary = FALSE.



fviz_silhouette(km.res, palette = "jco", 
                ggtheme = theme_classic())



ggplot(data = wb_ethnicity_brexit, aes(x=year, y=value, group = LAD16CD)) + geom_line(aes(color = clust)) +
  theme_cowplot() +
  scale_colour_gradientn(colours = terrain.colors(10)) +
  labs(x = "Year" , y = "Proportion of LA white British", colour = "Cluster")
