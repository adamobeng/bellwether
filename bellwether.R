library(data.table)
library(knitr)
library(ggplot2)

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

prediction.accuracy = predictions[,list(
	percent.correct=sum(correct, na.rm=T)/sum(!is.na(correct)),
	n.correct=sum(correct, na.rm=T),
	n.elections=sum(!is.na(correct))), by=list(State, Area) 
]

## Most frequently correct counties for which there are results in all of the
## past 43 elections
sink('./out/bellwethers_since_1840.md')
kable(
	head(
	     prediction.accuracy[n.elections>40][order(-percent.correct)],
	     n=20
	     )
)
sink()

prediction.accuracy[Area=='Webster'& State=='Georgia']

sink('./out/bellwethers_since_1888.md')
kable(
      head(
	predictions[as.numeric(year)>=1888][,list(
		percent.correct=sum(correct, na.rm=T)/sum(!is.na(correct)),
		n.correct=sum(correct, na.rm=T),
		n.elections=sum(!is.na(correct))), by=list(State, Area) 
	][n.elections==32][order(-percent.correct)],
	n=20)
)
sink()

sink('./out/bellwethers_since_1956.md')
kable(
      head(
	predictions[as.numeric(year)>=1956][,list(
		percent.correct=sum(correct, na.rm=T)/sum(!is.na(correct)),
		n.correct=sum(correct, na.rm=T),
		n.elections=sum(!is.na(correct))), by=list(State, Area) 
	][n.elections==15][order(-percent.correct)],
	n=20)
)
sink()




## Streaks

all.streakers = data.table()
for (end_year in seq(as.numeric(min(predictions$year))+56, as.numeric(max(predictions$year)),4))
{
	streakers = predictions[(as.numeric(year)>=(end_year-60)) & (as.numeric(year) < end_year)][,list(
		percent.correct=sum(correct, na.rm=T)/sum(!is.na(correct)),
		n.correct=sum(county.winning.party==winning.party, na.rm=T),
		n.elections=sum(!is.na(correct))), by=list(State, Area) 
	][percent.correct==1&n.elections==15]
	current.year = predictions[as.numeric(year)==end_year, list(State, Area, current.correct=correct, end_year)]
	streakers = merge(streakers, current.year, all.x=T, by=c('State', 'Area'))
	all.streakers = rbind(all.streakers, streakers)
}

## List of streaking counties
unique(all.streakers[,list(State, Area)])

## Proportion of all streaks which continued in the next election, by year
all.streakers[,list(sum(current.correct,na.rm=T),length(current.correct),sum(current.correct,na.rm=T)/length(current.correct)), by=end_year]

## Proportion of all streaks which continued in the next election
all.streakers[,list(sum(current.correct,na.rm=T),length(current.correct),sum(current.correct, na.rm=T)/length(current.correct))]


## Streaks graph

most_recent_streak <- function(x) {
	rles <- rle(x)
	tail(rles[[1]], 1)
}

streak.lengths = data.table()
for (end_year in seq(as.numeric(min(predictions$year)), as.numeric(max(predictions$year)),4))
{
	streak.lengths = rbind(streak.lengths,
	predictions[order(year)][year < end_year, 
	 list(length=most_recent_streak(county.winning.party==winning.party), year=end_year),
	 by=list(State,Area)
	]
	)
}

top.streaks = unique(streak.lengths[length>15][,list(State, Area, color=paste0(Area, ', ', State))])
streak.lengths = merge(streak.lengths, top.streaks, by=c('State', 'Area'), all.x= T)

theme_set(theme_bw())
ggplot(streak.lengths[!is.na(color)]) + geom_line(aes(x=year, y=length, group=paste(State, Area), color=color)) + 
	scale_x_continuous(breaks=seq(1840,2012, 4)) +
	theme(axis.text.x = element_text(angle = 45, hjust = 1))
ggsave('out/streaks.png', width=10)
