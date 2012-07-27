$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'zypper'

puts "Testing Zypper::Package methods..."

class TestPackage < Test::Unit::TestCase
  include TestHelper

  def setup
    @package = Zypper::Package.new
  end

  def teardown
    unstub
  end

  def test_find
    prepare_data('packages-all')

    assert_equal(13438, @package.find.size)
  end

  def test_installed
    prepare_data('packages-installed')

    assert_equal(332, @package.installed.size)
  end

  def test_available
    prepare_data('packages-uninstalled')

    assert_equal(13106, @package.available.size)
  end

  def test_updates
    prepare_data('list-updates-packages', 'xml')

    assert_equal(41, @package.updates.size)

    update_names = ["PolicyKit", "PolicyKit-doc", "branding-SLES",
      "desktop-translations", "dosfstools", "e2fsprogs", "elfutils", "gfxboot",
      "gfxboot-branding-SLES", "glib2", "glib2-lang", "grep", "insserv",
      "libasm1", "libaugeas0", "libcom_err2", "libdw1", "libebl1", "libelf1",
      "libext2fs2", "libgcrypt11", "libglib-2_0-0", "libgobject-2_0-0",
      "libgpg-error0", "libgthread-2_0-0", "libopenssl0_9_8", "libtiff3",
      "libudev0", "libzypp", "netcfg", "openslp", "openssl", "pam-config",
      "pciutils-ids", "postfix", "sles-release-DVD", "sysvinit", "udev",
      "yast2-trans-en_US", "zypper", "zypper-log"]

    assert_equal(update_names, @package.updates.collect{|update| update[:name]}.sort)
  end

end
