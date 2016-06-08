lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'png_canvas'

Gem::Specification.new do |gem|
  gem.name          = 'png_canvas'
  gem.version       = PngCanvas::VERSION
  gem.authors       = ['Daniel Cruz Horts']
  gem.summary       = %q{A minimalist library to render PNG images using pure Ruby}
  gem.homepage      = 'https://github.com/dncrht/png_canvas'
  gem.license       = 'MIT'

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'rspec', '>= 3'
  gem.add_development_dependency 'pry-byebug'
end
