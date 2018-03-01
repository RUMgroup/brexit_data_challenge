ethnicity_data <- read.csv("data/ethnicity-full-nested-new.csv")
  
#mean by local authority 
eth_aggregate <- aggregate(. ~ LAD16CD + ethnic2, ethnicity_data, mean)

#change calculated here
eth_aggregate$change10 <- (eth_aggregate$y2015 - eth_aggregate$y2005)/eth_aggregate$y2005
eth_aggregate$change05 <- (eth_aggregate$y2015 - eth_aggregate$y2010)/eth_aggregate$y2010
eth_aggregate$change03 <- (eth_aggregate$y2015 - eth_aggregate$y2012)/eth_aggregate$y2012

#remove columms don't need
eth_aggregate <- eth_aggregate[,c(-3:-29)]


brexit_data <- read.csv("data/eu-referendum-result-data.csv")
brexit_data_clean <- brexit_data[,c(-1,-2,-6,-7,-8,-10,-11,-12,-13,-14,-15,-16,-17,-18)]
brexit_data_clean$LAD16CD <- brexit_data_clean$Area_Code

eth_brexit <- merge(eth_aggregate, brexit_data_clean, by=c("LAD16CD"))

eth_brexit_big <- spread(eth_brexit, ethnic2, change10) 

eth_brexit_big <- eth_brexit %>%
  gather(variable, value, change10:change03) %>%
  unite(temp, ethnic2, variable) %>%
  spread(temp, value)

eth_brexit_big_10 <- spread(eth_brexit, ethnic2, change10)
eth_brexit_big_05 <- spread(eth_brexit, ethnic2, change05)
eth_brexit_big_03 <- spread(eth_brexit, ethnic2, change03)

write.csv(eth_brexit_big_10, file="draft_ethnicity_brexit_10.csv")
write.csv(eth_brexit_big_05, file="draft_ethnicity_brexit_05.csv")
write.csv(eth_brexit_big_03, file="draft_ethnicity_brexit_03.csv")
