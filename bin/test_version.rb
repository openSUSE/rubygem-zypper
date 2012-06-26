#!/usr/bin/ruby

$:.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib/')))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "Version: " + zypper.version.inspect
