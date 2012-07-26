require 'zypper/utils'

class Zypper
  class Update
    include ZypperUtils

    KNOWN_TYPES = [:patch, :package, :pattern, :product]

    DEFALUT_TYPE = :patch

    # Lists all known updates
    def find(options = {})
      options[:type] = DEFALUT_TYPE if options[:type].nil?
      # FIXME: check allowed types

      additional_options = {:quiet => true, :get => XML_COMMANDS_GET, :type => options[:type].to_s}

      out = xml_run build_command('list-updates', options.merge(additional_options))

      convert_output(out.fetch(:stream, {}).fetch(:update_status, {}).fetch(:update_list, {}).fetch(:update, []), options[:type])
      # FIXME: implement filters
    end

  end
end
