\d+ nrc
drop view nrc;
create view nrc as select * from name_review_comment;
select context, count(*) from nrc group by context;
select context, t.name from nrc join nrct on nrc.name_review_comment_type_id = nrct.id ;
\dv
create view nrct as select * from name_review_comment_type;
select context, t.name from nrc join nrct on nrc.name_review_comment_type_id = nrct.id ;
select context, nrct.name from nrc join nrct on nrc.name_review_comment_type_id = nrct.id ;
\d name_review_comment
select context, nrct.name from nrc join nrct on nrc.name_review_comment_type_id = nrct.id join loader_name n on nrc.loader_name_id = n.id ;
select context, nrct.name, n.record_type from nrc join nrct on nrc.name_review_comment_type_id = nrct.id join loader_name n on nrc.loader_name_id = n.id ;
select nrc.id, context, nrct.name, n.record_type from nrc join nrct on nrc.name_review_comment_type_id = nrct.id join loader_name n on nrc.loader_name_id = n.id ;
update name_review_comment set context = 'loader-name' where context = 'unknown';
select nrc.id, context, nrct.name, n.record_type, comment from nrc join nrct on nrc.name_review_comment_type_id = nrct.id join loader_name n on nrc.loader_name_id = n.id ;
select nrc.id, context, nrct.name, n.record_type, nrc.comment from nrc join nrct on nrc.name_review_comment_type_id = nrct.id join loader_name n on nrc.loader_name_id = n.id ;
\x
select nrc.id, context, nrct.name, n.record_type, nrc.comment from nrc join nrct on nrc.name_review_comment_type_id = nrct.id join loader_name n on nrc.loader_name_id = n.id ;
\q
\d name_review_comment
alter table name_review_comment add context varchar(30) not null default 'unknown' check (context ~ 'loader-name|distribution|concept-note|unknown');
\q
\d name_review_comment
alter table name_review_comment add context varchar(30) not null default 'unknown' check (context ~ 'loader-name|distribution|concept-note|unknown');
\q
\q
select * from name_review_comment_type 
;
\i deprecate_bad_review_comment_types.sql 
select * from name_review_comment_type 
;
\q
select * from name_review_comment_type 
;
\i deprecate_bad_review_comment_types.sql 
select * from name_review_comment_type 
;
\q
\d batch_reviewer
\q
\d batch_reviewer
:q
\q
desc dba_users
;
\q
\df
\x
\df
\df fn*
\q
\df fn*
\q
vacuum full verbose analyze;
\q
\dt
\dt batch_review_period
\d batch_review_period
\d loader_name
\q
alter database nsl_dev rename to nsl_dev_retired_jan_17_2022;
alter database apni_test_jan rename to nsl_dev;
\q
select * from loader_batch;
\dv
\dt
\dv
select b.name from loader_batch;
select b.name from loader_batch b;
select b.name from loader_batch b join batch_review r on b.id = r.loader_batch.id;
select b.name from loader_batch lb join batch_review br on lb.id = br.loader_batch.id;
select b.name from loader_batch lb join batch_review as br on lb.id = br.loader_batch.id;
select b.name from loader_batch lb join batch_review br on lb.id = br.loader_batch_id;
select lb.name from loader_batch lb join batch_review br on lb.id = br.loader_batch_id;
select lb.name, count(*) from loader_batch lb join batch_review br on lb.id = br.loader_batch_id;
select lb.name, count(*) from loader_batch lb join batch_review br on lb.id = br.loader_batch_id group by lb.name;
select lb.name, count(*) from loader_batch lb join batch_review br on lb.id = br.loader_batch_id join batch_review_period brp on br.id = brp.batch_review_id group by lb.name;
select lb.name from loader_batch lb join batch_review br on lb.id = br.loader_batch_id join batch_review_period brp on br.id = brp.batch_review_id ;
select lb.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id join batch_review_period brp on br.id = brp.batch_review_id ;
select lb.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id ;
select lb.name, br.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id ;
select lb.name, br.name, brp.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id ;
select lb.name, br.name, brp.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id left outer join batch_reviewer brer on brp.id = brer.batch_review_period.id;
select lb.name, br.name, brp.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id left outer join batch_reviewer brer on brp.id = brer.batch_review_period_id;
select lb.name, br.name, brp.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id left outer join batch_reviewer brer on brp.id = brer.batch_review_period_id;
select lb.name, br.name, brp.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id left outer join batch_reviewer brer on brp.id = brer.batch_review_period_id;
\q
select lb.name, br.name, brp.name from loader_batch lb left outer join batch_review br on lb.id = br.loader_batch_id left outer join batch_review_period brp on br.id = brp.batch_review_id left outer join batch_reviewer brer on brp.id = brer.batch_review_period_id;
select name from loader_batch where loader_batch.name = 'List 100';
select 'batch', name from loader_batch where loader_batch.name = 'List 100';
select 'batch' "type", name from loader_batch where loader_batch.name = 'List 100';
select 'batch' "type", name from loader_batch where loader_batch.name = 'List 100'
union
select 'review' "type", name from batch_review br join loader_batch lb on br.loader_batch_id = lb.id where lb.name = 'List 100'
;
select 'batch' "type", name from loader_batch where loader_batch.name = 'List 100'
union
select 'review' "type", br.name from batch_review br join loader_batch lb on br.loader_batch_id = lb.id where lb.name = 'List 100'
;
\w nested-stack.sql
\d batch_reviewer
\i nested-stack.sql
\d brer
\i nested-stack.sql
k
;
\i nested-stack.sql
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
select name from loader_batch;
\i nested-stack.sql 
select * from name where id = 51623666;
select * from loader_name where id = 51623666;
select * from name where simple_name = 'Taraxacum sect. Hamata H.Øllg';
select * from name where full_name = 'Taraxacum sect. Hamata H.Øllg';
select simple_name, full_name from loader_name limit 5;
select simple_name, full_name from loader_name limit 50;
select simple_name, full_name from loader_name where loader_batch_id = (select id from loader_batch where name like 'APC%' limit 50;
);
select simple_name, full_name from loader_name where loader_batch_id = (select id from loader_batch where name like 'APC%') limit 50;
;
select simple_name, full_name, rank from loader_name where loader_batch_id = (select id from loader_batch where name like 'APC%') limit 50;
;
\d loader_name
select simple_name, full_name from loader_name where id = 51623696;
select simple_name, full_name from loader_name ln left outer join name on ln.simple_name = name.simple_name where ln.id = 51623696;
select ln.simple_name, ln.full_name from loader_name ln left outer join name on ln.simple_name = name.simple_name where ln.id = 51623696;
select ln.simple_name, ln.full_name, name.simple_name, name.id from loader_name ln left outer join name on ln.simple_name = name.simple_name where ln.id = 51623696;
select ln.simple_name, ln.full_name, name.simple_name, name.id from loader_name ln left outer join name on ln.simple_name = name.simple_name where ln.id = 51623696 or name.id = 191169;
select name.simple_name, name.id from name where name.id = 191169;
select ln.simple_name, ln.full_name from loader_name where ln.id = 51623696;
select ln.simple_name, ln.full_name from loader_name ln where ln.id = 51623696;
\q
\d loader_name
select count(*) from loader_name where simple_name like '%x%';
select count(*) from loader_name where simple_name like '%x%';
select count(*) from loader_name where simple_name like '%×%';
begin;
select count(*) from loader_name where alt_name_for_matching is not null;
update loader_name set alt_name_for_matching = replace(simple_name,'×','x') where simple_name like '%×%';
\w set_alt_name_to_x_for_multiplication_sign.sql
select count(*) from loader_name where alt_name_for_matching is not null;
commit;
begin;
update loader_name set alt_name_for_matching = null where alt_name_for_matching is not null;
commit;
begin;
update loader_name set alt_name_for_matching = replace(simple_name,'×','x') where simple_name like '%×%' and loader_batch_id = (select id from loader_batch where name = 'APC List 103';
);
rollback;
begin;
update loader_name set alt_name_for_matching = replace(simple_name,'×','x') where simple_name like '%×%' and loader_batch_id = (select id from loader_batch where name = 'APC List 103');
\w set_alt_name_to_x_for_multiplication_sign.sql
commit;
\q
select count(*) from loader_name where alt_name_for_matching is not null;
begin;
\i set_alt_name_to_x_for_multiplication_sign.sql 
select count(*) from loader_name where alt_name_for_matching is not null;
commit;
\q
\d loader_name
\q
select count(*) from loader_name where alt_name_for_matching is not null;
begin;
\i set_alt_name_to_x_for_multiplication_sign.sql 
select count(*) from loader_name where alt_name_for_matching is not null;
commit;
\q
elect * from loader_name where simple_name like 'GEN%';
select * from loader_name where simple_name like 'GEN%';
\q
insert into users (name, given_name,family_name) values ('gclarke','Greg','Clarke');
\q
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
select now()::date;
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\d brer
\d batch_reviewer
\d users
\d users
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i nested-stack.sql 
\i batch-stack-view.sql 
drop view batch_stack_vw;
\i batch-stack-view.sql 
select * from batch_stack_vw;
select * from batch_stack_vw order by order_by;
\d batch_stack_vw
drop view batch_stack_vw;
\i batch-stack-view.sql 
drop view batch_stack_vw;
\i batch-stack-view.sql 
\d users
\! pwd
insert into users (name, given_name,family_name) values ('gclarke', 'Greg', 'Clarke');
drop view batch_stack_vw;
\i batch-stack-view.sql 
drop view batch_stack_vw;
\i batch-stack-view.sql 
\dt
\q
\d name_review_comment
\q
\d name_review_comment
\q
\i add-context-to-name-review-comment.sql 
\q
\d name_review_comment
\q
\d batch_stack
\dv
\d batch_stack_vw
\q
view batch_stack_vw;
\i batch-stack-view.sql 
dropew batch_stack_vw; 
drop view  batch_stack_vw; 
 \i batch-stack-view.sql
