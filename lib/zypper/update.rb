require 'zypper/utils'

class Zypper
  class Update
    include ZypperUtils

    KNOWN_TYPES = [:patch, :package, :pattern, :product]

    PARAMS_FOR_TYPES = {
      :patch => [
        # ['attribute_key', :type_to_convert_to],
        [:interactive, :boolean],
        [:pkgmanager, :boolean],
        [:restart, :boolean],
      ]
    }

    DEFALUT_TYPE = :patch

    # Lists all known updates
    def find(options = {})
      options[:type] = DEFALUT_TYPE if options[:type].nil?
      # FIXME: check allowed types

      additional_options = {:quiet => true, :get => XML_COMMANDS_GET, :type => options[:type].to_s}

      out = xml_run build_command('list-updates', options.merge(additional_options))

      convert_output(out, options[:type])
      # FIXME: implement filters
    end
 
    private

    def convert_output(parsed_stream, type)
      out = []

      params = PARAMS_FOR_TYPES.fetch(:patch, DEFALUT_TYPE)

      return_array(parsed_stream.fetch(:stream, {}).fetch(:update_status, {}).fetch(:update_list, {}).fetch(:update, [])).each do |update|
        one_update = update

        params.each do |param|
          one_update[param[0]] = convert_entry(update[param[0]], param[1])
        end

        out << one_update
      end

      out
    end

    def convert_entry(entry, to_type = nil)
      return entry unless to_type

      case to_type
        when :boolean
          Boolean(entry)
        else
          entry
      end
    end

    def Boolean(string)
      return false unless string
      return true if string== true || string =~ (/(true|t|yes|y|1)$/i)
      return false if string== false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
      raise ArgumentError.new("invalid value for Boolean: '#{string}'")
    end

  end
end
