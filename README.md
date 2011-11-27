tesseract-ocr - Ruby binding and wrapper
========================================
This wrapper binds the TessBaseAPI object through ffi-inliner (which means it will work on JRuby too)
and then proceeds to wrap said API in a more ruby-esque Engine class.

Making it work
--------------
To make this library work you need tesseract-ocr and leptonica libraries and headers and a C++ compiler.

For now you also need to install my own version of [ffi-inliner](https://github.com/meh/ffi-inliner)
because it's still under review for upstream merging.

Example
-------

```ruby
require 'tesseract'

e = Tesseract::Engine.new(language: :eng)
e.text_for('test/first.png').strip # => 'ABC'
e.words_for('test/second.png') # => ["|'m", "12", "and", "what", "is", "this.", "INSTALL", "GENTOO", "OH", "HAI", "1234"]
```

You can pass to `#text_for` either a path, an IO object or a string containing the image,
there are few supported formats so try to stay in the BMP/JPEG/PNG boundaries. This means
that you can also work on an image with RMagick or similar and then pass the raw data.
