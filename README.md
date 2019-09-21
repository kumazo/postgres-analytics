# PostgreSQL のためのデータ分析プログラミング

![象のコックさん](./img/elephant-cook.png)


[サポートページ](http://kumazo.github.io/postgres-analytics/) 


## ■ 改版履歴

* 2019-09-22 0.2版（印刷書籍）  
技術書典7 にて領布。

## ■ 訂正

### 【0.2版】

* p27-p28 　
「元号年」のサンプルコードにおいて、「令和元年」が「令和1年」と出力されてしまいます。
同ソースコードのユーザ定義関数（jp_era）を以下のSQLに訂正します。

```sql
create or replace function ja_era(d date) returns text
as $$
  with
  era(name, period) as (
    values
      ('明治', '[1868-10-23, 1912-07-29]'::daterange),
      ('大正', '[1912-07-30, 1926-12-24]'),
      ('昭和', '[1926-12-25, 1989-01-07]'),
      ('平成', '[1989-01-08, 2019-04-30]'),
      ('令和', '[2019-05-01,]')
  ),
  y as (
    select name, date_part('year', d) - date_part('year', lower(period)) + 1 as nen
    from era where period @> d
  )
  select name || case when nen = 1 then '元' else nen::text end || '年' from y;
$$ language sql;
```

## ■ ソースコード

 **《準備中》**

## ■ 参考文献

本書 0.2版では、時間的制約のため参考とさせていただいた書籍、サイト、資料等の一覧を掲載することができませんでした。

まだ、未整理ですが、ここに一部を紹介させていただきます。

* **【資料】**
  * PostgreSQL 11.4文書  
  https://www.postgresql.jp/document/11/html/index.html
  * PostgreSQL: Documentation: 12: PostgreSQL 12beta4 Documentation  
  https://www.postgresql.org/docs/12/index.html
  * ISO IEC TR 19075   
  SQL Technical Report. Part 6: SQL support for JavaScript Object Notation (JSON)  
  http://standards.iso.org/ittf/PubliclyAvailableStandards/c067367_ISO_IEC_TR_19075-6_2017.zip
  * 国民の祝日について - 内閣府  
  https://www8.cao.go.jp/chosei/shukujitsu/gaiyou.html?PHPSESSID=013ef321a0aea2e19e3937010efdf4e3
* **【書籍】**
  * 『データサイエンスのための統計学入門 ――予測、分類、統計モデリング、統計的機械学習とRプログラミング』 Peter Bruce、Andrew Bruce 著、黒川 利明　訳、大橋 真也　技術監修、O'Reilly Japan, Inc.  
  https://www.oreilly.co.jp/books/9784873118284/
  * 『プログラマのためのSQL 第4版 すべてを知り尽くしたいあなたに』 ジョー・セルコ 著、ミック 監訳、翔泳社  
  https://www.shoeisha.co.jp/book/detail/9784798128023
  * 『データ集計・分析のためのSQL入門』　株式会社ALBERT 他 著、マイナビ  
  https://book.mynavi.jp/ec/products/detail/id=28392
  * 『ビッグデータ分析・活用のためのSQLレシピ』　加嵜長門、田宮直人 著、マイナビ  
  https://book.mynavi.jp/ec/products/detail/id=65863
  * 『前処理大全［データ分析のためのSQL/R/Python実践テクニック］』本橋智光 著、株式会社ホクソエム　監修、技術評論社  
  https://gihyo.jp/book/2018/978-4-7741-9647-3

* **【参考】**
  * Mersenne Twister: A random number generator (since 1997/10)   
  http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/mt.html
  * Google Chromeが採用した、擬似乱数生成アルゴリズム「xorshift」の数理 – びりあるの研究ノート  
  https://blog.visvirial.com/articles/575
  * パレート分布 - Wikipedia  
  https://ja.wikipedia.org/wiki/%E3%83%91%E3%83%AC%E3%83%BC%E3%83%88%E5%88%86%E5%B8%83
  * 逆関数法 - Wikipedia  
  https://ja.wikipedia.org/wiki/%E9%80%86%E9%96%A2%E6%95%B0%E6%B3%95
  * ボックス＝ミュラー法 - Wikipedia  
  https://ja.wikipedia.org/wiki/%E3%83%9C%E3%83%83%E3%82%AF%E3%82%B9%EF%BC%9D%E3%83%9F%E3%83%A5%E3%83%A9%E3%83%BC%E6%B3%95
  * 国民の祝日 - Wikipedia  
  https://ja.wikipedia.org/wiki/%E5%9B%BD%E6%B0%91%E3%81%AE%E7%A5%9D%E6%97%A5
  * 春分・秋分点通過日時の計算 真木のホームページ  
  http://park12.wakwak.com/~maki/equinox21.htm
  * PostgreSQL 9.5のTABLESAMPLE句 - Qiita  
  https://qiita.com/sawada_masahiko/items/80ec96f3c19e8fcf3b23
  * Linuxコマンドをfile_fdwの入力として使う。 - Qiita  
  https://qiita.com/nuko_yokohama/items/1044020576d3f5affb53



