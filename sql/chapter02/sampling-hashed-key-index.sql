--
-- Hash インデックスによる分割抽出
--

drop table if exists data01;
create table data01(
    id serial primary key, 
    val text -- パフォーマンス比較用
); 
insert into data01 select i, random()::text || random()::text from generate_series(1, 1000000) as gs(i);

\timing

-- id のハッシュのインデックスを作成する。
-- hash アルゴリズムのインデックスという意味ではない。
-- キー(id) の MD5 でインデックスを作成するということ。
create index data01_id_md5_idx on data01(md5(id::text));

-- キーのMD5順でページネーションしてみる。
-- ハッシュされたキーはランダムな順序付けとみなせるはず。
select * from data01 order by md5(id::text) offset 500000 limit 1000;
-- Time: 473.841 ms

-- ちょっと重いかも。
-- LIMIT の代わりに FETCH を使っても効果は感じられない。 
select * from data01 order by md5(id::text) offset 500000 rows fetch next 1000 rows only;
-- Time: 448.903 ms


-- コストになっているのは、インデックスキーが大きい（32バイト文字列）のと、検索時のMD5の計算の両方か。
-- 工夫の余地がありそう。
select * from data01 order by id offset 500000 limit 1000;
-- Time: 48.957 ms
create index data01_val_idx on data01(val);
select * from data01 order by val offset 500000 limit 1000;
-- Time: 267.054 ms
select *, md5(id::text) from data01 order by id offset 500000 limit 1000;
-- Time: 239.781 ms

-- OFFSET/LIMITは固定値を指定する必要がある。

-- 後始末
drop table if exists data01;
