#! /usr/bin/env ruby

expected = File.read('captchas/captchas.txt').lines.to_a

`./break.rb captchas/*.png`.lines.each_with_index {|line, index|
	whole, path, output = line.match(/^(.*?): (.*?)$/).to_a

	unless output == expected[index].chomp
		puts "#{path}: expected #{expected[index].chomp} but got #{output}"
	end
}
