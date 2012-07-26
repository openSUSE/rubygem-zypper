$: << File.join(File.dirname(__FILE__), '..')

require 'test/unit'
require 'test_helper'
require 'repository_helper'
require 'zypper'

puts "Testing Zypper::Service methods..."

class TestService < Test::Unit::TestCase
  include TestHelper
  include RepositoryHelper

  SERVICE_NAME    = 'nu_novell_com_2'
  SERVICE_ALIAS   = 'nu_novell_com_2'
  SERVICE_URL     = 'https://nu.novell.com/?credentials=NCCcredentials'
  SERVICE_TYPE    = 'ris'
  SERVICE_ENABLED = true
  SERVICE_AUTOREF = false

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

  def test_find
    prepare_data('services_2', 'xml')

    services = @service.all.select{|service| service[:name] == SERVICE_NAME}
    assert_equal(1, services.size, "Cannot find service name #{SERVICE_NAME} in #{@service.all}")

    assert_equal(SERVICE_ALIAS,   services[0][:alias],       "Service alias in #{services.inspect} does not match #{SERVICE_ALIAS}")
    assert_equal(SERVICE_URL,     services[0][:url],         "Service URL in #{services.inspect} does not match #{SERVICE_URL}")
    assert_equal(SERVICE_TYPE,    services[0][:type],        "Service type in #{services.inspect} does not match #{SERVICE_TYPE}")
    assert_equal(SERVICE_ENABLED, services[0][:enabled],     "Service #{services.inspect} should be enabled")
    assert_equal(SERVICE_AUTOREF, services[0][:autorefresh], "Service #{services.inspect} should have autorefresh off")

    test_webyast services[0][:repo]
  end
end
