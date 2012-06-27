require File.expand_path(File.dirname(__FILE__) + "/lib/zypper/version")

gem_description = "Library for accessing zypper functions such as searching and
installing packages, adding and removing repositories and services. Supports
calling zypper in changed root (both with local zypper and zypper in chroot)."

root_dir = File.expand_path(File.dirname(__FILE__))

Gem::Specification.new do |s|
  s.name        = "zypper"
  s.version     = Zypper::VERSION
  s.date        = "2012-06-27"
  s.summary     = "Library for accessing zypper"
  s.description = gem_description
  s.author      = "Lukas Ocilka"
  s.email       = "lukas.ocilka@gmail.com"
  s.files       = Dir.glob("lib/*.rb") | Dir.glob("lib/zypper/*.rb") | [
    "LICENSE",
    "CHANGELOG",
    "README.markdown",
    "VERSION",
  ]
  s.homepage    = "https://github.com/openSUSE/rubygem-zypper"
  s.license     = "MIT"

  s.add_dependency "popen4"
  s.add_dependency "xml-simple"

  s.add_development_dependency "mocha"
  s.add_development_dependency "rake"
end