drop view  batch_stack_vw; 
 \i batch-stack-view.sql
drop view  batch_stack_vw; 
 \i batch-stack-view.sql
select * from name where simple_name = 'Blechnum parrisiae Christenh. – Blechnum rupestre (Kaulf. ex Link) Christenh.' or full_name like 'Blechnum parrisiae Christenh. – Blechnum rupestre (Kaulf. ex Link) Christenh.';
select * from name where simple_name like 'Blechnum parrisiae Christenh. % Blechnum rupestre (Kaulf. ex Link) Christenh.' or full_name like 'Blechnum parrisiae Christenh. % Blechnum rupestre (Kaulf. ex Link) Christenh.';
\q
select * from name where simple_name = 'Blechnum parrisiae Christenh. – Blechnum rupestre (Kaulf. ex Link) Christenh.' or full_name like 'Blechnum parrisiae Christenh. – Blechnum rupestre (Kaulf. ex Link) Christenh.';
select * from name where f_unaccent(simple_name) = f_unaccent('Blechnum parrisiae Christenh. – Blechnum rupestre (Kaulf. ex Link) Christenh.') or f_unaccent(full_name) like f_unaccent('Blechnum parrisiae Christenh. – Blechnum rupestre (Kaulf. ex Link) Christenh.');
\q
\d loader_name
\d name
\di
\d name
\d name_lower_unacent_full_name_gin_trgm
\d+ name_lower_unacent_full_name_gin_trgm
\d loader_name
create index simple_name_ndx on loader_name using btree (simple_name);
\timing
drop index simple_name_ndx;
select id from loader_name where simple_name like 'Blechnum parrisiae%';
select id from loader_name where simple_name like 'Blechnum parrisiae%' or full_name like 'Blechnum parrisiae%';
create index simple_name_ndx on loader_name using btree (simple_name);
select id from loader_name where simple_name like 'Blechnum parrisiae%';
select id from loader_name where simple_name like 'Blechnum parrisiae%' or full_name like 'Blechnum parrisiae%';
select id from loader_name where simple_name like 'Blechnum parrisiae%' or full_name like 'Blechnum parrisiae%';
select id from loader_name where f_unaccent(simple_name) like f_unaccent('Blechnum parrisiae%') or full_name like 'Blechnum parrisiae%';
select id from loader_name where f_unaccent(simple_name) like f_unaccent('Blechnum parrisiae%') or f_unaccent(full_name) like f_unaccent('Blechnum parrisiae%');
create index simple_name_ndx on loader_name using btree (simple_name);
drop index simple_name_ndx;
select id from loader_name where f_unaccent(simple_name) like f_unaccent('Blechnum parrisiae%') or f_unaccent(full_name) like f_unaccent('Blechnum parrisiae%');
create index simple_name_ndx on loader_name using btree (f_unaccent(simple_name));
select id from loader_name where f_unaccent(simple_name) like f_unaccent('Blechnum parrisiae%') or f_unaccent(full_name) like f_unaccent('Blechnum parrisiae%');
select id from loader_name where f_unaccent(simple_name) like f_unaccent('Blechnum parrisiae%') ;
drop index simple_name_ndx;
select id from loader_name where f_unaccent(full_name) like f_unaccent('Blechnum parrisiae%') ;
create index simple_name_unaccent_ndx on loader_name using btree (f_unaccent(simple_name));
select id from loader_name where f_unaccent(simple_name) like f_unaccent('Blechnum parrisiae%') ;
\d name
SELECT COUNT(*) FROM (SELECT 1 AS one FROM "loader_name" WHERE (1=1) AND ((lower(simple_name) like 'blechnum%')
        or exists (
        select null
          from loader_name parent
        where parent.id         = loader_name.parent_id
       and lower(parent.simple_name) like 'blechnum%')
        or exists (
        select null
          from loader_name child
        where child.parent_id   = loader_name.id
       and lower(child.simple_name) like 'blechnum%')
        or exists (
        select null
          from loader_name sibling
        where sibling.parent_id = loader_name.parent_id
       and lower(sibling.simple_name) like 'blechnum%')) AND (not exists (
        select null
          from name
        where (f_unaccent(loader_name.simple_name)          = f_unaccent(name.simple_name)
            or f_unaccent(loader_name.alt_name_for_matching) = f_unaccent(name.simple_name)
            or f_unaccent(loader_name.simple_name)           = f_unaccent(name.full_name)
            or f_unaccent(loader_name.alt_name_for_matching) = f_unaccent(name.full_name))
          and exists (
            select null
              from name_type nt
            where name.name_type_id = nt.id
              and nt.scientific))) AND (loader_batch_id = (select id from loader_batch where lower(name) = 'apc list 103')  ) ORDER BY seq LIMIT 20) subquery_for_count;
