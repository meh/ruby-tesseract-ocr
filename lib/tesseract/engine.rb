#--
# Copyright 2011 meh. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without modification, are
# permitted provided that the following conditions are met:
#
#    1. Redistributions of source code must retain the above copyright notice, this list of
#       conditions and the following disclaimer.
#
# THIS SOFTWARE IS PROVIDED BY meh ''AS IS'' AND ANY EXPRESS OR IMPLIED
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
# FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL meh OR
# CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
# ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
# NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
# ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#
# The views and conclusions contained in the software and documentation are those of the
# authors and should not be interpreted as representing official policies, either expressed
# or implied, of meh.
#++

require 'namedic'
require 'tesseract/api'

module Tesseract

class Engine
	namedic :path, :language,
		:optional => { :path => '.', :language => :eng, :mode => :DEFAULT },
		:alias    => { :data => :path, :lang => :language }
	def initialize (path = '.', language = :eng, mode = :DEFAULT)
		@api = API.new
		@api.init(path, language, mode)
	end

	def image= (image)
		@image = image
	end

	namedic :image, :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def text_for (image = nil, x = nil, y = nil, width = nil, height = nil)
		image ||= @image or raise ArgumentError, 'you have to set an image first'

		image = if image.is_a?(String) && File.exists?(File.expand_path(image))
			C::pix_read(File.expand_path(image))
		elsif image.is_a?(String)
			C::pix_read_mem(image, image.bytesize)
		elsif image.is_a?(IO)
			C::pix_read_stream(image.to_i)
		else
			raise ArgumentError, 'invalid image'
		end

		x      ||= 0
		y      ||= 0
		width  ||= C::pix_get_width(image)
		height ||= C::pix_get_height(image)

		@api.set_image(image)
		@api.set_rectangle(x, y, width, height)

		@api.get_text.tap {
			C::pix_destroy(image)
		}
	end

	namedic :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def text_at (x = nil, y = nil, width = nil, height = nil)
		text_for(nil, x, y, width, height)
	end
end

end
