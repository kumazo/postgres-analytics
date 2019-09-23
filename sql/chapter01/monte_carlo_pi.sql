--
-- モンテカルロ法による円周率の近似解の計算
-- 

-- モンテカルロ法による円周率の近似解計算
with
random_points as (
  select i, random() as x, random() as y
--  select i, gen_random_double() as x, gen_random_double() as y
--  select i, mt_random() as x, mt_random() as y
  from generate_series(1, 100000) as gs(i)
),
cropper as (
  select
  x * x + y * y,
    x * x + y * y <= 1.0 as cropped 
  from random_points
),
monte_carlo as (
  select
    count(*) filter(where cropped)::numeric / count(*) as ratio 
  from cropper
)
select 4.0 * ratio as "approx π" from monte_carlo 
;
        approx π         
-------------------------
 3.148120000000000000000
(1 row)


-- ストアドファンクションのXorShift実装による
-- あくまで参考
with
random_points as (
  select xorshift64_double(100000, 1) as x, xorshift64_double(100000, 2) as y
),
cropper as (
  select 
    x * x + y * y <= 1.0 as cropped 
  from random_points
),
monte_carlo as (
  select
    count(*) filter(where cropped)::numeric / count(*) as ratio 
  from cropper
)
select 4.0 * ratio as "approx π" from monte_carlo 
;
        approx π         
-------------------------
 3.149200000000000000000
(1 row)
