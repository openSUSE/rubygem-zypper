$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'zypper'

puts "Testing Zypper::Repository methods..."

class TestRepository < Test::Unit::TestCase
  include TestHelper

  WEBYAST_UPDATES_REPO_NAME = 'SLE11-WebYaST-SP2-Updates'

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

  def test_find
    prepare_data('repos', 'xml')

    repos_found = @repo.all.select{|repo| repo[:name] == WEBYAST_UPDATES_REPO_NAME}
    assert_equal(1, repos_found.size)
  end
end
