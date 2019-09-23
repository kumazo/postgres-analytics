--
-- XorShiftをPL/PgSQLで実装してみる
--


--
-- XorShiftによる乱数をbigint型で返すテーブル関数
-- n 生成個数
-- seed 乱数シード
--
create or replace function xorshift64_bigint(n numeric, seed bigint)
returns setof bigint as $$
declare
  x bigint := 88172645463325252 + seed;
  H7B0 constant bigint := x'01FFFFFFFFFFFFFF'::bigint;
begin
  for i in 1 .. n loop
    x := x # (x << 13);
    x := x # ((x >> 7) & H7B0);
    x := x # (x << 17);
    return next x;
  end loop;
  return;
end;
$$ language plpgsql

--
-- XorShiftによる乱数をbigint型で返すテーブル関数
-- n 生成個数
-- seed 乱数シード
--
--
-- XorShiftによる乱数をdouble precision型で返す
-- n 生成個数
-- seed 乱数シード
--
create or replace function xorshift64_double(n numeric, seed bigint)
returns setof double precision as $$
declare
  x bigint := 88172645463325252 + seed;
  H7B0 constant bigint := x'01FFFFFFFFFFFFFF'::bigint;
  -- Postgres には符号なし整数がないので最上位ビットを捨てた正数の最大値で代用する。
  MAX_BIGINT constant numeric := x'7FFFFFFFFFFFFFFF'::bigint::numeric;
begin
  for i in 1 .. n loop
    x := x # (x << 13);
    x := x # ((x >> 7) & H7B0);
    x := x # (x << 17);
    return next (abs(x) / MAX_BIGINT)::double precision;
  end loop;
  return;
end;
$$ language plpgsql
;

-- 試行
select xorshift64_bigint(10, 1)
;
/*
  xorshift64_bigint   
----------------------
  8748534152403105265
  4193751004206715354
 -5408378583463445255
  1251377252218112960
  -589665183797930537
   124667262579121724
 -4323602128030638848
  3344362114786403770
 -7330413784229857423
 -5008461207087382689
(10 rows)
*/

select xorshift64_double(10, 1)
;
/*
 xorshift64_double  
--------------------
  0.948517973409908
  0.454687394962419
  0.586377580981514
  0.135674593545382
 0.0639316273312781
 0.0135164516926105
  0.468765882017377
  0.362596467042963
   0.79476505500797
  0.543018452153351
(10 rows)
*/

-- 後始末
drop function xorshift64_bigint;
drop function xorshift64_double;
