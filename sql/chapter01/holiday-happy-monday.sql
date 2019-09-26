--
-- 月曜固定祝日
--

-- 毎月第2月曜日
select dt::date 
from generate_series('2019-01-01', '2020-01-01', interval '1 day') as gs(dt)
where
  (date_part('day', dt)::int + 6) / 7 = 2  -- 第２
and
  date_part('dow', dt) = 1   -- 月曜日
;
/*
     dt     
------------
 2019-01-14
 2019-02-11
 2019-03-11
 2019-04-08
 2019-05-13
 2019-06-10
 2019-07-08
 2019-08-12
 2019-09-09
 2019-10-14
 2019-11-11
 2019-12-09
(12 rows)
*/

-- 2019年の月曜固定祝日を出力
with
dates as (
  select dt as dt,
  extract(month from dt) as month,
  extract(day from dt) as day,
  extract(dow from dt) as day_of_week
  from generate_series('2019-01-01', '2019-12-31', interval '1 day') as gs(dt)
),
annual(month, day, nth, day_of_week, name) as (
  values
    ( 1, NULL,  2, 1, '成人の日'),
    ( 7, NULL,  3, 1, '海の日'),
    ( 9, NULL,  3, 1, '敬老の日'),
    (10, NULL,  2, 1, '体育の日'),
    (12,    1,  NULL, NULL, 'テスト')
),
monday as (
  select dt, an.name from dates as ds, annual as an
  where 
    -- 行コンストラクたを使って比較する場合、
    -- NULLに備えて = 演算子ではなく IS NOT DISTINCT FROM を使わなければならない。
    (ds.month, (ds.day::int + 6) / 7, ds.day_of_week) is not distinct from (an.month, an.nth, an.day_of_week)
 --   (ds.month, (ds.day::int + 6) / 7, ds.day_of_week) = (an.month, an.nth, an.day_of_week)
)
select * from monday
;
/*
           dt           |   name   
------------------------+----------
 2019-01-14 00:00:00+00 | 成人の日
 2019-07-15 00:00:00+00 | 海の日
 2019-09-16 00:00:00+00 | 敬老の日
 2019-10-14 00:00:00+00 | 体育の日
(4 rows)
*/