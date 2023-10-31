



update loader_name
   set sort_col = family||'.family.'||simple_name
 where coalesce(lower(rank),'x') != family
   and record_type in ('accepted', 'excluded')
   and loader_batch_id in (
    select id
      from loader_batch
 where use_sort_col_for_ordering
       );
