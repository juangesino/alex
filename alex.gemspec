# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alex/version'

Gem::Specification.new do |spec|
  spec.name          = "alex"
  spec.version       = Alex::VERSION
  spec.authors       = ["Juan I. Gesino"]
  spec.email         = ["juangesino@gmail.com"]
  spec.summary       = %q{Alex Command-line tool.}
  spec.description   = %q{Alex is a Ruby on Rails template generator. Alex asks the user some questions to generate the templates and then applies the template to the new app.}
  spec.homepage      = "https://rubygems.org/gems/alex"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.executables << 'alex'
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'thor', "~> 0.19.1"

  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
  spec.add_development_dependency "aruba", "~> 0.12.0"

end
