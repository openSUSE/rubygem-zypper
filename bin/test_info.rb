#!/usr/bin/ruby

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib/')))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "Info: " + zypper.package.info(:package => 'less').inspect

puts "Installed? " + zypper.package.installed?(:package => 'less').inspect
