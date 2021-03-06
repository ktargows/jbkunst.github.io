#' ---
#' title: "Presenting Highcharter"
#' author: "Joshua Kunst"
#' categories: R
#' layout: post
#' featured_image: /images/presenting-higcharter/presenting-higcharter.png 
#' ---


#+ echo=FALSE, message=FALSE, warning=FALSE
#### setup ws packages ####
rm(list = ls())
knitr::opts_chunk$set(message = FALSE, warning = FALSE, fig.keep = "none")
library("printr")

#' After a lot of documentation, a lot of `R CMD check`s and a lot of patience from CRAN
#' people I'm happy to anonounce [highcharter](http://jkunst.com/highcharter) v0.1.0:
#' *A(nother) wrapper for [Highcharts](http://highcharts.com) charting library*.
#' 
#' Now it's easy make a chart like this. Do you want to know how?
#' 
#' ![presentinghighcharts](/images/presenting-higcharter/presenting-higcharter.png)
#' 
#' [I like Highcharts](http://jkunst.com/r/ggplot-with-a-highcharts-taste/). It was the 
#' first charting javascript library what I used in a long time and have
#' very a mature API to plot a lot of types of charts. Obviously there are some R 
#' packages to plot data using this library:
#' 
#' - [Ramnath Vaidyanathan](https://github.com/ramnathv)'s [rCharts](https://github.com/ramnathv/rCharts).
#' What a library. This was the beginning to the R & JS romance. The `rCharts` approach to plot data
#' is object oriented; here we used a lot of `chart$Key(arguments, ...)`.
#' - [highchartR](https://github.com/jcizel/highchartR) package from [jcizel](https://github.com/jcizel).
#' This package we use the `highcharts` function and give some parameters, like the variable's names 
#' to get the chart.
#' 
#' With these package you can plot almost anything, so **why another wrapper/package/ for highcharts?** 
#' The main reasons were/are:
#' 
#' - Write/code highcharts plots using the piping style and get similar results like 
#' [dygraphs](https://rstudio.github.io/dygraphs/), [metricsgraphics](http://hrbrmstr.github.io/metricsgraphics/),
#' [taucharts](http://rpubs.com/hrbrmstr/taucharts), [leaflet](https://rstudio.github.io/leaflet/)
#' packages.
#' - Get all the funcionalities from the highcharts' [API](api.highcharts.com/highcharts). This means 
#' make a not so useR-friendly wrapper in the sense that you maybe need to make/construct 
#' the chart specifying paramter by parameter (just like highcharts). But don't worry, there are 
#' some *shortcuts* functions to plot some R objects on the fly (see the examples below).
#' - Include and create [*themes*](http://jkunst.com/highcharter/#themes) :D.
#' - Put all my love for highcharts in somewhere.
#' 
##' ##  Some Q&A ####
#' 
#' **When use this package?** I recommend use this when you have finish your analysis and you want
#' to show your result with some interactivity. So, before use experimental plot to visualize, explore
#' the data with **ggplot2** then use **highcharter** as one of the various alternatives what we have
#' in ou*R* community like ggivs, dygraphs, taucharts, metricsgraphics, plotly among others 
#' (please check hafen's [htmlwidgets gallery](http://hafen.github.io/htmlwidgetsgallery/))
#' 
#' **What are the advantages of using this package?** Basically the advantages are inherited from
#' highcharts: have a numerous chart types with the **same** format, style, flavour. I think in a
#' situation when you use a treemap and a scatter chart from differents packages in a shiny app.
#' Other advantage is the posibility to create or modify themes (I like this a lot!) and 
#' customize in every way your chart: beatiful tooltips, titles, credits, legends, [add plotlines or 
#' plotbands](http://jkunst.com/highcharter/#hc_xaxis-and-hc_yaxis).
#' 
#' **What are the disadvantages of this package and highcharts?** One thing I miss is the facet 
#' implementation like in taucharts and hrbrmstr's [taucharts](http://rpubs.com/hrbrmstr/taucharts).
#' This is not really necesary but it's really good when a visualization library has it. Maybe 
#' other disadvantage of *this* implmentation is the functions use standar evaluation 
#' `plot(data$x, data$y)` instead something more direct like `plot(data, ~x, ~y)`. That's why
#' I recommed this package to make the final chart instead use the package to explorer visually
#' the data.
#' 
#' ##  The Hello World chart ####
#' 
#' Let's see a simple chart.
#' 
#+ message=FALSE, warning=FALSE
library("highcharter")
library("magrittr")
library("dplyr")

