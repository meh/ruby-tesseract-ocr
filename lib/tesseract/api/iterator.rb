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

module Tesseract; class API

class Iterator
	def initialize (pointer)
		raise ArgumentError, 'the pointer is null' if pointer.nil? || pointer.null?

		@internal = FFI::AutoPointer.new(pointer, self.class.method(:finalize))
	end

	def self.finalize (pointer) # :nodoc:
		C::Iterator.destroy(pointer)
	end

	def begin
		C::Iterator.begin(to_ffi)
	end

	def beginning? (level = :word)
		C::Iterator.is_at_beginning_of(to_ffi, C.for_enum(level))
	end

	def end? (level, element)
		C::Iterator.is_at_final_element(to_ffi, C.for_enum(level), C.for_enum(element))
	end

	def next (level = :word)
		C::Iterator.next(to_ffi, C.for_enum(level))
	end

	def bounding_box (level = :word)
		C::Iterator.bounding_box(to_ffi, C.for_enum(level))
	end

	def get_binary_image (level = :word)
		Image.new(C::Iterator.get_binary_image(to_ffi, C.for_enum(level)))
	end

	def get_image (level = :word, padding = 0)
		image = C::Iterator.get_image(to_ffi, C.for_enum(level), padding)

		Image.new(image[:pix], image[:x], image[:y])
	end

	def baseline (level = :word)
		C::Iterator.baseline(to_ffi, C.for_enum(level))
	end

	def orientation
		C::Iterator.orientation(to_ffi)
	end

	def get_text (level = :word)
		pointer = C::Iterator.get_utf8_text(to_ffi, C.for_enum(level))
		
		return if pointer.null?

		result = pointer.read_string
		result.force_encoding 'UTF-8'

		result
	ensure
		C.free_array_of_char(pointer) unless pointer.null?
	end

	def confidence (level = :word)
		C::Iterator.confidence(to_ffi, C.for_enum(level))
	end

	def block_type
		C::Iterator.block_type(to_ffi)
	end

	def word_font_attributes
		C::Iterator.word_font_attributes(to_ffi)
	end

	def word_is_from_dictionary?
		C::Iterator.word_is_from_dictionary(to_ffi)
	end

	def word_is_numeric?
		C::Iterator.word_is_numeric(to_ffi)
	end

	def symbol_is_superscript?
		C::Iterator.symbol_is_superscript(to_ffi)
	end

	def symbol_is_subscript?
		C::Iterator.symbol_is_subscript(to_ffi)
	end

	def symbol_is_dropcap?
		C::Iterator.symbol_is_dropcap(to_ffi)
	end

	def to_ffi
		@internal
	end
end

end; end
