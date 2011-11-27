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
		:optional => { :path => '.', :language => :eng, :mode => :DEFAULT, :variables => {} },
		:alias    => { :data => :path, :lang => :language }
	def initialize (path = '.', language = :eng, mode = :DEFAULT, variables = {})
		@api = API.new

		@path      = path
		@language  = language
		@mode      = mode
		@variables = variables

		_init
	end

	def set (name, value)
		@variables[name] = value

		_init
	end

	def get (name)
		@api.get_variable(name) || @variables[name]
	end

	%w(path language mode).each {|name|
		define_method name do
			instance_variable_get "@#{name}"
		end

		define_method "#{name}=" do |value|
			instance_variable_set "@#{name}", value

			_init
		end
	}

	def image= (image)
		@image = image
	end

	namedic :image, :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def text_for (image = nil, x = nil, y = nil, width = nil, height = nil)
		image ||= @image or raise ArgumentError, 'you have to set an image first'
		image   = API.image_for(image)

		x      ||= 0
		y      ||= 0
		width  ||= C::pix_get_width(image)
		height ||= C::pix_get_height(image)

		@api.set_image(image)
		@api.set_rectangle(x, y, width, height)

		@api.get_text.tap {|text|
			text.instance_exec(@api) {|api|
				@confidence = api.mean_text_confidence

				class << self
					attr_reader :confidence
				end
			}

			C::pix_destroy(image)
		}
	end

	namedic :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def text_at (x = nil, y = nil, width = nil, height = nil)
		text_for(nil, x, y, width, height)
	end

	def words_for (*args)
		_confidences(text_for(*args).split(/\s+/))
	end

	def words_at (*args)
		_confidences(text_at(*args).split(/\s+/))
	end

private
	def _init
		@api.end

		@variables.each {|name, value|
			@api.set_variable(name.to_s, value.to_s)
		}

		@api.init(File.expand_path(@path), API.to_language_code(@language), @mode)
	end

	def _confidences (words)
		pointer = @api.all_word_confidences
		current = 0

		while (tmp = pointer.get_int(current)) != -1
			break unless words[current]

			words[current].instance_eval {
				@confidence = tmp

				class << self
					attr_reader :confidence
				end
			}

			current += 1
		end

		C::free_array_of_int(pointer)

		words
	end
end

end
