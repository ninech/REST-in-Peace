# -*- encoding: utf-8 -*-
#
$:.push File.expand_path('../lib', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'rest-in-peace'
  s.version     = File.read(File.expand_path('../VERSION', __FILE__)).strip
  s.authors     = ['Raffael Schmid']
  s.email       = ['raffael.schmid@nine.ch']
  s.homepage    = 'http://github.com/ninech/'
  s.license     = 'MIT'
  s.summary     = 'REST in peace'
  s.description = 'Let your api REST in peace.'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_runtime_dependency 'activemodel', '>= 3.2', '< 6'
  s.add_runtime_dependency 'addressable', '~> 2.5'

  s.add_development_dependency 'rake', '~> 10.0'
  s.add_development_dependency 'rspec', '~> 3.0'
  s.add_development_dependency 'guard', '~> 2.6', '>= 2.6.1'
  s.add_development_dependency 'guard-rspec', '~> 4.2', '>= 4.2.0'
  s.add_development_dependency 'simplecov', '~> 0.8', '>= 0.8.2'
end
