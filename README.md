# README

## Build 

TIP: To setup your build environment in linux try the setup-dev-linux.sh bash script. This will make sure tou have the
prerequisites installed and run the bootstrap below.

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