drop index simple_name_ndx;
\d loader_name
drop index simple_name_unaccent_ndx;
drop index xsimple_name_unaccent_ndx;
drop index simple_name_unaccent_ndx;
\q
\d loader_name
drop index simple_name_unaccent_ndx;
create index lower_simple_name_unaccent_ndx on loader_name using btree (lower(f_unaccent(simple_name)));
\! pwd
\w create-index-lower-simple-name-unaccent-ndx.sql
\! cat create-index-lower*
SELECT COUNT(*) FROM (SELECT 1 AS one FROM "loader_name" WHERE (1=1) AND ((lower(simple_name) like 'blechnum%')
        or exists (
        select null
          from loader_name parent
        where parent.id         = loader_name.parent_id
       and lower(parent.simple_name) like 'blechnum%')
        or exists (
        select null
          from loader_name child
        where child.parent_id   = loader_name.id
       and lower(child.simple_name) like 'blechnum%')
        or exists (
        select null
          from loader_name sibling
        where sibling.parent_id = loader_name.parent_id
       and lower(sibling.simple_name) like 'blechnum%')) AND (not exists (
        select null
          from name
        where (f_unaccent(loader_name.simple_name)          = f_unaccent(name.simple_name)
            or f_unaccent(loader_name.alt_name_for_matching) = f_unaccent(name.simple_name)
            or f_unaccent(loader_name.simple_name)           = f_unaccent(name.full_name)
            or f_unaccent(loader_name.alt_name_for_matching) = f_unaccent(name.full_name))
          and exists (
            select null
              from name_type nt
            where name.name_type_id = nt.id
              and nt.scientific))) AND (loader_batch_id = (select id from loader_batch where lower(name) = 'apc list 103')  ) ORDER BY seq LIMIT 20) subquery_for_count;
