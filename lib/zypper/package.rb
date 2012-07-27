require 'zypper/update'

class Zypper
  class Package < Update

    class Status
      INSTALLED = :installed
      AVAILABLE = :uninstalled
    end

    PACKAGE_STATUSES = {
      ''  => Status::AVAILABLE,
      'i' => Status::INSTALLED,
    }

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
      info(options).fetch(Status::INSTALLED, 'No') == 'Yes'
    end

    # Returns packages found using given parameters
    #
    # @param (Hash) of options
    #   (string) :name - exact name of a package
    #   (symbol) :status - See Zypper::Package::Status class constants
    def find(options = {})
      additional_options = {:cmd_options => ['--type package'], :quiet => true}

      if (run (build_command('search', options.merge(additional_options))))
        convert_packages(last_message)
      end
    end

    # Returns all installed packages
    def installed(options = {})
      find(options.merge(:status => Status::INSTALLED))
    end

    # Returns all available packages (that are not installed yet)
    def available(options = {})
      find(options.merge(:status => Status::AVAILABLE))
    end

    # Finds all package updates
    def updates(options = {})
      find_updates(options.merge(:type => :package))
    end

    private

    def status(status)
      return PACKAGE_STATUSES[status] if PACKAGE_STATUSES[status]

      raise "Unknown package status '#{status}'"
    end

    # SLE11 zypper doesn't support XML output for packages yet
    def convert_packages(packages)
      out = []
      table_header_lines = 3
      package = {}

      for line in packages.split("\n")
        # Skip the table header
        if table_header_lines > 0
          table_header_lines = table_header_lines - 1
          next
        end

        line.strip!
        package = line.split(%r{ *\| *})

        out << {
          :status  => status(package[0]),
          :name    => package[1],
          :summary => package[2],
          :type    => package[3]
        }
      end

      out
    end

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
