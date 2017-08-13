rm(list = ls())
library(data.table)
library(XML)
library(rvest)

error_count <<- 0

collect <- function(sublinks){


  newdata <- c()
  for(i in 1:length(sublinks)){
    result = tryCatch({
      Sahibinden <- read_html(sublinks[i])
    }, warning = function(w) {
      warning-handler-code
    }, error = function(e) {
      print(paste(e))
      error_count <<- error_count + 1
    })

    print(paste(sublinks[i]))
    attribute <- Sahibinden %>% html_nodes(".classifiedInfoList") %>% html_nodes("li") %>% html_nodes("strong") %>% html_text()
    attribute <- gsub("[\t\r\n\ ]", "", attribute)
    value     <- Sahibinden %>% html_nodes(".classifiedInfoList") %>% html_nodes("li") %>% html_nodes("span") %>% html_text()
    value     <- gsub("[\t\r\n\ ]", "", value)


    result = tryCatch({
      newdata    <- rbind(newdata, t(value))
    }, warning = function(w) {
      warning-handler-code
    }, error = function(e) {
      print(paste(e))
      error_count <<- error_count + 1
    })


    if(i == 1){
      colnames(newdata) <- attribute
    }
  }
  return(newdata)
}





url <- "https://www.sahibinden.com/satilik"
result = tryCatch({
  sahibinden <- read_html(url)
}, warning = function(w) {
  warning-handler-code
}, error = function(e) {
  print(paste(e))
  error_count <<- error_count + 1
})





sublinks     <- sahibinden %>% html_nodes(".classifiedTitle") %>% html_attr("href")
emlak_tipi   <- sahibinden %>% html_nodes(".searchResultsTagAttributeValue") %>% html_text()
ilan_basligi <- sahibinden %>% html_nodes(".classifiedTitle") %>% html_text()
m2_oda       <- sahibinden %>% html_nodes(".searchResultsAttributeValue") %>% html_text()
tek          <- seq(1, length(m2_oda), 2)
cift         <- seq(2, length(m2_oda), 2)
m2           <- m2_oda[tek]
oda          <- m2_oda[cift]
ilan_tarihi  <- sahibinden %>% html_nodes(".searchResultsDateValue") %>% html_text()
fiyat        <- sahibinden %>% html_nodes(".searchResultsPriceValue") %>% html_text()
location     <- sahibinden %>% html_nodes(".searchResultsLocationValue") %>% html_text()

pos = grep('/projeler/p', sublinks)
if(length(pos) != 0){
  ilan_basligi <- ilan_basligi[-pos]
  sublinks     <- sublinks[-pos]
}


mydata        <- data.table(cbind(emlak_tipi, ilan_basligi, m2, oda, ilan_tarihi, fiyat, location))
allSubLinks   <- paste("https://www.sahibinden.com" ,sublinks,sep = "")
newAttributes <- collect(allSubLinks)
mydata        <- cbind(mydata, newAttributes)

nextPage <- length(m2)

while(TRUE){

  nextUrl  <- "?pagingOffset="
  newUrl   <- paste(url, nextUrl, toString(nextPage), sep = "")
  nextPage <- nextPage + length(m2)

  result = tryCatch({
    sahibinden <- read_html(url)
  }, warning = function(w) {
    warning-handler-code
  }, error = function(e) {
    print(paste(e))
    error_count <<- error_count + 1
  })

  print(paste("------------------"))
  print(paste(newUrl))

  sublinks     <- sahibinden %>% html_nodes(".classifiedTitle") %>% html_attr("href")
  emlak_tipi   <- sahibinden %>% html_nodes(".searchResultsTagAttributeValue") %>% html_text()
  ilan_basligi <- sahibinden %>% html_nodes(".classifiedTitle") %>% html_text()
  m2_oda       <- sahibinden %>% html_nodes(".searchResultsAttributeValue") %>% html_text()
  tek          <- seq(1, length(m2_oda), 2)
  cift         <- seq(2, length(m2_oda), 2)
  m2           <- m2_oda[tek]
  oda          <- m2_oda[cift]
  ilan_tarihi  <- sahibinden %>% html_nodes(".searchResultsDateValue") %>% html_text()
  fiyat        <- sahibinden %>% html_nodes(".searchResultsPriceValue") %>% html_text()
  location     <- sahibinden %>% html_nodes(".searchResultsLocationValue") %>% html_text()

  pos = grep('/projeler/p', sublinks)
  if(length(pos) != 0){
    ilan_basligi <- ilan_basligi[-pos]
    sublinks     <- sublinks[-pos]
  }

  mydataNew     <- data.table(cbind(emlak_tipi, ilan_basligi, m2, oda, ilan_tarihi, fiyat, location))
  allSubLinks   <- paste("https://www.sahibinden.com" ,sublinks,sep = "")
  newAttributes <- collect(allSubLinks)
  mydataNew     <- cbind(mydataNew, newAttributes)
  mydata        <- rbind(mydata, mydataNew)

  print(paste(dim(mydata), error_count))

}
