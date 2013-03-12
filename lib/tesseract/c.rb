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

require 'ffi'
require 'ffi/extra'
require 'ffi/inline'

module Tesseract

module C
	extend FFI::Inline

	inline 'C++' do |cpp|
		cpp.include   'tesseract/strngs.h'
		cpp.libraries 'tesseract'

		cpp.function %{
			void free (void* pointer) {
				free(pointer);
			}
		}

		cpp.function %{
			void free_array_of_char (char* pointer) {
				delete [] pointer;
			}
		}

		cpp.function %{
			void free_array_of_int (int* pointer) {
				delete [] pointer;
			}
		}

		cpp.function %{
			STRING* create_string (void) {
				return new STRING();
			}
		}

		cpp.function %{
			void destroy_string (STRING* value) {
				delete value;
			}
		}

		cpp.function %{
			int string_length (STRING* value) {
				return value->length();
			}
		}

		cpp.function %{
			const char* string_content (STRING* value) {
				return value->string();
			}
		}
	end

	def self.for_enum (what)
		what.is_a?(Integer) ? what : what.to_s.upcase.to_sym
	end
end

end

require 'tesseract/c/leptonica'
require 'tesseract/c/baseapi'
require 'tesseract/c/iterator'
