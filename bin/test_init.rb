#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib/'))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "Refreshing repositories: " + zypper.refresh_repositories.inspect

puts "Refreshing services: " + zypper.refresh_services.inspect

puts "Listing repositories: " + zypper.repositories.inspect
