echo "\nConvert the JRuby version of the Editor to Ruby"
export RUBY_VERSION='ruby-2.6.10'
export PATH="~/.rubies/${RUBY_VERSION}/bin:$PATH"
echo $PATH

echo "${RUBY_VERSION}" >.ruby-version
cat .ruby-version
which ruby
echo 'Modify Gemfile'
ed Gemfile <  switch-to-ruby/gemfile-commands.ed

which bundle
gem install bundler:2.3.21
which bundle
bundle

rake webpacker:install

