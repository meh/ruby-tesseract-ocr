#! /usr/bin/env ruby
require 'rubygems'
require 'tesseract'

class Block; end
class Paragraph; end
class Line; end
class Word; end
class Symbol; end

describe Tesseract::Engine do
	let :engine do
		Tesseract::Engine.new(language: :eng)
	end

	describe '#text_for' do
		it 'can read the first test image' do
			expect(engine.text_for('first.png').strip).to eq('ABC')
		end

		it 'can read the second test image' do
			expect(engine.text_for('second.png').strip).to eq("#{Tesseract::API.new.version == '3.01' ? ?| : ?I}'m 12 and what is this.\nINSTALL GENTOO\nOH HAI 1234")
		end

		it 'raises when going out of the image boundaries' do
			expect {
				engine.text_for('second.png', 0, 0, 1000, 1000)
			}.to raise_error IndexError
		end
	end

	describe '#text_at' do
		it 'can read the first test image' do
			engine.image = 'first.png'

			expect(engine.text_at(2, 2, 2, 2).strip).to eq('')
		end

		it 'can read the second test image' do
			engine.image = 'second.png'

			expect(engine.text_at(242, 191, 129, 31).strip).to eq('OH HAI 1234')
		end

		it 'raises when going out of the image boundaries' do
			expect {
				engine.image = 'second.png'
				engine.text_at(10, 20, 1000, 1000)
			}.to raise_error IndexError
		end
	end

	describe '#text' do
		it 'can read the first test image' do
			engine.image = 'first.png'
			engine.select 2, 2, 2, 2

			expect(engine.text.strip).to eq('')
		end

		it 'can read the second test image' do
			engine.image = 'second.png'
			engine.select 242, 191, 129, 31

			expect(engine.text.strip).to eq('OH HAI 1234')
		end

		it 'raises when going out of the image boundaries' do
			expect {
				engine.image = 'second.png'
				engine.select 10, 20, 1000, 1000
				engine.text
			}.to raise_error IndexError
		end
	end

	describe '#hocr' do
		it 'can read the first test image' do
			engine.image = 'first.png'
			engine.select 2, 2, 2, 2

			expect(engine.hocr).to eq("  <div class='ocr_page' id='page_1' title='image \"\"; bbox 2 2 2 2; ppageno 0'>\n  </div>\n")
		end

		it 'can read the second test image' do
			engine.image = 'second.png'
			engine.select 242, 191, 129, 31

			expect(engine.hocr).to eq("  <div class='ocr_page' id='page_1' title='image \"\"; bbox 242 191 129 31; ppageno 0'>\n   <div class='ocr_carea' id='block_1_1' title=\"bbox 242 191 371 222\">\n    <p class='ocr_par' dir='ltr' id='par_1_1' title=\"bbox 250 200 365 213\">\n     <span class='ocr_line' id='line_1_1' title=\"bbox 250 200 365 213; baseline 0 0\"><span class='ocrx_word' id='word_1_1' title='bbox 250 200 275 213; x_wconf 94' lang='eng' dir='ltr'>OH</span> <span class='ocrx_word' id='word_1_2' title='bbox 285 200 313 213; x_wconf 90' lang='eng' dir='ltr'>HAI</span> <span class='ocrx_word' id='word_1_3' title='bbox 323 200 365 213; x_wconf 86' lang='eng'>1234</span> \n     </span>\n    </p>\n   </div>\n  </div>\n")
		end

		it 'raises when going out of the image boundaries' do
			expect {
				engine.image = 'second.png'
				engine.select 10, 20, 1000, 1000

				engine.hocr
			}.to raise_error IndexError
		end
	end

	describe '#blacklist' do
		it 'works with removing weird signs' do
			expect(engine.with { |e| e.blacklist = '|' }.text_for('second.png').strip).to eq("I'm 12 and what is this.\nINSTALL GENTOO\nOH HAI 1234")
		end
	end

	describe '#whitelist' do
		it 'makes everything into a number' do
			expect(engine.with { |e| e.whitelist = '1234567890' }.text_for('second.png').strip).to match(/^[\d\s]*$/)
		end
	end

	describe '#page_segmentation_mode' do
		it 'sets it correctly' do
			expect(engine.with {|e|
				e.page_segmentation_mode = :single_line
				e.whitelist              = [*'a'..'z', *'A'..'Z', *0..9, " ."].join
			}.text_for('jsmj.png').strip).to eq('Jsmj')
		end
	end

	describe '#blocks' do
		it 'works properly with first image' do
			expect(engine.blocks_for('first.png').first.to_s.strip).to eq('ABC')
		end
	end

	describe '#paragraphs' do
		it 'works properly with first image' do
			expect(engine.paragraphs_for('first.png').first.to_s.strip).to eq('ABC')
		end
	end

	describe '#lines' do
		it 'works properly with first image' do
			expect(engine.lines_for('first.png').first.to_s.strip).to eq('ABC')
		end
	end

	describe '#words' do
		it 'works properly with first image' do
			expect(engine.words_for('first.png').first.to_s).to eq('ABC')
		end
	end

	describe '#symbols' do
		it 'works properly with first image' do
			expect(engine.symbols_for('first.png').first.to_s).to eq('A')
		end
	end
end
