require_relative 'lib/checklinks/version'

Gem::Specification.new do |spec|
  spec.name          = 'checklinks'
  spec.version       = Checklinks::VERSION
  spec.authors       = ['Chris Seaton']
  spec.email         = ['chris@chrisseaton.com']

  spec.summary       = 'Find broken links in your static website'
  spec.homepage      = 'https://github.com/chrisseaton/checklinks/'
  spec.license       = 'MIT'

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0")
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.5.8'
end
