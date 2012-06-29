require 'zypper/utils'

class Zypper
  class Update
    include ZypperUtils

    KNOWN_TYPES = [:patch, :package, :pattern, :product]

    PARAMS_FOR_TYPES = {
      :patch => [
        # ['in_hash_string', :out_hash_symbol],
        ['interactive', :interactive, :boolean],
        ['status', :status],
        ['name', :name],
        ['source', :source],
        ['edition', :edition],
        ['pkgmanager', :pkgmanager, :boolean],
        ['description', :description],
        ['restart', :restart, :boolean],
        ['category', :category],
        ['license', :license],
        ['summary', :summary],
        ['arch', :arch],
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

      # FIXME: check if exists
      params = PARAMS_FOR_TYPES[:patch]

      parsed_stream.fetch('update-status', []).fetch(0, {}).fetch('update-list', []).fetch(0, {}).fetch('update', []).each do |update|
        one_update = {}

        params.each do |param|
          one_update[param[1]] = convert_entry(update[param[0]], param[2])
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
