---
--- 差分抽出
---

drop table if exists cpy01;
drop table if exists org01;

-- オリジナルテーブル
create table org01 (
  id serial,
  code text,
  name text,
  val int,
  dt timestamp default CURRENT_TIMESTAMP
);
insert into org01(code, name, val) values
  ('A01', 'Boo', 100),
  ('A02', 'Foo', 200),
  ('A03', 'Woo', 300);

-- 既存テーブルをコピーする
create table cpy01 as select * from org01;

-- オリジナルテーブルに更新が発生する
update org01 set name = 'Bar', dt = now() where id = 1; -- 更新
insert into org01(code, name, val) values('A04', 'Qoo', 400); -- 行追加
delete from org01 where id = 3; -- 行削除
insert into org01(code, name, val) values('A03', 'Woo', 300); -- 復活

select * from org01;
select * from cpy01;

-- オリジナルとコピーの差分を抽出してみる
select l.*, r.* 
from org01 as l full join cpy01 as r using(id) 
where l is null or r is null
  or l <> r    -- レコード比較
;

/*
 id | code | name | val |             dt             | id | code | name | val |             dt             
----+------+------+-----+----------------------------+----+------+------+-----+----------------------------
  1 | A01  | Bar  | 100 | 2019-08-20 02:20:27.820104 |  1 | A01  | Boo  | 100 | 2019-08-20 02:20:27.814741
  4 | A04  | Qoo  | 400 | 2019-08-20 02:20:27.821482 |    |      |      |     | 
  5 | A03  | Woo  | 300 | 2019-08-20 02:20:27.824103 |    |      |      |     | 
    |      |      |     |                            |  3 | A03  | Woo  | 300 | 2019-08-20 02:20:27.814741
(4 rows)*/

-- ユニークキーで付き合わせができるなら、業務データのカラムだけを比較できる。
select l.*, r.*
from org01 as l full join cpy01 as r using(code)
where l is null or r is null
   --　業務カラムのみを比較
  or  (l.code, l.name, l.val) is distinct from (l.code, r.name, r.val)
;
/*
 id | code | name | val |             dt             | id | code | name | val |             dt             
----+------+------+-----+----------------------------+----+------+------+-----+----------------------------
  1 | A01  | Bar  | 100 | 2019-08-20 02:20:27.820104 |  1 | A01  | Boo  | 100 | 2019-10-20 02:20:27.814741
  4 | A04  | Qoo  | 400 | 2019-08-20 02:20:27.821482 |    |      |      |     | 
(2 rows)
*/

-- 業務データのカラムだけで差分をとりたい
-- JSONでidとdtのカラムをマスクする
select masked.* 
from org01,
     jsonb_populate_record(org01, '{"id":0, "dt":null}'::jsonb) as masked
;
/*
 id | code | name | val | dt 
----+------+------+-----+----
  0 | A02  | Foo  | 200 | 
  0 | A01  | Bar  | 100 | 
  0 | A04  | Qoo  | 400 | 
  0 | A03  | Woo  | 300 | 
(4 rows)
*/

-- JSONマスクで業務カラムを比較する
with
js as (
  -- idとdtのマスク
  select '{"id":0, "dt":null}'::jsonb as mask
)
select l.*, r.* 
from js,
  org01 as l full join cpy01 as r using(code),
  jsonb_populate_record(l, js.mask) as ll,
  jsonb_populate_record(r, js.mask) as rr
where ll is null or rr is null or ll <> rr 
;
/*
 id | code | name | val |             dt             | id | code | name | val |             dt             
----+------+------+-----+----------------------------+----+------+------+-----+----------------------------
  1 | A01  | Bar  | 100 | 2019-08-20 02:20:27.820104 |  1 | A01  | Boo  | 100 | 2019-10-20 02:20:27.814741
  4 | A04  | Qoo  | 400 | 2019-08-20 02:20:27.821482 |    |      |      |     | 
(2 rows)
*/

-- JSONマスクしたテーブルをさらに EXCEPT 構文で差分をとる
with
js as (
  select '{"id":0, "dt":null}'::jsonb as mask
)
select l.* from js, org01, jsonb_populate_record(org01, js.mask) as l 
except all
select r.* from js, cpy01, jsonb_populate_record(cpy01, js.mask) as r
;
/*
 id | code | name | val | dt 
----+------+------+-----+----
  0 | A01  | Bar  | 100 | 
  0 | A04  | Qoo  | 400 | 
(2 rows)
*/


-- 後始末
drop table if exists cpy01;
drop table if exists org01;
