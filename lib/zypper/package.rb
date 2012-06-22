require 'zypper/utils'

class Zypper
  class Package
    include ZypperUtils

    # Installs packages given as parmeter
    #   (array) :packages
    def install(options = {})
      run build_command('install', options)
    end

    # Removes packages given as parmeter
    #   (array) :packages
    def remove(options = {})
      run build_command('remove', options)
    end

    # Returns hash of information on a package given as parameter
    #   (string) :package
    def info(options = {})
      if (run(build_command('info', options)))
        convert_info(last_message)
      end
    end

    # returns whether a package given as parameter is installed
    #   (string) :package
    def installed?(options = {})
      info(options).fetch(:installed, 'No') == 'Yes'
    end

    private

    def convert_info(info)
      out = {}

      info.split("\n").each do |line|
        if /([[:alnum:]]+): (.+)/.match(line)
          out[$1.downcase.to_sym] = $2
        end
      end

      out
    end

  end
end
