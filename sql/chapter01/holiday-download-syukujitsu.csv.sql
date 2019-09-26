--
-- HTTP 経由で内閣府の祝祭日CSVを取り込む。
--

-- file_fdw モジュールを有効にする。
-- PostgreSQL に同梱されているモジュールなのでインストールは不要のはず。
create extension file_fdw;

-- fs という名前で外部データラッパーを作成
create server fs foreign data wrapper file_fdw;

-- syukujitsu テーブル定義
-- wget でCSVを取得し標準出力をロードする。
-- Docker公式のpostgresイメージ（debianベース）にはwgetがインストールされていないようなので
-- agt-get でインストールするか、代わりに curl を使う。
create foreign table syukujitsu (holiday date, name text) server fs
options(
  program 'wget -O - https://www8.cao.go.jp/chosei/shukujitsu/syukujitsu.csv',
  format 'csv', header 'true', encoding 'sjis');

-- 外部テーブルにクエリを投げると、内閣府へリクエストを投げて祝日データを取得する
select * from syukujitsu where date_part('year', holiday) = '2019';
/*
  holiday   |           name           
------------+--------------------------
 2019-01-01 | 元日
 2019-01-14 | 成人の日
 2019-02-11 | 建国記念の日
 2019-03-21 | 春分の日
 2019-04-29 | 昭和の日
 2019-04-30 | 休日
 2019-05-01 | 休日（祝日扱い）
 2019-05-02 | 休日
 2019-05-03 | 憲法記念日
 2019-05-04 | みどりの日
 2019-05-05 | こどもの日
 2019-05-06 | 休日
 2019-07-15 | 海の日
 2019-08-11 | 山の日
 2019-08-12 | 休日
 2019-09-16 | 敬老の日
 2019-09-23 | 秋分の日
 2019-10-14 | 体育の日（スポーツの日）
 2019-10-22 | 休日（祝日扱い）
 2019-11-03 | 文化の日
 2019-11-04 | 休日
 2019-11-23 | 勤労感謝の日
(22 rows)

Time: 135.372 ms　　-- 当然遅い
*/

-- 外部テーブルをマテビューに固める。
create materialized view jp_holidays as select * from syukujitsu;

-- リクエストは飛ばない。
select * from jp_holidays;
-- Time: 1.899 ms  -- 当然速い。

-- その代わり年1でリフレッシュが必要。
refresh materialized view jp_holidays;

-- 後片付け
drop materialized view if exists jp_holidays cascade;
drop foreign table if exists syukujitsu cascade;
drop server if exists fs cascade;
drop extension if exists file_fdw;


