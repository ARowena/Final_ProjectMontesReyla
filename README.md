
[<img src="https://www.hertie-school.org/uploads/pics/HSG_Logo_rgb_33c6f5.jpg" align="right" height="135" width ="200"/>](http://www.hertie-school.org/)
<i>
#Have innovations in ICT changed the game for international migration?
</i>
###Final Project: Ana Cecilia Montes and Ayra Rowena Reyla 
####Introduction and Background Information
This repository is created to perform our research articule for the course introduction to MPP_1180: Collaborative Social Science Data Analysis at Hertie School of Govermance, taught by Prof. Dr. Christopher Gandrud. 

The objective of this pair assignment is to:

####Instructions


####Data Gathering 

#####International Migration Stock, Total

The original data was obtained through the United Nations Population Division, and downloaded through our repository as a Microsoft Excel file. The Excel datasheet had a matrix that described the population outflows and inflows for each country and for several time periods. This analysis focuses four time series; 1990. 2000, 2010 and 2013. 

Gather the data using the *import* command, afterwards we used a loop to import the file to R Studio. Since this analysis is only interested in migration, we only extracted the Migration column from all the countries in the data set, and created a vector. From each matrix, we only selected the years of interest for this analysis. Afterwards we transposed the data to transform it into a more usable and readable format, and then we declared it as a data frame. Using the command *callnames*, we renamed each column appropriately. We ended the loop by assigned each year to a specific data frame. Using the command *cbind* we combined all the extracted data from above, thus creating combined year in a singular data frame. In order to reshape the new data frame, we used the command *gather*. This takes multiple columns and collapses them into key value pairs, this created two new variables called _emmigration_ and _year_. Finally, we included the corresponding year names to the specific year variables. 

#####World Bank Indicators

To import the indicators we used *install.packages ('WDI)*, afterwards we imported it into our library using *library("WDI")*. Then, we specified which indicators we wanted to include in our analysis by using the specific codes available on the metadata set of the World Bank. We then properly renamed the variables using the *rename* command. Once the data was loaded, we used *Merged <- merge(emigrationtotal, WDI_indi, by = c('iso2c','year'))* to combine the WDI indicators with the International Migration Stock.