data("citytemp")

citytemp

hc <- highchart() %>% 
  hc_add_serie(name = "tokyo", data = citytemp$tokyo)

hc

#' Very simple chart. Here comes the powerful highchart API: Adding more series
#' data and adding themes.

hc <- hc %>% 
  hc_title(text = "Temperatures for some cities") %>% 
  hc_xAxis(categories = citytemp$month) %>% 
  hc_add_serie(name = "London", data = citytemp$london,
               dataLabels = list(enabled = TRUE)) %>%
  hc_add_serie(name = "New York", data = citytemp$new_york,
               type = "spline") %>% 
  hc_yAxis(title = list(text = "Temperature"),
           labels = list(format = "{value}? C")) %>%
  hc_add_theme(hc_theme_sandsignika())

hc
  
#' Now, what we can do with a little extra effort:
#' 
#' 

library("httr")
library("purrr")

# get some data
swmovies <- content(GET("http://swapi.co/api/films/?format=json"))

swdata <- map_df(swmovies$results, function(x){
  data_frame(title = x$title,
             species = length(x$species),
             planets = length(x$planets),
             release = x$release_date)
}) %>% arrange(release)

swdata 

# made a theme
swthm <- hc_theme_merge(
  hc_theme_darkunica(),
  hc_theme(
    credits = list(
      style = list(
        color = "#4bd5ee"
      )
    ),
    title = list(
      style = list(
        color = "#4bd5ee"
        )
      ),
    chart = list(
      backgroundColor = "transparent",
      divBackgroundImage = "http://www.wired.com/images_blogs/underwire/2013/02/xwing-bg.gif",
      style = list(fontFamily = "Lato")
    )
  )
)

# chart
highchart() %>% 
  hc_add_theme(swthm) %>% 
  hc_xAxis(categories = swdata$title,
           title = list(text = "Movie")) %>% 
  hc_yAxis(title = list(text = "Number")) %>% 
  hc_add_serie(data = swdata$species, name = "Species",
               type = "column", color = "#e5b13a") %>% 
  hc_add_serie(data = swdata$planets, name = "Planets",
               type = "column", color = "#4bd5ee") %>%
  hc_title(text = "Diversity in <span style=\"color:#e5b13a\">
           STAR WARS</span> movies",
           useHTML = TRUE) %>% 
  hc_credits(enabled = TRUE, text = "Source: SWAPI",
             href = "https://swapi.co/",
             style = list(fontSize = "12px"))


#' ##  More Examples ####

#' For ts objects. Compare this example with the [dygraphs](https://rstudio.github.io/dygraphs/)
#' one

highchart() %>% 
  hc_title(text = "Monthly Deaths from Lung Diseases in the UK") %>% 
  hc_add_serie_ts2(fdeaths, name = "Female") %>%
  hc_add_serie_ts2(mdeaths, name = "Male") 

