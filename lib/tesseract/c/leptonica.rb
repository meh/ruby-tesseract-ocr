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

module Tesseract; module C

module Leptonica
	extend FFI::Inline

	inline 'C++' do |cpp|
		cpp.include   'leptonica/allheaders.h'
		cpp.libraries 'lept'

		cpp.eval {
			enum :Format, [
				:UNKNOWN, :BMP, :JFIF_JPEG, :PNG,
				:TIFF, :TIFF_PACKBITS, :TIFF_RLE, :TIFF_G3, :TIFF_G4, :TIFF_LZW, :TIFF_ZIP,
				:PNM, :PS, :GIF, :JP2, :WEBP, :LPDF, :DEFAULT, :SPIX
			]
		}

		cpp.typedef 'int32_t', 'Format'

		cpp.function %{
			Pix* pix_read (const char* path) {
				return pixRead(path);
			}
		}, blocking: true

		cpp.function %{
			Pix* pix_read_stream (int fd) {
				return pixReadStream(fdopen(fd, "rb"), 0);
			}
		}, blocking: true

		cpp.function %{
			Pix* pix_read_mem (const l_uint8* data, size_t size) {
				return pixReadMem(data, size);
			}
		}, blocking: true

		cpp.function %{
			bool pix_write_mem (Pix* pix, uint8_t** data, size_t* size, Format format) {
				return pixWriteMem(data, size, pix, format);
			}
		}, blocking: true

		cpp.function %{
			void pix_destroy (Pix* pix) {
				pixDestroy(&pix);
			}
		}

		cpp.function %{
			int32_t pix_get_width (Pix* pix) {
				return pixGetWidth(pix);
			}
		}

		cpp.function %{
			int32_t pix_get_height (Pix* pix) {
				return pixGetHeight(pix);
			}
		}
	end
end

end; end
