require 'rubygems'
require 'rake'
require 'spec/rake/spectask'

task :default => :spec
task :test => :spec

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts = ['--colour', '--format=specdoc']
end