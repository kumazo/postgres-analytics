--
-- 中心極限定理（Cental Limit Theorem）による正規分布乱数の生成
--

-- 中央極限定理による正規乱数
select
  sum(random()) - 6 from generate_series(1, 12)
;
/*
     ?column?      
-------------------
 0.416586356703192
(1 row)
*/

-- 
-- 中心極限定理により、一様乱数から正規分布乱数を得る
-- μ  期待値
-- σ2 分散
-- n  加算回数。省略可、デフォルト値12
-- 
create or replace function random_normal_clt(
  μ double precision, σ double precision, n int = 12)
returns double precision
as $$
  select (sum(random()) - n::double precision / 2) * σ * sqrt(12 / n) + μ 
  from generate_series(1, n)
$$ language sql;


-- 試行
select random_normal_clt(μ := 0, σ := 1)
;
random_normal_clt  
--------------------
 -0.186747404746711
(1 row)

-- 検証
with
norm as (
  select n, random_normal_clt(0, 1) as nd from generate_series(1,10000) as gs(n)
)
select n, nd as smpl, 
  avg(nd) over(order by n) as mean, 
  var_pop(nd) over (order by n) as variance
from norm 
;
/*
   n   |         smpl          |         mean          |      variance      
-------+-----------------------+-----------------------+--------------------
     1 |   0.00225733639672399 |   0.00225733639672399 |                  0
     2 |     0.376241584308445 |     0.189249460352585 |  0.034966054421524
     3 |     0.688958899118006 |     0.355819273274392 | 0.0788017081012944
     4 |    -0.915749351959676 |     0.037927116965875 |  0.362267550203406
     5 |    -0.598813301417977 |   -0.0894209667108953 |  0.354684177827308
     6 |   -0.0173277454450727 |   -0.0774054298332582 |  0.296292013821712
     7 |     -1.52739018853754 |    -0.284546109648155 |   0.51140815068082
     8 |      2.38853610726073 |    0.0495891674654558 |   1.22900681572825
     9 |      1.08287153579295 |     0.164398319501844 |   1.19789963400007
    10 |    -0.100818722974509 |     0.137876615254208 |   1.08444027776585
    11 |    0.0892921490594745 |     0.133459845600142 |  0.986049876510727
    12 |     0.176828844938427 |     0.137073928878332 |  0.904022731045525
    13 |      -1.0592424729839 |    0.0450495902735453 |  0.936104267712881
    14 |    0.0900415596552193 |    0.0482633023722363 |  0.869373940452854
    15 |     0.473756031598896 |    0.0766294843206803 |  0.822680641652648
    16 |    -0.051434432156384 |    0.0686254895408638 |  0.772224060535887
    17 |     -0.93527262378484 |   0.00957265934523414 |  0.782594903864304
    18 |      1.00870008626953 |     0.065079738618806 |   0.79149501864638
    19 |     0.129150575958192 |    0.0684518879524579 |  0.750042071126356
    20 |      -1.6422746386379 |     -0.01708443837706 |  0.851552766887084
    21 |       1.0301673929207 |     0.032784696446643 |   0.86074124729185
    22 |      -1.3056553248316 |   -0.0280534863387319 |  0.899343619319381
    23 |    -0.518849065061659 |   -0.0493924245440766 |  0.870259429069327
    24 |    -0.273472835775465 |   -0.0587291083453844 |  0.836003613806101
    25 |     0.882407989818603 |   -0.0210836244188249 |  0.836575848295413
    26 |     0.429560192860663 |  -0.00375116990807538 |  0.811910203614385
     :
  9990 |     -0.22032527718693 |  -0.00371587703375517 |   1.01969696859261
  9991 |    -0.942057594191283 |  -0.00380979573229961 |    1.0196830260525
  9992 |      1.01815163623542 |  -0.00370751776673038 |   1.01968548978531
  9993 |       -1.062228187453 |  -0.00381344398204973 |   1.01969556367636
  9994 |    -0.292551161255687 |  -0.00384233508844093 |   1.01960187401894
  9995 |      0.85994078591466 |  -0.00375591356557919 |      1.01957450481
  9996 |     0.447193776722997 |  -0.00371080055134464 |   1.01949284822483
  9997 |     0.260133394505829 |  -0.00368440821413776 |   1.01939783111446
  9998 |      -2.2628135276027 |  -0.00391036631769733 |   1.01980628841376
  9999 |     0.748395937494934 |  -0.00383512816350065 |   1.01976089406274
 10000 |    -0.839012901764363 |  -0.00391864594086073 |   1.01972866318947
(10000 rows)
*/

