--
-- 指数分布乱数の生成
-- Exponetial distribution - time series
--

--
-- 時系列の指数分布乱数
-- start 開始日時
-- stop  終了日時
-- λ     単位時間あたりの平均回数
-- unit_time 単位時間
--
create or replace function random_exponential(
  start timestamp, stop timestamp, λ double precision, unit_time interval)
returns setof timestamp
as $$
  with recursive
  exp_dist as (
    select start as t
    union all
    select t -ln(1.0 - random()) * unit_time / λ from exp_dist
    where t < stop 
  )
  select t from exp_dist where start < t and t <= stop
$$ language sql;


-- 試行
-- 1日に１回程度生起する事象の時系列分布
select n, dt from random_exponential(
  start := '2019-01-01', 
  stop  := '2019-12-31', 
  λ     := 1, 
  unit_time := '1 day') with ordinality re(dt, n);
/*
  n  |             dt             
-----+----------------------------
   1 | 2019-01-01 18:48:30.007719
   2 | 2019-01-02 05:31:19.884609
   3 | 2019-01-03 03:47:52.284384
   4 | 2019-01-03 21:52:01.008273
   5 | 2019-01-06 04:10:04.241973
   6 | 2019-01-06 19:41:04.774318
   7 | 2019-01-07 15:54:52.328856
   8 | 2019-01-08 11:33:01.254979
   9 | 2019-01-09 04:39:20.351234
  10 | 2019-01-09 10:02:04.992847
  11 | 2019-01-10 03:52:34.940988
  12 | 2019-01-10 13:30:20.417735
  13 | 2019-01-11 15:28:38.177917
  14 | 2019-01-12 06:02:46.188148
  15 | 2019-01-12 17:28:00.541148
  16 | 2019-01-13 01:58:55.791434
  17 | 2019-01-14 16:54:41.058719
  18 | 2019-01-16 07:25:15.367239
  19 | 2019-01-16 21:27:40.176912
   :
 364 | 2019-12-21 12:19:57.121786
 365 | 2019-12-22 09:25:18.065751
 366 | 2019-12-24 04:06:27.33169
 367 | 2019-12-25 23:45:59.351885
 368 | 2019-12-27 14:57:18.530818
 369 | 2019-12-28 08:29:42.661881
 370 | 2019-12-29 14:21:12.987716
 371 | 2019-12-30 07:02:10.487822
 372 | 2019-12-30 14:04:19.248948
(372 rows)
*/



-- 後始末
drop function random_exponential;
