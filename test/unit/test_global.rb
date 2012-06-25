$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'zypper'

puts "Testing global zypper methods..."

class TestGlobal < Test::Unit::TestCase
  include TestHelper

  def setup
    @zypper = Zypper.new
  end

  def teardown
    unstub
  end

  def test_version
    prepare_data('version', 'boolean')

    assert_equal({:major => 1, :minor => 4, :revision => 1001}, @zypper.version)
  end

  def test_clean_caches
    prepare_data('clean_caches', 'boolean')

    assert_equal(true, @zypper.clean_caches)
  end

  def test_auto_import_keys
    prepare_data('auto_import_keys', 'boolean')

    assert_equal(true, @zypper.auto_import_keys)
  end
end
