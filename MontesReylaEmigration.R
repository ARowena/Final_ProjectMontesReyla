########################################################################################
########################## Collaborative Data Analysis Assigement 3 ####################
########################################################################################

# 0. Clearing the workspace
rm(list = ls(all=TRUE))

# 1. Installing and loading packages

#install.packages('WDI')
#install.packages('tidyr')
#install.packages('rio')
#install.packages('countrycode')
#install.packages("RJOSONIO")  
#install.packages ("ggplot2")
#install.packages("rworldmap")
#install.packages("sp")
#install.packages("joinCountryData2Map")
#install.packages("kable")
#install.packages("plm")
#install.packages("Formula")
#install.packages("pglm")
#install.packages("stargazer")
#install.packages("migest")
install.packages("tseries")


library("ggmap")
library("maptools")
library("countrycode")
library("RJSONIO")
library("WDI")
library("tidyr")
library("rio")
library("ggplot2")
library("rworldmap")
library("sp")
library('Formula')
library('plm')
library('pglm')
library('stargazer')
library("migest")
library("tseries")
library("vif")


#2. Setting directory
setwd('/Users/AnaCe/Desktop/Final_ProjectMontesReyla')
#setwd('/Users/ayrarowenareyla/Desktop/The Hertie School of Governance/Collaborative Social Sciences/Assignment3MontesReyla/Assignment3MontesReyla')

########################################################################################
################################# LOADING AND CLEANING DATA ############################
########################################################################################

# 4. Loading Migration UN Data

### loop that loads into R each table in the file and extracts the relevant information for this assigment

tables <-c(2, 5, 8, 11)
for (i in tables)   {
  Migration<- import("UN_MigrantStockByOriginAndDestination_2013T1.xls", 
                     format = "xls", sheet =i)
  emigration<- Migration[c(15,16),]
  emigration<- t(emigration)
  emigration<-as.data.frame(emigration)
  emigration<- emigration[c(10:241),]
  colnames(emigration) <- c("Country","Emigration")
  assign(paste0("emigration", i), emigration)
}
emigrationtotal <- cbind(emigration11, emigration8, emigration5, emigration2)
emigrationtotal <-emigrationtotal[,c(1,2, 4, 6,  8)]
emigrationtotal <- gather(emigrationtotal, year, emigration, 2:5)
emigrationtotal$year <- as.character(emigrationtotal$year)
emigrationtotal$year[emigrationtotal$year=="Emigration"] <- "2013"
emigrationtotal$year[emigrationtotal$year=="Emigration.1"] <- "2010"
emigrationtotal$year[emigrationtotal$year=="Emigration.2"] <- "2000"
emigrationtotal$year[emigrationtotal$year=="Emigration.3"] <- "1990"
ls()
rm(list = c("emigration","emigration11", "emigration2", "emigration5", "emigration8", 
            "i", "tables"))

# 5. Loading data from the Worldbank database
wbdata <- c ("IT.CEL.SETS.P2", "IT.NET.USER.P2", "NY.GDP.PCAP.PP.CD","SP.POP.TOTL","SI.POV.DDAY","SL.UEM.TOTL.ZS","VC.IHR.PSRC.P5"
             ,"CC.EST","GE.EST","PV.EST","RQ.EST","RL.EST","VA.EST","SP.DYN.TFRT.IN")

WDI_indi<- WDI(country = "all", indicator = wbdata,
               start = 1990, end = 2013, extra = FALSE, cache = NULL)

# 6. Creating an unique identifier for both data frames
emigrationtotal$iso2c <- countrycode (emigrationtotal$Country, origin = 'country.name', 
                                      destination = 'iso2c', warn = TRUE)

WDI_indi$iso2c <- countrycode (WDI_indi$country, origin = 'country.name', 
                               destination = 'iso2c', warn = TRUE)

# Deleting agregates in the WDI indicators
WDI_indi <- WDI_indi[!is.na(WDI_indi$iso2c),]

# 7. Merging "WDI Indicators " and "UN Migration stocks"
Merged <- merge(emigrationtotal, WDI_indi, by = c('iso2c','year'))
summary(Merged)

# 8. Cleaning the data
# Dropping rows where all variables are missing
Merged <- Merged[which(rowSums(!is.na(Merged[, wbdata])) > 0), ]
# 9 observations

