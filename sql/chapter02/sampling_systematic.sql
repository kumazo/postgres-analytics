-- 
-- 系統抽出
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


with
params as (
  select 
    10       as n,    -- 取得行数 
    count(*) as cnt,  -- 総行数
    count(*) * random()      as init, -- 初期値はランダムに選択する。
    count(*) * (sqrt(5)-1)/2 as skip  -- 移動間隔（黄金比）
  from data01
),
sys as (
  select ceil(init + i * skip)::int % cnt as pick
  from params, generate_series(1, n) as gs(i)
)
select d.* from sys inner join data01 as d on d.id = sys.pick
;

   id   |        val         
--------+--------------------
 527141 |  0.972022225614637
 145175 |  0.974780853837729
 763209 |  0.300005593337119
 381243 |  0.326080047059804
 999277 |  0.445610370021313
 617311 |  0.245341151021421
 235345 | 0.0250735390000045
 853379 |  0.413046529516578
 471413 |  0.410539776552469
  89447 | 0.0889788419008255
(10 rows)

Time: 58.727 ms


-- 後始末
drop table if exists data01;

