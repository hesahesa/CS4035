library(sdcMicro)

data <- read.table("adult.data", sep = ",")

ndata <- subset(data, V1 != " ?" & V2 != " ?" & V3 != " ?" & V4 != " ?" & V5 != " ?" & V6 != " ?" & V7 != " ?" & V8 != " ?" & V9 != " ?" & V10 != " ?" & V11 != " ?" & V12 != " ?" & V13 != " ?" & V14 != " ?" & V15 != " ?")


# 1. record linkage

## age = V1
## sex = V10
## race = V9
## education = V4

# try to find from Table 1

# Patricia Corner (1 row)
pCorner <- subset(ndata, V1 == "39" & V10 == " Female" & V9 == " Black" & V4 == " Masters")

# Benjamin Hodges (1 row)
bHodges <- subset(ndata, V1 == "78" & V10 == " Male" & V9 == " White" & V4 == " Some-college")

# Sergio Townsend (0 row)
sTownsend <- subset(ndata, V1 == "24" & V10 == " Male" & V9 == " Asian-Pac-Islander" & V4 == " Bachelor")

# Dianne Joseph (1 row)
dJoseph <- subset(ndata, V1 == "31" & V10 == " Female" & V9 == " Black" & V4 == " 10th")

# Rufus George (1 row)
rGeorge <- subset(ndata, V1 == "52" & V10 == " Male" & V9 == " Amer-Indian-Eskimo" & V4 == " 7th-8th")

# 2. Domain Generalization Hierarchies

## occupation = V7
## income = V15

sdc <- createSdcObj(ndata, keyVars = c('V1', 'V4', 'V9', 'V10'), sensibleVar = c('V7', 'V15'))

# 3. k-anonymity with Generalisation and Suppression

# k = 3

sdck3 <- groupVars(sdc, var = "V10", before = c(" Female", " Male"), after = c(" AnySex", " AnySex"))
sdck3 <- globalRecode(sdck3, column = "V1", breaks = c(17, 21, 31, 41, 51, 61, 71, 81, 91))
sdck3 <- groupVars(sdck3, var = "V9", before = c(" White", " Asian-Pac-Islander", " Amer-Indian-Eskimo", " Other", " Black"), 
		after = c(" AnyRace", " AnyRace", " AnyRace", " AnyRace", " AnyRace"))
sdck3 <- groupVars(sdck3, var = "V4", before = c(" Preschool", " 1st-4th", " 5th-6th", " 7th-8th", " 9th", " 10th", " 11th", 
		" 12th", " HS-grad", " Bachelors", " Some-college", " Prof-school", " Assoc-acdm", " Assoc-voc", " Masters", " Doctorate"), 
		after = c(" Preschool-ElementarySchool", " Preschool-ElementarySchool", " Preschool-ElementarySchool", 
		" JuniorHigh", " JuniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " University/College", " University/College", 
		" Professional/Vocational", " Professional/Vocational", " Professional/Vocational", " PostGrad", " PostGrad"))
sdck3 <- localSuppression(sdck3, 3)

# k = 5

sdck5 <- groupVars(sdc, var = "V10", before = c(" Female", " Male"), after = c(" AnySex", " AnySex"))
sdck5 <- globalRecode(sdck5, column = "V1", breaks = c(17, 21, 31, 41, 51, 61, 71, 81, 91))
sdck5 <- groupVars(sdck5, var = "V9", before = c(" White", " Asian-Pac-Islander", " Amer-Indian-Eskimo", " Other", " Black"), 
		after = c(" AnyRace", " AnyRace", " AnyRace", " AnyRace", " AnyRace"))
sdck5 <- groupVars(sdck5, var = "V4", before = c(" Preschool", " 1st-4th", " 5th-6th", " 7th-8th", " 9th", " 10th", " 11th", 
		" 12th", " HS-grad", " Bachelors", " Some-college", " Prof-school", " Assoc-acdm", " Assoc-voc", " Masters", " Doctorate"), 
		after = c(" Preschool-ElementarySchool", " Preschool-ElementarySchool", " Preschool-ElementarySchool", 
		" JuniorHigh", " JuniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " University/College", " University/College", 
		" Professional/Vocational", " Professional/Vocational", " Professional/Vocational", " PostGrad", " PostGrad"))
sdck5 <- localSuppression(sdck5, 5)

# k = 10

sdck10 <- groupVars(sdc, var = "V10", before = c(" Female", " Male"), after = c(" AnySex", " AnySex"))
sdck10 <- globalRecode(sdck10, column = "V1", breaks = c(17, 31, 51, 71, 91))
sdck10 <- groupVars(sdck10, var = "V9", before = c(" White", " Asian-Pac-Islander", " Amer-Indian-Eskimo", " Other", " Black"), 
		after = c(" AnyRace", " AnyRace", " AnyRace", " AnyRace", " AnyRace"))
