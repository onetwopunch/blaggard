Gem::Specification.new do |s|
  s.name = 'blaggard'
  s.version = '1.0.1'
  s.date = '2013-06-02'
  s.summary = "This is a fork of Grack that adds Branch Level Access control and LDAP Authentication"
  s.description = "This is a fork of Grack that adds Branch Level Access control and LDAP Authentication"
  s.authors = ['Scott Chacon', 'Dawa Ometto', 'Ryan Canty']
  s.email = 'jrcanty@gmail.com'
  s.files = `git ls-files`.split("\n")
  s.executables << 'blaggard'
  s.homepage = "https://github.com/onetwopunch/blaggard"
  s.license = 'MIT'

  s.add_development_dependency('rspec')
  s.add_dependency('rack')
  s.add_dependency('thor')

end
