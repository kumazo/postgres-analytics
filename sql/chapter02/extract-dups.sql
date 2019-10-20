--
-- 重複データの排除
--

drop table if exists data01;
create table data01 (
  id serial,
  category text,
  name text,
  val int
);
insert into data01(category, name, val)
values
  ('A','とり', 100),
  ('B','ぶた', 200),
  ('C','さかな', 300),
  ('C','ぶた', 400),
  ('B','ぶた', 1000);

-- 重複行の抽出
with
cnts as (
  select *, 
    count(*) over(partition by category, name) as dup
  from data01
)
select * from cnts where dup > 1  
order by category, name
;
/*
 id | category | name | val  | dup 
----+----------+------+------+-----
  2 | B        | ぶた |  200 |   2
  5 | B        | ぶた | 1000 |   2
(2 rows)
*/

-- 重複行の排除
select distinct on (category, name) * from data01
order by category, name, id desc
;
/*
id | category |  name  | val  
----+----------+--------+------
  1 | A        | とり   |  100
  5 | B        | ぶた   | 1000
  4 | C        | ぶた   |  400
  3 | C        | さかな |  300
(4 rows)
*/


-- 累積COUNTでダブりの古い方を確認
select *, 
  count(*) over(partition by category, name order by id desc) as dup
from data01
;
/*
 id | category |  name  | val  | dup 
----+----------+--------+------+-----
  1 | A        | とり   |  100 |   1
  5 | B        | ぶた   | 1000 |   1
  2 | B        | ぶた   |  200 |   2
  4 | C        | ぶた   |  400 |   1
  3 | C        | さかな |  300 |   1
(5 rows)
*/

-- row_number でもよし
select *, 
  row_number() over(partition by category, name order by id desc) as dup
from data01

-- 重複行の削除
with
dels as (
  select id, 
     count(*) over(partition by category, name order by id desc) as dup
  from data01
)
delete from data01 as d using dels as c where d.id = c.id and c.dup > 1

-- 重複行の削除 row_number を使う
with
cnts as (
  select id, 
    row_number() over(partition by category, name order by id desc) as dup
  from data01
)
delete from data01 as d using cnts as c where d.id = c.id and c.dup > 1
;

select * from data01 order by category, name
;

/*
 id | category |  name  | val  
----+----------+--------+------
  1 | A        | とり   |  100
  5 | B        | ぶた   | 1000
  4 | C        | ぶた   |  400
  3 | C        | さかな |  300
(4 rows)
*/

-- 後始末
drop table if exists data01;
