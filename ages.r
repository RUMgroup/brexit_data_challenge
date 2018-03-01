library(reshape2)

age <- read.csv("gisruk_data/2016byAge.csv", stringsAsFactors = F)
str(age)

age.la.tmp <- age[age$LSOA.description == "",]


## At LA level
head(age.la.tmp)
age.la.tmp$LSOA.description <- NULL



age.la <- melt(age.la.tmp)
head(age.la)

all.ages <- subset(age.la, variable == "All.Ages")
age.la <- age.la[!age.la$variable == "All.Ages",]

all.ages[,c("Area.Names", "variable")] <- list(NULL)
head(all.ages)


age.la$variable <- as.numeric(gsub(pattern = "X", replacement = "", age.la$variable))
str(age.la)
head(age.la)

colnames(age.la)[3] <- "age"

breaks <- c(18,24,34,44,54,64)
age.la$groups <- cut(age.la$age, include.lowest = T, breaks)

head(age.la)
age.grp <- aggregate(age.la$value, list(age.la$LSOA, age.la$groups), sum, na.rm = T)

head(age.grp)
head(all.ages)

ages.fin <- merge(age.grp, all.ages, by.x = "Group.1", by.y = "LSOA")

head(ages.fin)
ages.fin$prop <- ages.fin$x/ages.fin$value

ages <- dcast(ages.fin[, c("Group.1", "Group.2", "prop")], Group.1~ Group.2)
## proportion of age groups per LAD17CD in 2016
