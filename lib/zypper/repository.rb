require 'zypper/utils'

class Zypper
  class Repository
    include ZypperUtils

    # Refreshes repositories
    #   @param (optional) options
    #     :force - to force the refresh
    #     :force_rebuild - forces rebuilding the libzypp database
    def refresh(options = {})
      run build_command('refresh', options)
    end

    # Lists all known repositories
    def all(options = {})
      out = xml_run build_command('repos', options.merge(:get => XML_COMMANDS_GET))
      convert_output(out.fetch(:stream, {}).fetch(:repo_list, {}).fetch(:repo, []), :repo)
    end

    # Adds a new repository defined by options
    #  (string) :url URL/URL
    #  (string) :alias
    def add(options = {})
      run build_command('addrepo', options)
    end

    # Removes a repository defined by options
    #  (string) :alias
    def remove(options = {})
      run build_command('removerepo', options)
    end

  end
end
