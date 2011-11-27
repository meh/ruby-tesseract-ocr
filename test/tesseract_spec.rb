#! /usr/bin/env ruby
require 'rubygems'
require 'tesseract'

describe Tesseract::Engine do
	let :engine do
		Tesseract::Engine.new(language: :eng)
	end

	describe '#text_for' do
		it 'can read the first test image' do
			engine.text_for('first.png').strip.should == 'ABC'
		end

		it 'can read the second test image' do
			engine.text_for('second.png').strip.should == "|'m 12 and what is this.\nINSTALL GENTOO\nOH HAI 1234"
		end
	end

	describe '#text_at' do
		it 'can read the first test image' do
			engine.image = 'first.png'
			engine.text_at(2, 2, 2, 2).strip.should == ''
		end

		it 'can read the second test image' do
			engine.image = 'second.png'
			engine.text_at(242, 191, 129, 31).strip.should == 'OH HAI 1234'
		end
	end

	describe '#words_for' do

	end
end
