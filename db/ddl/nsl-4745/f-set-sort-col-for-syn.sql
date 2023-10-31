


update loader_name
   set sort_col = (select family||'.'||'family'||'.'||simple_name||'.'||'a-synonym'||'.'||'user-to-set' from loader_name parent where parent.id = loader_name.parent_id)
 where parent_id is not null
   and record_type = 'synonym'
   and loader_batch_id in (
    select id
      from loader_batch
 where use_sort_col_for_ordering
       );
