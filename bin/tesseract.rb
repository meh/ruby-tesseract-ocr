#! /usr/bin/env ruby
require 'optparse'
require 'tesseract'

options = {}

OptionParser.new do |o|
	options[:path]     = ?.
	options[:language] = :en
	options[:mode]     = :DEFAULT

	o.on '-p', '--path PATH', 'datapath to set' do |value|
		options[:path] = value
	end

	o.on '-l', '--language LANGUAGE', 'language to use' do |value|
		options[:language] = value
	end

	o.on '-m', '--mode MODE', 'mode to use' do |value|
		options[:mode] = value.upcase.to_sym
	end

	o.on '-u', '--unlv' do
		options[:unlv] = true
	end

	o.on '-b', '--blacklist LIST', 'blacklist the following chars' do |value|
		options[:blacklist] = value
	end

	o.on '-w', '--whitelist LIST', 'whitelist the following chars' do |value|
		options[:whitelist] = value
	end
end.parse!

Tesseract::Engine.new(options[:path], options[:language], options[:mode]) {|engine|
	engine.blacklist options[:blacklist] if options[:blacklist]
	engine.whitelist options[:whitelist] if options[:whitelist]
}.tap {|engine|
	if options[:unlv]
		puts engine.text_for(ARGV.first).unlv.strip
	else
		puts engine.text_for(ARGV.first).strip
	end
}
