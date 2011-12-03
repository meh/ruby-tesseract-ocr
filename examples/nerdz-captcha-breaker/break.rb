#! /usr/bin/env ruby
require 'tesseract'
require 'RMagick'

# this function is used to get points near the current pixel to
# cleanup the oblique lines mess, horizontal points seem to output
# better cleanup
def near (x, y)
	[
#		[x - 1, y - 1],
#		[x,     y - 1],
#		[x + 1, y - 1],
		[x - 1, y    ],
		[x + 1, y    ],
#		[x - 1, y + 1],
#		[x,     y + 1],
#		[x + 1, y + 1]
	]
end

Tesseract::Engine.new {|engine|
	engine.page_segmentation_mode = 8
	engine.whitelist              = [*'a'..'z', *'A'..'Z', *0..9].join
}.tap {|engine|
	ARGV.each {|path|
		image  = Magick::Image.read(path).first
		pixels = Hash.new { |h, k| h[k] = 0 }

		image.each_pixel {|p|
			pixels[p] += 1
		}

		pixels.delete(Magick::Pixel.from_color('black'))

		text_color, count = pixels.max { |a, b| a.last <=> b.last }

		image.each_pixel {|p, x, y|
			next unless p == text_color or p.to_color == 'black'

			image.pixel_color x, y, p == text_color ? 'black' : 'white'
		}

		image.each_pixel {|p, x, y|
			next if p.to_color == 'black' || p.to_color == 'white'

			if near(x, y).map { |(x, y)| image.pixel_color x, y }.any? { |p| p.to_color == 'black' }
				image.pixel_color x, y, 'gray'
			else
				image.pixel_color x, y, 'white'
			end
		}

		image.each_pixel {|p, x, y|
			next unless p.to_color == 'gray'

			image.pixel_color x, y, 'black'
		}

		puts "#{path}: #{engine.text_for(image.resize 10).strip}"
	}
}
