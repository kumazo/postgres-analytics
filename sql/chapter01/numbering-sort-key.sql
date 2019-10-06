--
-- 配列によるソート順定義
--


-- サンプルテーブル
drop table if exists data01;
create table data01(id, name, unit, amount) as 
values
  (1, 'いちご', '個', 10),
  (2, 'にんじん', '本', 1),
  (3, 'サンダル', '足', 2),
  (4, 'ヨット', '舟', 3),
  (5, 'ごましお', '粒', 4),
  (6, 'ロケット', '台', 5),
  (7, '七面鳥', '羽', 6),
  (8, 'ハチ', '匹', 7),
  (9, 'くじら', '頭', 8),
  (10, 'ジュース', '杯', 9);


-- 配列の順序でソート
with
sel as (
  select array[
    'いちご', 'ジュース', 'サンダル', 'ロケット'  -- 値リストを展開
  ] as items
),
ord as (
  select o.name, o.i from sel, unnest(sel.items) with ordinality as o(name,i)
)
select d.* from sel, data01 as d left join ord using(name)
where d.name = any(sel.items)    -- IN句をANY句で置き換え
order by ord.i
;
/*
 id |   name   | unit | amount 
----+----------+------+--------
  1 | いちご   | 個   |     10
 10 | ジュース | 杯   |      9
  3 | サンダル | 足   |      2
  6 | ロケット | 台   |      5
(4 rows)
*/

-- array_position()でソート
with
sel as (
  select array[
    'いちご', 'ジュース', 'サンダル', 'ロケット'  -- 値リストを展開
  ] as items
)
select d.* 
from data01 as d, sel as s
where d.name = any(s.items)    -- IN句をANY句で置き換え
order by array_position(s.items, d.name)
;
/*
 id |   name   | unit | amount 
----+----------+------+--------
  1 | いちご   | 個   |     10
 10 | ジュース | 杯   |      9
  3 | サンダル | 足   |      2
  6 | ロケット | 台   |      5
(4 rows)
*/


-- 後始末
drop table if exists data01;
