#! /usr/bin/env ruby
require 'tesseract'
require 'benchmark'

Benchmark.bm do |b|
	engine = Tesseract::Engine.new

	b.report 'text_for: ' do
		100.times do
			engine.text_for('first.png')

			GC.start
		end
	end

	b.report 'words_for: ' do
		100.times do
			engine.words_for('first.png')

			GC.start
		end
	end

	b.report 'symbols_for: ' do
		100.times do
			engine.symbols_for('first.png')

			GC.start
		end
	end
end
