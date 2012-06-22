#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib/'))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "Refreshing repositories: " + zypper.repository.refresh.inspect

puts "Refreshing services: " + zypper.service.refresh.inspect

puts "Listing repositories: " + zypper.repository.all.inspect

puts "Adding repository: " + zypper.repository.add(:url => 'http://incorrect', :alias => 'some_alias').inspect

puts "Listing repositories: " + zypper.repository.all.inspect

puts "Removing repositories: " + zypper.repository.remove(:alias => 'some_alias').inspect

puts "Listing repositories: " + zypper.repository.all.inspect

puts "Listing services: " + zypper.service.all.inspect

puts "Installing packages: " + zypper.package.install(:packages => ['less']).inspect

puts "Removing packages: " + zypper.package.remove(:packages => ['less']).inspect

puts "Patches: " + zypper.patch.all.inspect
