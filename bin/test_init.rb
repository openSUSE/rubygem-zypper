#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib/'))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')

puts "Command returned: " + zypper.refresh_repositories.inspect
puts "Last message: #{zypper.last_message}"
puts "Last error message: #{zypper.last_error_message}"

puts "Command returned: " + zypper.refresh_services.inspect
puts "Last message: #{zypper.last_message}"
puts "Last error message: #{zypper.last_error_message}"
