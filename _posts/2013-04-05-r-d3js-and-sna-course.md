---
title: R, D3js and SNA Course
output: html_fragment
categories: R
layout: post
featured_image: /images/featured-image/r-d3js-sna-course.png
---



Update 2015-11-09: This is migration from an old post.

I took the [SNA course](https://www.coursera.org/course/sna) by [Lada Adamic](http://www.ladamic.com/) in coursera. 
It's a super interesting course. In fact, I was using the networks only how a visualization tool, and that is 
what it make me little bit embarrassing because there are more, a lot of more. You can detect communities, know 
more centric nodes and a lot of other information. So, there are a lot of reasons to look the course

By other hand I like the d3 javascript library. Recently I was learning javascript, so I decided make a very 
little app to keep learning this library and show differents measures of centrality for each node in a set 
of 4 toy networks and see these measures by size, color or a label

<iframe src="/media/sna.html" width="650px" height="500px"></iframe>

Now, the R code to make the data:


```r
rm(list = ls())
##### Load Packages ####
library("sna") 
# for build a block diagonal matrix
library("Matrix")   
# (https://stat.ethz.ch/pipermail/r-help/2007-June/133875.html)
library("reldist")  
library("plyr")
library("rjson")

##### Functions ####
degree_sna <- function(net, norm = TRUE, ...){
  degree(net, ...)/2/(if (norm) ncol(net) - 1 else 1)
}

betweenness_sna <- function(net, norm = FALSE, ...){
  n <- ncol(net)
  betweenness(net, ...)/2/(if (norm) (n - 1)*(n - 2)/2 else 1)
}

##### Networks ####
net.butterfly <- matrix(c(0,1,1,0,0,0,0,
                          1,0,1,0,0,0,0,
                          1,1,0,1,0,0,0,
                          0,0,1,0,1,0,0,
                          0,0,0,1,0,1,1,
                          0,0,0,0,1,0,1,
                          0,0,0,0,1,1,0),
                        byrow = TRUE, nrow = 7)

net.star <- matrix(c(0,1,1,1,1,1,
                     1,0,0,0,0,0,
                     1,0,0,0,0,0,
                     1,0,0,0,0,0,
                     1,0,0,0,0,0,
                     1,0,0,0,0,0),
                   byrow = TRUE, nrow = 6)

net.line <- matrix(c(0,1,0,0,0,
                     1,0,1,0,0,
                     0,1,0,1,0,
                     0,0,1,0,1,
                     0,0,0,1,0),
                   byrow = TRUE, nrow = 5)

net.circular <- matrix(c(0,1,0,0,1,
                         1,0,1,0,0,
                         0,1,0,1,0,
                         0,0,1,0,1,
                         1,0,0,1,0),
                       byrow = TRUE, nrow = 5)

nets <- list(net.butterfly, net.star, net.line, net.circular)
net.all <- as.matrix(bdiag(net.butterfly, net.star, net.line, net.circular))


##### Plots ####
gplot(net.butterfly, displaylabels = TRUE, usearrows = FALSE)
```

<img src="/images/r-d3js-and-sna-course/unnamed-chunk-1-1.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

```r
gplot(net.star, displaylabels = TRUE, usearrows = FALSE)
```

<img src="/images/r-d3js-and-sna-course/unnamed-chunk-1-2.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

```r
gplot(net.line, displaylabels = TRUE, usearrows = FALSE)
```

<img src="/images/r-d3js-and-sna-course/unnamed-chunk-1-3.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

```r
gplot(net.circular, displaylabels = TRUE, usearrows = FALSE)
```

<img src="/images/r-d3js-and-sna-course/unnamed-chunk-1-4.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

```r
gplot(net.all, usearrows = FALSE,
      label = unlist(llply(nets, degree_sna, norm = FALSE)))
```

<img src="/images/r-d3js-and-sna-course/unnamed-chunk-1-5.png" title="plot of chunk unnamed-chunk-1" alt="plot of chunk unnamed-chunk-1" style="display: block; margin: auto;" />

```r
#### Indicators ####
# Degrees for each node of each network
llply(nets, degree_sna)
```

```
## [[1]]
## [1] 0.333 0.333 0.500 0.333 0.500 0.333 0.333
## 
## [[2]]
## [1] 1.0 0.2 0.2 0.2 0.2 0.2
## 
## [[3]]
## [1] 0.25 0.50 0.50 0.50 0.25
## 
## [[4]]
## [1] 0.5 0.5 0.5 0.5 0.5
```

```r
llply(nets, degree_sna, norm = FALSE)
```

```
## [[1]]
## [1] 2 2 3 2 3 2 2
## 
## [[2]]
## [1] 5 1 1 1 1 1
## 
## [[3]]
## [1] 1 2 2 2 1
## 
## [[4]]
## [1] 2 2 2 2 2
```

```r
# Differences beetween degree for nodes in each network
laply(nets, function(net){ gini(degree_sna(net)) })
```

```
## [1] 0.0893 0.3333 0.1500 0.0000
```

```r
laply(nets, function(net){   sd(degree_sna(net)) })
```

```
## [1] 0.0813 0.3266 0.1369 0.0000
```

```r
# Centralization coefficient $C_D$
laply(nets, centralization, degree)
```

```
## [1] 0.167 1.000 0.167 0.000
```

```r
# Betweenness
llply(nets, betweenness_sna)
```

```
## [[1]]
## [1] 0 0 8 9 8 0 0
## 
## [[2]]
## [1] 10  0  0  0  0  0
## 
## [[3]]
## [1] 0 3 4 3 0
## 
## [[4]]
## [1] 1 1 1 1 1
```

```r
llply(nets, betweenness_sna, norm = TRUE)
```

```
## [[1]]
## [1] 0.000 0.000 0.533 0.600 0.533 0.000 0.000
## 
## [[2]]
## [1] 1 0 0 0 0 0
## 
## [[3]]
## [1] 0.000 0.500 0.667 0.500 0.000
## 
## [[4]]
## [1] 0.167 0.167 0.167 0.167 0.167
```

```r
# Closeness
llply(nets, closeness)
```

```
## [[1]]
## [1] 0.400 0.400 0.545 0.600 0.545 0.400 0.400
## 
## [[2]]
## [1] 1.000 0.556 0.556 0.556 0.556 0.556
## 
## [[3]]
## [1] 0.400 0.571 0.667 0.571 0.400
## 
## [[4]]
## [1] 0.667 0.667 0.667 0.667 0.667
```

```r
# Eigenvector Centrality
llply(nets, evcent)
```

```
## [[1]]
## [1] 0.335 0.335 0.450 0.384 0.450 0.335 0.335
## 
## [[2]]
## [1] 0.408 0.408 0.408 0.408 0.408 0.408
## 
## [[3]]
## [1] 0.309 0.463 0.617 0.463 0.309
## 
## [[4]]
## [1] 0.447 0.447 0.447 0.447 0.447
```

```r
#### Consolidate Data ####
names <- paste(rep(1:length(nets), laply(nets, ncol)),
               unlist(llply(nets, function(x) 1:ncol(x))), sep = "_")

colnames(net.all) <- names
rownames(net.all) <- names

links <- ldply(names, function(name){
  # name <- sample(names, size = 1)
  # name <- names[1]
  data.frame(source = which(names == name) - 1, 
             target = which(net.all[name,] == 1) - 1)
})

nodes <- data.frame(name = names)
nodes$degree_norm <- unlist(llply(nets, degree_sna))
nodes$degree <- unlist(llply(nets, degree_sna, norm = FALSE))
nodes$betweenness <- unlist(llply(nets, betweenness_sna))
nodes$betweenness_norm <- unlist(llply(nets, betweenness_sna, norm = TRUE))
nodes$closeness <- unlist(llply(nets, closeness))
nodes$eigen_vector_centrality <- unlist(llply(nets, evcent))

#### Exporting Data ####
nodes_json <- adply(nodes, 1, toJSON )$V1
nodes_json <- paste(" \"nodes\" : [", paste("\n", nodes_json, collapse = ", "), "\n]")

links_json <- adply(links, 1, toJSON)$V1
links_json <- paste(" \"links\" : [", paste("\n", links_json, collapse = ", "), "\n]")

data_json <- paste("{\n", nodes_json, "\n,\n", links_json, "}")
# write(data_json, "data.json")
```

You can fork the repo from [here](https://github.com/jbkunst/R-D3-SNA-Course-Example).
