create table taxonomy_review (
  id serial primary key,
  tree_version_id bigint not null,
  name varchar(50) not null,
  in_progress boolean not null default false,
  lock_version bigint not null default 0,
  created_at timestamp with time zone not null,
  created_by character varying(50)    not null,
  updated_at timestamp with time zone not null,
  updated_by character varying(50)    not null,
  constraint fk_tree_version
    foreign key (tree_version_id)
    references tree_version(id)
)
;
