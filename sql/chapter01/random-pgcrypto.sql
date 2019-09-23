--
-- pgcrypto モジュールのgen_random_bytes()を使う
--

-- pgcrypto モジュールをロードする
create extension pgcrypto;

--
-- gen_random_bytes()からbigintの乱数を取得する
-- 
create or replace function gen_random_bigint() returns bigint
as $$
declare
  rnd_bytes bytea := gen_random_bytes(8);
  rnd_bigint bigint := 0;
  i integer;
begin
  for i in 0..7 loop
    rnd_bigint := (rnd_bigint << 8) + get_byte(rnd_bytes, i);
  end loop;
  return rnd_bigint;
end;
$$ language plpgsql;

--
-- gen_random_bytes()からdouble precisionで[0,1)の乱数を取得する
--
create or replace function gen_random_double() returns double precision
as $$
declare
  -- Postgres には符号なし整数がないので最上位ビットを捨てた正数の最大値で代用する。
  MAX_BIGINT constant numeric := x'7FFFFFFFFFFFFFFF'::bigint::numeric;
begin
  return (abs(gen_random_bigint()) / MAX_BIGINT)::double precision;
end;
$$ language plpgsql;


-- 試行
select gen_random_bigint() from generate_series(1,10)
;
  gen_random_bigint   
----------------------
  2730768117056211920
 -5509603540359781536
  2967143255433393040
  8530108994692246425
  -285368667105271472
  1512575759472255029
 -8695316633578241766
  3817943667330899597
 -1639854688297899222
  -528675458294512224
(10 rows)

select gen_random_double() from generate_series(1,10)
 gen_random_double 
-------------------
 0.314494433279283
 0.703338253327061
 0.925117192181364
 0.982834982469862
 0.989409878015635
 0.149179714756877
 0.522065087649088
 0.611730047417372
 0.773719440237252
  0.26468391587025
(10 rows)

-- 後始末
drop function gen_random_double;
drop function gen_random_bigint;
drop extension pgcrypto;
