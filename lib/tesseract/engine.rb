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

require 'tesseract/api'

require 'tesseract/engine/iterator'

module Tesseract

class Engine
	attr_reader :config

	named :path, :language, :mode, :variables,
		:optional => { :path => '.', :language => :eng, :mode => :DEFAULT, :variables => {}, :config => [] },
		:alias    => { :data => :path, :lang => :language }
	def initialize (path = '.', language = :eng, mode = :DEFAULT, variables = {}, config = [], &block) # :yields: self
		@api = API.new

		@initializing = true

		@init      = block
		@path      = path
		@language  = language
		@mode      = mode
		@variables = variables
		@config    = config
		@rectangle = []

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
		self.class.new(@path, @language, @mode, @variables.clone, @config.clone) {|e|
			@init.call(e) if @init
			block.call(e) if block
		}
	end

	def input= (name)
		@api.set_input_name(name)
	end

	def output= (name)
		@api.set_output_name(name)
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

	def blacklist
		get('tessedit_char_blacklist').chars.to_a
	end

	def blacklist= (value)
		set('tessedit_char_blacklist', value.respond_to?(:to_a) ? value.to_a.join : value.to_s)
	end

	def whitelist
		get('tessedit_char_whitelist').chars.to_a
	end

	def whitelist= (value)
		set('tessedit_char_whitelist', value.respond_to?(:to_a) ? value.to_a.join : value.to_s)
	end

	def page_segmentation_mode
		@api.get_page_seg_mode
	end

	def page_segmentation_mode= (value)
		@psm = C.for_enum(value)

		@api.set_page_seg_mode @psm
	end

	def image= (image)
		@image = image
	end

	named :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def select (x = nil, y = nil, width = nil, height = nil)
		@rectangle = [x, y, width, height]
	end

	named :image, :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def text_for (image = nil, x = nil, y = nil, width = nil, height = nil)
		_setup(image, x, y, width, height)

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

	named :x, :y, :width, :height,
		:optional => 0 .. -1,
		:alias    => { :w => :width, :h => :height }
	def text_at (x = nil, y = nil, width = nil, height = nil)
		text_for(nil, x, y, width, height)
	end

	def text
		text_at
	end

	%w(block paragraph line word symbol).each {|level|
		define_method "each_#{level}" do |&block|
			raise ArgumentError, 'you have to pass a block' unless block

			_iterator.__send__ "each_#{level}", &block
		end

		named :image, :x, :y, :width, :height,
			:optional => 0 .. -1,
			:alias    => { :w => :width, :h => :height }
		define_method "each_#{level}_for" do |image = nil, x = nil, y = nil, width = nil, height = nil, &block|
			self.image = image if image
			select x, y, width, height

			__send__ "each_#{level}", &block
		end

		named :x, :y, :width, :height,
			:optional => 0 .. -1,
			:alias    => { :w => :width, :h => :height }
		define_method "each_#{level}_at" do |x = nil, y = nil, width = nil, height = nil, &block|
			__send__ "each_#{level}_for", nil, x, y, width, height, &block
		end

		define_method "#{level}s" do
			_iterator.__send__ "#{level}s"
		end

		named :image, :x, :y, :width, :height,
			:optional => 0 .. -1,
			:alias    => { :w => :width, :h => :height }
		define_method "#{level}s_for" do |image = nil, x = nil, y = nil, width = nil, height = nil|
			self.image = image if image
			select x, y, width, height

			__send__ "#{level}s"
		end

		named :x, :y, :width, :height,
			:optional => 0 .. -1,
			:alias    => { :w => :width, :h => :height }
		define_method "#{level}s_at" do |x = nil, y = nil, width = nil, height = nil|
			__send__ "#{level}s_for", nil, x, y, width, height
		end
	}

	def process (image, page = nil)
		if page
			@api.process_page(API.image_for(image), page)
		else
			raise ArgumentError, 'the path does not exist' unless File.exists?(image)

			@api.process_pages(image)
		end
	end

protected
	def _init
		@api.end

		@api.init(File.expand_path(@path), API.to_language_code(@language), @mode)

		@variables.each {|name, value|
			@api.set_variable(name.to_s, value.to_s)
		}

		@config.each {|conf|
			@api.read_config_file(conf)
		}

		@api.set_page_seg_mode @psm if @psm
	end

	def _setup (image = nil, x = nil, y = nil, width = nil, height = nil)
		image ||= @image or raise ArgumentError, 'you have to set an image first'
		image   = API.image_for(image)

		if !width && x
			width = image.width - x
		end

		if !height && y
			height = image.height - y
		end

		x      ||= @rectangle[0] || 0
		y      ||= @rectangle[1] || 0
		width  ||= @rectangle[2] || image.width
		height ||= @rectangle[3] || image.height

		if (x + width) > image.width || (y + height) > image.height
			raise IndexError, 'image access out of boundaries'
		end

		@api.set_image(image)
		@api.set_rectangle(x, y, width, height)
	end

	def _recognize
		_setup

		@api.get_text
	end

	def _iterator
		_recognize

		Iterator.new(@api.get_iterator)
	end
end

end
