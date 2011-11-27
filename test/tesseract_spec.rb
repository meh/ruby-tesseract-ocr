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
		it 'can read the first test image' do
			engine.words_for('first.png').should == ['ABC']
		end

		it 'can read the second test image' do
			engine.words_for('second.png').should == %w(|'m 12 and what is this. INSTALL GENTOO OH HAI 1234)
		end
	end

	describe '#words_at' do
		it 'can read the first test image' do
			engine.image = 'first.png'
			engine.words_at(2, 2, 2, 2).should == []
		end

		it 'can read the second test image' do
			engine.image = 'second.png'
			engine.words_at(242, 191, 129, 31).should == %w(OH HAI 1234)
		end
	end

	describe '#chars_for' do
		it 'can read the first test image' do
			engine.chars_for('first.png').should == 'ABC'.split('')
		end

		it 'can read the second test image' do
			engine.chars_for('second.png').should == "|'m 12 and what is this.\nINSTALL GENTOO\nOH HAI 1234".gsub(/\s+/, '').split('')
		end
	end

	describe '#chars_at' do
		it 'can read the first test image' do
			pending 'weird results'

			engine.image = 'first.png'
			engine.chars_at(2, 2, 2, 2).should == []
		end

		it 'can read the second test image' do
			pending 'weird results'

			engine.image = 'second.png'
			engine.chars_at(242, 191, 129, 31).should == 'OH HAI 1234'.gsub(/\s+/, '').split('')
		end
	end
end
