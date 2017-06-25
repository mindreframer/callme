# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'callme/version'

Gem::Specification.new do |spec|
  spec.name          = "callme"
  spec.version       = Callme::VERSION
  spec.authors       = ["Roman Heinrich", "Albert Gazizov"]
  spec.email         = ["roman.heinrich@gmail.com"]
  spec.description   = %q{Callme: Simple depencency injection lib}
  spec.summary       = %q{Callme: Simple depencency injection lib}
  spec.homepage      = "http://github.com/mindreframer/callme"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(spec)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "request_store"
  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
end