sdck10 <- groupVars(sdck10, var = "V4", before = c(" Preschool", " 1st-4th", " 5th-6th", " 7th-8th", " 9th", " 10th", " 11th", 
		" 12th", " HS-grad", " Bachelors", " Some-college", " Prof-school", " Assoc-acdm", " Assoc-voc", " Masters", " Doctorate"), 
		after = c(" Preschool-ElementarySchool", " Preschool-ElementarySchool", " Preschool-ElementarySchool", 
		" JuniorHigh", " JuniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " University/College", " University/College", 
		" Professional/Vocational", " Professional/Vocational", " Professional/Vocational", " PostGrad", " PostGrad"))
sdck10 <- localSuppression(sdck10, 10)

# k = 50

sdck50 <- groupVars(sdc, var = "V10", before = c(" Female", " Male"), after = c(" AnySex", " AnySex"))
sdck50 <- globalRecode(sdck50, column = "V1", breaks = c(17, 51, 91))
sdck50 <- groupVars(sdck50, var = "V9", before = c(" White", " Asian-Pac-Islander", " Amer-Indian-Eskimo", " Other", " Black"), 
		after = c(" AnyRace", " AnyRace", " AnyRace", " AnyRace", " AnyRace"))
sdck50 <- groupVars(sdck50, var = "V4", before = c(" Preschool", " 1st-4th", " 5th-6th", " 7th-8th", " 9th", " 10th", " 11th", 
		" 12th", " HS-grad", " Bachelors", " Some-college", " Prof-school", " Assoc-acdm", " Assoc-voc", " Masters", " Doctorate"), 
		after = c(" Preschool-ElementarySchool", " Preschool-ElementarySchool", " Preschool-ElementarySchool", 
		" JuniorHigh", " JuniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " SeniorHigh", " University/College", " University/College", 
		" Professional/Vocational", " Professional/Vocational", " Professional/Vocational", " PostGrad", " PostGrad"))

# this code throws error
#sdck50 <- localSuppression(sdck50, 50)

# k = 100

sdck100 <- groupVars(sdc, var = "V10", before = c(" Female", " Male"), after = c(" AnySex", " AnySex"))
sdck100 <- globalRecode(sdck100, column = "V1", breaks = c(17, 51, 91))
sdck100 <- groupVars(sdck100, var = "V9", before = c(" White", " Asian-Pac-Islander", " Amer-Indian-Eskimo", " Other", " Black"), 
		after = c(" AnyRace", " AnyRace", " AnyRace", " AnyRace", " AnyRace"))
sdck100 <- groupVars(sdck100, var = "V4", before = c(" Preschool", " 1st-4th", " 5th-6th", " 7th-8th", " 9th", " 10th", " 11th", 
		" 12th", " HS-grad", " Bachelors", " Some-college", " Prof-school", " Assoc-acdm", " Assoc-voc", " Masters", " Doctorate"), 
		after = c(" HighSchoolAndLower", " HighSchoolAndLower", " HighSchoolAndLower", 
		" HighSchoolAndLower", " HighSchoolAndLower", " HighSchoolAndLower", " HighSchoolAndLower", " HighSchoolAndLower", " HighSchoolAndLower", 
		" PostHighSchool", " PostHighSchool", 
		" PostHighSchool", " PostHighSchool", " PostHighSchool", " PostHighSchool", " PostHighSchool"))

# this code throws error
#sdck100 <- localSuppression(sdck100, 100)

# 4. Utility Measures on Anonymised Data
sizeOrig <- nrow(ndata)
numQID <- 4

# k = 3
newdata <- extractManipData(sdck3)
sizeGeneralized <- nrow(newdata)
ratioDGH1 <- 1/5
ratioDGH2 <- 1/4
ratioDGH3 <- 1/2
ratioDGH4 <- 1/2

1 - (sizeGeneralized*ratioDGH1 + sizeGeneralized*ratioDGH2 + 
	sizeGeneralized*ratioDGH3 + sizeGeneralized*ratioDGH4)/(sizeOrig * numQID)

# k = 5
newdata <- extractManipData(sdck5)
sizeGeneralized <- nrow(newdata)
ratioDGH1 <- 1/5
ratioDGH2 <- 1/4
ratioDGH3 <- 1/2
ratioDGH4 <- 1/2

1 - (sizeGeneralized*ratioDGH1 + sizeGeneralized*ratioDGH2 + 
	sizeGeneralized*ratioDGH3 + sizeGeneralized*ratioDGH4)/(sizeOrig * numQID)

# k = 10
newdata <- extractManipData(sdck10)
sizeGeneralized <- nrow(newdata)
ratioDGH1 <- 2/5
ratioDGH2 <- 1/4
ratioDGH3 <- 1/2
ratioDGH4 <- 1/2

