#! /usr/bin/env ruby
require 'rake'

task :default => :test

task :test do
	Dir.chdir 'test'
	sh 'rspec tesseract_spec.rb --color --format doc'
end

task :bench do
	Dir.chdir 'test'
	sh 'ruby tesseract_bench.rb'
end
