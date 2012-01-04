require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "activerecord-fast-import"
    gem.summary = "Fast MySQL import for ActiveRecord"
    gem.description = "Native MySQL additions to ActiveRecord, like LOAD DATA INFILE, ENABLE/DISABLE KEYS, TRUNCATE TABLE."
    gem.email = "johno@jsmf.net"
    gem.homepage = "http://github.com/jsuchal/activerecord-fast-import"
    gem.authors = ["Jan Suchal"]
    gem.add_development_dependency "rspec"
    gem.add_dependency 'activerecord', [">= 2.1.2"]
  end
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "activerecord-fast-import #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