# Renaming variables
Merged <- plyr::rename(Merged, c("IT.CEL.SETS.P2" = "CellphoneUsers"))
Merged <- plyr::rename(Merged, c("IT.NET.USER.P2" = "InternetUsers"))
Merged <- plyr::rename(Merged, c("NY.GDP.PCAP.PP.CD" = "GDPPerCapita"))
Merged <- plyr::rename(Merged, c("SP.POP.TOTL" = "TotalPopulation"))
Merged <- plyr::rename(Merged, c("SI.POV.DDAY" = "Poverty"))
Merged <- plyr::rename(Merged, c("SL.UEM.TOTL.ZS" = "UnemploymentRate"))
Merged <- plyr::rename(Merged, c("VC.IHR.PSRC.P5" = "IntentionalHomocides"))
Merged <- plyr::rename(Merged, c("CC.EST" = "Corruption"))
Merged <- plyr::rename(Merged, c("GE.EST" = "GovernmentEffectiveness"))
Merged <- plyr::rename(Merged, c("PV.EST" = "PoliticalStability"))
Merged <- plyr::rename(Merged, c("RQ.EST" = "RegulatoryQuality"))
Merged <- plyr::rename(Merged, c("RL.EST" = "RuleOfLaw"))
Merged <- plyr::rename(Merged, c("VA.EST" = " VoiceAndAccountability"))
Merged <- plyr::rename(Merged, c("SP.DYN.TFRT.IN" = "FertilityRate"))

# Generating Dependent variables
Merged$emigration2 = Merged$emigration/100000
Merged$emigrationpercap = Merged$emigration/Merged$TotalPopulation*100000
Merged$logemigrationpercap = log(Merged$emigrationpercap)
Merged$logemigration = log(Merged$emigration)

# Check Variables structure
str(Merged)
summary(Merged)
table (Merged$year)

# Code variables as numeric
Merged$year <- as.numeric(Merged$year)
Merged$emigration <- as.numeric(Merged$emigration)

# sub dataframes by year
merged90 <-subset(Merged, year==1990)
merged00 <-subset(Merged, year==2000)
merged10 <-subset(Merged, year==2010)
merged13 <-subset(Merged, year==2013)

# Code variables as numeric
Merged$year <- as.numeric(Merged$year)
Merged$emigration <- as.numeric(Merged$emigration)

# Counting missing information in the Independent Variables

variables <-c("CellphoneUsers", "InternetUsers", "GDPPerCapita", "TotalPopulation", "Poverty",
              "UnemploymentRate", "IntentionalHomocides", "Corruption", "FertilityRate", 
              "GovernmentEffectivness", "PoliticalStability", "RegulatoryStability", 
              "RegulatoryQuality", "RuleOfLaw", "VoiceAndAccountability")

NAs<- sum(is.na(Merged$CellphoneUsers))/nrow(Merged)
NAs$InternetUsers<- sum(is.na(Merged$InternetUsers))/nrow(Merged)
NAs$GDPPerCapita<- sum(is.na(Merged$GDPPerCapita))/nrow(Merged)
NAs$TotalPopulation<- sum(is.na(Merged$TotalPopulation))/nrow(Merged)
NAs$Poverty<- sum(is.na(Merged$Poverty))/nrow(Merged)
NAs$UnemploymentRate<- sum(is.na(Merged$UnemploymentRate))/nrow(Merged)
NAs$Corruption<- sum(is.na(Merged$Corruption))/nrow(Merged)
NAs$IntentionalHomocides<- sum(is.na(Merged$IntentionalHomocides))/nrow(Merged)
NAs$GovernmentEffectivness<- sum(is.na(Merged$GovernmentEffectivness))/nrow(Merged)
NAs$PoliticalStability<- sum(is.na(Merged$PoliticalStability))/nrow(Merged)
NAs$RegulatoryStability<- sum(is.na(Merged$RegulatoryStability))/nrow(Merged)
NAs$VoiceAndAccountability<- sum(is.na(Merged$VoiceAndAccountability))/nrow(Merged)
NAs$FertilityRate<- sum(is.na(Merged$FertilityRate))/nrow(Merged)

# After looking at the number of missing variables in the Merged data frame.
# Also, we are dropping independent variables with more than 15% of the total observations NA 
# Merged <- Merged[, !(colnames(Merged)) %in% c("Poverty", "IntentionalHomocides","PoliticalStability","Corruption", "UnemploymentRate")]
Merged <- Merged[, !(colnames(Merged)) %in% c("Poverty", "IntentionalHomocides","RegulatoryStability")]

