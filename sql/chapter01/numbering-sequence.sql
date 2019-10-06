--
-- SEQUENCE
--

-- セッションローカルなSEQUENCEを作成
create temp sequence tmp_seq01;

-- nextvalで行番号を採番
select id, nextval('tmp_seq01') as rn from generate_series(1,5) gs(id)
;
/*
 id | rn 
----+----
  1 |  1
  2 |  2
  3 |  3
  4 |  4
  5 |  5
(5 rows)
*/

-- SEQUENCEを削除
drop sequence tmp_seq01;

-- ORDER BY の影響を受けない
create temp sequence tmp_seq01;
select i, nextval('tmp_seq01') as rn from generate_series(1,5) gs(i) order by i desc;
drop sequence tmp_seq01
;
/*
 i | rn 
---+----
 5 |  1
 4 |  2
 3 |  3
 2 |  4
 1 |  5
(5 rows)
*/

-- OFFSET の影響を受ける。
create temp sequence tmp_seq01;
select i, nextval('tmp_seq01') as rn from generate_series(1,5) gs(i) OFFSET 2;
drop sequence tmp_seq01
;
/*
 i | rn 
---+----
 3 |  3
 4 |  4
 5 |  5
(3 rows)
*/

-- GROUP BYの後、OFFSETの前
create temp sequence tmp_seq01;
select
  i, 
  nextval('tmp_seq01') as sequence,
  row_number() over() as row_number  
from generate_series(1, 10) gs(i)
where i > 1
order by i desc
OFFSET 2
;
drop sequence tmp_seq01;

/*
 i | sequence | row_number 
---+----------+------------
 8 |        3 |          7
 7 |        4 |          6
 6 |        5 |          5
 5 |        6 |          4
 4 |        7 |          3
 3 |        8 |          2
 2 |        9 |          1
(7 rows)
*/

