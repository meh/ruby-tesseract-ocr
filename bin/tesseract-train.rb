#! /usr/bin/env ruby
require 'optparse'
require 'tmpdir'
require 'fileutils'
require 'shellwords'

options = {}

OptionParser.new do |o|
	o.on '-b', '--box FILE', 'the box file to use' do |value|
		options[:box] = File.realpath(value)
	end

	o.on '-i', '--image FILE', 'the image file to use' do |value|
		options[:image] = File.realpath(value)
	end

	o.on '-o', '--output FILE', 'the path where to output the traineddata' do |value|
		options[:output] = File.expand_path(value)
	end
end.parse!

if language = ARGV.shift
	options[:box]    = File.realpath("#{language}.box")
	options[:image]  = File.realpath("#{language}.tif")
	options[:output] = File.expand_path("#{language}.traineddata")
else
	language = options[:box][/^(.*?)\./, 1]
end

Dir.chdir FileUtils.mkpath(File.join(Dir.tmpdir, rand.to_s)).first

language = language.shellescape

%x{
	cp #{options[:box].shellescape} #{language}.box
	cp #{options[:image].shellescape} #{language}#{File.extname(options[:image])}

	tesseract #{language}#{File.extname(options[:image])} #{language} nobatch box.train.stderr

	unicharset_extractor #{language}.box

	echo #{language} 0 0 0 0 0 > font_properties
	mftraining -F font_properties -U unicharset #{language}.tr
	mftraining -F font_properties -U unicharset -O #{language}.unicharset #{language}.tr
	cntraining #{language}.tr

	mv Microfeat #{language}.Microfeat
	mv normproto #{language}.normproto
	mv pffmtable #{language}.pffmtable
	mv mfunicharset #{language}.mfunicharset
	mv inttemp #{language}.inttemp

	combine_tessdata #{language}.

	mv #{language}.traineddata #{options[:output].shellescape}
}

path = File.realpath(Dir.pwd)

Dir.chdir '/'

FileUtils.rm_rf path
