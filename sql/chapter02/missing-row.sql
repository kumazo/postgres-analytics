-- 
-- 欠損行を補完する
--

create table data01 (id int, name text, val int);
insert into data01   values
    (1, 'いちご', 100),
    (2, 'にんじん', 200),
 -- (3, 'サンダル', 300), -- 欠損
    (4, 'ヨット', 400),
    (5, 'ごましお', 500)
;

-- coalesce でNULL行を置き換える
select (coalesce(data01, (i, '---', 0)::data01)).*
from generate_series(1, 5) as gs(i)
left join data01 on id = i
;
/*
 id |   name   | val 
----+----------+-----
  1 | いちご   | 100
  2 | にんじん | 200
  3 | ---      |   0
  4 | ヨット   | 400
  5 | ごましお | 500
(5 rows)
*/

-- 後始末
drop table if exists data01;
