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
#install.packages("tseries")
#install.packages("DataCombine")
#install.packages("corrplot")
#install.packages("repmis")
#install.packages("Hmisc")

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
library("corrplot")
library("repmis")
library("Hmisc")
#2. Setting directory
setwd('/Users/AnaCe/Desktop/Final_ProjectMontesReyla')
#setwd('/Users/ayrarowenareyla/Desktop/The Hertie School of Governance/Collaborative Social Sciences/Final_ProjectMontesReyla')

########################################################################################
################################# LOADING AND CLEANING DATA ############################
########################################################################################

# 4. Loading Migration UN Data
## loop that loads into R each table in the file and transforms the relevant information for this assigment

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
rm(list = c("emigration","i", "tables"))

# 5. Creating an unique identifier for emigration
emigrationtotal$iso2c <- countrycode(emigrationtotal$Country, origin = 'country.name', 
                                      destination = 'iso2c', warn = TRUE)

# 6. Loading data from the Worldbank database
wbdata <- c ("IT.CEL.SETS.P2", "IT.NET.USER.P2", "NY.GDP.PCAP.PP.CD","SP.POP.TOTL","SI.POV.DDAY","SL.UEM.TOTL.ZS","VC.IHR.PSRC.P5"
             ,"CC.EST","GE.EST","PV.EST","RQ.EST","RL.EST","VA.EST","SP.DYN.TFRT.IN")

WDI_indi<- WDI(country = "all", indicator = wbdata,
               start = 1990, end = 2013, extra = FALSE, cache = NULL)

## Lagging some variables
WDI_indi <-slide(WDI_indi, Var="NY.GDP.PCAP.PP.CD", GroupVar="country", slideBy = -1)
                 
# Deleting agregates in the WDI indicators and small countries/islands
WDI_indi$iso2c[WDI_indi$iso2c== ""] <- NA
WDI_indi <- WDI_indi[!is.na(WDI_indi$iso2c),]
WDI_indi <- WDI_indi[!WDI_indi$iso2c %in% c("7E", "4E", "1W", "1A", "8S", "S3", "S4", "S2", "S1", "OE", "F1", "EU" , 
                                            "B8"),]

# 7. Merging "WDI Indicators " and "UN Migration stocks"
Merged <- merge(emigrationtotal, WDI_indi, by = c('iso2c','year'))
summary(Merged)

####################################################################################################
# 8. Cleaning the data
####################################################################################################

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
Merged <- plyr::rename(Merged, c("NY.GDP.PCAP.PP.CD-1" = "GDPPerCapita.l"))
                       
# Code variables as numeric
Merged$year <- as.numeric(Merged$year)
Merged$emigration <- as.numeric(Merged$emigration)

# Generating Dependent variables
Merged$emigrationpercap = Merged$emigration/Merged$TotalPopulation*100000
Merged$logemigrationpercap = log(Merged$emigrationpercap)
Merged$logemigration = log(Merged$emigration)

# Check Variables structure
str(Merged)
summary(Merged)
table (Merged$year)

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

# Removing extra country name coloumn
Merged <-subset.data.frame(Merged, select = -Country)

# Dropping missing values
Merged <- Merged[!is.na(Merged$InternetUsers),]
Merged <- Merged[!is.na(Merged$CellphoneUsers),]
Merged <- Merged[!is.na(Merged$GDPPerCapita),]
Merged <- Merged[!is.na(Merged$FertilityRate),]
Merged <- Merged[!is.na(Merged$iso2c),]
Merged <- Merged[!is.na(Merged$PoliticalStability),]
Merged <- Merged[!is.na(Merged$UnemploymentRate),]


# 9. Generating variables
Merged$logInternetUsers = log(Merged$InternetUsers)
Merged$logCellphoneUsers = log(Merged$CellphoneUsers)
Merged$logGDPPerCapita = log(Merged$GDPPerCapita)
Merged$logGDPPerCapita.l = log(Merged$GDPPerCapita.l)
Merged$logFertilityRate = log(Merged$FertilityRate)
Merged$logPoliticalStability = log(Merged$PoliticalStability)
Merged$employmentprob = 1-((Merged$UnemploymentRate)/100)

# Creating a .csv file with the final version of the data
write.csv(Merged, file="MontesandReyla")

# Dataframe with final variables
Merged2 <- Merged[c("iso2c","country","year", "logemigrationpercap", "CellphoneUsers", "InternetUsers" ,"FertilityRate", "PoliticalStability", "employmentprob", "logGDPPerCapita.l")]
write.csv(Merged2, file="MontesandReylaFinalVars")

