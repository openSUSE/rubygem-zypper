module Zypper
  # Zypper version (uses [semantic versioning](http://semver.org/)).
  VERSION = File.read(File.dirname(__FILE__) + "/../../VERSION").strip
end
