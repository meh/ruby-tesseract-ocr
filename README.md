ruby-tesseract - Ruby bindings and wrapper
==========================================
This wrapper binds the TessBaseAPI object through ffi-inliner (which means it will work on JRuby too)
and then proceeds to wrap said API in a more ruby-esque Engine class.

Making it work
--------------
To make this library work you need tesseract-ocr and leptonica libraries and headers and a C++ compiler.

For now you also need to install my own version of [ffi-inliner](https://github.com/meh/ffi-inliner)
because it's still under review for upstream merging.

The gem is called `tesseract-ocr`.

Example
-------

```ruby
require 'tesseract'

e = Tesseract::Engine.new {|e|
	e.language = :eng

	e.blacklist '|'
}

e.text_for('test/first.png').strip # => 'ABC'
e.words_for('test/second.png') # => ["I'm", "12", "and", "what", "is", "this.", "INSTALL", "GENTOO", "OH", "HAI", "1234"]

e.with { |e| e.whitelist '1234567890' }.text_for('test/second.png') # => "11111 12 3116 1111113115111151\n11157411 6511700\n014 11141 1234\n\n"
```

You can pass to `#text_for` either a path, an IO object or a string containing the image,
there are few supported formats so try to stay in the BMP/JPEG/PNG boundaries. This means
that you can also work on an image with RMagick or similar and then pass the raw data.

Using the binary
----------------
You can also use the shipped executable in the following way:

```bash
> tesseract.rb -h
Usage: tesseract [options]
        --path PATH                  datapath to set
    -l, --language LANGUAGE          language to use
    -m, --mode MODE                  mode to use
    -p, --psm MODE                   page segmentation mode to use
    -u, --unlv                       output in UNLV format
    -c, --confidence                 output the mean confidence of the recognition
    -C, --config PATH...             config files to load
    -b, --blacklist LIST             blacklist the following chars
    -w, --whitelist LIST             whitelist the following chars
> tesseract.rb test/first.png 
ABC
> tesseract.rb -c test/first.png 
86
```