1 - (sizeGeneralized*ratioDGH1 + sizeGeneralized*ratioDGH2 + 
	sizeGeneralized*ratioDGH3 + sizeGeneralized*ratioDGH4)/(sizeOrig * numQID)

# k = 50
newdata <- extractManipData(sdck50)
sizeGeneralized <- nrow(newdata)
ratioDGH1 <- 3/5
ratioDGH2 <- 1/4
ratioDGH3 <- 1/2
ratioDGH4 <- 1/2

1 - (sizeGeneralized*ratioDGH1 + sizeGeneralized*ratioDGH2 + 
	sizeGeneralized*ratioDGH3 + sizeGeneralized*ratioDGH4)/(sizeOrig * numQID)

# k = 100
newdata <- extractManipData(sdck100)
sizeGeneralized <- nrow(newdata)
ratioDGH1 <- 3/5
ratioDGH2 <- 2/4
ratioDGH3 <- 1/2
ratioDGH4 <- 1/2

1 - (sizeGeneralized*ratioDGH1 + sizeGeneralized*ratioDGH2 + 
	sizeGeneralized*ratioDGH3 + sizeGeneralized*ratioDGH4)/(sizeOrig * numQID)

# 5. Attribute Linkage Attack

# k = 3
newdatak3 <- extractManipData(sdck3)
pCorner <- subset(newdatak3, V1 == "(31,41]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " PostGrad")
# extract information of occupation and income. If all observation are in one element (e.g.: all income are in >50k) then
# homogeneity attack successful. If any one observation is in one element (e.g.: there is 1 occupation as Tech-Support) then background
# knowledge attack (assuming we know the information) is successful.
table(pCorner$V7)
table(pCorner$V15)
bHodges <- subset(newdatak3, V1 == "(71,81]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " University/College")
table(bHodges$V7)
table(bHodges$V15)
dJoseph <- subset(newdatak3, V1 == "(31,41]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " SeniorHigh")
table(dJoseph$V7)
table(dJoseph$V15)
rGeorge <- subset(newdatak3, V1 == "(51,61]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " JuniorHigh")
table(rGeorge$V7)
table(rGeorge$V15)

# k = 5
newdatak5 <- extractManipData(sdck5)
pCorner <- subset(newdatak5, V1 == "(31,41]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " PostGrad")
table(pCorner$V7)
table(pCorner$V15)
bHodges <- subset(newdatak5, V1 == "(71,81]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " University/College")
table(bHodges$V7)
table(bHodges$V15)
dJoseph <- subset(newdatak5, V1 == "(31,41]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " SeniorHigh")
table(dJoseph$V7)
table(dJoseph$V15)
rGeorge <- subset(newdatak5, V1 == "(51,61]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " JuniorHigh")
table(rGeorge$V7)
table(rGeorge$V15)

# k = 10
newdatak10 <- extractManipData(sdck10)
pCorner <- subset(newdatak10, V1 == "(31,51]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " PostGrad")
table(pCorner$V7)
table(pCorner$V15)
bHodges <- subset(newdatak10, V1 == "(71,91]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " University/College")
table(bHodges$V7)
table(bHodges$V15)
dJoseph <- subset(newdatak10, V1 == "(31,51]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " SeniorHigh")
table(dJoseph$V7)
table(dJoseph$V15)
rGeorge <- subset(newdatak10, V1 == "(51,71]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " JuniorHigh")
table(rGeorge$V7)
table(rGeorge$V15)

# k = 50
newdatak50 <- extractManipData(sdck50)
pCorner <- subset(newdatak50, V1 == "(17,51]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " PostGrad")
table(pCorner$V7)
table(pCorner$V15)
bHodges <- subset(newdatak50, V1 == "(51,91]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " University/College")
table(bHodges$V7)
table(bHodges$V15)
dJoseph <- subset(newdatak50, V1 == "(17,51]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " SeniorHigh")
table(dJoseph$V7)
table(dJoseph$V15)
rGeorge <- subset(newdatak50, V1 == "(51,91]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " JuniorHigh")
table(rGeorge$V7)
table(rGeorge$V15)

# k = 100
newdatak100 <- extractManipData(sdck100)
pCorner <- subset(newdatak100, V1 == "(17,51]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " PostHighSchool")
table(pCorner$V7)
table(pCorner$V15)
bHodges <- subset(newdatak100, V1 == "(51,91]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " PostHighSchool")
table(bHodges$V7)
table(bHodges$V15)
dJoseph <- subset(newdatak100, V1 == "(17,51]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " HighSchoolAndLower")
table(dJoseph$V7)
table(dJoseph$V15)
rGeorge <- subset(newdatak100, V1 == "(51,91]" & V10 == " AnySex" & V9 == " AnyRace" & V4 == " HighSchoolAndLower")
table(rGeorge$V7)
table(rGeorge$V15)