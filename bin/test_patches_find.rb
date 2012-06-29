#!/usr/bin/ruby

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib/')))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

all_patches = zypper.patch.all

puts "All Patches: " + all_patches.select{|patch| patch[:status] != 'not-needed' && patch[:status] != 'applied'}.inspect
