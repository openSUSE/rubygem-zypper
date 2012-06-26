#!/usr/bin/ruby

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib/')))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "All Patches: " + zypper.patch.all.size.inspect

puts "Installed 1: " + zypper.patch.find(:status => 'Installed').size.inspect

puts "Installed 2: " + zypper.patch.installed.size.inspect

puts "Applicable: " + zypper.patch.applicable.size.inspect
