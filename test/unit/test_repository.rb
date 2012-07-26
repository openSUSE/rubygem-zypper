$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'zypper'

puts "Testing Zypper::Repository methods..."

class TestRepository < Test::Unit::TestCase
  include TestHelper

  WEBYAST_UPDATES_REPO_NAME  = 'SLE11-WebYaST-SP2-Updates'
  WEBYAST_UPDATES_REPO_ALIAS = 'nu_novell_com:SLE11-WebYaST-SP2-Updates'
  WEBYAST_UPDATES_REPO_URL   = 'https://nu.novell.com/repo/$RCE/SLE11-WebYaST-SP2-Updates/sle-11-x86_64?credentials=NCCcredentials'

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

    assert_equal(false, repos_found[0][:enabled],     "Repository should not be enabled #{repos_found.inspect}")
    assert_equal(true,  repos_found[0][:gpgcheck],    "Repository should have GPG Check enabled #{repos_found.inspect}")
    assert_equal(true,  repos_found[0][:autorefresh], "Repository should have Autorefresh enabled #{repos_found.inspect}")

    assert_equal(WEBYAST_UPDATES_REPO_ALIAS, repos_found[0][:alias], "Repository alias #{repos_found.inspect} does not match #{WEBYAST_UPDATES_REPO_ALIAS}")
    assert_equal(WEBYAST_UPDATES_REPO_URL,   repos_found[0][:url],   "Repository URL #{repos_found.inspect} does not match #{WEBYAST_UPDATES_REPO_URL}")
  end
end
