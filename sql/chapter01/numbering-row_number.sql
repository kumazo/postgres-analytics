--
-- 行番号
--

-- row_nubmer関数を使う

-- サンプルデータ
-- id の順序がバラバラで格納されてる状態。
drop table if exists data01;
create table data01(id, name) as 
  values
    (101, 'aaa'),
    (103, 'bbb'),
    (105, 'ccc'),
    (104, 'ddd'),
    (102, 'eee');

-- row_number で行番号を振り出してみる。
-- rn は出力の行番号のように見える。
select *, row_number() over() as rn from data01
;
 id  | name | rn 
-----+------+----
 101 | aaa  |  1
 103 | bbb  |  2
 105 | ccc  |  3
 104 | ddd  |  4
 102 | eee  |  5
(5 rows)

-- しかし id でソートすると、rn は崩れてしまう。
-- rn は GROUP BY 句によるソート前の順序で採番されている。
select *, row_number() over() as rn from data01 order by id -- id でソート
;
 id  | name | rn 
-----+------+----
 101 | aaa  |  1
 102 | eee  |  5
 103 | bbb  |  2
 104 | ddd  |  4
 105 | ccc  |  3
(5 rows)

-- row_number の OVER 句でも id 順を指定すれば、id ソートと順序が一致するようになる。
select *, row_number() over(order by id) as rn from data01 order by id
;
 id  | name | rn 
-----+------+----
 101 | aaa  |  1
 102 | eee  |  2
 103 | bbb  |  3
 104 | ddd  |  4
 105 | ccc  |  5
(5 rows)

-- 試しに name 順で並べ替えても rn は id に追従している
select *, row_number() over(order by id) rn from data01 order by name
;
 id  | name | rn 
-----+------+----
 101 | aaa  |  1
 103 | bbb  |  3
 105 | ccc  |  5
 104 | ddd  |  4
 102 | eee  |  2
(5 rows)

-- OVER句の ORDER BY は実際に行をソートする効果をもつ。
-- 最後に呼ばれたOVER句の順序になる。
select *, row_number() over(order by id) rn, row_number() over(order by name desc) rn2 from data01
;
 id  | name | rn | rn2 
-----+------+----+-----
 102 | eee  |  2 |   1
 104 | ddd  |  4 |   2
 105 | ccc  |  5 |   3
 103 | bbb  |  3 |   4
 101 | aaa  |  1 |   5
(5 rows)


-- では SELECT 文の ORDER BY と OVER句の ORDER BY を矛盾させるとどうなるか
select *, row_number() over(order by id desc) rn from data01 order by id
;
 id  | name | rn 
-----+------+----
 101 | aaa  |  5
 102 | eee  |  4
 103 | bbb  |  3
 104 | ddd  |  2
 105 | ccc  |  1
(5 rows)
-- SELECT 文の ORDER BY が勝つ
-- 確実に行番号の並びとするにはこちらに ORDER BY を書いたほうがいい。 


-- 後始末
drop table if exists data01;