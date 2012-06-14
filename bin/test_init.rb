#!/usr/bin/ruby

$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__), '../lib/'))

require 'zypper'

zypper = Zypper.new(:root => '/chroot-SLES11-SP1', :chroot_method => 'chroot')
puts "Command returned: " + zypper.refresh_repositories(:force => true).inspect
puts "Last message:
------------------------------------------------------------
#{zypper.last_message}
------------------------------------------------------------"
