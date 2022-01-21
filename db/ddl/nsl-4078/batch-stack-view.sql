create view batch_stack_vw as 
select * 
from
(
select 'Loader Batch in stack' "display_as", id, name, name batch_name, description, created_at::date, created_at::date as "start", 'A batch ' || name as order_by
  from loader_batch
union
select 'Batch Review in stack' "display_as", br.id, br.name, lb.name batch_name, '' description, br.created_at::date, br.created_at::date,'A batch '|| lb.name || ' B review ' || br.name as order_by
  from batch_review br
  join loader_batch lb
    on br.loader_batch_id = lb.id
union
select 'Review Period in stack' "display_as", brp.id, brp.name, lb.name batch_name, '' description, brp.created_at::date, brp.start_date::date, 'A batch '|| lb.name || ' B review ' || br.name || ' C period ' || brp.start_date::date as order_by
  from batch_review_period brp
  join batch_review br
    on brp.batch_review_id = br.id
  join loader_batch lb
    on br.loader_batch_id = lb.id
union
select 'Batch Reviewer in stack' "display_as",
       brer.id,
       users.given_name || ' ' || users.family_name || ' for ' || org.abbrev as name,
       lb.name batch_name,
       '' description, 
       brp.created_at::date,
       brp.start_date::date,
       'A batch '|| lb.name || ' B review ' || br.name || ' C period ' || brp.start_date::date || ' ' || users.name as order_by
  from batch_reviewer brer
  join batch_review_period brp
    on brer.batch_review_period_id = brp.id
  join users 
    on brer.user_id = users.id
  join batch_review br
    on brp.batch_review_id = br.id
  join loader_batch lb
    on br.loader_batch_id = lb.id
  join org
    on brer.org_id = org.id
) fred
order by order_by
;
