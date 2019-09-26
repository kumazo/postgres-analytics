--
-- 日本の祝祭日出力 
--

-- 未来の祝日を算出する。
-- ちゃんと確認していないが、だいたいあっているはず。
with
period as (
  -- 休日を取得したい期間を指定する
  select
    '2019-01-01'::date as from_dt,
    '2020-12-31'::date as to_dt
),
dates as (
  select dt as dt,
  extract(year from dt) as year,
  extract(month from dt) as month,
  extract(dow from dt) as day_of_week,
  extract(day from dt) as day
  from period, generate_series(from_dt, to_dt, interval '1 day') as gs(dt)
),
national(month, day, nth, day_of_week, period, name) as (
  -- 国民の休日
  values
    ( 1,  1, NULL, NULL, '[1948-07-20,)'::daterange, '元日'),
    ( 1, 15, NULL, NULL, '[1948-07-20, 2000-01-01)', '成人の日'),
    ( 1, NULL,  2,    1, '[2000-01-01,)',            '成人の日'),
    ( 2, 11, NULL, NULL, '[1966-06-25,)',            '建国記念の日'),
    ( 2, 23, NULL, NULL, '[2019-05-01,)',            '天皇誕生日'),
    ( 4, 29, NULL, NULL, '[1948-07-20, 1989-02-17)', '天皇誕生日'),
    ( 4, 29, NULL, NULL, '[1989-02-17, 2007-01-01)', 'みどりの日'),
    ( 4, 29, NULL, NULL, '[2007-01-01,)',            '昭和の日'),
    ( 5,  3, NULL, NULL, '[1948-07-20,)',            '憲法記念日'),
    ( 5,  4, NULL, NULL, '[2007-01-01,)',            'みどりの日'),
    ( 5,  5, NULL, NULL, '[1948-07-20,)',            'こどもの日'),
    ( 7, 20, NULL, NULL, '[1996-01-01, 2003-01-01)', '海の日'),
    ( 7, NULL,  3,    1, '[2003-01-01,)',            '海の日'),
    ( 8, 11, NULL, NULL, '[2016-01-01,)',            '山の日'),
    ( 9, 15, NULL, NULL, '[1966-06-25, 2003-01-01)', '敬老の日'),
    ( 9, NULL,  3,    1, '[2003-01-01,)',            '敬老の日'),
    (10, 10, NULL, NULL, '[1966-06-25, 2000-01-01)', '体育の日'),
    (10, NULL,  2,    1, '[2000-01-01, 2020-06-20)', '体育の日'),
    (10, NULL,  2,    1, '[2020-06-20,)',            'スポーツの日'),
    (11,  3, NULL, NULL, '[1948-07-20,)',            '文化の日'),
    (11, 23, NULL, NULL, '[1948-07-20,)',            '勤労感謝の日'),
    (12, 23, NULL, NULL, '[1989-02-17, 2019-05-01)', '天皇誕生日')
),
imperial(dt, name) as (
  -- 皇室慶弔行事
  select imp.* 
  from dates as ds inner join (values
    ('1959-04-10'::date, '皇太子明仁親王の結婚の儀'),
    ('1989-02-24', '昭和天皇の大喪の礼'),
    ('1990-11-12', '即位の礼正殿の儀'),
    ('1993-06-09', '皇太子徳仁親王の結婚の儀'),
    ('2019-05-01', '天皇の即位'),
    ('2019-10-22', '即位の礼正殿の儀')
  ) as imp(dt, name) on imp.dt = ds.dt
),
special(original_dt, change_dt, name) as (
  -- 2020年は東京オリンピック特別措置法による特例で以下の休日が移動される
  values
    ('2020-07-20'::date, '2020-07-23'::date, '海の日'),
    ('2020-10-12', '2020-07-24', 'スポーツの日'), 
    ('2020-08-11', '2020-08-10', '山の日')
),
equinox as (
  -- 春分の日、秋分の日
  select 
    base.dt + make_interval(secs => 31556925::bigint * (ds.year - 2000)) as dt, 
    base.name as name
  from
    dates as ds,
    (values
      ('2000-03-20 16:29:00'::timestamp, '春分の日'),
      ('2000-09-23 02:10:00',            '秋分の日') 
    ) as base(dt, name)
),
nth_dow as (
  -- 曜日固定の祝日
  select ds.dt, n.name from dates as ds, national as n
  where n.period @> ds.dt::date
    and (ds.month, (ds.day::int + 6) / 7, ds.day_of_week)
      is not distinct from (n.month, n.nth, n.day_of_week)
      -- and (ds.month, (ds.day::int + 6) / 7, ds.day_of_week) = (n.month, n.nth, n.day_of_week)
),
annual as (
  -- 日付固定の祝日
  select ds.dt, n.name 
  from dates as ds, national as n
  where n.period @> ds.dt::date
    and (ds.month, ds.day) is not distinct from (n.month, n.day)
    -- and (ds.month, ds.day) = (n.month, n.day)
),
holidays as (
  -- 全祝祭日
  select dt::date, name from equinox
  union
  select dt::date, name from nth_dow
  union
  select dt::date, name from annual
  union
  select dt::date, name from imperial
),
holidays2 as (
  -- 特例の適用
  select 
    coalesce(s.change_dt, h.dt) as dt,
    coalesce(s.name, h.name) as name
    from holidays as h left join special as s
      on h.dt = s.original_dt
),
furikae_rule as (
  -- 振替休日
  select dt + interval '1 day' as dt, '振替休日' as name from holidays2
  where dt >= '1973-04-12'::date
    and extract(dow from dt) = 0   -- 日曜日
),
kokumin_rule as (
  -- 国民の日
  select h1.dt + interval '1 day' as dt, '国民の日' as name  
  from holidays2 as h1
    inner join holidays2 as h2 on h1.dt + interval '2 days ' = h2.dt
    left join holidays2 as h3 on h1.dt + interval '1 day' = h3.dt
  where h1.dt >= '1985-12-27'::date
    and h3.dt is null
)
(
  select dt::date, name from holidays2
  union
  select dt::date, name from furikae_rule
  union
  select dt::date, name from kokumin_rule
)
order by dt
;

/*
     dt     |       name       
------------+------------------
 2019-01-01 | 元日
 2019-01-14 | 成人の日
 2019-02-11 | 建国記念の日
 2019-03-21 | 春分の日
 2019-04-29 | 昭和の日
 2019-04-30 | 国民の日
 2019-05-01 | 天皇の即位
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
 2019-10-22 | 即位の礼正殿の儀
 2019-11-03 | 文化の日
 2019-11-04 | 振替休日
 2019-11-23 | 勤労感謝の日
 2020-01-01 | 元日
 2020-01-13 | 成人の日
 2020-02-11 | 建国記念の日
 2020-02-23 | 天皇誕生日
 2020-02-24 | 振替休日
 2020-03-20 | 春分の日
 2020-04-29 | 昭和の日
 2020-05-03 | 憲法記念日
 2020-05-04 | みどりの日
 2020-05-04 | 振替休日
 2020-05-05 | こどもの日
 2020-07-23 | 海の日
 2020-07-24 | スポーツの日
 2020-08-10 | 山の日
 2020-09-21 | 敬老の日
 2020-09-22 | 秋分の日
 2020-11-03 | 文化の日
 2020-11-23 | 勤労感謝の日
(40 rows)
*/