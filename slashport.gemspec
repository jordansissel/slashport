files = ["Rakefile"]
dirs = %w{app autotest bin config doc lib public spec tasks}
dirs.each do |d|
  files += Dir["#{d}/**/*"] 
end
files << "log"

spec = Gem::Specification.new do |s|
  s.name = 'slashport'
  s.version = '0.15.9'
  s.summary = "slashport"
  s.description = %{slashport}
  s.files = files
  s.add_dependency("merb-core", ">= 1.0.12")
  s.add_dependency("mongrel", ">= 1.1.5")
  s.add_dependency("sequel", ">= 3.5.0")
  s.add_dependency("mysql", ">= 2.8.1")
  s.bindir = "bin"
  s.executables << "slashport"
  s.executables << "slashportfetch"
  s.require_path = '.'
  s.has_rdoc = false
  s.author = "Jordan Sissel"
  s.email = "jls@semicomplete.com"
  s.homepage = "http://www.semicomplete.com/"
end
