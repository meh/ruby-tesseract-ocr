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

module BaseAPI
	extend FFI::Inline

	inline 'C++' do |cpp|
		cpp.include   'tesseract/baseapi.h'
		cpp.libraries 'tesseract'

		cpp.raw 'using namespace tesseract;'

		cpp.eval {
			enum :OcrEngineMode, [
				:TESSERACT_ONLY, :CUBE_ONLY, :TESSERACT_CUBE_COMBINED, :DEFAULT
			]

			enum :PageSegMode, [
				:OSD_ONLY, :AUTO_OSD,
				:AUTO_ONLY, :AUTO, :SINGLE_COLUMN, :SINGLE_BLOCK_VERT_TEXT,
				:SINGLE_BLOCK, :SINGLE_LINE, :SINGLE_WORD, :CIRCLE_WORD, :SINGLE_CHAR,
				:COUNT
			]
		}

		cpp.function %{
			TessBaseAPI* create (void) {
				return new TessBaseAPI();
			}
		}

		cpp.function %{
			void destroy (TessBaseAPI* api) {
				delete api;
			}
		}

		cpp.function %{
			const char* version (TessBaseAPI* api) {
				return api->Version();
			}
		}, return: :string

		cpp.function %{
			void set_input_name (TessBaseAPI* api, const char* name) {
				api->SetInputName(name);
			}
		}

		cpp.function %{
			void set_output_name (TessBaseAPI* api, const char* name) {
				api->SetOutputName(name);
			}
		}

		cpp.function %{
			bool set_variable (TessBaseAPI* api, const char* name, const char* value) {
				return api->SetVariable(name, value);
			}
		}

		cpp.function %{
			bool has_int_variable (TessBaseAPI* api, const char* name) {
				int tmp;

				return api->GetIntVariable(name, &tmp);
			}
		}

		cpp.function %{
			bool has_bool_variable (TessBaseAPI* api, const char* name) {
				bool tmp;

				return api->GetBoolVariable(name, &tmp);
			}
		}

		cpp.function %{
			bool has_double_variable (TessBaseAPI* api, const char* name) {
				double tmp;

				return api->GetDoubleVariable(name, &tmp);
			}
		}

		cpp.function %{
			bool has_string_variable (TessBaseAPI* api, const char* name) {
				return api->GetStringVariable(name) != NULL;
			}
		}

		cpp.function %{
			int get_int_variable (TessBaseAPI* api, const char* name) {
				int result = 0;

				api->GetIntVariable(name, &result);

				return result;
			}
		}

		cpp.function %{
			bool get_bool_variable (TessBaseAPI* api, const char* name) {
				bool result = false;

				api->GetBoolVariable(name, &result);

				return result;
			}
		}

		cpp.function %{
			double get_double_variable (TessBaseAPI* api, const char* name) {
				double result = 0;

				api->GetDoubleVariable(name, &result);

				return result;
			}
		}

		cpp.function %{
			const char* get_string_variable (TessBaseAPI* api, const char* name) {
				return api->GetStringVariable(name);
			}
		}, return: :string

		cpp.function %{
			int init (TessBaseAPI* api, const char* datapath, const char* language, OcrEngineMode oem) {
				return api->Init(datapath, language, oem);
			}
		}

		cpp.function %{
			void set_page_seg_mode (TessBaseAPI* api, PageSegMode mode) {
				api->SetPageSegMode(mode);
			}
		}

		cpp.function %{
			PageSegMode get_page_seg_mode (TessBaseAPI* api) {
				return api->GetPageSegMode();
			}
		}

		cpp.function %{
			void set_image (TessBaseAPI* api, Pix* pix) {
				api->SetImage(pix);
			}
		}

		cpp.function %{
			void set_rectangle (TessBaseAPI* api, int left, int top, int width, int height) {
				api->SetRectangle(left, top, width, height);
			}
		}

		cpp.function %{
			bool process_pages (TessBaseAPI* api, const char* filename, TessResultRenderer* output) {
				return api->ProcessPages(filename, NULL, 0, output);
			}
		}, blocking: true

		cpp.function %{
			bool process_page (TessBaseAPI* api, Pix* pix, int page_index, const char* filename, TessResultRenderer* output) {
				return api->ProcessPage(pix, page_index, filename, NULL, 0, output);
			}
		}, blocking: true

		cpp.function %{
			ResultIterator* get_iterator (TessBaseAPI* api) {
				return api->GetIterator();
			}
		}

		cpp.function %{
			char* get_utf8_text (TessBaseAPI* api) {
				return api->GetUTF8Text();
			}
		}, blocking: true

		cpp.function %{
			char* get_hocr_text (TessBaseAPI* api, int page_number) {
				return api->GetHOCRText(page_number);
			}
		}, blocking: true

		cpp.function %{
			char* get_box_text (TessBaseAPI* api, int page_number) {
				return api->GetBoxText(page_number);
			}
		}, blocking: true

		cpp.function %{
			char* get_unlv_text (TessBaseAPI* api) {
				return api->GetUNLVText();
			}
		}, blocking: true

		cpp.function %{
			int mean_text_conf (TessBaseAPI* api) {
				return api->MeanTextConf();
			}
		}, blocking: true

		cpp.function %{
			int* all_word_confidences (TessBaseAPI* api) {
				return api->AllWordConfidences();
			}
		}, blocking: true

		cpp.function %{
			void clear (TessBaseAPI* api) {
				api->Clear();
			}
		}

		cpp.function %{
			void end (TessBaseAPI* api) {
				api->End();
			}
		}
	end

	begin
		inline 'C++' do |cpp|
			cpp.include   'tesseract/baseapi.h'
			cpp.libraries 'tesseract'

			cpp.raw 'using namespace tesseract;'

			cpp.function %{
				void read_config_file (TessBaseAPI* api, const char* filename) {
					api->ReadConfigFile(filename, false);
				}
			}
		end
	rescue CompilationError
		inline 'C++' do |cpp|
			cpp.include   'tesseract/baseapi.h'
			cpp.libraries 'tesseract'

			cpp.raw 'using namespace tesseract;'

			cpp.function %{
				void read_config_file (TessBaseAPI* api, const char* filename) {
					api->ReadConfigFile(filename);
				}
			}
		end
	end
end

end; end
