#Read ethnicity data frame
ethnicity_data <- read.csv("data/ethnicity-full-nested.csv")

#mean by local authority 
ethnicity_data_aggregate <- aggregate(. ~ LAD16CD + ethnic, ethnicity_data, mean)

#take just the white british ethnicity data and rearrange etc
wb_data_aggregate <- ethnicity_data_aggregate[ethnicity_data_aggregate$ethnic == "WBR",]
wb_data_aggregate <- wb_data_aggregate[,c(-3, -24, -25, -26, -27, -28, -29)]
wb_data_aggregate <- gather(wb_data_aggregate, key, value, -LAD16CD, -ethnic)
wb_data_aggregate$year <- as.numeric(substring(wb_data_aggregate$key, 2))


#ggplot(data = wb_data_aggregate, aes(x = year, y = value, group = LAD16CD)) + geom_line() + theme_bw()

#read brexit data
brexit_data <- read.csv("data/eu-referendum-result-data.csv")
brexit_data_clean <- brexit_data[,c(-1,-2,-3,-5,-6,-7,-8,-9,-10,-11,-12,-13,-14,-15,-16,-17,-18)]
brexit_data_clean$LAD16CD <- brexit_data_clean$Area_Code

#merge dataframes
wb_ethnicity_brexit <- merge(wb_data_aggregate, brexit_data_clean, by=c("LAD16CD"))

#plot
ggplot(data = wb_ethnicity_brexit, aes(x=year, y=value, group = LAD16CD)) + geom_line(aes(color = Pct_Leave)) +
  theme_cowplot() +
  scale_colour_gradientn(colours = terrain.colors(10)) +
  ylab("Proportion of LA white British") +
  xlab("Year")
