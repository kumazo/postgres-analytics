--
-- 無作為抽出
-- ランダムに１行抽出する方法
-- 

-- 100万行のテーブル
drop table if exists data01;
create table data01(
    id serial primary key, 
    val NUMERIC
); 
insert into data01 select i, random() from generate_series(1, 1000000) as gs(i);


-- 処理時間計測
\timing


-- ランダムソート -------------------------------------------------------------
select * from data01 order by random() limit 1
;
-- Time: 204.208 ms

-- ランダムOFFSET -------------------------------------------------------------
-- サブクリエリによるランダムOFFSET
select * from data01 order by id
offset (select floor(random() * count(*))::int from data01)
limit 1
;
/*
   id   |        val        
--------+-------------------
 697395 | 0.551311177201569
(1 row)

Time: 116.166 ms
*/

select * from data01
offset (select floor(random() * count(*))::int from data01)
limit 1
-- Time: 80.157 ms

-- ソートなしでテーブルのOFFSETを取ると結果が不定になる。
select *, ctid from data01 offset 500000 limit 1; -- 中間にOFFSET
/*
   id   |        val        |   ctid   
--------+-------------------+----------
 375740 | 0.206740326713771 | (2032,8)
(1 row)
Time: 40.599 ms
select *, ctid from data01 offset 500000 limit 1;
   id   |        val        |    ctid    
--------+-------------------+------------
 875733 | 0.773033510893583 | (4735,179)
(1 row)
Time: 36.593 ms
select *, ctid from data01 offset 500000 limit 1;
   id   |        val        |   ctid   
--------+-------------------+----------
 372781 | 0.326497331727296 | (2016,7)
(1 row)
Time: 38.951 ms
*/

-- ソートすれば安定するが、パフォーマンスが悪化する。
select *, ctid from data01 order by id offset 500000 limit 1; -- 中間にOFFSET
;
/*
   id   |       val        |    ctid    
--------+------------------+------------
 500001 | 0.67983263451606 | (2703,184)
(1 row)

Time: 65.058 ms
select *, ctid from data01 order by id offset 500000 limit 1
;
   id   |       val        |    ctid    
--------+------------------+------------
 500001 | 0.67983263451606 | (2703,184)
(1 row)

Time: 64.915 ms
select *, ctid from data01 order by id offset 500000 limit 1
;
   id   |       val        |    ctid    
--------+------------------+------------
 500001 | 0.67983263451606 | (2703,184)
(1 row)

Time: 70.705 ms
*/

select * from data01 offset 0 limit 1;
-- Time: 0.509 ms
select * from data01 offset 999999 limit 1;
-- Time: 44.678 ms

select * from data01 order by id
offset (select floor(random() * count(*))::int from data01)
limit 1

-- serial型連番（インデックス付き）を行番号とみなす ---------------------------
with
rnd as (
  select ceil(max(id) * random())::int as id from data01
)
SELECT data01.* from rnd inner join data01 using(id) limit 1
;
-- Time: 0.602 ms

-- リトライあり
with
rnd as (
  select ceil(max_id * random())::int as id 
  from (select max(id) as max_id from data01) as a,
    generate_series(1, 3) as gs(n) -- リトライ2回
)
SELECT data01.* from rnd inner join data01 using(id) limit 1
;
-- Time: 0.676 ms

-- row_number() で行番号をふる ------------------------------------------------

-- 共通テーブル式を使う
with
rnd as (
  select ceil(random() * count(*))::int as rn from data01
),
rn as (
  -- ここで全行データがマテリアライズされる!
  select *, row_number() over() as rn from data01
)
select * from rnd inner join rn using(rn) 
;
-- Time: 592.559 ms

with
rnd as (
  select ceil(random() * count(*))::int as rn from data01
),
rn as (
  -- マテリアライズのボリュームを軽減してみると少しは効果がある
  select id, row_number() over() as rn from data01
)
select data01.* from rnd inner join rn using(rn) inner join data01 using(id)
;
-- Time: 509.283 ms

-- サブクエリにしたほうが早い
with
rnd as (
  select ceil(random() * count(*))::int as rn
  from data01
)
select d.* from rnd inner join
  (select id, row_number() over() as rn from data01) as rn using(rn)
  inner join data01 as d using(id)
;
-- Time: 299.087 ms

-- 共通テーブル式の内容はマテリアライズされる問題は、
-- PostgreSQL 12 で改善され、サブクエリに変換される予定

-- SEQUENCE で行番号をふる　--------------------------------------------------

-- 一時シーケンスを作成
create temp sequence rn01;

with
rnd as (
  select ceil(random() * count(*))::int as rn
  from data01
)
-- テーブルの各行でnextval()を呼ぶ導出テーブルを結合する。
select d.*, seq.rn
from data01 as d, rnd, 
  lateral (select d.id, nextval('rn01') as rn) as seq
where
  rnd.rn = seq.rn
limit 10
;

-- 都度シーケンス削除
-- 使い回しはできない
drop sequence rn01
;

-- nth_value() で行番号をふる ------------------------------------------------
with
rnd as (
  select ceil(random() * count(*))::int as rn from data01  
)
select nth_value(d.id, rnd.rn) over() as id from data01 as d, rnd limit 1
;
/*
   id   |        val        
--------+-------------------
 511090 | 0.709794399794191
(1 row)

Time: 247.334 ms
*/

-- nth_value も OFFSET 同様な不安定さを現す
select nth_value(d.id, 500000) over() as id, val from data01 as d limit 1
;
/*
   id   |        val        
--------+-------------------
 423090 | 0.116480868309736
   id   |        val        
--------+-------------------
 920133 | 0.141727549023926
   id   |        val        
--------+-------------------
 420130 | 0.381558133289218
   id   |        val         
--------+--------------------
 917175 | 0.0263826344162226
*/

-- 後始末
\timing
drop table if exists data01;
