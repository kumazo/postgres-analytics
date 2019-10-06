--
-- ツリー構造による階層項番の採番 
--

-- 文書テーブル
-- 章節による階層構造を持つ
drop table if EXISTS doc;
create table doc (
  id serial,
  parent_id int, -- 親ノードのID
  title text,
  content text
);

-- ダミーデータを作成。
with
top as (
  insert into doc(parent_id, title, content) select NULL, '大項目' || i, '概要文'
  from generate_series(1,3) as gs(i)
  returning id
),
secondary as (
  insert into doc(parent_id, title, content) select p.id, '中項目' || i, '説明文'
  from top as p, generate_series(1,3) as gs(i)
  returning id
),
tertiary as (
  insert into doc(parent_id, title, content) select p.id, '小項目' || i, '詳細文'
  from secondary as p, generate_series(1,3) as gs(i)
  returning id
)
select null; -- 共通テーブル式は参照しなくても実行されるらしい

-- ダミーデータ内容確認
select * from doc;


-- 各行に階層的な項番を追加する
with recursive
nodes as (
  select
    -- 兄弟ノードで連番を振る。
    row_number() over (partition by parent_id order by id) as num,
    id, parent_id
  from doc
),
tree as (
  -- 階層的な項番を配列として保持し、再帰的に連結する。
  select array[n.num] as nums, n.* from nodes as n 
  where n.parent_id is null
  union all
  select t.nums || n.num as nums, n.*
  from tree as t inner join nodes as n on n.parent_id = t.id
)
select doc.id, array_to_string(tree.nums, '.') || '. ' as item_number, doc.title, doc.content
from tree inner join doc on tree.id = doc.id
order by item_number
;

-- 後始末
drop table if exists doc;