library(sdcMicro)
library(sqldf)

data <- read.table("data_for_student_case.csv", sep = ",", header=TRUE)
data <- data[complete.cases(data),]
data$creationdate <- weekdays(as.Date(data$creationdate))

#sqldf('update data set issuercountrycode="A",  shoppercountrycode="B" where issuercountrycode<>shoppercountrycode')
#sqldf('update data set issuercountrycode="A",  shoppercountrycode="A" where issuercountrycode=shoppercountrycode')
sqlres <- sqldf('select issuercountrycode,shoppercountrycode,shopperinteraction, creationdate, count(*) from data group by issuercountrycode,issuercountrycode,shoppercountrycode,shopperinteraction,creationdate order by count(*) ')

sdc <- createSdcObj(data, keyVars = c("shoppercountrycode", "issuercountrycode", "shopperinteraction", "creationdate"), sensibleVar = c("card_id"))
