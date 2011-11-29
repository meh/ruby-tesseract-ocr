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

module Tesseract; class Engine

class FontAttributes
	def initialize (struct)
		@internal = struct
	end

	C::Iterator::FontAttributes.layout.members.each {|name|
		define_method name do
			@internal[name]
		end
	}

	alias bold?       is_bold
	alias italic?     is_italic
	alias underlined? is_underlined
	alias monospace?  is_monospace
	alias serif?      is_serif
	alias smallcaps?  is_smallcaps

	def inspect
		"#<Font(#{id} #{name || 'unknown'} #{pointsize}pt):#{' bold' if bold?}#{' italic' if italic?}#{' underlined' if underlined?}#{' monospace' if monospace?}#{' serif' if serif?}#{' smallcaps' if smallcaps?}>"
	end
end

end; end
