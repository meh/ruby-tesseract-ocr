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
			engine.text_for('second.png').strip.should == "#{Tesseract::API.new.version == '3.01' ? ?| : ?I}'m 12 and what is this.\nINSTALL GENTOO\nOH HAI 1234"
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
			engine.with { |e| e.whitelist = '1234567890' }.text_for('second.png').strip.should match(/^[\d\s]*$/)
		end
	end

	describe '#page_segmentation_mode' do
		it 'sets it correctly' do
			engine.with {|e|
				e.page_segmentation_mode = :single_line
				e.whitelist              = [*'a'..'z', *'A'..'Z', *0..9, " ."].join
			}.text_for('jsmj.png').strip.should == 'JSmj'
		end
	end

	describe '#blocks' do
		it 'works properly with first image' do
			engine.blocks_for('first.png').first.to_s.strip.should == 'ABC'
		end
	end

	describe '#paragraphs' do
		it 'works properly with first image' do
			engine.paragraphs_for('first.png').first.to_s.strip.should == 'ABC'
		end
	end

	describe '#lines' do
		it 'works properly with first image' do
			engine.lines_for('first.png').first.to_s.strip.should == 'ABC'
		end
	end

	describe '#words' do
		it 'works properly with first image' do
			engine.words_for('first.png').first.to_s.should == 'ABC'
		end
	end

	describe '#symbols' do
		it 'works properly with first image' do
			engine.symbols_for('first.png').first.to_s.should == 'A'
		end
	end
end
