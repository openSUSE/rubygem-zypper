#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib/'))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "Nr. of installed packages: " + zypper.package.installed().size.inspect
puts "Nr. of available packages: " + zypper.package.available().size.inspect

puts "Package 'less': " + zypper.packages.find(:name => 'less').inspect
puts "Package 'zypp*': " + zypper.packages.find(:name => 'zypp*').inspect
