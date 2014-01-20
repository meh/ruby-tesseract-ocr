ruby-tesseract - Ruby bindings and wrapper
==========================================
This wrapper binds the TessBaseAPI object through ffi-inline (which means it
will work on JRuby too) and then proceeds to wrap said API in a more ruby-esque
Engine class.

Making it work
--------------
To make this library work you need tesseract-ocr and leptonica libraries and
headers and a C++ compiler.

The gem is called `tesseract-ocr`.

If you're on a distribution that separates the libraries from headers, remember
to install the *-dev* package.

On Debian you will need to `libleptonica-dev` and `libtesseract-dev`.

Examples
--------
Following are some examples that show the functionalities provided by
tesseract-ocr.

### Basic functionality of tesseract

```ruby
require 'tesseract'

e = Tesseract::Engine.new {|e|
  e.language  = :eng
  e.blacklist = '|'
}

e.text_for('test/first.png').strip # => 'ABC'
```

You can pass to `#text_for` either a path, an IO object, a string containing
the image or an object that responds to `#to_blob` (for example
Magick::Image), keep in mind that the format has to be supported by leptonica.

### Accessing advanced features

With advanced features you get access to blocks, paragraphs, lines, words and
symbols.

Replace **level** in method names with either `block`, `paragraph`, `line`,
`word` or `symbol`.

The following kind of accessors need a block to be passed and they pass to the
block each `Element` object. The Element object has various getters to access
certain features, I'll talk about them later.

The methods are:

* `each_level`
* `each_level_for`
* `each_level_at`

The following accessors instead return an `Array` of `Element`s with cached
getters, the getters are cached beacause the values accessible in the `Element`
are linked to the state of the internal API, and that state changes if you
access something else.

The methods are:

*	`levels`
*	`levels_for`
*	`levels_at`

Again, to `*_for` methods you can pass what you can pass to a `#text_for`.

Each `Element` object has the following getters:

* `bounding_box`, this will return the box where the element is confined into
* `binary_image`, this will return the bichromatic image of the element
* `image`, this will return the image of the element
* `baseline`, this will return the line where the text is with a pair of
  coordinates
* `orientation`, this will return the orientation of the element
* `text`, this will return the text of the element
* `confidence`, this will return the confidence of correctness for the element

`Block` elements also have `type` accessors that specify the type of the block.

`Word` elements also have `font_attributes`, `from_dictionary?` and `numeric?`
getters.

`Symbol` elements also have `superscript?`, `subscript?` and `dropcap?`
getters.

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

License
-------
The license is BSD one clause.
