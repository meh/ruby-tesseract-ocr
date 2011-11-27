#! /usr/bin/env ruby
require 'rubygems'
require 'tesseract'

describe Tesseract::Engine do
	let :engine do
		Tesseract::Engine.new(language: :eng)
	end

	describe '#text_for' do
		it 'can read first test image' do
			engine.text_for('first.png').strip.should == 'ABC'
		end
	end
end
