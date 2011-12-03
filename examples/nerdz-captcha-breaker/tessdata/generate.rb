#! /usr/bin/env ruby
require 'rubygems'
require 'gd2'
require 'RMagick'

captchas = File.read(ARGV.shift).lines.to_a

image = GD2::Image.new(90, captchas.length * 30)
font  = GD2::Font::Giant

captchas.each_with_index {|captcha, index|
	font.draw(image.image_ptr, 10, index * 30 + 10, 0, captcha.chomp, GD2::Color::WHITE.to_i)
}

output = ARGV.shift

image.export(output)

image = Magick::Image.read(output).first

File.open(output, 'wb') { |f| f.write(image.scale(4).to_blob) }
