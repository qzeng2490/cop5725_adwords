drop   table  Keywords;
drop   table  Queries;
drop   table  Advertisers;
create table Queries(qid integer,query varchar(400));
create table Advertisers(advertiserId integer,budget float,ctc float);
create table Keywords(advertiserId integer,keyword varchar(100),bid float);
exit;
