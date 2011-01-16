=begin
Ruby library implementation of EMI/UCP protocol v4.6 for SMS
Copyright (C) 2011, Sergio Freire <sergio.freire@gmail.com>

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
=end


require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'

require 'rake/testtask'
require 'rcov/rcovtask'


begin
  require 'jeweler'
  Jeweler::Tasks.new do |s|
    s.name = "ruby_ucp"
    s.summary = "EMI/UCP protocol library"
    s.email = "sergio.freire@gmail.com"
    s.homepage = "https://github.com/bitcoder/ruby_ucp"
    s.description = "Ruby library implementation of EMI/UCP protocol v4.6 for SMS"
    s.authors = ["Sergio Freire"]
    s.files =  FileList["[A-Z]*", "{bin,generators,lib,test}/**/*", 'lib/jeweler/templates/.gitignore']
    #s.add_dependency 'schacon-git'
  end
  Jeweler::RubygemsDotOrgTasks.new
#  Jeweler::RubyforgeTasks.new do |rubyforge|
#    rubyforge.doc_task = "yardoc"
#  end

rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end


begin
  require 'yard'
  YARD::Rake::YardocTask.new(:yardoc)
rescue LoadError
  task :yardoc do
    abort "YARD is not available. In order to run yard, you must: sudo gem install yard"
  end
end



# FIX THIS: there is an overlap between and jeweler; although jeweler seems better,
#            it does not provide the "gem" task, that is needed in order to integrate
#            with Netbeans

spec = Gem::Specification.new do |s|
  s.name = 'ruby_ucp'
  s.version = '0.1.0'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'EMI/UCP protocol library'
  s.description = s.summary
  s.author = 'Sergio Freire'
  s.email = 'sergio.freire@gmail.com'
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end



Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "ruby_ucp Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end


Rake::TestTask.new do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = false
end




Rcov::RcovTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/**/*_test.rb']
  t.verbose = true
end


task :default => :build

