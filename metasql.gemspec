require_relative 'lib/metasql/version'

Gem::Specification.new do |spec|
  spec.name          = 'metasql'
  spec.version       = Metasql::VERSION
  spec.authors       = ['Nobuo Takizawa']
  spec.email         = ['longzechansheng@gmail.com']
  spec.licenses      = ['MIT']

  spec.summary       = 'Resolve parameters of Metabase flavored query.'
  spec.homepage      = 'https://github.com/nobuyo/metasql'

  spec.required_ruby_version = Gem::Requirement.new('>= 2.5.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/nobuyo/metasql'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
end
