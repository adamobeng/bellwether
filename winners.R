library(XML)
library(RCurl)

winners <- data.table(readHTMLTable(getURL('https://en.wikipedia.org/wiki/United_States_presidential_election'))[[3]])
setnames(winners, make.names(names(winners)))

winners$year = str_sub(winners$Election.year, 1, 4)
winners$winning.party=str_match(winners$Winner, '\\(.*\\)')
winners$winning.party=str_replace_all(winners$winning.party, '[()]', '')
# TODO account for non R/D parties
winners[!(winning.party %in% c('Democrat', 'Republican')), winning.party:=NA]
winners[!is.na(winning.party), winning.party:=substr(winning.party, 1, 1)]

winners[,Order:=NULL]
winners[,Other.major.candidates.31.:=NULL]
winners[,Election.year:=NULL]
winners[,Winner:=NULL]
