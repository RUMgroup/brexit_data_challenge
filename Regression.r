#NARROW DOWN COVRIATES TO INCLUDE IN FINAL MODEL

load("Covariates.rda")
all<-all[,c(1,3:12)]
a<-read.csv("draft_ethnicity_brexit_03.csv")
test3<-merge(a,all,all.x=TRUE)
attach(test3)

#WHEN WE DECIDE WHICH VARIABLES TO INCLUDE WE WILL UPDATE THE MODEL CODE
RegModel.1 <- 
  lm(Pct_Leave.x~rate_nonUk+age_grp18_24+age_grp25_34+age_grp35_44+age_grp45_54+age_grp55_64+
  age_grp65_over+Area.Sq.Km+change10+change05+
 Mid.2016.Population+Pct_Turnout.x+Rejected_Ballots+
  People.per.Sq.Km,  data=test3)
   
 #STEPWISE SIMPLIFICATION
drop1(RegModel.1, test="F")

#At the 3 year level, drop1 proposed dropped variables are Age group 45-54 and 5 year change (not 10 year change)

RegModel.2<-update(RegModel.1,~.-age_grp45_54)
anova(RegModel.1,RegModel.2,test="Chi") #P=0.799
anova(RegModel.2) #Mid 2016 population seems non significant

RegModel.3<-update(RegModel.2,~.-Mid.2016.Population)
anova(RegModel.2,RegModel.3,test="Chi") #P=0.0001324

RegModel.4<-update(RegModel.2,~.-change05)
anova(RegModel.2,RegModel.4,test="Chi") #P=0.2187
summary(RegModel.4)

#Significant: rate_nonUk, all age bands, Area.sq.km, change10, 
#Mid2016 Population, Pct_Turnout.x, change10,Mid.2016.Population,Pct_Turnout.x,Rejected_Ballots,People.per.Sq.Km

#EXPAND ETHNICITY (REPLACE rate_nonUk with ethnicity specific rates)
 
load("Brexit03Covariates.rda")
RegModel.5<-lm(formula = Pct_Leave.y ~ age_grp18_24 + age_grp25_34 + age_grp35_44 + 
    age_grp45_54 + age_grp55_64 + age_grp65_over + Area.Sq.Km + 
    Asian + Black + Mid.2016.Population + Other + Pct_Turnout.y + People.per.Sq.Km + 
    Rejected_Ballots + 
    White.British + White.Other, data = threeall)

drop1(RegModel.5, test="F")
