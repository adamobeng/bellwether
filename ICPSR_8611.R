library(data.table)
library(foreign)
library(stringr)
library(tools)

raw.data <- data.table(read.dta('./data/ICPSR_08611/DS0001/08611-0001-Data.dta'))
raw.data[,Area:=V2]
raw.data[,Area:=toTitleCase(tolower(Area))]
raw.data[,Area:=str_replace_all(Area, '[^A-Za-z0-9 ]', '')]
raw.data[,State:=V1]
raw.data[,State:=str_extract(State, '(.*) \\(')]
raw.data[,State:=str_sub(State, 0, -3)]
raw.data[,State:=toTitleCase(tolower(State))]


source('./elections.columns.list.R')

full.results = data.table()
for (el in elections.columns.list) {
	results = raw.data[,list(State,Area, year=as.character(el$year))]
	for (col in el$party.columns ) raw.data[get(col)>100, (col):=NA]
	results$county.winning.party = el$party.names[max.col(raw.data[,el$party.columns, with=F])]
	results[(county.winning.party %in% c('DEM', 'REP')), county.winning.party:=substr(county.winning.party, 1, 1)]
	full.results <- rbind(full.results, results)
}

results = full.results[as.numeric(year) < 1920]
