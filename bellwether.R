library(data.table)

all.results = data.table()
source('./ICPSR_8611.R')
all.results = rbind(all.results, results)
source('./CQ.R')
all.results = rbind(all.results, results)
all.results = all.results[!(Area %in% c('Votes not Reported by County', 'Votes not Included in the Average Elector Vote'))]

source('./winners.R')

predictions = merge(all.results, winners, all.x=T, by=c('year'))
predictions[,correct:=county.winning.party==winning.party]
paste(length(unique(predictions$year)), 'elections in dataset')
#predictions = predictions[as.numeric(year)>=1888]
prediction.accuracy = predictions[,list(
	percent.correct=sum(correct, na.rm=T)/length(winning.party),
	n.correct=sum(correct, na.rm=T),
	n.elections=length(winning.party)), by=list(State, Area) 
]

## Most frequently correct counties for which there are results in all of the
## past 43 elections
head(
     prediction.accuracy[n.elections==43][order(-percent.correct)],
     n=20
     )


## Streaks

all.streakers = data.table()
for (end_year in seq(as.numeric(min(predictions$year))+56, as.numeric(max(predictions$year)),4))
{
	streakers = predictions[(as.numeric(year)>=(end_year-60)) & (as.numeric(year) < end_year)][,list(
		percent.correct=sum(correct, na.rm=T)/length(winning.party),
		n.correct=sum(county.winning.party==winning.party, na.rm=T),
		n.elections=length(winning.party)), by=list(State, Area) 
	][percent.correct==1&n.elections==15]
	current.year = predictions[as.numeric(year)==end_year, list(State, Area, current.correct=correct, end_year)]
	streakers = merge(streakers, current.year, all.x=T, by=c('State', 'Area'))
	all.streakers = rbind(all.streakers, streakers)
}

## List of streaking counties
unique(all.streakers[,list(State, Area)])

## Proportion of all streaks which continued in the next election, by year
all.streakers[,list(sum(current.correct),length(current.correct),sum(current.correct)/length(current.correct)), by=end_year]

## Proportion of all streaks which continued in the next election
all.streakers[,list(sum(current.correct,na.rm=T),length(current.correct),sum(current.correct, na.rm=T)/length(current.correct))]
