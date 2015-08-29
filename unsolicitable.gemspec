$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "unsolicitable/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "unsolicitable"
  s.version     = Unsolicitable::VERSION
  s.authors     = ["Mat Harvard"]
  s.email       = ["mat.harvard@gmail.com"]
  s.homepage    = "https://matharvard.ca/"
  s.summary     = "A spam prevention plugin for Ruby on Rails."
  s.description = "A simple spam prevention plugin for Ruby on Rails applications that does not rely on any third-party services."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.4"

  s.add_development_dependency "sqlite3"
end
