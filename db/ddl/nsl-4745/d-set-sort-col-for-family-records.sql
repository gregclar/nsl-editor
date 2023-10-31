

update loader_name
   set sort_col = family || '.family'
 where lower(rank)     = 'family'
   and loader_batch_id in (
    select id
      from loader_batch
 where use_sort_col_for_ordering
       );
