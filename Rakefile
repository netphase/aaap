require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rubygems'
require 'fileutils'
include FileUtils

NAME = "acts_as_amazon_product"
# REV = File.read(".svn/entries")[/committed-rev="(\d+)"/, 1] rescue nil
# VERS = ENV['VERSION'] || ("1.1" + (REV ? ".#{REV}" : ""))
VERS = ENV['VERSION'] || "1.4.1"
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

Gem::manage_gems
require 'rake/gempackagetask'
spec = Gem::Specification.new do |s|
    s.platform  =   Gem::Platform::RUBY
    s.name      =   NAME
    s.version   =   VERS
    s.author    =   "Scott Nedderman"
    s.email     =   "scott@netphase.com"
    s.homepage  =   "http://netphase.com"
    s.summary   =   "A package for simplifying use of the Amazon/ECS API"
    s.files     =   FileList['lib/*.rb', 'test/*'].to_a.reject {|f| f.match /config\.yml/ }
    s.require_path  =   "lib"
    # s.autorequire   =   "acts_as_amazon_product"
    s.test_files = Dir.glob('tests/*.rb')
    s.has_rdoc  =   true
    s.extra_rdoc_files  =   ["README"]
    s.add_dependency("amazon-ecs", ">=0.5.1")
end
Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_tar = true
end
task :default => "pkg/#{spec.name}-#{spec.version}.gem" do
    puts "generated latest version"
end

task :install do
  sh %{rake package}
  sh %{sudo gem install pkg/#{NAME}-#{VERS}}
end

task :uninstall => [:clean] do
  sh %{sudo gem uninstall #{NAME}}
end

desc 'Test the acts_as_amazon_product plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

