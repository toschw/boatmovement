
#BOATMOVEMENT STUDY, sample of 5100 boatowners

##TASKS
#We got government-related boats in this dataset, too. Need to take them out. 

library(dplyr)
library(tidyr)
library(stringr)
library(sampling)

#Importing dataset and reference table to set regions, renaming columns
data <- read.csv("D:/Dropbox/DATA/2018_boat_survey/registration/DMV_registered_boats_data_2017.csv", stringsAsFactors=FALSE)

#Subset for current registrations
data <- subset(data, REG.YR.EXPIRE >=2018)
#renaming columns
names(data)[names(data)=="ADDR.RES.CITY"] <- "Community"
names(data)[names(data)=="OWNRSHIP.TYPE.1"] <- "OWNER1"
names(data)[names(data)=="OWNRSHIP.TYPE.2"] <- "OWNER2"
names(data)[names(data)=="OWNRSHIP.TYPE.3"] <- "OWNER3"
names(data)[names(data)=="OWNRSHIP.TYPE.4"] <- "OWNER4"
#remove all white space in the file, including in the column headers
register <- data
names(register)<-names(register)%>% 
  stringr::str_replace_all("\\s","_")
register$Community <- str_trim(register$Community)
register$OWNER.NAME.FIRST.1 <- str_trim(register$OWNER.NAME.FIRST.1)
register$OWNER.NAME.LAST.1 <- str_trim(register$OWNER.NAME.LAST.1)
register$OWNER.NAME.MIDDLE.1 <- str_trim(register$OWNER.NAME.MIDDLE.1)
register$CATEGORY.SUB <- str_trim(register$CATEGORY.SUB)
register$USE.TYPE <- str_trim(register$USE.TYPE)
#ADDR.MAIL.ZIP column needs to be trimmed to five digits
register$ADDR.MAIL.ZIP <- strtrim(register$ADDR.MAIL.ZIP,5)
register$OWNER.NAME.COMPANY.1 <- str_trim(register$OWNER.NAME.COMPANY.1)

# Turn middle names into just one capital letter
register$OWNER.NAME.MIDDLE.1 <- substring(register$OWNER.NAME.MIDDLE.1, 1, 1)
register$NAME1 <- paste(register$OWNER.NAME.FIRST.1, register$OWNER.NAME.MIDDLE.1, register$OWNER.NAME.LAST.1, register$OWNER.NAME.COMPANY.1, sep=" ")
register$multi_own <- with(register, ifelse((OWNER2=="O" & OWNER3==" "),2,ifelse((OWNER3=="O" & OWNER4==" "),3,ifelse((OWNER4=="O"|OWNER4=="S"),4,1))))

#joining region aggregation 
regions <-  read.csv("E:/GoogleDrive/CURRENT_PROJECTS/3_SASAP_salmon_synthesis/Analysis_ref_files/index_table_051118.csv", stringsAsFactors=FALSE)
regions <- subset(regions,select= c("Community", "SASAPRegions","Urban"))
regions <- mutate_at(regions,vars(Community), funs(toupper))
register2 <- register %>%
  left_join(regions, by="Community")

#Excluding houseboats CATEGORY.SUB == D, commercial fishing boats USE.TYPE == C
register3 <- subset(register2, USE.TYPE!="C")
register3 <- subset(register3, CATEGORY.SUB!="D")

#Getting to unique first owners name (incl. company) and unique street address field
boat_owners <- register3 %>%
  distinct(NAME1, ADDR.MAIL.STREET, .keep_all=TRUE)

#summarizing ownership per region
ownersPERregion <- boat_owners%>%
  group_by(SASAPRegions)%>%
  summarise(owners1 = length(NAME1),
            owners = sum(multi_own),
            skiffs = sum(CATEGORY.SUB=="A"))

##Creating simple random sample for pre-test
frame <- boat_owners
sam.srswor <- srswor(n=50,N=44841)
sample.srswor <- frame[which(x=(sam.srswor ==1)),]

##Creating mailout database for pretest
pretest <- select(sample.srswor, OWNER.NAME.LAST.1, OWNER.NAME.FIRST.1, OWNER.NAME.MIDDLE.1, OWNER.NAME.SFX.1, OWNER.NAME.COMPANY.1, ADDR.MAIL.STREET, ADDR.MAIL.EXTRA.LINE, ADDR.MAIL.CITY, ADDR.MAIL.STATE, ADDR.MAIL.COUNTRY, ADDR.MAIL.ZIP , PROPERTY.ISN, CATEGORY.SUB, USE.TYPE)
write.csv(pretest, "G:/My Drive/CURRENT_PROJECTS/4_Boatmovements/pre_test/pretest_contacts.csv")



##Creating remaining frame, eliminating pre-test contacts
eliminate <- pretest$PROPERTY.ISN
frame2 <- subset(boat_owners, !(boat_owners$PROPERTY.ISN %in% eliminate))

mailout <- sample(frame2,5100,replace = FALSE)


##Creating simple random sample for first letter mail out
sam.srswor2 <- srswor(n=5100,N=34340)
sample.srswor2 <- frame3[which(x=(sam.srswor2 ==1)),]
mailout <- select(sample.srswor2, OWNER.NAME.LAST.1, OWNER.NAME.FIRST.1, OWNER.NAME.MIDDLE.1, OWNER.NAME.SFX.1, OWNER.NAME.COMPANY.1, ADDR.MAIL.STREET, ADDR.MAIL.EXTRA.LINE, ADDR.MAIL.CITY, ADDR.MAIL.STATE, ADDR.MAIL.COUNTRY, ADDR.MAIL.ZIP , PROPERTY.ISN, CATEGORY.SUB, USE.TYPE)
business <- subset(mailout, OWNER.NAME.COMPANY.1!="")
private <- subset(mailout, OWNER.NAME.LAST.1!="")
  
write.csv(business, "G:/My Drive/CURRENT_PROJECTS/4_Boatmovements/sampling/business_mailout.csv")
write.csv(private, "G:/My Drive/CURRENT_PROJECTS/4_Boatmovements/sampling/private_mailout.csv")

## Creating table of PROPERTY.ISN (serving as unique ID), and ZIP code, for research subject payment documentation
table_lexi <- mailout[,c("PROPERTY.ISN","ADDR.MAIL.CITY","ADDR.MAIL.ZIP")]
write.csv(table_lexi,"G:/My Drive/CURRENT_PROJECTS/4_Boatmovements/sampling/table_lexi.csv")







