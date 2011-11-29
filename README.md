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
	e.language  = :eng
	e.blacklist = '|'
}

e.text_for('test/first.png').strip # => 'ABC'

e.image = 'test/second.png'

e.words # [
        #      [ 0] #<Tesseract(93.41653442382812): "|'m">,
        #      [ 1] #<Tesseract(91.11811828613281): "12">,
        #      [ 2] #<Tesseract(85.71760559082031): "and">,
        #      [ 3] #<Tesseract(83.4853515625): "what">,
        #      [ 4] #<Tesseract(86.71072387695312): "is">,
        #      [ 5] #<Tesseract(83.2227783203125): "this.">,
        #      [ 6] #<Tesseract(82.81439208984375): "INSTALL">,
        #      [ 7] #<Tesseract(86.46566772460938): "GENTOO">,
        #      [ 8] #<Tesseract(93.19613647460938): "OH">,
        #      [ 9] #<Tesseract(82.81439208984375): "HAI">,
        #      [10] #<Tesseract(85.9158935546875): "1234">
        #  ]
```

You can pass to `#text_for` either a path, an IO object, a string containing the image or
an object that responds to `#to_blob` (for example  Magick::Image), keep in mind that
the format has to be supported by leptonica.

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
