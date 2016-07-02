library(sdcMicro)
library(sqldf)

# loading  the data
ccdata <- read.table("data_for_student_case.csv", sep = ",", header=TRUE)

# replace countricode NA to NB so that it is not considered as N/A
ccdata <- sqldf(c('update ccdata set issuercountrycode="NB" where issuercountrycode is NULL', 'select * from main.ccdata'))
ccdata <- sqldf(c('update ccdata set shoppercountrycode="NB" where shoppercountrycode is NULL', 'select * from main.ccdata'))

# remove record with missing value
ccdata <- ccdata[complete.cases(ccdata),]

# create new data for anonymized version
newdata <- ccdata

# update currencycode to match shoppercountrycode
newdata <- sqldf(c('update newdata set currencycode="A" where (
                  (currencycode="AUD" and shoppercountrycode="AU") or
                   (currencycode="GBP" and shoppercountrycode="GB") or
                   (currencycode="MXN" and shoppercountrycode="MX") or
                   (currencycode="NZD" and shoppercountrycode="NZ") or
                   (currencycode="SEK" and shoppercountrycode="SE") )
                   ', 'select * from main.newdata'))
newdata <- sqldf(c('update newdata set currencycode="B" where currencycode<>"A" and not(
                  (currencycode="AUD" and shoppercountrycode="AU") or
                  (currencycode="GBP" and shoppercountrycode="GB") or
                  (currencycode="MXN" and shoppercountrycode="MX") or
                  (currencycode="NZD" and shoppercountrycode="NZ") or
                  (currencycode="SEK" and shoppercountrycode="SE") )
                   ', 'select * from main.newdata'))

# anonymize issuercountrycode and shoppercountrycode
newdata <- sqldf(c('update newdata set issuercountrycode="A",  shoppercountrycode="A" where issuercountrycode==shoppercountrycode', 'select * from main.newdata'))
newdata <- sqldf(c('update newdata set issuercountrycode="B",  shoppercountrycode="A" where shoppercountrycode<>"A" and issuercountrycode<>shoppercountrycode', 'select * from main.newdata'))


newdata <- sqldf(c('update newdata set shopperinteraction="*"', 'select * from main.newdata'))

getAnonimity <- function(dt) {
  # extract day of the week information
  dt$weekday <- weekdays(as.Date(dt$creationdate))
  sdc <- createSdcObj(dt, keyVars = c("shoppercountrycode", "issuercountrycode", "shopperinteraction", "weekday"), sensibleVar = c("card_id"))
  anoset_size = {}
  
  for (i in 1:10){
    #take sample with i/10 fraction
    sample_size <- round(i/10*nrow(dt),digits=0)
    sample <- dt[sample(1:nrow(dt), sample_size, replace=FALSE),]
    
    # aggregate sample based on quasi-identifier (extract the anonimirt sets)
    sample_summary <- sqldf('select issuercountrycode,shoppercountrycode,shopperinteraction, weekday, count(*) from sample group by issuercountrycode,issuercountrycode,shoppercountrycode,shopperinteraction,weekday order by count(*) ')
    # get size of anonimity set
    as_size <- nrow(sample_summary)
    anoset_size[i] = as_size
    sample_sdc <- createSdcObj(dt, keyVars = c("shoppercountrycode", "issuercountrycode", "shopperinteraction", "weekday"), sensibleVar = c("card_id"))
  }

  plot(anoset_size, ylim=range(0:max(anoset_size)+5))
  return(anoset_size)
}

# check anonimity from original data
anonimityset_size_plot_before = getAnonimity(ccdata)
ccdata$weekday <- weekdays(as.Date(ccdata$creationdate))
ano_set_before <- sqldf('select issuercountrycode,shoppercountrycode,shopperinteraction, weekday, count(*) as k from ccdata group by issuercountrycode,issuercountrycode,shoppercountrycode,shopperinteraction,weekday order by count(*) ')
k_before = ano_set_before[1,"k"]
k_freq_before = sqldf(' select k, count(*) as freq from ano_set_before group by k order by k')

# check anonimity after anonymization
anonimityset_size_plot_after = getAnonimity(newdata)
newdata$weekday <- weekdays(as.Date(newdata$creationdate))
ano_set_after <- sqldf('select issuercountrycode,shoppercountrycode,shopperinteraction, weekday, count(*) as k from newdata group by issuercountrycode,issuercountrycode,shoppercountrycode,shopperinteraction,weekday order by count(*) ')
k_after = ano_set_after[1,"count(*)"]
k_freq_after = sqldf(' select k, count(*) as freq from ano_set_after group by k order by k')
