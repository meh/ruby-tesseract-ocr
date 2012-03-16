#! /usr/bin/env ruby
require 'optparse'
require 'tmpdir'
require 'fileutils'
require 'shellwords'

options = {}

OptionParser.new do |o|
	o.on '-d', '--data DATA...', Array, 'the data to use' do |value|
		options[:data] = Hash[value.map { |e| e.split(?:).map { |p| File.realpath(p) } }]
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
	language = options[:output][/^(.*?)\./, 1]
end

Dir.chdir FileUtils.mkpath(File.join(Dir.tmpdir, rand.to_s)).first

language = language.shellescape

options[:data].each_with_index {|(box, image), index|
	%x{
		cp #{box.shellescape} #{language}.#{index}.box
		cp #{image.shellescape} #{language}.#{index}#{File.extname(image)}

		tesseract #{language}.#{index}#{File.extname(image)} #{language} nobatch box.train.stderr

		unicharset_extractor #{language}.box

		echo #{language}.#{index} 0 0 0 0 0 >> font_properties
		mftraining -F font_properties -U unicharset -O #{language}.unicharset #{language}.tr
	}
}

%x{
	cntraining #{language}.tr

	mv Microfeat #{language}.Microfeat
	mv normproto #{language}.normproto
	mv pffmtable #{language}.pffmtable
	mv mfunicharset #{language}.mfunicharset
	mv inttemp #{language}.inttemp

	combine_tessdata #{language}.

	mv #{language}.traineddata #{options[:output].shellescape}
}

=begin
path = File.realpath(Dir.pwd)

Dir.chdir '/'

FileUtils.rm_rf path
=end
