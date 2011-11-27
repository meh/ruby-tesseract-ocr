tesseract-ocr - Ruby binding and wrapper
========================================
This wrapper binds the TessBaseAPI object through ffi-inliner (which means it will work on JRuby too)
and then proceeds to wrap said API in a more ruby-esque Engine class.

Example
-------

```ruby
require 'tesseract'

e = Tesseract::Engine.new(language: :eng)
e.text_for('test/first.png').strip # => 'ABC'
```

You can pass to `#text_for` either a path, an IO object or a string containing the image,
there are few supported formats so try to stay in the BMP/JPEG/PNG boundaries. This means
that you can also work on an image with RMagick or similar and then pass the raw data.