# Dropping missing values
Merged <- Merged[!is.na(Merged$InternetUsers),]
Merged <- Merged[!is.na(Merged$CellphoneUsers),]
Merged <- Merged[!is.na(Merged$GDPPerCapita),]
Merged <- Merged[!is.na(Merged$FertilityRate),]
Merged <- Merged[!is.na(Merged$iso2c),]
Merged <- Merged[!is.na(Merged$PoliticalStability),]
Merged <- Merged[!is.na(Merged$UnemploymentRate),]

# Removing extra country name coloumn
Merged <-subset.data.frame(Merged, select = -Country)

# 9. Generating variables
Merged$logInternetUsers = log(Merged$InternetUsers)
Merged$logCellphoneUsers = log(Merged$CellphoneUsers)
Merged$logGDPPerCapita = log(Merged$GDPPerCapita)
Merged$logFertilityRate = log(Merged$FertilityRate)
Merged$logPoliticalStability = log(Merged$PoliticalStability)
Merged$employmentprob = 1-((Merged$UnemploymentRate))

# sub dataframes by year
merged90 <-subset(Merged, year==1990)
merged00 <-subset(Merged, year==2000)
merged10 <-subset(Merged, year==2010)
merged13 <-subset(Merged, year==2013)

# Creating a .csv file with the final version of the data
write.csv(Merged, file="MontesandReyla")

###############################################################################################
############################### DESCRIPTIVE STATISTICS ##############################
####################################################################################

##Set data as panel data
Merged <- plm.data(Merged, index=c("iso2c", "year"))

##Dependent Variable
# Mapping global emigration
# 1990
sPDF <- joinCountryData2Map( merged90
                             ,joinCode = "ISO2"
                             ,nameJoinColumn = "iso2c")
mapDevice(Map1)
mapCountryData(sPDF, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 1990',
               colourPalette = c("darkorange", "coral2","gold","aquamarine1", "cyan3", "blue","magenta"),
               borderCol='black', missingCountryCol="beige")
# 2000
sPDFII <- joinCountryData2Map( merged00
                               ,joinCode = "ISO2"
                               ,nameJoinColumn = "iso2c")
mapCountryData(sPDFII, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 2000',
               colourPalette = c("darkorange", "coral2","gold","aquamarine1", "cyan3", "blue","magenta"),
               borderCol='black')
# 2010
sPDFIII <- joinCountryData2Map( merged10
                                ,joinCode = "ISO2"
                                ,nameJoinColumn = "iso2c")
mapCountryData(sPDFIII, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 2010',
               colourPalette = c("darkorange", "coral2","gold","aquamarine1", "cyan3", "blue","magenta"),
               borderCol='black')
# 2013
sPDFIV <- joinCountryData2Map( merged13
                               ,joinCode = "ISO2"
                               ,nameJoinColumn = "iso2c")
mapCountryData(sPDFIV, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 2013',
               colourPalette = c("darkorange", "coral2","gold","aquamarine1", "cyan3", "blue","magenta"),
               borderCol='black')


## Historgram
hist(Merged$emigration2, xlab = "Thousands of emigrants", main = "Histogram")
hist(Merged$emigrationpercap, xlab = "Emigrants per capita", main = "Histogram")
hist(Merged$logemigrationpercap, xlab = "Emigrants per capita (log)", main = "Histogram")
hist(Merged$logemigration, xlab = "Number of Emigrants (log)", main = "Histogram")

## Normality
jarque.bera.test(Merged$logemigrationpercap)
jarque.bera.test(Merged$logemigration)

## Summary
summary(Merged$logemigrationpercap, na.rm = TRUE)

#Range
range(Merged$logemigrationpercap)

#Interquantile Range
IQR(Merged$logemigrationpercap)

# Boxplots
boxplot(Merged$logemigrationpercap, main = 'Emigration')
boxplot(Merged$CellphoneUsers, main = 'Cellphone Users')

#Variance
var(Merged$logemigrationpercap)
var(Merged$CellphoneUsers)
var(Merged$InternetUsers)

#Standar Deviation
sd(Merged$logemigrationpercap)
sd(Merged$CellphoneUsers)
sd(Merged$InternetUsers)

#Standar Error function
sd_error <- function(x) {
  sd(x)/sqrt(length(x))
}

sd_error(Merged$emigration)

## Independent variables

