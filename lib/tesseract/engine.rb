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
	attr_reader :config

	namedic :path, :language, :mode, :variables,
		:optional => { :path => '.', :language => :eng, :mode => :DEFAULT, :variables => {} },
		:alias    => { :data => :path, :lang => :language }
	def initialize (path = '.', language = :eng, mode = :DEFAULT, variables = {}) # :yields: self
		@api = API.new

		@initializing = true

		@path      = path
		@language  = language
		@mode      = mode
		@variables = variables
		@config    = []

		yield self if block_given?

		@initializing = false

		_init
	end

	def version
		@api.version
	end

	def load_config (*config)
		@config.concat config.flatten.compact.uniq

		unless @initializing
			@config.each {|conf|
				@api.read_config_file(conf)
			}
		end
	end

	def with (&block) # :yields: self
		self.class.new(@path, @language, @mode, @variables.clone, &block)
	end

	def set (name, value)
		@variables[name] = value

		@api.set_variable(name.to_s, value.to_s)
	end

	def get (name)
		@api.get_variable(name.to_s) || @variables[name]
	end

	%w(path language mode).each {|name|
		define_method name do
			instance_variable_get "@#{name}"
		end

		define_method "#{name}=" do |value|
			instance_variable_set "@#{name}", value

			_init unless @initializing
		end
	}

	def blacklist (what = nil)
		if what
			set 'tessedit_char_blacklist', what.respond_to?(:to_a) ? what.to_a.join : what.to_s
		else
			get 'tessedit_char_blacklist'.chars.to_a
		end
	end

	def whitelist (what = nil)
		if what
			set 'tessedit_char_whitelist', what.respond_to?(:to_a) ? what.to_a.join : what.to_s
		else
			get 'tessedit_char_whitelist'.chars.to_a
		end
	end

	def page_segmentation_mode
		@api.get_page_seg_mode
	end

	def page_segmentation_mode= (value)
		@api.page_seg_mode = if value.to_i >= 1 && value.to_i <= 10
			value.to_i
		else
			value.to_s.upcase.to_sym
		end
	end

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
				@unlv       = api.get_unlv
				@confidence = api.mean_text_confidence

				class << self
					attr_reader :unlv, :confidence
				end
			}
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

	namedic :image, :page, :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def chars_for (image = nil, page = nil, x = nil, y = nil, width = nil, height = nil)
		image ||= @image or raise ArgumentError, 'you have to set an image first'
		image   = API.image_for(image)

		page   ||= 0
		x      ||= 0
		y      ||= 0
		width  ||= C::pix_get_width(image)
		height ||= C::pix_get_height(image)

		@api.set_image(image)
		@api.set_rectangle(x, y, width, height)

		@api.get_box(page).lines.map {|line|
			char, x, y, width, height, page = line.chomp.split ' '

			char.instance_eval {
				@x      = x.to_i
				@y      = y.to_i
				@width  = width.to_i
				@height = height.to_i
				@page   = page.to_i + 1

				class << self
					attr_reader :x, :y, :width, :height, :page
				end
			}

			char
		}
	end

	namedic :page, :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def chars_at (page = nil, x = nil, y = nil, width = nil, height = nil)
		chars_for(nil, page, x, y, width, height)
	end

private
	def _init
		@api.end

		@api.init(File.expand_path(@path), API.to_language_code(@language), @mode)

		@variables.each {|name, value|
			@api.set_variable(name.to_s, value.to_s)
		}

		@config.each {|conf|
			@api.read_config_file(conf)
		}
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
