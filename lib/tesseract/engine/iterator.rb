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

require 'tesseract/engine/bounding_box'
require 'tesseract/engine/baseline'
require 'tesseract/engine/orientation'
require 'tesseract/engine/font_attributes'

module Tesseract; class Engine

class Iterator
	class Element
		def self.for (level)
			Iterator.const_get(level.capitalize)
		rescue
			self
		end

		def initialize (level, iterator)
			@level    = level
			@iterator = iterator
		end

		memoize
		def bounding_box
			BoundingBox.new(@iterator.bounding_box(@level))
		end

		memoize
		def binary_image
			@iterator.get_binary_image(@level) rescue nil
		end

		memoize
		def image
			@iterator.get_image(@level) rescue nil
		end

		memoize
		def baseline
			Baseline.new(@iterator.baseline(@level))
		end

		memoize
		def orientation
			Orientation.new(@iterator.orientation)
		end

		memoize
		def text
			@iterator.get_text(@level)
		end

		memoize
		def confidence
			@iterator.confidence(@level)
		end

		alias to_s text

		def inspect
			"#<Tesseract::#{@level.capitalize}(#{confidence}): #{text.inspect}>"
		end
	end

	class Block < Element
		memoize
		def type
			@iterator.block_type
		end
	end

	class Word < Element
		memoize
		def font_attributes
			FontAttributes.new(@iterator.word_font_attributes)
		end

		memoize
		def from_dictionary?
			@iterator.word_is_from_dictionary?
		end

		memoize
		def numeric?
			@iterator.word_is_numeric?
		end
	end

	class Symbol < Element
		memoize
		def superscript?
			@iterator.symbol_is_superscript?
		end

		memoize
		def subscript?
			@iterator.symbol_is_subscript?
		end

		memoize
		def dropcap?
			@iterator.symbol_is_dropcap?
		end
	end

	def initialize (iterator)
		@iterator = iterator
	end

	%w(block paragraph line word symbol).each {|level|
		define_method "each_#{level}" do |&block|
			return enum_for "each_#{level}" unless block

			@iterator.begin

			begin
				block.call Element.for(level).new(level, @iterator)
			end while @iterator.next level
		end

		define_method "#{level}s" do
			__send__("each_#{level}").map {|e|
				e.methods.each {|name|
					if e.is_memoized?(name)
						e.__send__ name
					end
				}

				e.instance_eval {
					@iterator = nil
				}

				e
			}
		end
	}
end

end; end
