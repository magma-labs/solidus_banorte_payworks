# encoding: UTF-8
$:.push File.expand_path('../lib', __FILE__)
require 'solidus_banorte_payworks/version'

Gem::Specification.new do |s|
  s.name        = 'solidus_banorte_payworks'
  s.version     = SolidusBanortePayworks::VERSION
  s.summary     = 'Extension for Banorte Payworks 2.0'
  s.description = 'This is an extension to receive payments with Banorte Payworks'
  s.license     = 'BSD-3-Clause'

  s.author    = 'MagmaLabs'
  s.email     = 'developers@magmalabs.io'
  s.homepage  = 'http://www.magmalabs.io'

  s.files = Dir["{app,config,db,lib}/**/*", 'LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_dependency 'solidus_core', '>= 2.0.0'

  s.add_development_dependency 'capybara'
  s.add_development_dependency 'sqlite3'
end
