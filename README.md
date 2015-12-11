
[<img src="https://www.hertie-school.org/uploads/pics/HSG_Logo_rgb_33c6f5.jpg" align="right" height="135" width ="200"/>](http://www.hertie-school.org/)
<i>
#Push or Pull? The Influence of ICT on Emigration Flows
</i>

This repository is created for our final research project produced for MPP_1180: Collaborative Social Science Data Analysis at Hertie School of Govermance, taught by Prof. Dr. Christopher Gandrud. 

by Ana Ceclia Montes and Ayra Reyla

####Useful links 

- Final paper Rmd.: https://github.com/ARowena/Final_ProjectMontesReyla/blob/master/Final_Paper_.Rmd
- Final paper pdf: https://github.com/ARowena/Final_ProjectMontesReyla/blob/master/Final_Paper_.pdf

- Link to our website: http://arowena.github.io/Final_ProjectMontesReyla/ 

####Intoduction

Migration is broadly defined as a permanent or semi-permanent relocation of residence, there are no restrictions placed upon the distance or voluntary or involuntary nature of moving (Lee 1966). In fact, few countries today are not affected by international migration (Martin 2014). For many years, the idea of international migration meant disconnecting with one’s homeland. This meant the process of communication with friends and family left behind was a slow process, often via hand written letters. However, since the dawn the digital age at the start of the 20th century information and communication technology (ICT) has radically changed the speed and nature of interactions between people worldwide. New ICT such as mobile phones have facilitated instant communication by phone calls, text messages, e-mail, and other social platforms. Cheap international telephone calls function as the ‘social glue’ binding migrants to their friends and families in their home country by creating constant involvement and engagement in their life (Vetrovec 2004). Castells (2009) argues that the digital age has drastically changed the speed of communication within transnational populations. Since the introduction of the Internet to the masses, it has developed into a globally diverse web of opportunities for gathering information, interacting globally and effectively producing new forms of media and content for consumption.

This paper aims to answer the following question using emperical methods: <i> Have ICTs, more specifically Internet Usage and mobile phone subscriptions impacted the flow of emigration?</i>

###Data 
#####International Migration Stock, Total

The original data was obtained through the United Nations Population Division, and downloaded through our repository as a Microsoft Excel file. The Excel datasheet had a matrix that described the population outflows and inflows for each country and for several time periods. This analysis focuses four time series; 1990. 2000, 2010 and 2013.

  Gather the data using the `import` command from the package `rio` , afterwards we used a loop to import the file to R Studio. Since this analysis is only interested in emigration, we extracted the migration column from all origin countries in the data set, and created a vector. From each matrix, we selected the years of interest for this analysis. Afterwards we transposed the data to transform it into a more usable and readable format, and then we declared it as a data frame. Using the command `callnames`, we renamed each column appropriately. We ended the loop by assigned each year to a specific data frame. Using the command cbind we combined all the extracted data from above, thus creating combined year in a singular data frame. In order to reshape the new data frame, we used the function  `gather`  from the package `tidyr`. This takes multiple columns and collapses them into key value pairs, this created two new variables called emmigration and year. Finally, we included the corresponding year names to the specific year variables.
  
 Moreover, we create a  an unique identifier for each country using the `countrycode` function in the package `countrycode`  

###World Bank Indicators

To import the indicators we used `WDI` and `RJSONIO`. Then, we specified which indicators we wanted to include in our analysis by using the specific codes available on the metadata set of the World Bank. We then properly renamed the variables using the `plyr::rename` function. Once the data was loaded, we used Merged <- merge(emigrationtotal, WDI_indi, by = c('iso2c','year')) to combine the WDI indicators with the International Migration Stock. 




Our final paper follows the following strucutre:

1. Introduction
2. Theory, Literature Review
3. Description of Data Sources
4. Emperical Results 
5. Limitations
6. Conclusion
Annex Bibliography

# Folder Structure
- Visual Maps:                                        Folder that contains all world maps on migration
- Final_Paper_.Rmd:                                   The Rmd to create the Final document
- Final_Paper_.pdf:                                   A PDF file with th efinal paper
- MontesReylaEmigration.R:                            The Rmd in which data collection is explained and the inferencial analysis was performed
- Montes_and_Reyla__2015_Presentation.Rmd:            The Rmd for a short presentation of the project
- Montes_and_Reyla__2015_Presentation.pdf:            A PDF file containing a short presentation of the project
- MontesandReyla:                                     The Final Data Base
- MontesandReylaFinalVars:                            Database that only the relevant variables for all the years
- merged00:                                           Sub-Database for the year 2000
- merged10:                                           Sub-Database for the year 2010
- merged13:                                           Sub-Database for the year 2013
- merged90:                                           Sub-Database for the year 1990
- RPackages.bib:                                      A bibtex file with the references for the R packages
- referencesreylamontes2.bib:                         A bibtex file with the references for the literature on migration
- UN_MigrantStockByOriginAndDestination_2013T1.xls:	  Original database
- header.tex:                                         A function that allows to cange the PDF header
- index.Rmd:                                        	The Rmd of the Web Page for Final Paper	
- index.html:	                                        A html of the Web Page for Final Paper	

Deadline for submission: 11th December 2015

