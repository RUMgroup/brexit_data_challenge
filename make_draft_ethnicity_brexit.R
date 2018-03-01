ethnicity_data <- read.csv("data/ethnicity-full-nested.csv")

#mean by local authority 
eth_aggregate <- aggregate(. ~ LAD16CD + ethnic, ethnicity_data, mean)

#change calculated here
eth_aggregate$change <- (eth_aggregate$y2015 - eth_aggregate$y2005)/eth_aggregate$y2005
  
#remove columms don't need
eth_aggregate <- eth_aggregate[,c(-3:-29)]


brexit_data <- read.csv("data/eu-referendum-result-data.csv")
brexit_data_clean <- brexit_data[,c(-1,-2,-6,-7,-8,-10,-11,-12,-13,-14,-15,-16,-17,-18)]
brexit_data_clean$LAD16CD <- brexit_data_clean$Area_Code

eth_brexit <- merge(eth_aggregate, brexit_data_clean, by=c("LAD16CD"))

eth_brexit_big <- spread(eth_brexit, ethnic, change)

#write.csv(eth_brexit_big, file="draft_ethnicity_brexit.csv")
