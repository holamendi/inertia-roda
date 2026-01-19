# inertia-roda.gemspec
Gem::Specification.new do |s|
  s.name = "inertia-roda"
  s.version = "0.1.0"
  s.summary = "Inertia.js adapter for Roda"
  s.description = "A Roda plugin providing server-side Inertia.js adapter"
  s.authors = ["Pablo"]
  s.files = Dir["lib/**/*.rb"]
  s.homepage = "https://github.com/pablo/inertia-roda"
  s.license = "MIT"

  s.required_ruby_version = ">= 2.7.0"

  s.add_dependency "roda", ">= 3.0"

  s.add_development_dependency "minitest", "~> 5.0"
  s.add_development_dependency "rack-test", "~> 2.0"
  s.add_development_dependency "rake", "~> 13.0"
  s.add_development_dependency "tilt", "~> 2.0"
  s.add_development_dependency "standard", "~> 1.0"
end
