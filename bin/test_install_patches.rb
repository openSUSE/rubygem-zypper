#!/usr/bin/ruby

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '../lib/')))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

max_loop = 3

while zypper.patches.applicable? and max_loop > 0
  max_loop = max_loop - 1
  puts "There are #{zypper.patches.applicable.size} applicable patches"
  zypper.patches.install
end

if zypper.patches.applicable?
  puts "There are still #{zypper.patches.applicable.size} patches left..."
else
  puts "All applicable patches were installed"
end
