$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'zypper'

puts "Testing Zypper::Service methods..."

class TestService < Test::Unit::TestCase
  include TestHelper

  def setup
    @service = Zypper::Service.new
  end

  def teardown
    unstub
  end

  def test_all
    prepare_data('services', 'xml')

    assert_equal(1, @service.all.size)
  end

  def test_more_services
    prepare_data('services_2', 'xml')

    assert_equal(2, @service.all.size)
  end
end
