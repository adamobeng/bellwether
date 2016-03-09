library(data.table)
library(stringr)

## This assumes you have CQ data files produced using process.py
## with filenames {1920,...,2012}.txt
results = data.frame()
for (file in Sys.glob('./data/*.txt')) {
	print(file)
	year = str_split(file, "[/.]")[[1]][[4]]
	results = rbind(
		results,
		fread(file, sep='\t')[,list(
		    State,
		    #  This is very slow for some reason
		    Area=str_replace_all(toTitleCase(tolower(Area)), '[^A-Za-z0-9 ]', ''),
		    county.winning.party=PluralityParty,
		    year=as.character(year)
		    )]
	)
}

results[State=='Florida'  & Area=='Dade',Area:='MiamiDade']
