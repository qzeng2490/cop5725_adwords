load data
infile 'Advertisers.dat'
append into table Advertisers
fields terminated by X'09'
(advertiserId,budget,ctc)
