require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "tenacity"
  gem.homepage = "http://github.com/jwood/tenacity"
  gem.license = "MIT"
  gem.summary = %Q{A ORM independent way of specifying simple relationships between models backed by different databases.}
  gem.description = %Q{Tenacity provides an ORM independent way of specifying simple relationships between models backed by different databases.}
  gem.email = "john@johnpwood.com"
  gem.authors = ["John Wood"]

  gem.add_runtime_dependency 'activesupport', '> 2.3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "tenacity #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'test/active_record_test_helper'
namespace :db do
  desc "Create the test databases"
  task :create do
    system "mysqladmin -u root create tenacity_test"
  end

  desc "Drop the test databases"
  task :drop do
    system "mysqladmin -u root drop tenacity_test"
  end

  namespace :test do
    desc "Setup the test databases"
    task :prepare do
      ActiveRecord::Schema.define :version => 0 do
        create_table :accounts, :force => true do |t|
        end
      end
    end
  end
end