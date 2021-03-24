create table orchid_batch_job_locks 
(restriction int not null default 1 primary key,
 name varchar(30), constraint force_one_row check (restriction = 1)
) ;
