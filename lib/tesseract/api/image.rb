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

class Image
	def self.new (image, x = 0, y = 0)
		image = if image.is_a?(String) && (File.exists?(File.expand_path(image)) rescue nil)
			C::Leptonica.pix_read(File.expand_path(image))
		elsif image.is_a?(String)
			C::Leptonica.pix_read_mem(image, image.bytesize)
		elsif image.is_a?(IO)
			C::Leptonica.pix_read_stream(image.to_i)
		elsif image.respond_to? :to_blob
			image = image.to_blob

			C::Leptonica.pix_read_mem(image, image.bytesize)
		else
			image
		end

		raise ArgumentError, 'invalid image' if image.nil? || image.null?

		super(image, x, y)
	end

	attr_accessor :x, :y

	def initialize (pointer, x = 0, y = 0)
		@internal = FFI::AutoPointer.new(pointer, self.class.method(:finalize))
		@x        = x
		@y        = y
	end

	def self.finalize (pointer)
		C::Leptonica.pix_destroy(pointer)
	end

	def width
		C::Leptonica.pix_get_width(to_ffi)
	end

	def height
		C::Leptonica.pix_get_height(to_ffi)
	end

	def to_blob (format = :default)
		data = FFI::MemoryPointer.new(:pointer)
		size = FFI::MemoryPointer.new(:size_t)

		C::Leptonica.pix_write_mem(to_ffi, data, size, C.for_enum(format))
		result = data.typecast(:pointer).read_string(size.typecast(:size_t))
		C.free(data.typecast(:pointer))

		result
	end

	def to_ffi
		@internal
	end
end

end; end
