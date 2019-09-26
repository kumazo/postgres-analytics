--
-- 日本語日付・和暦
--



-- 日本語日付ロケール
SET lc_time TO 'ja_JP.utf8'; 
-- SET lc_time TO 'Japanese'; Windows用

select name, setting, context from pg_settings where name like 'lc_time'
;
/*
  name   |  setting   | context 
---------+------------+---------
 lc_time | ja_JP.utf8 | user
(1 row)
*/

-- 日本語書式のチェック
with
fmt as (
  select '{HH,HH12,HH24,MI,SS,MS,US,SSSS,AM,A.M.,"Y,YYY",YYYY,YYY,YY,Y,IYYY,IYY,IY,I,BC,B.C.,MONTH,Month,month,MON,Mon,mon,MM,DAY,Day,day,DY,Dy,dy,DDD,IDDD,DD,D,ID,WW,IW,CC,J,Q,RM,rm,TZ,tz,TZH,TZM,OF}'::text[] as pat
)
select p as pattern, to_char(now(), p) as "C", 'TM'||p as "TM", to_char(now(), 'TM'||p) as "ja_JP"
from fmt, unnest(fmt.pat) as f(p)
;
/*
pattern |     C     |   TM    |  ja_JP  
---------+-----------+---------+---------
 HH      | 09        | TMHH    | 09
 HH12    | 09        | TMHH12  | 09
 HH24    | 21        | TMHH24  | 21
 MI      | 01        | TMMI    | 01
 SS      | 11        | TMSS    | 11
 MS      | 467       | TMMS    | 467
 US      | 467890    | TMUS    | 467890
 SSSS    | 75671     | TMSSSS  | 75671
 AM      | PM        | TMAM    | PM
 A.M.    | P.M.      | TMA.M.  | P.M.
 Y,YYY   | 2,019     | TMY,YYY | 2,019
 YYYY    | 2019      | TMYYYY  | 2019
 YYY     | 019       | TMYYY   | 019
 YY      | 19        | TMYY    | 19
 Y       | 9         | TMY     | 9
 IYYY    | 2019      | TMIYYY  | 2019
 IYY     | 019       | TMIYY   | 019
 IY      | 19        | TMIY    | 19
 I       | 9         | TMI     | 9
 BC      | AD        | TMBC    | AD
 B.C.    | A.D.      | TMB.C.  | A.D.
 MONTH   | SEPTEMBER | TMMONTH | 9月
 Month   | September | TMMonth | 9月
 month   | september | TMmonth | 9月
 MON     | SEP       | TMMON   |  9月
 Mon     | Sep       | TMMon   |  9月
 mon     | sep       | TMmon   |  9月
 MM      | 09        | TMMM    | 09
 DAY     | TUESDAY   | TMDAY   | 火曜日
 Day     | Tuesday   | TMDay   | 火曜日
 day     | tuesday   | TMday   | 火曜日
 DY      | TUE       | TMDY    | 火
 Dy      | Tue       | TMDy    | 火
 dy      | tue       | TMdy    | 火
 DDD     | 267       | TMDDD   | 267
 IDDD    | 268       | TMIDDD  | 268
 DD      | 24        | TMDD    | 24
 D       | 3         | TMD     | 3
 ID      | 2         | TMID    | 2
 WW      | 39        | TMWW    | 39
 IW      | 39        | TMIW    | 39
 CC      | 21        | TMCC    | 21
 J       | 2458751   | TMJ     | 2458751
 Q       | 3         | TMQ     | 3
 RM      | IX        | TMRM    | IX  
 rm      | ix        | TMrm    | ix  
 TZ      | UTC       | TMTZ    | UTC
 tz      | utc       | TMtz    | utc
 TZH     | +00       | TMTZH   | +00
 TZM     | 00        | TMTZM   | 00
 OF      | +00       | TMOF    | +00
(51 rows)
*/

--
-- 元号年を出力する
--
create or replace function ja_era(d date) returns text
as $$
  with
  era(name, period) as (
    -- 元号期間に日付範囲型を使う（文書8.17.）
   values
      ('明治', '[1868-10-23, 1912-07-29]'::daterange),
      ('大正', '[1912-07-30, 1926-12-24]'),
      ('昭和', '[1926-12-25, 1989-01-07]'),
      ('平成', '[1989-01-08, 2019-04-30]'),
      ('令和', '[2019-05-01,]')           -- 上限値を省略すると未来永劫となる
  ),
  y as (
    select name, date_part('year', d) - date_part('year', lower(period)) + 1 as nen
    from era where period @> d     -- 範囲演算子（期間に日付が含まれると真）
  )
  select name || case when nen = 1 then '元' else nen::text end || '年' from y;
$$ language sql;

-- 試行
select ja_era(now()::date) || to_char(now(), 'MM月DD日TMDay') as 和暦
;
/*
          和暦          
------------------------
 令和元年09月22日日曜日
(1 row)
*/

-- 境界値チェック
with
dates(d) as (
  values
    ('2019-04-30'::date),
    ('2019-05-01'),
    ('2019-12-31'),
    ('2020-01-01')
)
select ja_era(d) || to_char(d, 'MM月DD日TMDay') from dates
;
/*
        ?column?        
------------------------
 平成31年04月30日火曜日
 令和元年05月01日水曜日
 令和元年12月31日火曜日
 令和2年01月01日水曜日
(4 rows)
*/

-- 後始末
drop function if exists ja_era;
SET lc_time TO 'en_US.utf8'; 
