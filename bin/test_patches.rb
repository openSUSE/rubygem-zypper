#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib/'))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "All Patches: " + zypper.patch.all.inspect

puts "Installed patches: " + zypper.patch.all(:where => {:status => 'Installed'}).inspect
