--
-- グループ内の順位をつける
--

-- グループに対する連番
-- dense_rank テストデータ
drop table if exists data01;
create table data01 (
  id serial primary key,
  category text,
  name text,
  val int
);
insert into data01(category, name, val)
values
  ('貧乏', '田中', 11),
  ('貧乏', '中山', 12),
  ('貧乏', '山田', 13),
  ('大臣', '田島', 100),
  ('貧乏', '島村', 14),
  ('大臣', '村田', 120),
  ('大大臣', '田村', 1000);

-- 項目の異なりへの番号の降り出し。
-- categoryでソートし、dense_rank()で連番を採番する。
select *,
   dense_rank() over(order by category) as cat_cd
from data01;
 id | category | name | val  | cat_cd 
----+----------+------+------+--------
  7 | 大大臣   | 田村 | 1000 |      1
  4 | 大臣     | 田島 |  100 |      2
  6 | 大臣     | 村田 |  120 |      2
  1 | 貧乏     | 田中 |   11 |      3
  5 | 貧乏     | 島村 |   14 |      3
  2 | 貧乏     | 中山 |   12 |      3
  3 | 貧乏     | 山田 |   13 |      3
(7 rows)



-- 順序を維持した連番
-- first_value テストデータ
drop table if exists data02;
create table data02 (
  id serial primary key,
  category text,
  name text,
  val int
);
insert into data02(category, name, val)
values
  ('小学生', '田中', 3000),
  ('小学生', '中山', 5000),
  ('中学生', '山田', 5000),
  ('中学生', '田島', 10000),
  ('高校生', '島村', 5000),
  ('大学生', '村田', 10000),
  ('大学生', '田村', 0);

-- カテゴリが初めて出現したのIDを項目番号とする。
select *,
  first_value(id) over(partition by category order by id) as cat_cd
from data02 order by id;
/*
 id | category | name |  val  | cat_cd 
----+----------+------+-------+--------
  1 | 小学生   | 田中 |  3000 |      1
  2 | 小学生   | 中山 |  5000 |      1
  3 | 中学生   | 山田 |  5000 |      3
  4 | 中学生   | 田島 | 10000 |      3
  5 | 高校生   | 島村 |  5000 |      5
  6 | 大学生   | 村田 | 10000 |      6
  7 | 大学生   | 田村 |     0 |      6
(7 rows)
*/


-- first_value によるカテゴリ（cat_cd1）は飛び番になる。
-- それを dense_rank でさらに連番にする。
with
tmp as (
  select id, 
    first_value(id) over(partition by category order by id) as cat_cd1
  from data02
)
select *,
   dense_rank() over(order by cat_cd1) as cat_cd2
from tmp inner join data02 using(id) order by id;


-- 分類階層
-- ダミーデータ
drop table if exists data02;
create table data02 (
  id serial,
  major text,
  minor text,
  subminor text,
  val int
);

with
majors(a) as (
  values('大項目1'),('大項目2'),('大項目3')
),
minors(b) as (
  values('中項目1'),('中項目2'),('中項目3')
),
subminors(c) as (
  values('小項目1'),('小項目2'),('小項目3')
)
insert into data02 (major, minor, subminor, val)
select a, b, c, 100 from majors, minors, subminors
;

select * from data02;

select
  id,
  dense_rank() over(order by major) * 100
  + dense_rank() over(partition by major order by minor) * 10
  + dense_rank() over(partition by major, minor order by subminor)
    as code,
  major,
  minor,
  subminor,
  val
from data02
order by code
;
/*
 id | code |  major  |  minor  | subminor | val 
----+------+---------+---------+----------+-----
  1 |  111 | 大項目1 | 中項目1 | 小項目1  | 100
 10 |  112 | 大項目1 | 中項目1 | 小項目2  | 100
 19 |  113 | 大項目1 | 中項目1 | 小項目3  | 100
  2 |  121 | 大項目1 | 中項目2 | 小項目1  | 100
 11 |  122 | 大項目1 | 中項目2 | 小項目2  | 100
 20 |  123 | 大項目1 | 中項目2 | 小項目3  | 100
  3 |  131 | 大項目1 | 中項目3 | 小項目1  | 100
 12 |  132 | 大項目1 | 中項目3 | 小項目2  | 100
 21 |  133 | 大項目1 | 中項目3 | 小項目3  | 100
  4 |  211 | 大項目2 | 中項目1 | 小項目1  | 100
 13 |  212 | 大項目2 | 中項目1 | 小項目2  | 100
 22 |  213 | 大項目2 | 中項目1 | 小項目3  | 100
  5 |  221 | 大項目2 | 中項目2 | 小項目1  | 100
 14 |  222 | 大項目2 | 中項目2 | 小項目2  | 100
 23 |  223 | 大項目2 | 中項目2 | 小項目3  | 100
  6 |  231 | 大項目2 | 中項目3 | 小項目1  | 100
 15 |  232 | 大項目2 | 中項目3 | 小項目2  | 100
 24 |  233 | 大項目2 | 中項目3 | 小項目3  | 100
  7 |  311 | 大項目3 | 中項目1 | 小項目1  | 100
 16 |  312 | 大項目3 | 中項目1 | 小項目2  | 100
 25 |  313 | 大項目3 | 中項目1 | 小項目3  | 100
  8 |  321 | 大項目3 | 中項目2 | 小項目1  | 100
 17 |  322 | 大項目3 | 中項目2 | 小項目2  | 100
 26 |  323 | 大項目3 | 中項目2 | 小項目3  | 100
  9 |  331 | 大項目3 | 中項目3 | 小項目1  | 100
 18 |  332 | 大項目3 | 中項目3 | 小項目2  | 100
 27 |  333 | 大項目3 | 中項目3 | 小項目3  | 100
(27 rows)
*/


-- 後始末
drop table if exists data02;
drop table if exists data01;