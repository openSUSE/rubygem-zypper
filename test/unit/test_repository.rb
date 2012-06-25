$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'zypper'

puts "Testing Zypper::Repository methods..."

class TestRepository < Test::Unit::TestCase
  include TestHelper

  def setup
    @repo = Zypper::Repository.new
  end

  def teardown
    unstub
  end

  def test_all
    prepare_data('repos', 'xml')

    assert_equal(19, @repo.all.size)
  end
end
