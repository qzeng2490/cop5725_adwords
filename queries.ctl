load data
infile 'Queries.dat'
append into table Queries
fields terminated by X'09'
(qid,query char(4000))



