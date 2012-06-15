#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib/'))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "Refreshing repositories: " + zypper.refresh_repositories.inspect

puts "Refreshing services: " + zypper.refresh_services.inspect

puts "Listing repositories: " + zypper.repositories.inspect

puts "Adding repository: " + zypper.add_repository(:url => 'http://incorrect', :alias => 'some_alias').inspect

puts "Listing repositories: " + zypper.repositories.inspect

puts "Removing repositories: " + zypper.remove_repository(:alias => 'some_alias').inspect

puts "Listing repositories: " + zypper.repositories.inspect

puts "Listing services: " + zypper.services.inspect

puts "Installing packages: " + zypper.install(:packages => ['less']).inspect

puts "Removing packages: " + zypper.remove(:packages => ['less']).inspect

puts "Patches: " + zypper.patches.inspect
