#This is the script for looking at the differences between the three rates of change measures


#this first part is creating the data also in maake_draft_ethnicity_brexit.R

ethnicity_data <- read.csv("data/ethnicity-full-nested-new.csv")

#mean by local authority 
eth_aggregate <- aggregate(. ~ LAD16CD + ethnic2, ethnicity_data, mean)

#change calculated here
eth_aggregate$change10 <- (eth_aggregate$y2015 - eth_aggregate$y2005)/eth_aggregate$y2005
eth_aggregate$change05 <- (eth_aggregate$y2015 - eth_aggregate$y2010)/eth_aggregate$y2010
eth_aggregate$change03 <- (eth_aggregate$y2015 - eth_aggregate$y2012)/eth_aggregate$y2012



##check variation between the 3 measures

#make df where change measure is a variable
check_measures <- eth_aggregate %>%
  select (LAD16CD, ethnic2, change03, change05, change10) %>%
  gather(change_measures, change_values, -LAD16CD, -ethnic2)

#label the measures nicely
check_measures$change_measures <- factor(check_measures$change_measures,
                           labels = c("change03" = "Three years", 
                                      "change05" = "Five years", 
                                      "change10" = "Ten years"))



#check that it worked and looks right
table(check_measures$change_measures)

#run anova to look if difference between measures is statistically significant
change_check_aov <- aov(change_values ~ change_measures, data=check_measures)
summary(change_check_aov)

#This suggests a statistically significant difference between the different measures (p < 0.001, F-value = 989.2, degrees of freedom = 2)

summary.lm(change_check_aov)


#Taking the square root of eta squared gives you the correlation between the metric and the categorical variable.
#Eta or the correlation is a measure of effect size; that is of the substantive impact of your categorical variable. 
#In this case that value (square root of 0.2796) is 
sqrt(0.2796)
#0.5287722. That suggests that range used to calculate rate of change has a large effect on what that value is. (ref here: http://imaging.mrc-cbu.cam.ac.uk/statswiki/FAQ/effectSize)

#diagnostics on the assumptions
plot(change_check_aov)

#somewhat concerned (doesnt look normally distributed, also variance) so check welch f text
oneway.test(change_values ~ change_measures, data=check_measures)

#some insight into what's going on:
#the prot from the lessR::ANOVA function shows that there are much larger values of change in the 10-year range (makse sense), but also somehow in the 3 year range, which is weird
library(lessR)
ANOVA(change_values ~ change_measures, data=check_measures, brief=TRUE) #The brief argument set to TRUE excludes pairwise comparisons and extra text from being printed.


#boxplot for more clarity

ggplot(check_measures, aes(x = change_measures, y = change_values)) + 
  geom_boxplot() +
  theme_minimal() +
  labs(x = "Range considered",
       y = "Percentage change")


#are all the differences significant? Pairwise t-test to check
pairwise.t.test(check_measures$change_values, check_measures$change_measures, p.adjust.method="bonferroni") 
#yepp they are...


