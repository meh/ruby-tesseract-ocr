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

module Iterator
	extend FFI::Inline

	inline 'C++' do |cpp|
		cpp.include   'tesseract/resultiterator.h'
		cpp.libraries 'tesseract'

		cpp.raw 'using namespace tesseract;'

		cpp.eval {
			enum :PolyBlockType, [
				:UNKNOWN,
				:FLOWING_TEXT, :HEADING_TEXT, :PULLOUT_TEXT, :TABLE, :VERTICAL_TEXT, :CAPTION_TEXT,
				:FLOWING_IMAGE, :HEADING_IMAGE, :PULLOUT_IMAGE,
				:HORZ_LINE, :VERT_LINE, :NOISE, :COUNT
			]

			enum :PageIteratorLevel, [
				:BLOCK, :PARAGRAPH, :LINE, :WORD, :SYMBOL
			]

			orientation = enum :UP, :RIGHT, :DOWN, :LEFT
			direction   = enum :LEFT_TO_RIGHT, :RIGHT_TO_LEFT, :TOP_TO_BOTTOM

			BoundingBox = Class.new(FFI::Struct) {
				layout \
					:left,   :int,
					:top,    :int,
					:right,  :int,
					:bottom, :int
			}

			Image = Class.new(FFI::Struct) {
				layout \
					:pix,  :pointer,
					:x,    :int,
					:y,    :int
			}

			Baseline = Class.new(FFI::Struct) {
				layout \
					:x1, :int,
					:y1, :int,
					:x2, :int,
					:y2, :int
			}

			Orientation = Class.new(FFI::Struct) {
				layout \
					:orientation,       orientation,
					:writing_direction, direction,
					:textline_order,    direction,
					:deskew_angle,      :float
			}

			FontAttributes = Class.new(FFI::Struct) {
				layout \
				:id,        :int,
				:name,      :string,
				:pointsize, :int,

				:is_bold,       :bool,
				:is_italic,     :bool,
				:is_underlined, :bool,
				:is_monospace,  :bool,
				:is_serif,      :bool,
				:is_smallcaps,  :bool
			}

			typedef BoundingBox.by_value,    :BoundingBox
			typedef Image.by_value,          :Image
			typedef Baseline.by_value,       :Baseline
			typedef Orientation.by_value,    :OrientationResult
			typedef FontAttributes.by_value, :FontAttributes
		}

		cpp.raw %{
			typedef struct BoundingBox {
				int left;
				int top;
				int right;
				int bottom;
			} BoundingBox;

			typedef struct Image {
				Pix* pix;
				int  x;
				int  y;
			} Image;

			typedef struct Baseline {
				int x1;
				int y1;
				int x2;
				int y2;
			} Baseline;

			typedef struct OrientationResult {
				Orientation      orientation;
				WritingDirection writing_direction;
				TextlineOrder    textline_order;
				float            deskew_angle;
			} OrientationResult;

			typedef struct FontAttributes {
				int         id;
				const char* name;
				int         pointsize;

				bool is_bold;
				bool is_italic;
				bool is_underlined;
				bool is_monospace;
				bool is_serif;
				bool is_smallcaps;
			} FontAttributes;
		}

		cpp.function %{
			void destroy (PageIterator* it) {
				delete it;
			}
		}

		cpp.function %{
			void begin (PageIterator* it) {
				it->Begin();
			}
		}

		cpp.function %{
			bool next (PageIterator* it, PageIteratorLevel level) {
				return it->Next(level);
			}
		}

		cpp.function %{
			bool is_at_beginning_of (PageIterator* it, PageIteratorLevel level) {
				return it->IsAtBeginningOf(level);
			}
		}

		cpp.function %{
			bool is_at_final_element (PageIterator* it, PageIteratorLevel level, PageIteratorLevel element) {
				return it->IsAtFinalElement(level, element);
			}
		}

		cpp.function %{
			BoundingBox bounding_box (PageIterator* it, PageIteratorLevel level) {
				BoundingBox result;

				it->BoundingBox(level, &result.left, &result.top, &result.right, &result.bottom);

				return result;
			}
		}

		cpp.function %{
			PolyBlockType block_type (PageIterator* it) {
				return it->BlockType();
			}
		}

		cpp.function %{
			Pix* get_binary_image (PageIterator* it, PageIteratorLevel level) {
				return it->GetBinaryImage(level);
			}
		}

		cpp.function %{
			Image get_image (PageIterator* it, PageIteratorLevel level, int padding) {
				Image result;

				result.pix = it->GetImage(level, padding, result.pix, &result.x, &result.y);

				return result;
			}
		}

		cpp.function %{
			Baseline baseline (PageIterator* it, PageIteratorLevel level) {
				Baseline result;

				it->Baseline(level, &result.x1, &result.y1, &result.x2, &result.y2);

				return result;
			}
		}

		cpp.function %{
			OrientationResult orientation (PageIterator* it) {
				OrientationResult result;

				it->Orientation(&result.orientation, &result.writing_direction, &result.textline_order, &result.deskew_angle);

				return result;
			}
		}

		cpp.function %{
			char* get_utf8_text (ResultIterator* it, PageIteratorLevel level) {
				return it->GetUTF8Text(level);
			}
		}, blocking: true

		cpp.function %{
			float confidence (ResultIterator* it, PageIteratorLevel level) {
				return it->Confidence(level);
			}
		}, blocking: true

		cpp.function %{
			FontAttributes word_font_attributes (ResultIterator* it) {
				FontAttributes result;

				result.name = it->WordFontAttributes(&result.is_bold, &result.is_italic, &result.is_underlined,
					&result.is_monospace, &result.is_serif, &result.is_smallcaps, &result.pointsize, &result.id);

				return result;
			}
		}

		cpp.function %{
			bool word_is_from_dictionary (ResultIterator* it) {
				return it->WordIsFromDictionary();
			}
		}

		cpp.function %{
			bool word_is_numeric (ResultIterator* it) {
				return it->WordIsNumeric();
			}
		}

		cpp.function %{
			bool symbol_is_superscript (ResultIterator* it) {
				return it->SymbolIsSuperscript();
			}
		}

		cpp.function %{
			bool symbol_is_subscript (ResultIterator* it) {
				return it->SymbolIsSubscript();
			}
		}

		cpp.function %{
			bool symbol_is_dropcap (ResultIterator* it) {
				return it->SymbolIsDropcap();
			}
		}
	end
end

end; end
