require 'rake'
require 'spec/rake/spectask'

desc "Run all unit tests"
Spec::Rake::SpecTask.new( 'test' ) do |t|
  t.spec_files = ['rspec/_config.rb'] + FileList['rspec/**/*.rb']
end

task :default => :test