#' 
#' A more elaborated example using the `mtcars` data. And it's nice like 
#' [juba's scatterD3](https://github.com/juba/scatterD3).
#' 
hcmtcars <- highchart() %>% 
  hc_title(text = "Motor Trend Car Road Tests") %>% 
  hc_subtitle(text = "Source: 1974 Motor Trend US magazine") %>% 
  hc_xAxis(title = list(text = "Weight")) %>% 
  hc_yAxis(title = list(text = "Miles/gallon")) %>% 
  hc_chart(zoomType = "xy") %>% 
  hc_add_serie_scatter(mtcars$wt, mtcars$mpg,
                       mtcars$drat, mtcars$hp,
                       rownames(mtcars),
                       dataLabels = list(
                         enabled = TRUE,
                         format = "{point.label}"
                       )) %>% 
  hc_tooltip(useHTML = TRUE,
             headerFormat = "<table>",
             pointFormat = paste("<tr><th colspan=\"1\"><b>{point.label}</b></th></tr>",
                                 "<tr><th>Weight</th><td>{point.x} lb/1000</td></tr>",
                                 "<tr><th>MPG</th><td>{point.y} mpg</td></tr>",
                                 "<tr><th>Drat</th><td>{point.z} </td></tr>",
                                 "<tr><th>HP</th><td>{point.valuecolor} hp</td></tr>"),
             footerFormat = "</table>")
hcmtcars

#' Let's try treemaps

library("treemap")
library("viridisLite")

data(GNI2010)

#+
tm <- treemap(GNI2010, index = c("continent", "iso3"),
              vSize = "population", vColor = "GNI",
              type = "value", palette = viridis(6))


hc_tm <- highchart() %>% 
  hc_add_serie_treemap(tm, allowDrillToNode = TRUE,
                       layoutAlgorithm = "squarified",
                       name = "tmdata") %>% 
  hc_title(text = "Gross National Income World Data") %>% 
  hc_tooltip(pointFormat = "<b>{point.name}</b>:<br>
             Pop: {point.value:,.0f}<br>
             GNI: {point.valuecolor:,.0f}")

hc_tm

#' ##  You can do anything ####

#' As uncle Bem said some day:
#' 
#' ![SavePie](https://raw.githubusercontent.com/jbkunst/r-posts/master/032-presenting-highcharter/save%20pie.jpg)
#' 
#' You can use this pacakge for evil purposes so be good with the people who see 
#' your charts. So, I will not be happy if I see one chart like this:

iriscount <- count(iris, Species)
iriscount

highchart(width = 400, height = 400) %>% 
  hc_title(text = "Nom! a delicious 3d pie!") %>%
  hc_subtitle(text = "your eyes hurt?") %>% 
  hc_chart(type = "pie", options3d = list(enabled = TRUE, alpha = 70, beta = 0)) %>% 
  hc_plotOptions(pie = list(depth = 70)) %>% 
  hc_add_serie_labels_values(iriscount$Species, iriscount$n) %>% 
  hc_add_theme(hc_theme(
    chart = list(
      backgroundColor = NULL,
      divBackgroundImage = "https://media.giphy.com/media/Yy26NRbpB9lDi/giphy.gif"
    )
  ))


#' ##  Other charts just for charting ####
#' 
data("favorite_bars")
data("favorite_pies")

highchart() %>% 
  hc_title(text = "This is a bar graph describing my favorite pies
           including a pie chart describing my favorite bars") %>%
  hc_subtitle(text = "In percentage of tastiness and awesomeness") %>% 
  hc_add_serie_labels_values(favorite_pies$pie, favorite_pies$percent, name = "Pie",
                             colorByPoint = TRUE, type = "column") %>% 
  hc_add_serie_labels_values(favorite_bars$bar, favorite_bars$percent, type = "pie",
                             name = "Bar", colorByPoint = TRUE, center = c('35%', '10%'),
                             size = 100, dataLabels = list(enabled = FALSE)) %>% 
  hc_yAxis(title = list(text = "percentage of tastiness"),
           labels = list(format = "{value}%"), max = 100) %>% 
  hc_xAxis(categories = favorite_pies$pie) %>% 
  hc_credits(enabled = TRUE, text = "Source (plz click here!)",
             href = "https://www.youtube.com/watch?v=f_J8QU1m0Ng",
             style = list(fontSize = "12px")) %>% 
  hc_legend(enabled = FALSE) %>% 
  hc_tooltip(pointFormat = "{point.y}%")

#' Well, I hope you use, reuse and enjoy this package!
