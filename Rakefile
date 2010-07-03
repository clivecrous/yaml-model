require 'rake'
require 'spec/rake/spectask'

desc "Run all unit tests"
Spec::Rake::SpecTask.new( 'test' ) do |t|
  t.spec_files = FileList['rspec/**/*.rb']
end

task :default => :test
