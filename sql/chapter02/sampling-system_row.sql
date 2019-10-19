--
-- system_rowsサンプリングメソッド
--


-- tsm_system_rows 拡張モジュールをロードする。
create extension tsm_system_rows;


-- 100万行のテーブル
drop table if exists data01;
create table data01(
    id serial primary key, 
    val NUMERIC
); 
insert into data01 select i, random() from generate_series(1, 1000000) as gs(i);

-- 処理時間計測
\timing

-- system_rowsサンプリングメソッドで1件の無作為抽出
-- 処理時間は試行によってばらつきがある。
select * from data01 tablesample system_rows(1);
-- Time: 0.512 ms

-- 10件の無作為抽出
-- 連続行が取得される
select *, ctid from data01 tablesample system_rows(4)
;
/*
   id   |        val        |   ctid   
--------+-------------------+----------
 976704 |  0.68525346647948 | (5282,1)
 976705 | 0.772242407314479 | (5282,2)
 976706 | 0.624257534276694 | (5282,3)
 976707 | 0.975382226053625 | (5282,4)
(4 rows)
*/

-- 後始末
\timing
drop table if exists data01;
drop extension tsm_system_rows;