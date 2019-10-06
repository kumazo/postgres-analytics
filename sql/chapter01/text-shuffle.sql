--
-- テキストの文字をシャッフルする
--


-- 文字分解
with
txt as (
  select 'あいうえお' as str
)
select
  regexp_split_to_table(str, '')
from txt
;
/*
 regexp_split_to_table 
-----------------------
 あ
 い
 う
 え
 お
(5 rows)
*/

-- 文字結合
with
chars(ch) as (
  values
    ('あ'),
    ('か'),
    ('さ'),
    ('た'),
    ('な')
)
select string_agg(ch, '') from chars
;
/*
 string_agg 
------------
 あかさたな
(1 row)
*/

-- 集約関数のORDER BY句
with
chars(ch) as (
  values
    ('な'),
    ('た'),
    ('さ'),
    ('か'),
    ('あ')
)
select string_agg(ch, '' order by ch) from chars  
;
/*
 string_agg 
------------
 あかさたな
(1 row)
*/

-- 指定の文字列の文字をランダムに並べ替える関数
create or replace function shuffle(str text) returns text
as $$
  select string_agg(ch, '' order by random()) from regexp_split_to_table(str, '') as ch(ch);
$$ language sql;

-- 使用例
select shuffle('ひでぶ！あべし！ぐわし！さばら！') || '！';
/*
              ?column?              
------------------------------------
 ！あぐし！でぶわ！ばべしさ！らひ！
(1 row)
*/
 

-- 後始末
drop function if exists shuffle;