#NARROW DOWN COVRIATES TO INCLUDE IN FINAL MODEL

load("Covariates.rda")
all<-all[,c(1,3:12)]
a<-read.csv("draft_ethnicity_brexit_03.csv")
test3<-merge(a,all,all.x=TRUE)
attach(test3)

#WHEN WE DECIDE WHICH VARIABLES TO INCLUDE WE WILL UPDATE THE MODEL CODE
RegModel.1 <- 
  lm(Pct_Leave.x~rate_nonUK+age_grp18_24+age_grp25_34+age_grp35_44+age_grp45_54+age_grp55_64+
  age_grp65_over+Area.Sq.Km+Country.of.Birth....Not.United.Kingdom..2011+change10+change05+
  Economic.Activity..Unemployment.Rate..2011+Mid.2016.Population+Pct_Turnout.x+Rejected_Ballots
  People.per.Sq.Km,  data=test3)
   
 #STEPWISE SIMPLIFICATION
drop1(RegModel.1, test="F")
RegModel.2<-
 #EXPAND ETHNICITY
  
