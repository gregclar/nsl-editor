# README

## Build 

TIP: To setup your build environment in linux try the setup-dev-linux.sh bash script. This will make sure tou have the
prerequisites installed and run the bootstrap below.

When running the setup-dev-linux script you should "source" it if you want to run commands from the same command line, e.g.

    . ./setup-dev-linux.sh

If you're not using linux have a look at the script, it _may_ help.

### Prerequisites
#### java
* version: 8 (Suggest 8u252 e.g. AdoptOpenJDK)
* https://adoptopenjdk.net/

To install I would recommend using sdkman https://sdkman.io/

#### jruby 
* version: 9.2.11.1 
* from: https://www.jruby.org/download
* download: https://repo1.maven.org/maven2/org/jruby/jruby-dist/9.2.11.1/jruby-dist-9.2.11.1-bin.zip
* md5 hash: 52dece370067d74bdba38dbdab1a87ee

To install you can download and unpack somewhere and set some environment variables.

    JRUBY_HOME=$PWD/bin/jruby-9.2.11.1
    PATH=$JRUBY_HOME/bin:$PATH
    export JRUBY_HOME PATH

#### yarn
* version: 1.22.4
* install: see https://classic.yarnpkg.com/en/docs/install#centos-stable

#### node
* version: >12
* install: https://nodejs.org/en/download/package-manager/#enterprise-linux-and-fedora

### bootstrapping

To get this all started run:

    yarn
    gem install bundler
    bundle install

## Configuration

Configuration files normally live in the `~/.nsl` directory. You will need a development and test directory
within `~/.nsl` to house your development configs. I recommend you set environment variables to set the location of
the configuration files.

    EDITOR_CONFIG_FILE=$HOME/.nsl/editor-config.rb
    EDITOR_CONFIGDB_FILE=$HOME/.nsl/editor-database.yml
    export EDITOR_CONFIG_FILE EDITOR_CONFIGDB_FILE

See the docs/configuration-guide.adoc

example local development editor-config.rb

    #Services
      Rails.configuration.services_clientside_root_url = 'http://localhost:8080/services/'
      Rails.configuration.services = 'http://localhost:8080/services/'
      Rails.configuration.name_services = 'http://localhost:8080/services/rest/name/apni/'
      Rails.configuration.reference_services = 'http://localhost:8080/services/rest/reference/apni/'
      Rails.configuration.api_key = 'my dog ate my homework'
      Rails.configuration.nsl_links = 'http://localhost:8080/services/'
      Rails.configuration.nsl_linker = 'http://localhost:7070/nsl-mapper/'
      Rails.configuration.api_key = 'dev-apni-editor'
    
    #LDAP
      Rails.configuration.ldap_admin_username = "uid=admin,ou=system"
      Rails.configuration.ldap_admin_password = "make this really secret"
      Rails.configuration.ldap_base = "ou=users,dc=nsl,dc=bio,dc=org,dc=au"
      Rails.configuration.ldap_host = "localhost"
      Rails.configuration.ldap_port = 10389
      Rails.configuration.ldap_users = "ou=users,dc=nsl,dc=bio,dc=org,dc=au"
      Rails.configuration.ldap_groups = "ou=groups,dc=nsl,dc=bio,dc=org,dc=au"
    
    #mapper
      Rails.configuration.mapper_root_url = 'http://localhost:7070/nsl-mapper/'
      Rails.configuration.mapper_shard = 'myshard'
      
    #environment
      Rails.configuration.environment = 'development'
    
      if ENV['SESSION_KEY_TAG'].nil?
        Rails.configuration.session_key_tag = 'dev'
      else
        Rails.configuration.session_key_tag = ENV['SESSION_KEY_TAG']
      end
    
    Rails.configuration.draft_instances = 'true'

example local development editor-database.yml

    default: &default
      adapter: postgresql
      encoding: unicode
    
    production:
      <<: *default
      url: "postgresql://999.999.999.999:5432/mydb"
      username: web
      password: dont_tell_anyone
    
    development:
      <<: *default
      url: "postgresql://127.0.0.1:5432/mydb"
      username: web
      password: dont_tell_anyone
    
    test:
      adapter: postgresql
      encoding: unicode
      host: localhost
      database: nsl-ed-test
      username: web
      password: dont_tell_anyone   

Note with the new micronaut mapper the api has been revised and the mapper config looks like this:

    #mapper                                                        
    Rails.configuration.x.mapper_api.version = 2
    Rails.configuration.x.mapper_api.url = "#{internal_mapper_host}/api/"
    Rails.configuration.x.mapper_api.username = 'TEST-services'
    Rails.configuration.x.mapper_api.password = 'buy-me-a-pony'
    Rails.configuration.x.mapper_external.url = "#{external_mapper_host}/" 

see: application_helper.rb and tree/as_services.rb
       
## Running

To run in development run `rails s` from the command line in your project directory

---

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