\w trial-select.sql
\i trial-select.sql
\timing
\i trial-select.sql
create index lower_unaccent_alt_name_for_matching_ndx on loader_name using btree (lower(f_unaccent(alt_name_for_matching)));
\w create-lower-unaccent-alt-name-for-matching-ndx.sql
\i trial-select.sql
\i trial-select.sql
\i trial-select.sql
\i trial-select.sql
\i trial-select.sql
\i trial-select.sql
\q
select count(*) from name;
select count(*) from name where name_rank_id = (select id from name_rank r where r.name = 'species');
select count(*) from name where name_rank_id = (select id from name_rank r where r.name = 'Species');
select count(*) from name join name parent on name.parent_id = parent.id  where name_rank_id = (select id from name_rank r where r.name = 'Species');
select count(*) from name join name parent on name.parent_id = parent.id  where name.name_rank_id = (select id from name_rank r where r.name = 'Species');
select count(*) from name join name parent on name.parent_id = parent.id  where name.name_rank_id = (select id from name_rank r where r.name = 'Species') and name.simple_name not like parent.simple_name || '%';
select name.id, name.simple_name from name join name parent on name.parent_id = parent.id  where name.name_rank_id = (select id from name_rank r where r.name = 'Species') and name.simple_name not like parent.simple_name || '%';
select name.id, name.simple_name, parent.id, parent.simple_name from name join name parent on name.parent_id = parent.id  where name.name_rank_id = (select id from name_rank r where r.name = 'Species') and name.simple_name not like parent.simple_name || '%';
select parent.id, parent.simple_name, name.id, name.simple_name from name join name parent on name.parent_id = parent.id  where name.name_rank_id = (select id from name_rank r where r.name = 'Species') and name.simple_name not like parent.simple_name || '%';
select parent.id, parent.simple_name, name.id, name.simple_name from name join name parent on name.parent_id = parent.id  where parent.name_rank_id = (select id from name_rank r where r.name = 'Genus') and name.simple_name not like parent.simple_name || '%';
select parent.id, parent.simple_name, name.id, name.rank, name.simple_name from name join name parent on name.parent_id = parent.id  where parent.name_rank_id = (select id from name_rank r where r.name = 'Genus') and name.simple_name not like parent.simple_name || '%';
select parent.id, parent.simple_name, name.id, name.simple_name from name join name parent on name.parent_id = parent.id  where parent.name_rank_id = (select id from name_rank r where r.name = 'Genus') and name.simple_name not like parent.simple_name || '%';
\q
select parent.id, parent.simple_name, name.id, name.simple_name from name join name parent on name.parent_id = parent.id  where parent.name_rank_id = (select id from name_rank r where r.name = 'Genus') and name.simple_name not like parent.simple_name || '%';
\i trial-select.sql 
\timing
\i trial-select.sql 
\i trial-select2.sql 
\i trial-select2.sql 
\i trial-select2.sql 
\i trial-select2.sql 
\i trial-select2.sql 
\i trial-select2.sql 
\i trial-select2.sql 
\i trial-select2.sql 
drop index lower_simple_name_unaccent_ndx;
\d loader_name
\i create-index-lower-simple-name-unaccent-ndx.sql 
\i trial-select.sql 
\d loader_name
drop index lower_simple_name_unaccent_ndx'
';
drop index lower_simple_name_unaccent_ndx;
\i create-index-lower-simple-name-unaccent-ndx.sql 
\d loader_name
\i trial-select.sql 
\i trial-select.sql 
\q
\d instance
\dt
\d instance_notes
\d instance_note
select count(*) from instance_note;
select length(value), value from instance_note order by length(value) limit 400;
    