# sub dataframes by year
merged00 <-subset(Merged2, year==2000)
write.csv(merged00, file="merged00")

merged10 <-subset(Merged2, year==2010)
write.csv(merged10, file="merged10")

merged13 <-subset(Merged2, year==2013)
write.csv(merged13, file="merged13")

###############################################################################################
############################### DESCRIPTIVE STATISTICS ########################################
###############################################################################################

#```{r, echo=FALSE, message=FALSE, warning=FALSE, header=FALSE, results="asis"}
#labels1 <- c("Cellphone Users","Internet User","PoliticalStability","FertilityRate", #"logGDPPerCapita","employmentprob")
#stargazer::stargazer(Merged2, type = "latex", title="Descriptive statistics", labels1, digits=2)
##Set data as panel data

Merged <- plm.data(Merged, index=c("iso2c", "year"))

##Dependent Variable
# Mapping global emigration
# 1990
sPDF <- joinCountryData2Map( merged90
                             ,joinCode = "ISO2"
                             ,nameJoinColumn = "iso2c")
#mapDevice(Map1)
mapCountryData(sPDF, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 1990',
               colourPalette = c("heat"),
               borderCol='black', missingCountryCol="beige")
# 2000
sPDFII <- joinCountryData2Map( merged00
                               ,joinCode = "ISO2"
                               ,nameJoinColumn = "iso2c")
mapCountryData(sPDFII, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 2000',
               colourPalette = c("heat"),
               borderCol='black')
# 2010
sPDFIII <- joinCountryData2Map( merged10
                                ,joinCode = "ISO2"
                                ,nameJoinColumn = "iso2c")
mapCountryData(sPDFIII, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 2010',
               colourPalette = c("heat"),
               borderCol='black')
# 2013
sPDFIV <- joinCountryData2Map( merged13
                               ,joinCode = "ISO2"
                               ,nameJoinColumn = "iso2c")
mapCountryData(sPDFIV, nameColumnToPlot='emigrationpercap', mapTitle= 'Number of emigrants per capita 2013',
               colourPalette = c("heat"),
               borderCol='black')


## Historgram
hist(Merged$emigration2, xlab = "Thousands of emigrants", main = "Histogram")
hist(Merged$emigrationpercap, xlab = "Emigrants per capita", main = "Histogram")
hist(Merged$logemigrationpercap, xlab = "Emigrants per capita (log)", main = "Histogram")
hist(Merged$logemigration, xlab = "Number of Emigrants (log)", main = "Histogram")
qplot(logemigrationpercap, data=Merged, geom="histogram") + geom_histogram(aes(fill = ..count..))


hist(Merged$CellphoneUsers, xlab = "Number of Cellphone users", main = "Histogram")

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
cor.test(Merged$GDPPerCapita, Merged$InternetUsers, na.rm = TRUE)
cor.test(Merged$GDPPerCapita.l, Merged$InternetUsers)

cor.test(Merged$TotalPopulation, Merged$InternetUsers)
cor.test(merged13$FertilityRate, merged13$InternetUsers)

cor.test(Merged$InternetUsers, Merged$CellphoneUsers, na.rm = TRUE)
cor.test(Merged$GDPPerCapita, Merged$CellphoneUsers)
cor.test(merged10$TotalPopulation, merged10$CellphoneUsers)
cor.test(merged13$FertilityRate, merged13$CellphoneUsers)
cor.test(Merged$logGDPPerCapita, Merged$logCellphoneUsers)
cor.test(Merged$logInternetUsers, Merged$logCellphoneUsers, na.rm = TRUE)

cor.test(Merged$employmentprob, Merged$InternetUsers)
cor.test(Merged$employmentprob, Merged$GDPPerCapita.l)

car::scatterplotMatrix(Merged2)

# Figure
plot(Merged$InternetUsers)

plot(Merged$logemigrationpercap, Merged$CellphoneUsers)
plot(Merged$logemigrationpercap, Merged$InternetUsers)

ggplot2::ggplot(Merged, aes(logemigrationpercap, InternetUsers)) +
  geom_point() + geom_smooth() + theme_bw()

####################################################################################
#################################### PANEL MODEL ###################################
####################################################################################

##Cellphone users - using log
# Pool OLS
#Without interaction
pooling_13 <- plm(logemigrationpercap ~ CellphoneUsers + logGDPPerCapita +  FertilityRate + PoliticalStability, data = Merged, index = c("country", "year"), model = "pooling")

