Gem::Specification.new do |s|
  s.name        = 'capistrano3-multiyaml'
  s.version     = '1.0.0'
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Oleg Yakovenko"]
  s.email       = 'olegykz@gmail.com'
  s.homepage    = 'http://github.com/olegykz/capistrano3-multiyaml'
  s.summary     = 'Capistrano 3 plugin for storing multistage configuration in a YAML file.'
  s.description = 'This plugin simplifies and clarifies the multistage deploy process by reading settings from a simple YAML file that can be updated programatically. Even if the file is only managed by humans, there are still several benefits including centralizing stage/role configuration in one file, discouraging per-stage logic in deference to properly hooked before/after callbacks, and simplified configuration reuse.'

  s.add_runtime_dependency "capistrano",        "~>3"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
