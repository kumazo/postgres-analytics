--
-- Pythonの乱数生成器（メルセンヌ・ツイスター）を使う
--

-- PL/Python をロードする
-- 環境によっては、plpython3uインストール作業が必要
create extension plpython3u;

-- 
-- メルセンヌ・ツイスター
-- Pythonのrandom.random()を呼び出すだけの関数
-- 
create or replace function mt_random() returns double precision 
as $$
  import random
  return random.random()
$$ language plpython3u;

-- 試行
select mt_random() from generate_series(1,10);
/*
     mt_random     
-------------------
 0.665907233535906
 0.194182593226989
 0.960270394683691
 0.354596097095044
 0.103940596330274
 0.757955746790278
 0.714482911077618
 0.619097893339312
 0.746828425021883
 0.438988467687745
(10 rows)
*/
-- 後始末
drop function mt_random;
drop extension plpython3u;