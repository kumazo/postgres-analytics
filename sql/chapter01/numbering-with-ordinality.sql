--
-- テーブル関数のWITH ORDIALITY句と対合（zip）
--


-- WITH ORDINARITY句による連番

with
words as (
  -- 文字列の配列
  select array['Apple','Banana','Cherry','Durian'] as arr
)
select no, word from words, unnest(words.arr) with ordinality as a(word, no)
;
/*
 no |  word  
----+--------
  1 | Apple
  2 | Banana
  3 | Cherry
  4 | Durian
(4 rows)
*/


-- SELECTリストでのテーブル関数の対合

select
  generate_series(1, 4) as no,
  'くだもの' as category,
  unnest('{Apple, Banana, Cherry, Durian}'::text[]) as en,
  unnest('{リンゴ, バナナ, サクランボ, ドリアン}'::text[]) as ja
;
 no | category |   en   |     ja     
----+----------+--------+------------
  1 | くだもの | Apple  | リンゴ
  2 | くだもの | Banana | バナナ
  3 | くだもの | Cherry | サクランボ
  4 | くだもの | Durian | ドリアン
(4 rows)



-- ROWS FROM 構文を使う

create table words(lang, word) as values
  ('en', 'Apple'),  ('ja', 'リンゴ'),
  ('en', 'Banana'), ('ja', 'バナナ'),
  ('en', 'Cherry'), ('ja', 'サクランボ'),
  ('en', 'Durian'), ('ja', 'ドリアン');

select * from words
;
/*
 lang |    word    
------+------------
 en   | Apple
 ja   | リンゴ
 en   | Banana
 ja   | バナナ
 en   | Cherry
 ja   | サクランボ
 en   | Durian
 ja   | ドリアン
(8 rows)
*/
with
j(w) as (
    select array_agg(word) from words where lang = 'ja' group by lang
),
e(w) as (
    select array_agg(word) from words where lang = 'en' group by lang
)
select no, en, ja
from e, j, 
  rows from(unnest(e.w), unnest(j.w))
    with ordinality as dic(en, ja, no)
;
/*
 no |   en   |     ja     
----+--------+------------
  1 | Apple  | リンゴ
  2 | Banana | バナナ
  3 | Cherry | サクランボ
  4 | Dorian | ドリアン
(4 rows)
*/