select * from instance_note where value in ('W','?');
\q
    
select * from instance_note where value in ('W','?');
\q
\dt
\d instance_note_key
select id,name from instance_note_key ;
select length(value), value from instance_note n join instance_note_key key on n.instance_note_key_id = key.id order by length(value) limit 400;
select k.name, length(value), value from instance_note n join instance_note_key key on n.instance_note_key_id = key.id order by length(value) limit 400;
select key.name, length(value), value from instance_note n join instance_note_key key on n.instance_note_key_id = key.id order by length(value) limit 400;
select key.name, length(value), value from instance_note n join instance_note_key key on n.instance_note_key_id = key.id where key.name = 'Comment' order by length(value) limit 400;
select n.instance_id, key.name, length(value), value from instance_note n join instance_note_key key on n.instance_note_key_id = key.id where key.name = 'Comment' order by length(value) limit 400;
select n.instance_id, key.name, length(value), value from instance_note n join instance_note_key key on n.instance_note_key_id = key.id where key.name = 'Comment' order by length(value) limit 4000;
\q
\copy (select n.instance_id, key.name, length(value), value from instance_note n join instance_note_key key on n.instance_note_key_id = key.id where key.name = 'Comment' order by length(value) limit 4000) to first-4000.csv csv header;
\q
\q
\i batch-stack-view.sql 
drop view batch_stack_vw;
\i batch-stack-view.sql 
\d users
\i batch-stack-view.sql 
drop view batch_stack_vw;
\i batch-stack-view.sql 
\d brer
drop view batch_stack_vw;
\i batch-stack-view.sql 
\q
\d batch_reviewer
\d users
\d org
\q
\i batch-stack-view.sql 
grant select on batch_stack_vw to webapni;
\w grant-select-on-batch-stack-vw-to-webapni.sql
\q
select simple_name from loader_name where id = 51626966;
select simple_name ln from loader_name ln left outer join name on ln.simple_name = name.simple_name where ln.id = 51626966;
select ln.simple_name from loader_name ln left outer join name on ln.simple_name = name.simple_name where ln.id = 51626966;
select ln.simple_name from loader_name ln left outer join name on ln.simple_name = name.simple_name where ln.id = 51626966 or name.id = 51263583;
select ln.simple_name from loader_name ln right outer join name on ln.simple_name = name.simple_name where ln.id = 51626966 or name.id = 51263583;
select simple_name from loader_name id = 51626966;
select simple_name from loader_name where id = 51626966;
select simple_name from name where name.id = 51263583;
\q
drop view batch_stack_vw ;
\i batch-stack-view.sql 
drop view batch_stack_vw ;
\i batch-stack-view.sql 
drop view batch_stack_vw ;
\i batch-stack-view.sql 
drop view batch_stack_vw ;
\i batch-stack-view.sql 
\i batch-stack-view.sql 
drop view batch_stack_vw ;
\i batch-stack-view.sql 
drop view batch_stack_vw ;
\i batch-stack-view.sql 
\i batch-stack-view.sql 
\i batch-stack-view.sql 
drop view batch_stack_vw ;
\i batch-stack-view.sql 
select * from batch_review_period where end_date is null;
select name, case end_date when null then 'null' else end_date end from batch_review_period;
select name, case end_date::text when null then 'null' else end_date end from batch_review_period;
select name, case end_date::text when null then 'null' else end_date::text end from batch_review_period;
select name, case end_date is null when true then 'null' else 'not null' end from batch_review_period;
select name, case end_date is null when true then 'null' else end_date end from batch_review_period;
select name, case end_date is null when true then 'null' else end_date::text end from batch_review_period;
drop view batch_stack_vw ;
\i batch-stack-view.sql 
select id, simple_name from loader_name where simple_name like '%  %';
select id, simple_name from loader_name where simple_name like '%  %' and loader_batch_id = (select id from loader_batch where name = 'APC List 103';
);
select id, simple_name from loader_name where simple_name like '%  %' and loader_batch_id = (select id from loader_batch where name = 'APC List 103');
select simple_name from loader_name where id = 51626966;
select count(*) from name where simple_name like '%  %';
select id, simple_name from name where simple_name like '%  %' order by simple_name;
\q
select id, simple_name from name where simple_name like '%  %' order by simple_name;
\q
select id, simple_name from name where simple_name like '%  %' order by simple_name;
\q
\d batch_stack_vw 
select * from batch_stack_vw;
\q
\d batch_stack_vw 
\q
drop view batch_stack_vw ;
\i batch-stack-view.sql 
select to_char(current_timestamp, 'HH12:MI:SS');
select to_char(current_timestamp, 'DD Mon YYYY');
select to_char(current_timestamp, 'DD-Mon-YYYY');
\! pwd
drop view batch_stack_vw ;
\i db/ddl/nsl-4078/batch-stack-view.sql 
\i db/ddl/nsl-4078/batch-stack-view.sql 
drop view batch_stack_vw ;
\i db/ddl/nsl-4078/batch-stack-view.sql 
drop view batch_stack_vw ;
\i db/ddl/nsl-4078/batch-stack-view.sql 
\q
select * from batch_review_period where id = 51633703;
select * from batch_review where id = 51633703;
select * from loader_batch where id = 51633703;
\q
\d batch_stack_vw 
\! pwd
drop view batch_stack_vw 
;
\w
\q
\i batch-stack-view.sql 
\i batch-stack-view.sql 
select * from batch_stack_vw;
drop view batch_stack_vw 
;
\i batch-stack-view.sql 
select * from batch_stack_vw;
\d batch_stack_vw
drop view batch_stack_vw 
;
\i batch-stack-view.sql 
select * from batch_stack_vw;
select * from review_period;
\dt
select * from batch_review_period order by created_at;
drop view batch_stack_vw 
;
\i batch-stack-view.sql 
select * from batch_stack_vw;
update batch_review_period set created_at = now() where id = 51633731;
select * from batch_stack_vw;
select * from batch_review_period order by created_at;
drop view batch_stack_vw 
;
\i batch-stack-view.sql 
select * from batch_review_period order by created_at;
select * from batch_stack_vw;
\q
\dv
\i batch-stack-view.sql 
\i grant-select-on-batch-stack-vw-to-webapni.sql 
\q
\i batch-stack-view.sql 
\i grant-select-on-batch-stack-vw-to-webapni.sql 
\q
\dv
\d batch_stack_vw
\q
\dt
\d loader_name
\d loader_name
\i add-col-simple-name-as-loaded.sql 
\d loader_name
begin;
update loader_name set simple_name_as_loaded = simple_name ;
commit;
\q
alter table loader_name alter column simple_name_as_loaded set not null;
\w alter-column-loader_name-set-not-null.sql
\q
\d loader_name
\q
\d loader_name
\q
\d loader_name
alter table loader_name drop column alt_name_for_matching;
\s remove-col-alt-name-for-matching.sql