# Descriptive statistics
summary(Merged$CellphoneUsers, na.rm = TRUE)
summary(Merged$InternetUsers, na.rm = TRUE)
summary(Merged$GDPPerCapita, na.rm = TRUE)
summary(Merged$TotalPopulation, na.rm = TRUE)
summary(Merged$FertilityRate, na.rm = TRUE)
summary(Merged$GovernmentEffectivness, na.rm = TRUE)
summary(Merged$RegulatoryStability, na.rm = TRUE)
summary(Merged$RegulatoryQuality, na.rm = TRUE)
summary(Merged$RuleOfLaw, na.rm = TRUE)
summary(Merged$VoiceAndAccountability, na.rm = TRUE)

# Correlation between independent variables
cor.test(Merged$InternetUsers, Merged$CellphoneUsers, na.rm = TRUE)
cor.test(merged90$GDPPerCapita, merged90$InternetUsers)
cor.test(merged10$TotalPopulation, merged10$InternetUsers)
cor.test(merged13$FertilityRate, merged13$InternetUsers)

cor.test(Merged$InternetUsers, Merged$CellphoneUsers, na.rm = TRUE)
cor.test(merged90$GDPPerCapita, merged90$CellphoneUsers)
cor.test(merged10$TotalPopulation, merged10$CellphoneUsers)
cor.test(merged13$FertilityRate, merged13$CellphoneUsers)
cor.test(Merged$logGDPPerCapita, Merged$logCellphoneUsers)
cor.test(Merged$logInternetUsers, Merged$logCellphoneUsers, na.rm = TRUE)

# Figure
plot(Merged$InternetUsers)

plot(Merged$logemigrationpercap, Merged$CellphoneUsers)
plot(Merged$logemigrationpercap, Merged$InternetUsers)

####################################################################################
#################################### PANEL MODEL ###################################
####################################################################################

##Cellphone users
# Poisson Regression
#Poisson_1 <- glm(emigration2 ~ CellphoneUsers + TotalPopulation + GDPPerCapita + year + FertilityRate, data = Merged, family = 'poisson')
#summary(Poisson_1)

# Panel regression, within estimator 
Within_1 <- plm(emigration2 ~ CellphoneUsers + TotalPopulation + GDPPerCapita + FertilityRate, data = Merged, index = c("country", "year"), model = "within")
summary(Within_1)

# Panel regression, between estimator 
Between_1 <- plm(emigration2 ~ CellphoneUsers + TotalPopulation + GDPPerCapita + FertilityRate, data = Merged, index = c("country", "year"), model = "between")
summary(Between_1)

# Panel regression, random effects
Random_1 <- plm(emigration2 ~ CellphoneUsers + TotalPopulation + GDPPerCapita + FertilityRate, data = Merged, index = c("country", "year"), model = "random")
#summary(Random_1)

Random_1 <- plm(emigration2 ~ CellphoneUsers + GDPPerCapita + FertilityRate, data = Merged, index = c("country", "year"), model = "random")


# using log
pooling_12 <- plm(logemigrationpercap ~ CellphoneUsers +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "pooling")
summary(pooling_12)

Within_12 <- plm(logemigrationpercap ~ CellphoneUsers +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "within")
summary(Within_12)

Between_12 <- plm(logemigrationpercap ~ CellphoneUsers +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "between")
summary(Between_12)

Random_12 <- plm(logemigrationpercap ~ CellphoneUsers + FertilityRate + PoliticalStability + employmentprob, , data = Merged, index = c("country", "year"), model = "random")
summary(Random_12)

# LM test for pooling versus random effects
plmtest(pooling_12)

# LM test for fixed verus pooling
pFtest (Within_12, pooling_12)

# LM test for Random verus fixed
phtest (Within_12, Random_12 )

##Internet Users
# Poisson Regression
#Poisson_2 <- glm(emigration2 ~ InternetUsers + TotalPopulation + GDPPerCapita + year + FertilityRate, data = Merged, family = 'poisson')
#summary(Poisson_2)

# Panel regression, within estimator 
Within_2 <- plm(emigration2 ~ InternetUsers + TotalPopulation + GDPPerCapita + FertilityRate, data = Merged, index = c("country", "year"), model = "within")
summary(Within_2)

# Panel regression, between estimator 
Between_2 <- plm(emigration2 ~ InternetUsers + TotalPopulation + GDPPerCapita + FertilityRate, data = Merged, index = c("country", "year"), model = "between")
summary(Between_2)

