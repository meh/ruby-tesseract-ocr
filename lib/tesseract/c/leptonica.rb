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
	extend FFI::Inliner

	inline 'C++' do |cpp|
		cpp.include   'leptonica/allheaders.h'
		cpp.libraries 'lept'

		cpp.function %{
			Pix* pix_read (const char* path) {
				return pixRead(path);
			}
		}

		cpp.function %{
			Pix* pix_read_fd (int fd) {
				return pixReadStream(fdopen(fd, "rb"), 0);
			}
		}

		cpp.function %{
			Pix* pix_read_mem (const l_uint8* data, size_t size) {
				return pixReadMem(data, size);
			}
		}

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
