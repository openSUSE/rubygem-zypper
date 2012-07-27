$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'zypper'

puts "Testing Zypper::Patch methods..."

class TestPatch < Test::Unit::TestCase
  include TestHelper

  def setup
    @patch = Zypper::Patch.new
  end

  def teardown
    unstub
  end

  def test_all
    prepare_data('list-updates-patches', 'xml')

    assert_equal(1331, @patch.all.size)
  end

  def test_applicable
    prepare_data('list-updates-patches', 'xml')

    assert_equal(8, @patch.applicable.size)

    assert_equal(1, @patch.applicable(
      :name => 'slessp2-sysvinit'
    ).size)

    assert_equal(0, @patch.applicable(
      :name => 'no-such-patch-exists'
    ).size)
  end

  def test_applicable?
    prepare_data('list-updates-patches', 'xml')

    assert @patch.applicable?
  end

  def test_installed
    prepare_data('list-updates-patches', 'xml')

    assert_equal(187, @patch.installed.size)

    assert_equal(72, @patch.installed(
      :category => Zypper::Patch::Category::SECURITY
    ).size)
  end

  def test_find
    prepare_data('list-updates-patches', 'xml')

    for test_definition in [
      [8,    {:status => Zypper::Patch::Status::NEEDED}],
      [187,  {:status => Zypper::Patch::Status::INSTALLED}],
      [1136, {:status => Zypper::Patch::Status::NOT_APPLICABLE}],

      [718,  {:category => Zypper::Patch::Category::RECOMMENDED}],
      [25,   {:category => Zypper::Patch::Category::OPTIONAL}],
      [556,  {:category => Zypper::Patch::Category::SECURITY}],
      [32,   {:category => Zypper::Patch::Category::FEATURE}],

      [2,    {:edition => '3970'}],
      [1,    {:edition => '3970', :repository_alias => 'nu_novell_com:SLES11-SP1-Updates'}],

      [767,  {:repository_url => 'https://nu.novell.com/repo/$RCE/SLES11-SP1-Updates/sle-11-x86_64?credentials=NCCcredentials'}],
      [8,    {:name => 'slessp1-apache2-mod_php5', :repository_url => 'https://nu.novell.com/repo/$RCE/SLES11-SP1-Updates/sle-11-x86_64?credentials=NCCcredentials'}],

      [11,   {:status => Zypper::Patch::Status::NOT_APPLICABLE, :name => 'sdksp1-libopenssl-devel'}],

      [27,   {:restart => true}],
      [1304, {:restart => false}],

      [1331, {:arch => 'noarch'}],

      [16,   {:pkgmanager => true}],
      [1315, {:pkgmanager => false}],

      [27,   {:interactive => true}],
      [1304, {:interactive => false}],
    ]
      assert_equal(
        test_definition[0],
        @patch.find(test_definition[1]).size,
        "Testing #{test_definition[1].inspect}"
      )
    end
  end
end