# Panel regression, random effects
#Random_2 <- plm(emigration2 ~ InternetUsers + TotalPopulation + GDPPerCapita + FertilityRate, data = Merged, index = c("country", "year"), model = "random")
#summary(Random_2)

# using log
pooling_22 <- plm(logemigrationpercap ~ InternetUsers +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "pooling")
summary(pooling_22)

Within_22 <- plm(logemigrationpercap ~ InternetUsers +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "within")
summary(Within_22)

Between_22 <- plm(logemigrationpercap ~ InternetUsers +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "between")
summary(Between_22)

Random_22 <- plm(logemigrationpercap ~ InternetUsers + FertilityRate + PoliticalStability + employmentprob, , data = Merged, index = c("country", "year"), model = "random")
summary(Random_22)

# LM test for pooling versus random effects
plmtest(pooling_22)

# LM test for fixed verus pooling
pFtest (Within_22, pooling_22)

# LM test for Random verus fixed
phtest (Within_22, Random_22 )



# Creating table output 
stargazer(Poisson_1, Within_1, Between_1,
          type = "latex",
          header = FALSE, 
          title = "Table 1. Regression analysis of emigration stocks around the world 1990-2013",
          digits = 2,
          omit.stat = c("f", "ser"),
          notes = "This regression output shows the results using cellphone users as a proxy of 
          comunication technology")

stargazer(Poisson_2, Within_2, Between_2,
          type = "latex",
          header = FALSE, 
          title = "Table 2. Regression analysis of emigration stocks around the world 1990-2013",
          digits = 2,
          omit.stat = c("f", "ser"),
          notes = "This regression output shows the results using Internet users as a proxy of 
          comunication technology")



#########################################################################################################
######################## Migration total: Dataset with both Origin and Destination ######################
#########################################################################################################

# Loading data and reshaping
tables <-c(2, 5, 8, 11)
for (i in tables)   {
  Migration2<- import("UN_MigrantStockByOriginAndDestination_2013T1.xls", 
                      format = "xls", sheet =i)
  Migration2 <-Migration2[-c(1:14, 17:22, 23, 44, 54, 62, 68, 86, 87, 93, 101, 113, 123, 142, 143, 154, 168, 185, 195, 196, 223, 232, 247, 253, 254, 257, 263, 271),]
  Migration2 <-Migration2[, -c(1, 3:9)]
  nombres <-Migration2[1,]
  colnames(Migration2) <- c(nombres)
  Migration2 <-Migration2[-c(1,2),]
  emigration2 <- gather(Migration2, Origin, emigration, 2:233)
  colnames(emigration2) <- c("Destination","Origin", "Emigration")
  assign(paste0("emigration", i), emigration2)
}

emigrationtotal2 <- cbind(emigration11, emigration8, emigration5, emigration2)
emigrationtotal2 <-emigrationtotal2[,c(1,2, 3, 6, 9, 12)]
emigrationtotal2 <- gather(emigrationtotal2, year, emigration, 3:6)
emigrationtotal2$year <- as.character(emigrationtotal2$year)
emigrationtotal2$year[emigrationtotal2$year=="Emigration"] <- "2013"
emigrationtotal2$year[emigrationtotal2$year=="Emigration.1"] <- "2010"
emigrationtotal2$year[emigrationtotal2$year=="Emigration.2"] <- "2000"
emigrationtotal2$year[emigrationtotal2$year=="Emigration.3"] <- "1990"
ls()
rm(list = c("emigration11", "emigration2", "emigration5", "emigration8", 
            "i", "tables", "nombres"))
## Code for countries
### Country of origin
emigrationtotal2$iso2c <- countrycode (emigrationtotal2$Origin, origin = 'country.name', 
                                       destination = 'iso2c', warn = TRUE)
colnames(emigrationtotal2) <- c("Destination","Origin", "year", "emigration","iso2cOri" )

### Country of destination
emigrationtotal2$iso2c <- countrycode (emigrationtotal2$Destination, origin = 'country.name', 
                                       destination = 'iso2c', warn = TRUE)
colnames(emigrationtotal2) <- c("Destination","Origin", "year", "emigration","iso2cOri", "iso2cDest")

# Deleting missing values
emigrationtotal2 <- emigrationtotal2[!is.na(emigrationtotal2$emigration),]

# Saving File
write.csv(Merged, file="MontesandReylaTotal")

#### WDI
WDI_indi2 <- WDI_indi[which(rowSums(!is.na(WDI_indi[, wbdata])) > 0), ]