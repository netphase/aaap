require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'fileutils'
include FileUtils

NAME = "acts_as_amazon_product"
CLEAN.include ['**/.*.sw?', '*.gem', '.config', 'test/test.log']

desc 'Default: run unit tests.'
task :default => [:package]
task :package => [:clean]

desc 'Generate documentation for the acts_as_amazon_product plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'ActsAsAmazonProduct'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Test the acts_as_amazon_product plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "acts_as_amazon_product"
    gemspec.summary = "A package for simplifying use of the Amazon/ECS API"
    gemspec.email = "scott@netphase.com"
    gemspec.homepage = "http://github.com/netphase/aaap"
    gemspec.authors = ["Scott Nedderman","Chris Beck"]
    gemspec.add_dependency("amazon-ecs", ">=0.5.6")
    gemspec.files.exclude 'test/config.yml'
    
  end
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install technicalpickles-jeweler -s http://gems.github.com"
end

