Kernel.load 'lib/tesseract/version.rb'

Gem::Specification.new {|s|
	s.name         = 'tesseract'
	s.version      = Tesseract.version
	s.author       = 'meh.'
	s.email        = 'meh@paranoici.org'
	s.homepage     = 'http://github.com/meh/ruby-tesseract'
	s.platform     = Gem::Platform::RUBY
	s.summary      = 'A wrapper library to the tesseract-ocr API.'

	s.files         = `git ls-files`.split("\n")
	s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
	s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
	s.require_paths = ['lib']

	s.add_dependency 'namedic'

	s.add_dependency 'ffi-extra'
	s.add_dependency 'ffi-inliner'
}
