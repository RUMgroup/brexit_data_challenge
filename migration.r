##### MIGRATION ####

mig <- read.csv("gisruk_data/nonUKborn.csv", stringsAsFactors = F)
str(mig)
head(mig)

mig$prop2015 <- mig$nonUK2015/(mig$resPop2015 + mig$nonUK2015)
mig$prop2005 <- mig$nonUK2005/(mig$resPop2005 + mig$nonUK2005) 

mig$rate05_15 <- (mig$prop2015-mig$prop2005)/mig$prop2005

hist(mig$rate05_15)

colnames(mig)
nonUK <- melt(mig[,c("AreaCode","AreaName", "rate05_15")])
head(nonUK)

colnames(nonUK)[4] <- "rate_nonUk"
nonUK$variable <- NULL

save(brexit.nonUK, file = "nonUK.rdata")
