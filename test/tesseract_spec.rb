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

		it 'raises when going out of the image boundaries' do
			expect {
				engine.text_for('second.png', 0, 0, 1000, 1000)
			}.should raise_error
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

		it 'raises when going out of the image boundaries' do
			expect {
				engine.image = 'second.png'
				engine.text_at(10, 20, 1000, 1000)
			}.should raise_error
		end
	end

	describe '#text' do
		it 'can read the first test image' do
			engine.image = 'first.png'
			engine.select 2, 2, 2, 2

			engine.text.strip.should == ''
		end

		it 'can read the second test image' do
			engine.image = 'second.png'
			engine.select 242, 191, 129, 31
			engine.text.strip.should == 'OH HAI 1234'
		end

		it 'raises when going out of the image boundaries' do
			expect {
				engine.image = 'second.png'
				engine.select 10, 20, 1000, 1000
				engine.text
			}.should raise_error
		end

	end

	describe '#blacklist' do
		it 'works with removing weird signs' do
			engine.with { |e| e.blacklist = '|' }.text_for('second.png').strip.should == "I'm 12 and what is this.\nINSTALL GENTOO\nOH HAI 1234"
		end
	end

	describe '#whitelist' do
		it 'makes everything into a number' do
			engine.with { |e| e.whitelist = '1234567890' }.text_for('second.png').strip.should == "11111 12 3116 1111113115111151\n11157411 6511700\n014 11141 1234"
		end
	end

	describe '#each_block' do
		it 'works properly with first image' do

		end
	end
end
