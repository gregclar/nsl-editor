
create table orchid_processing_logs
(id serial,
 log_entry text not null default 'Wat?',
 logged_at timestamp with time zone not null default Now(),
 logged_by varchar(255) not null
);
 

