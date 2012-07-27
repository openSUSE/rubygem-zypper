require 'zypper/update'

class Zypper
  class Patch < Update

    class Status
      NEEDED         = 'needed'
      INSTALLED      = 'applied'
      NOT_APPLICABLE = 'not-needed'
    end

    class Category
      SECURITY    = 'security'
      RECOMMENDED = 'recommended'
      FEATURE     = 'feature'
      OPTIONAL    = 'optional'
    end

    FILTER_OPTIONS = [:name, :edition, :arch, :category, :status, :pkgmanager,
                      :restart, :interactive, :repository_url, :repository_alias]

    # Lists all patches
    #
    # @param Hash with optional key :where (Hash)
    #        that can consist of one or more parameters from
    #        :repository, :name, :version, :category, and :status.
    #        Logical AND is always applied for all the options present
    #
    # @example
    #   find(:status => Zypper::Patch::Status::INSTALLED)
    def find(options = {})
      apply_filters(find_updates(options.merge(:type => :patch)), options)
    end

    # Lists all known patches
    def all(options = {})
      find(options)
    end

    # All applicable patches
    def applicable(options = {})
      find(options.merge(:status => Status::NEEDED))
    end

    # Are there any applicable patches present?
    def applicable?(options = {})
      applicable(options).size > 0
    end

    # Installs all applicable patches
    def install(options = {})

      run(build_command('patch', options))
    end

    # All installed patches
    def installed(options = {})
      find(options.merge(:status => Status::INSTALLED))
    end

    private

    # Filters patches according to given parameters
    #
    # @param (Array) patches
    # @param (Hash)  filters criteria, possible keys are :name, :edition, :arch, :category, :status,
    #                :pkgmanager, :restart, :interactive, :repository_url, :repository_alias
    #
    # @example
    #   apply_patch_filters(patches, { :status => 'needed' })
    #   apply_patch_filters(patches, { :edition => '1887', ... })
    def apply_filters(patches = [], filters = {})
      filters.each {|filter_key, filter_value|
        raise "Unknown filter parameter '#{filter_key}'" unless FILTER_OPTIONS.include? filter_key

        case filter_key
          when :repository_url
            patches = patches.select{|patch| patch[:source][:url] == filter_value}
          when :repository_alias
            patches = patches.select{|patch| patch[:source][:alias] == filter_value}
          else
            patches = patches.select{|patch| patch[filter_key] == filter_value}
        end
      }
      patches
    end

  end
end
