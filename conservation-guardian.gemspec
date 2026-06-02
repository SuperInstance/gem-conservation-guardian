# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "conservation-guardian"
  spec.version       = "0.1.0"
  spec.authors       = ["SuperInstance"]
  spec.email         = ["team@superinstance.com"]
  spec.summary       = "Universal Budget → Profile → Detect → Report pattern for resource conservation"
  spec.description   = "A guardian pattern library that provides budget tracking, usage profiling, waste detection, and conservation reporting for any Ruby project."
  spec.homepage      = "https://github.com/SuperInstance/gem-conservation-guardian"
  spec.license       = "MIT"
  spec.required_ruby_version = ">= 2.7"

  spec.files = Dir["lib/**/*.rb", "README.md"]
  spec.require_paths = ["lib"]
end
