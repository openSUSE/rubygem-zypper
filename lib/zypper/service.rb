require 'zypper/utils'

class Zypper
  class Service
    include ZypperUtils

    # Refreshes services
    def refresh(options = {})
      run build_command('refresh-services', options)
    end

    # Lists all known services
    def all(options = {})
      out = xml_run build_command('services', options.merge(:get => XML_COMMANDS_GET))
      convert_output(out.fetch(:stream, {}).fetch(:service_list, {}).fetch(:service, []), :service)
    end

  end
end