-- ヒストグラム
with
norm as (
  select n, random_normal_clt(0, 1) as nd from generate_series(1,10000) as gs(n)
),
hist as (
  select floor(nd*10)/10 as bin, count(nd) as cnt
  from norm group by bin order by bin
)
select bin,
  cnt::double precision / sum(cnt) over() as density,
  repeat('*',((cnt/sum(cnt) over())*1000)::int) as bar
from hist
;
/*
 bin  | density |                    bar                    
------+---------+-------------------------------------------
 -3.9 |  0.0001 | 
 -3.7 |  0.0001 | 
 -3.3 |  0.0001 | 
 -3.2 |  0.0001 | 
 -3.1 |  0.0003 | 
   -3 |  0.0009 | *
 -2.9 |  0.0007 | *
 -2.8 |  0.0007 | *
 -2.7 |  0.0009 | *
 -2.6 |  0.0011 | *
 -2.5 |  0.0015 | **
 -2.4 |  0.0032 | ***
 -2.3 |  0.0035 | ****
 -2.2 |  0.0045 | *****
 -2.1 |  0.0051 | *****
   -2 |  0.0062 | ******
 -1.9 |  0.0075 | ********
 -1.8 |  0.0096 | **********
 -1.7 |  0.0103 | **********
 -1.6 |  0.0125 | *************
 -1.5 |  0.0137 | **************
 -1.4 |  0.0169 | *****************
 -1.3 |  0.0198 | ********************
 -1.2 |  0.0226 | ***********************
 -1.1 |  0.0225 | ***********************
   -1 |  0.0255 | **************************
 -0.9 |  0.0268 | ***************************
 -0.8 |  0.0303 | ******************************
 -0.7 |  0.0323 | ********************************
 -0.6 |  0.0335 | **********************************
 -0.5 |  0.0405 | *****************************************
 -0.4 |  0.0379 | **************************************
 -0.3 |  0.0403 | ****************************************
 -0.2 |  0.0379 | **************************************
 -0.1 |  0.0381 | **************************************
    0 |  0.0403 | ****************************************
  0.1 |  0.0391 | ***************************************
  0.2 |  0.0407 | *****************************************
  0.3 |  0.0357 | ************************************
  0.4 |  0.0328 | *********************************
  0.5 |  0.0304 | ******************************
  0.6 |  0.0345 | ***********************************
  0.7 |  0.0328 | *********************************
  0.8 |  0.0266 | ***************************
  0.9 |  0.0229 | ***********************
    1 |  0.0232 | ***********************
  1.1 |  0.0217 | **********************
  1.2 |  0.0189 | *******************
  1.3 |  0.0155 | ****************
  1.4 |  0.0136 | **************
  1.5 |  0.0114 | ***********
  1.6 |  0.0111 | ***********
  1.7 |  0.0076 | ********
  1.8 |  0.0068 | *******
  1.9 |  0.0047 | *****
    2 |   0.004 | ****
  2.1 |  0.0045 | *****
  2.2 |  0.0028 | ***
  2.3 |  0.0026 | ***
  2.4 |  0.0019 | **
  2.5 |  0.0021 | **
  2.6 |  0.0008 | *
  2.7 |  0.0008 | *
  2.8 |  0.0006 | *
  2.9 |  0.0006 | *
    3 |  0.0008 | *
  3.1 |  0.0004 | 
  3.2 |  0.0001 | 
  3.3 |  0.0001 | 
  3.8 |  0.0001 | 
(70 rows)
*/

-- 後始末
drop function if exists random_normal_clt;



