--
-- パスワード生成
--

-- パスワードポリシーに合った文字列を生成する。
with
policy as (
  select
    -- パスワード文字数
    8 as min_len,
    -- 使用可能文字
    'abcdefghijklmnopqrstuvwxyz'  -- 英字子文字
    'ABCDEFGHIJKLMNOPQRSTUVWXYZ'  -- 英字大文字
    '0123456789'                  -- 数字
    '!#$%&@;/_'                   -- 記号
      as chset,
    -- パスワードポリシーの必須文字種の正規表現
    -- 英字の小文字と大文字、数字、記号が含まれること
    '{"[a-z]", "[A-Z]", "\\d", "[^\\w\\d]"}'::text[] as required
    -- array['[a-z]', '[A-Z]', '\d', '[^\w\d]'] as required
),
gen_ch as (
  -- ランダムに8個の文字を選択
  -- 重複もありうる
  select ceil(random() * length(chset))::int as ch
  from policy, generate_series(1, min_len)
),
gen_pass as (
  -- 文字列にまとめる
  select string_agg(substr(chset, ch, 1), '') as passwd from policy, gen_ch
),
test as (
  -- 必須文字種の正規表現にマッチするかテストする
  -- 正規表現の~演算子は、パターンの配列をall句でまとめてチェックしている
  select passwd from policy, gen_pass where passwd ~ all(required) limit 1
)
-- パスワードポリシーのテストで成功すると生成パスワードが出力される。
-- 失敗すると出力なし。本来はリトライもさせるべき。
select * from test
;
/*
  passwd  
----------
 Sc4abT$c
(1 row)
*/

