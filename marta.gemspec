# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'marta/version'

Gem::Specification.new do |spec|
  spec.name          = Marta::NAME
  spec.version       = Marta::VERSION
  spec.authors       = ["Sergei Seleznev"]
  spec.email         = ["s_seleznev_qa@hotmail.com"]

  spec.summary       = "That will be an another one watir-webdriver wrap"
  spec.description   = "Element location tool for your watir autotests."
  spec.homepage      = "https://github.com/sseleznevqa/marta"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) } + Dir.glob("lib/marta/data/*")
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "rspec"
  spec.add_development_dependency "simplecov"
  spec.add_dependency "watir"
  #spec.add_dependency "fileutils"
  spec.add_dependency "json"
end
