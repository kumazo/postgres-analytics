--
-- 振替休日・国民の日の算出
--

-- 祝祭日が日曜だった時の振替休日と、休日に挟まれた日も休日にするルールで
-- 追加される休日を算出する
-- 2019年のゴールデンウィークが再現できればOK
with
dates as (
  select dt as dt,
  extract(year from dt) as year,
  extract(dow from dt) as day_of_week
  from generate_series('2019-01-01', '2019-12-31', interval '1 day') as gs(dt)
),
annuals(month, day, name) as (
  -- 2019年の祝祭日
  values
    ( 1,  1, '元日'),
    ( 1, 14, '成人の日'),
    ( 2, 11, '建国記念の日'),
    ( 3, 21, '春分の日'),
    ( 4, 29, '昭和の日'),
    ( 5,  1, '即位の日'),
    ( 5,  3, '憲法記念日'),
    ( 5,  4, 'みどりの日'),
    ( 5,  5, 'こどもの日'),
    ( 7, 15, '海の日'),
    ( 8, 11, '山の日'),
    ( 9, 16, '敬老の日'),
    ( 9, 23, '秋分の日'),
    (10, 14, '体育の日'),
    (10, 22, '即位礼正殿の儀'),
    (11,  3, '文化の日'),
    (11, 23, '勤労感謝の日')
),
holidays as (
  select * 
  from dates as ds 
  inner join annuals as a on (make_date(ds.year::int, a.month, a.day) = ds.dt)
),
furikae_rule as (
  -- 振替休日
  -- 祝祭日が日曜日に当たっていた場合、翌日を振替休日とする。
  select dt + '1 day' as dt, '振替休日' as name from holidays
  where dt >= '1973-04-12'::date
    and day_of_week = 0   -- 日曜日
),
kokumin_rule as (
  -- 国民の日
  -- 休日に挟まれた日は国民の日という休日にする。
  select h1.dt + '1 day' as dt, '国民の日' as name  
  from holidays as h1
    inner join holidays as h2 on h1.dt + '2 days ' = h2.dt
    left join holidays as h3 on h1.dt + '1 day' = h3.dt
  where h1.dt >= '1973-04-12'::date
    and h3.dt is null
)
(
  select dt::date, name from holidays
  union
  select dt::date, name from furikae_rule
  union
  select dt::date, name from kokumin_rule
)
order by dt
;

/*
     dt     |      name      
------------+----------------
 2019-01-01 | 元日
 2019-01-14 | 成人の日
 2019-02-11 | 建国記念の日
 2019-03-21 | 春分の日
 2019-04-29 | 昭和の日
 2019-04-30 | 国民の日
 2019-05-01 | 即位の日
 2019-05-02 | 国民の日
 2019-05-03 | 憲法記念日
 2019-05-04 | みどりの日
 2019-05-05 | こどもの日
 2019-05-06 | 振替休日
 2019-07-15 | 海の日
 2019-08-11 | 山の日
 2019-08-12 | 振替休日
 2019-09-16 | 敬老の日
 2019-09-23 | 秋分の日
 2019-10-14 | 体育の日
 2019-10-22 | 即位礼正殿の儀
 2019-11-03 | 文化の日
 2019-11-04 | 振替休日
 2019-11-23 | 勤労感謝の日
(22 rows)
*/
