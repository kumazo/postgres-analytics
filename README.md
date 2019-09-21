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

* **【資料】**
  * PostgreSQL 11.4文書  
  https://www.postgresql.jp/document/11/html/index.html
  * PostgreSQL: Documentation: 12: PostgreSQL 12beta4 Documentation  
  https://www.postgresql.org/docs/12/index.html
  * ISO IEC TR 19075   
  SQL Technical Report. Part 6: SQL support for JavaScript Object Notation (JSON)  
  http://standards.iso.org/ittf/PubliclyAvailableStandards/c067367_ISO_IEC_TR_19075-6_2017.zip

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




