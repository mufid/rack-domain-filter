lib = File.expand_path('./lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rack/domain_filter/version'

Gem::Specification.new do |spec|
  spec.authors       = ['Muhammad Mufid Afif']
  spec.description   = 'Check Gitlab Web Status via HTTP Response.'
  spec.email         = ['mufidafif@icloud.com']
  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.start_with?('spec/') }
  spec.homepage      = 'https://github.com/wazaundtechnik/rack-subdomain-company'
  spec.licenses      = %w[MIT]
  spec.name          = 'rack-domain-filter'
  spec.require_paths = %w[lib]

  spec.summary       = spec.description
  spec.version       = Rack::DomainFilter::VERSION

  spec.add_dependency 'rack'
  spec.add_dependency 'activesupport'

  # Test and build tools
  # The test shouldn't broken by the incompatible RSpec version.
  # Thus, we need to lock the version.
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'rake', '~> 12.0'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rspec', '~> 3.7.0'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'simplecov-html'

  # Docs, debugger, linter.
  # We don't need to specify the lock version for these documentation
  # Please do adjust our program so that it will always compatible
  # with the latest version of these dependencies
  spec.add_development_dependency 'maruku'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'reek'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'yard'
end
