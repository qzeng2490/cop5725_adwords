 
set serverout on
drop table temp_advertisers;
create table temp_advertisers as select * from advertisers order by advertiserid;
create or replace TYPE bid_list IS TABLE OF FLOAT;
/
create or replace TYPE w_list IS TABLE OF VARCHAR(400);
/

   create or replace FUNCTION split (                     
   split_str       IN VARCHAR, 
   split_d        IN VARCHAR default(' ')
   )
   RETURN w_list
   IS
       j22 INT := 0;
       i22 INT := 1;
       mylen INT := 0;
       mylen1 INT := 0;
       mystr VARCHAR (100);
       splitmy w_list := w_list ();
   BEGIN
       mylen := LENGTH (split_str);
       mylen1 := LENGTH (split_d);
 
       WHILE j22 < mylen
       LOOP
           j22 := INSTR (split_str, split_d, i22);
   
           IF j22 = 0
           THEN
               j22 := mylen;
               mystr := SUBSTR (split_str, i22);
               splitmy.EXTEND;
               splitmy (splitmy.COUNT) := mystr;
 
               IF i22 >= mylen
               THEN
                   EXIT;
               END IF;
           ELSE
               mystr := SUBSTR (split_str, i22, j22 - i22);
               i22 := j22 + mylen1;
               splitmy.EXTEND;
               splitmy (splitmy.COUNT) := mystr;
           END IF;
       END LOOP;
       RETURN splitmy;
   END split;
   /
   create or replace FUNCTION wordstable(adid IN Advertisers.Advertiserid%type)
       return w_list
   IS
       temp_list w_list := w_list();
       counter INTEGER := 0;
   BEGIN
       FOR n IN(
           select keyword
           from keywords
           where adid = keywords.advertiserid  
       )
       LOOP
           counter := counter +1;
           temp_list.extend;
           temp_list(counter) := n.keyword;
       END LOOP;
       return temp_list;
   END;
   /
   create or replace FUNCTION simcos(A IN w_list, B IN w_list)
   return FLOAT
   IS
   cos FLOAT;
   i INTEGER := 0 ;
   j INTEGER := 0 ;
   k INTEGER := 0 ;
   la INTEGER := A.count ; 
   lb INTEGER :=B.count ;
   C w_list := w_list() ;
   s0 INTEGER := 0 ;
   sa INTEGER := 0;
   sb INTEGER := 0;
   n INTEGER;
   TYPE v_list  IS VARRAY(100) OF INTEGER;
   a0 v_list := v_list();
   b0 v_list := v_list();
   BEGIN
       FOR counter IN 1 .. 100 LOOP
           a0.extend;
           b0.extend;
           a0(counter) := 0;
           b0(counter) := 0;
       END LOOP;
       FOR counter IN 1 .. lb LOOP
           IF NOT B(counter) member of C THEN
               C.extend;
               k := k+1;
               C(k) := B(counter);
           END IF;
       END LOOP;
       k := C.COUNT;
       FOR counter IN 1 .. la LOOP 
       IF NOT A(counter) member of C THEN 
           C.extend ;
           i := i+1;
           C(k+i) := A(counter) ;
       END IF;
       END LOOP;   
       n := C.count ;  
       << outer_loopa >>
       FOR i IN 1..n LOOP
           << inner_loopa >>
           FOR j IN 1..la LOOP
               IF(A(j) = C(i)) THEN 
               a0(i) := a0(i) + 1;
               END IF;
           END loop inner_loopa;
       END loop outer_loopa;

       << outer_loopb >>
       FOR i IN 1..n LOOP
           << inner_loopb >>
           FOR j IN 1..lb LOOP
               IF (B(j) = C(i)) THEN 
               b0(i) :=  b0(i) + 1;
               END IF;
           END loop inner_loopb;
       END loop outer_loopb;
 
       FOR i IN  1 .. n LOOP
           s0 := s0 + a0(i) * b0(i);
           sa := sa + a0(i)*a0(i);
           sb := sb + b0(i)*b0(i);
       END LOOP;
       cos := s0/(SQRT(sa)*SQRT(sb)) ;
       --dbms_output.put_line('s0:  '||s0||' sa： '||sa||' sb： '|| sb||' n: '||n);
       return cos;
   END; 
   /
   
   create or replace FUNCTION ctc_adid(adid IN advertisers.advertiserid%type)
   return FLOAT
   IS
   res FLOAT ;
   BEGIN
       select ctc
       into res
       from advertisers a
       where adid = a.advertiserid ;
       
       return res;
   END;
   /
   create or replace FUNCTION second_auction(selfbid IN FLOAT, bidset IN bid_list)
   return FLOAT
   IS
   res FLOAT;
   temp_list bid_list;
   BEGIN
       select *
       bulk collect into temp_list
       from table( bidset )
       order by 1 DESC;
       /**
       FOR i IN 1 .. temp_list.count LOOP
           dbms_output.put_line('templist '||temp_list(i));
       END LOOP; **/
       
       FOR i IN temp_list.first .. temp_list.last LOOP
           IF (i = temp_list.last) THEN
               res := selfbid;
			   exit;
           ELSIF (selfbid <= temp_list(i) and selfbid > temp_list(i+1)) THEN 
               res := temp_list(i+1);
               exit;
           END IF;
       END LOOP;
       return res;
   END;
   /
   create or replace PROCEDURE proj(num IN INTEGER, atype IN INTEGER, btype IN INTEGER) IS
       --TYPE sum_bid IS TABLE OF FLOAT;
       --TYPE advertiser_row IS TABLE OF advertisers%rowtype;
       TYPE advertiserid_type IS TABLE OF advertisers.advertiserid%type;
       TYPE show_type IS TABLE OF INTEGER ;
       
       --CURSOR c_advertisers is
           --select advertiserid from advertisers;
       CURSOR c_queries is
           select qid, query from queries order by queries.qid;
       sumbid bid_list;
	   tempbid bid_list;
       --vad  advertiser_row;
       adid advertiserid_type; 
       show show_type;
       n0     INTEGER;
       balance0 FLOAT;
       budget0 FLOAT;
       temp0 FLOAT;
	   
   BEGIN
       
       select count(*) into n0 from advertisers;
      -- select * bulk collect into vad from advertisers order by advertiserid;
       show := show_type();
       FOR n IN 1 .. n0  LOOP
           show.extend;
           show(n) := 0; 
       END LOOP;
			 
		   DBMS_OUTPUT.PUT_LINE('begin!');
       
       FOR i_query IN c_queries LOOP
           IF atype = 1 THEN 
               select a.advertiserid , sum(bid) 
               bulk collect into adid , sumbid
               from advertisers a join keywords k on a.advertiserId=k.advertiserId 
               where k.keyword in (select * from table(split(i_query.query)))                    
               group by a.advertiserid,a.ctc
               having sum(bid) < (select b.budget from temp_advertisers b where b.advertiserId=a.advertiserId)
               order by sum(bid) * a.ctc*simcos(split(i_query.query,' '),wordstable(a.advertiserid)) desc ,a.advertiserid ;
            ELSIF atype = 2 THEN
               select a.advertiserid , sum(bid)
               bulk collect into adid , sumbid
               from advertisers a join keywords k on a.advertiserId=k.advertiserId join 
                    temp_advertisers t on k.advertiserid = t.advertiserid
               where k.keyword in (select * from table(split(i_query.query)))
               group by a.advertiserid,t.budget,a.ctc
               having sum(bid) < t.budget
               order by t.budget*a.ctc*simcos((split(i_query.query,' ')),wordstable(a.advertiserid)) desc , a.advertiserid ;
            ELSIF atype = 3 THEN
               select a.advertiserid , sum(bid)
               bulk collect into adid , sumbid
               from advertisers a join keywords k on a.advertiserId=k.advertiserId join
                    temp_advertisers t on k.advertiserid = t.advertiserid 
               where k.keyword in (select * from table(split(i_query.query)))
               group by a.advertiserid,t.budget,a.budget,a.ctc
               having sum(bid) < t.budget
               order by sum(bid)*a.ctc*(1-1/(power(2.718281828459,(t.budget/a.budget))))*simcos((split(i_query.query,' ')),wordstable(a.advertiserid)) desc ,a.advertiserid ;
            END IF;
			
            select *
            bulk collect into tempbid
            from table( sumbid ) ;
			
            IF btype = 2 THEN 
               for i in 1.. adid.count loop  
			       
                   temp0 := tempbid(i);
                   sumbid(i) := second_auction(temp0,tempbid);
           --        if i = adid.count then 
            --           sumbid(i) := sumbid(i);
              --     else sumbid(i):= sumbid(i+1);
             --      end if;
               end loop;
	          end if;
            -- if mod(post_list(adid_list(i)),100) < to_number(to_char(ctc_adid(adid(i)) * 100,'FM99990.00')) then
            for i in 1.. adid.count loop
            exit when i > num;
            if mod(show(adid(i)),100)< to_number(to_char(ctc_adid(adid(i)) * 100,'FM99990.00')) then   
               update temp_advertisers set budget=budget-sumbid(i) where advertiserid = adid(i);
            end if;      
            show(adid(i)):=show(adid(i))+1;
            select budget into balance0 from temp_advertisers where advertiserid = adid(i);
            select budget into budget0 from advertisers where advertiserid = adid(i); 
            DBMS_OUTPUT.PUT_LINE(i_query.qid||' '||i||' '||adid(i)||' '||to_char(balance0,'FM99990.00')||' '||to_char(budget0,'FM99990.00'));
            end loop;
       END LOOP;
       DBMS_OUTPUT.PUT_LINE('end!');
   END; 
/
exit;
