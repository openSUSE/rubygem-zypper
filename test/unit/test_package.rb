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
    prepare_data('packages-all', 'xml')

    assert_equal(13438, @package.find.size)
  end

  def test_installed
    prepare_data('packages-installed', 'xml')

    assert_equal(332, @package.installed.size)
  end

  def test_available
    prepare_data('packages-uninstalled', 'xml')

    assert_equal(13106, @package.available.size)
  end

end
