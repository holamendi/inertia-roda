# inertia-roda.gemspec
Gem::Specification.new do |spec|
  spec.name = "inertia-roda"
  spec.version = "0.1.0"
  spec.authors = ["Pablo Orellana"]
  spec.email = ["hola@mendi.cl"]

  spec.summary = "Inertia.js adapter for Roda"
  spec.description = "A Roda plugin providing server-side Inertia.js adapter"
  spec.homepage = "https://github.com/holamendi/inertia-roda"
  spec.license = "MIT"

  spec.required_ruby_version = ">= 3.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/holamendi/inertia-roda"
  spec.metadata["changelog_uri"] = "https://github.com/holamendi/inertia-roda/blob/main/CHANGELOG.md"

  spec.files = Dir["lib/**/*", "LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "roda", "~> 3.0"

  spec.add_development_dependency "minitest", "~> 5.0"
  spec.add_development_dependency "rack-test", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "tilt", "~> 2.0"
  spec.add_development_dependency "standard", "~> 1.0"
end
