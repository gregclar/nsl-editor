#
# this is the command I used to test these scripts
#
# dropdb ned_test; createdb -O nsl ned_test; bundle exec rake db:schema:dump; bundle exec rake db:prep_structure_sql; RAILS_ENV=test bin/rails db:setup
#
#
#
namespace :db do
  desc "Prepare the structure.sql file - run this after you generate structure.sql"
  task prep_structure_sql: :environment do
    puts "Place holder for preparing the structure.sql file after you generate a new one."
    sh "ed db/structure.sql <lib/scripts/structure/a.ed"
    sh "ed db/structure.sql <lib/scripts/structure/b.ed"
    sh "ed db/structure.sql <lib/scripts/structure/c.ed"
    sh "ed db/structure.sql <lib/scripts/structure/d.ed"
    sh "ed db/structure.sql <lib/scripts/structure/e.ed"
    sh "ed db/structure.sql <lib/scripts/structure/f.ed"
    sh "ed db/structure.sql <lib/scripts/structure/g.ed"
    sh "ed db/structure.sql <lib/scripts/structure/h.ed"
    sh "ed db/structure.sql <lib/scripts/structure/i.ed"
    sh "ed db/structure.sql <lib/scripts/structure/j.ed"
    sh "ed db/structure.sql <lib/scripts/structure/k.ed"
    sh "ed db/structure.sql <lib/scripts/structure/l.ed"
    sh "ed db/structure.sql <lib/scripts/structure/m.ed"
    sh "ed db/structure.sql <lib/scripts/structure/n.ed"
    sh "ed db/structure.sql <lib/scripts/structure/o.ed"
    sh "ed db/structure.sql <lib/scripts/structure/p.ed"
    sh "ed db/structure.sql <lib/scripts/structure/q.ed"
    sh "ed db/structure.sql <lib/scripts/structure/r.ed"
    sh "ed db/structure.sql <lib/scripts/structure/s.ed"
    sh "ed db/structure.sql <lib/scripts/structure/t.ed"
    sh "ed db/structure.sql <lib/scripts/structure/u.ed"
    sh "ed db/structure.sql <lib/scripts/structure/v.ed"
    sh "ed db/structure.sql <lib/scripts/structure/w.ed"
    sh "ed db/structure.sql <lib/scripts/structure/x.ed"
    sh "ed db/structure.sql <lib/scripts/structure/y.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z1.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z2.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z3.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z4.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z5.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z6.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z7.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z8.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z9.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z9a.ed"
    sh "ed db/structure.sql <lib/scripts/structure/z9b.ed"
  end

end



# ed statements to remove sections of the structure.sql file
#
#
#
#   create role rdsamin;
#   create role nsl_readonly;
#   create role rdfuser;
#   create role nsl_graph_read;
#   create role read_only;


#   DETAIL:  Could not open extension control file "/opt/homebrew/opt/postgresql@15/share/postgresql@15/extension/oracle_fdw.control": No such file or directory.
#   HINT:  The extension must first be installed on the system where PostgreSQL is running.
#   bin/rails aborted!
#   failed to execute:
#   psql --set ON_ERROR_STOP=1 --quiet --no-psqlrc --output /dev/null --file /Users/gclarke/anbg/rails/nedruby/db/structure.sql ned_test



#   nsl_global_seq


#   CREATE SEQUENCE public.nsl_global_seq
    #   START WITH 1
    #   INCREMENT BY 1
    #   CACHE 1;
#
#
#   loader.nsl_global_seq



# for testing:  % dropdb ned_test; createdb -O nsl ned_test; RAILS_ENV=test bin/rails db:setup
#
#
# SET default_tablespace = '';



# add loader.nsl_global_seq
# remove min/max from public.nsl_global_seq
# remove oracle_fdw stuff
# see more in diff-my-structure-sql-structure-sql
