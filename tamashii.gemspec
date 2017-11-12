# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'tamashii/version'

Gem::Specification.new do |spec|
  spec.name          = 'tamashii'
  spec.version       = Tamashii::VERSION
  spec.authors       = ['蒼時弦也', 'Liang-Chi Tseng', '五倍紅寶石']
  spec.email         = ['elct9620@frost.tw', 'lctseng@cs.nctu.edu.tw', 'hi@5xruby.tw']

  spec.summary       = %q{The WebSocket framework implement inspired by ActionCable}
  spec.description   = %q{The WebSocket framework implement inspired by ActionCable}
  spec.homepage      = 'https://github.com/5xRuby/tamashii'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    # spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
      'public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency "concurrent-ruby"
  spec.add_runtime_dependency "logger-colors"
  spec.add_runtime_dependency "nio4r"
  spec.add_runtime_dependency "rack"
  spec.add_runtime_dependency "redis"
  spec.add_runtime_dependency "tamashii-common"
  spec.add_runtime_dependency "tamashii-config"
  spec.add_runtime_dependency "tamashii-hookable"
  spec.add_runtime_dependency "websocket-driver"

  spec.add_development_dependency 'bundler', '~> 1.14'
  spec.add_development_dependency "codeclimate-test-reporter"
  spec.add_development_dependency "guard-rspec"
  spec.add_development_dependency "rack-test"
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency "simplecov"
end