# With interaction
pooling_12 <- plm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "pooling")
summary(pooling_12)

#Within
Within_12 <- plm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "within")
summary(Within_12)

#Between
Between_12 <- plm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita +  FertilityRate + PoliticalStability + employmentprob, data = Merged, index = c("country", "year"), model = "between")
summary(Between_12)

#Random
Random_12 <- plm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita + FertilityRate + PoliticalStability + employmentprob, , data = Merged, index = c("country", "year"), model = "random")
summary(Random_12)

#################################################################################################
######################################## TESTS ##################################################
#################################################################################################
# LM test for fixed verus pooling
pFtest (Within_12, pooling_1)
# reject the null hypothesis that the country fixed effects are equal to zero.

# LM test for pooling versus random effects
plmtest(pooling_1, type="bp")
#The test suggest that we should dismiss  POOL OLS

# LM test for Random verus fixed
phtest (Within_12, Random_12 )
# Since we reject the Null the best model is the fixed effects

#################################################################################################
# All with logsn
pooling_13 <- plm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita+  FertilityRate + PoliticalStability, data = Merged, index = c("country", "year"), model = "pooling")
summary(pooling_13)

pooling_14 <- plm(logemigrationpercap ~ InternetUsers*logGDPPerCapita+  FertilityRate + PoliticalStability, data = Merged, index = c("country", "year"), model = "pooling")
summary(pooling_14)

pooling_15 <- plm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita.l+  FertilityRate + PoliticalStability, data = Merged, index = c("country", "year"), model = "pooling")
summary(pooling_15)

pooling_16 <- plm(logemigrationpercap ~ InternetUsers*logGDPPerCapita.l +  FertilityRate + PoliticalStability, data = Merged, index = c("country", "year"), model = "pooling")
summary(pooling_16)

#################################################################################################
##################################### Internet Users ############################################
#################################################################################################

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

#################################################################################################
################################ Yearly Cross sections###########################################
#################################################################################################
#Cellphones
OLS00_1 <- lm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged00)
OLS10_1 <- lm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged10)
OLS13_1 <- lm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged13)

summary(OLS00_1)
summary(OLS10_1)
summary(OLS13_1)


# Internet
OLS00_2 <- lm(logemigrationpercap ~ InternetUsers + FertilityRate + PoliticalStability +employmentprob+ logGDPPerCapita.l, data = merged00)
summary(OLS00_2)

OLS10_2 <- lm(logemigrationpercap ~ InternetUsers + FertilityRate + PoliticalStability + employmentprob + logGDPPerCapita.l, data = merged10)
summary(OLS10_2)

OLS13_2 <- lm(logemigrationpercap ~ InternetUsers + FertilityRate + PoliticalStability + employmentprob + logGDPPerCapita.l, data = merged13)
summary(OLS13_2)

#Model by years and interaction
#CEllphones
OLS00_1 <- lm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged00)
summary(OLS00_1)

OLS10_1 <- lm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged10)
summary(OLS10_1)

OLS13_1 <- lm(logemigrationpercap ~ CellphoneUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged13)
summary(OLS13_1)

# Internet
OLS00_2 <- lm(logemigrationpercap ~ InternetUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged00)
summary(OLS00_2)

OLS10_2 <- lm(logemigrationpercap ~ InternetUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged10)
summary(OLS10_2)

OLS13_2 <- lm(logemigrationpercap ~ InternetUsers*logGDPPerCapita.l + FertilityRate + PoliticalStability + employmentprob, data = merged13)
summary(OLS13_2)



# Creating table output 
stargazer::stargazer(OLS00_1, OLS10_1, OLS13_1, OLS00_2, OLS10_2, OLS13_2, 
          type = "latex", 
          header = FALSE, title = "Table 1. Regression analysis of emigration stocks around the world 2000-2013",
          digits = 4,
          omit.stat = c("f", "ser"),
          notes = "This regression output shows the results using cellphone users and Internet as a proxy of 
          comunication technology")

stargazer(OLS00_1, OLS10_1, OLS13_1, OLS00_2, OLS10_2, OLS13_2,
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


# Create list of packages and BibTex file for packages
PackagesUsed <- c("repmis", "ggplot2", "knitr", "plm", "Hmisc", "Formula", "rworldmap", "RColorBrewer", "maptools", "countrycode","RJSONIO", "pglm", "WDI", "tidyr", "rio", "sp", "stargazer", "tseries", "DataCombine")
repmis::LoadandCite(PackagesUsed, file = "RPackages.bib", install = FALSE)

