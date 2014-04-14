spec = Gem::Specification.new do |s|
  s.name = 'wheaties'
  s.version = '1.0.0'
  s.platform = Gem::Platform::RUBY
  s.authors = ['Ross Paffett']
  s.email = ['ross@rosspaffett.com']
  s.homepage = 'https://github.com/raws/wheaties'
  s.summary = 'IRC framework'
  s.description = 'An extensible IRC connection framework.'
  s.license = 'MIT'
  s.files = Dir['lib/**/*.rb']
  s.require_path = 'lib'
  s.executables = ['wheaties', 'wheaties-daemon', 'wheaties-log', 'wheaties-setup']

  s.add_runtime_dependency 'eventmachine', '~> 1.0', '>= 1.0.3'
end
