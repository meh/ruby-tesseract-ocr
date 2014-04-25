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

require 'tesseract/extensions'
require 'tesseract/c'

require 'tesseract/api/image'
require 'tesseract/api/iterator'

module Tesseract

class API
	##
	# Get a pointer to a tesseract-ocr usable image from a path, a string
	# with the data or an IO stream.
	def self.image_for (image)
		Image.new(image)
	end

	##
	# Transform a language code to tesseract-ocr usable codes
	def self.to_language_code (code)
		ISO_639.find(code.to_s.downcase).alpha3
	rescue
		code.to_s
	end

	Types = {
		int:    [:integer],
		bool:   [:boolean],
		double: [:float],
		string: [:str]
	}

	def initialize
		@internal = FFI::AutoPointer.new(C::BaseAPI.create, self.class.method(:finalize))
	end

	def self.finalize (pointer) # :nodoc:
		C::BaseAPI.destroy(pointer)
	end

	def version
		C::BaseAPI.version(to_ffi)
	end

	def set_input_name (name)
		C::BaseAPI.set_input_name(to_ffi, name)
	end

	def set_output_name (name)
		C::BaseAPI.set_output_name(to_ffi, name)
	end

	def set_variable (name, value)
		C::BaseAPI.set_variable(to_ffi, name, value)
	end

	def get_variable (name, type = nil)
		if type.nil?
			type = Types.keys.find { |type| C::BaseAPI.__send__ "has_#{type}_variable", to_ffi, name }

			if type
				C::BaseAPI.__send__ "get_#{type}_variable", to_ffi, name
			end
		else
			unless Types.has_key?(type)
				name, aliases = Types.find { |name, aliases| aliases.member?(type) }

				raise ArgumentError, "unknown type #{type}" unless name

				type = name
			end

			if C::BaseAPI.__send__ "has_#{type}_variable", to_ffi, name
				C::BaseAPI.__send__ "get_#{type}_variable", to_ffi, name
			end
		end
	end

	def init (datapath = Tesseract.prefix || '.', language = 'eng', mode = :DEFAULT)
		unless C::BaseAPI.init(to_ffi, datapath, language.to_s, mode).zero?
			raise 'the API did not Init correctly'
		end
	end

	def read_config_file (path)
		C::BaseAPI.read_config_file(to_ffi, path)
	end

	def get_page_seg_mode
		C::BaseAPI.get_page_seg_mode(to_ffi)
	end

	def set_page_seg_mode (value)
		C::BaseAPI.set_page_seg_mode(to_ffi, value)
	end

	def set_image (pix)
		C::BaseAPI.set_image(to_ffi, pix.is_a?(Image) ? pix.to_ffi : pix)
	end

	def set_rectangle (left, top, width, height)
		C::BaseAPI.set_rectangle(to_ffi, left, top, width, height)
	end

	def process_pages (name)
		result = C.create_string

		unless C::BaseAPI.process_pages(to_ffi, name, result)
			raise 'process_pages failed'
		end

		C.string_content(result).read_string(C.string_length(result))
	ensure
		C.destroy_string(result)
	end

	def process_page (pix, page = 0, name = "")
		result = C.create_string

		unless C::BaseAPI.process_page(to_ffi, pix.is_a?(Image) ? pix.to_ffi : pix, page, name, result)
			raise 'process_page failed'
		end

		C.string_content(result).read_string(C.string_length(result))
	ensure
		C.destroy_string(result)
	end

	def get_iterator
		Iterator.new(C::BaseAPI.get_iterator(to_ffi))
	end

	def get_text
		pointer = C::BaseAPI.get_utf8_text(to_ffi)

		return if pointer.null?

		result = pointer.read_string
		result.force_encoding 'UTF-8'

		result
	ensure
		C.free_array_of_char(pointer) unless pointer.null?
	end

	def get_box (page = 0)
		pointer = C::BaseAPI.get_box_text(to_ffi, page)
		result  = pointer.read_string
		result.force_encoding 'UTF-8'

		result
	ensure
		C.free_array_of_char(pointer)
	end

	def get_unlv
		pointer = C::BaseAPI.get_unlv_text(to_ffi)
		result  = pointer.read_string
		result.force_encoding 'ISO8859-1'

		result
	ensure
		C.free_array_of_char(pointer)
	end

	def mean_text_confidence
		C::BaseAPI.mean_text_conf(to_ffi)
	end

	def all_word_confidences
		C::BaseAPI.all_word_confidences(to_ffi)
	end

	def clear
		C::BaseAPI.clear(to_ffi)
	end

	def end
		C::BaseAPI.end(to_ffi)
	end

	def to_ffi
		@internal
	end
end

end
