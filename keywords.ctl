load data
infile 'Keywords.dat'
append into table Keywords
fields terminated by X'09'
(advertiserId,keyword,bid)
