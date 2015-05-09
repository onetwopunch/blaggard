Gem::Specification.new do |s|
  s.name = 'blaggard'
  s.version = '0.1.0'
  s.date = '2013-06-02'
  s.summary = "This is a fork of Grack that adds Branch Level Access control and LDAP Authentication"
  s.description = "This is a fork of Grack that adds Branch Level Access control and LDAP Authentication. This was designed to be used in conjuction with Qualcomm's ChipCode web application"
  s.authors = ['Scott Chacon', 'Dawa Ometto', 'Ryan Canty']
  s.email = 'rcanty@qti.qualcomm.com'
  s.files = `git ls-files`.split("\n")
  s.executables << 'blaggard'
  s.homepage = "https://github.qualcomm.com/rcanty/blaggard"
  s.license = 'MIT'

  s.add_development_dependency('rspec')
  s.add_dependency('rack')
  s.add_dependency('thor')

end
