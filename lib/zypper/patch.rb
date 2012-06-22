require 'zypper/utils'

class Zypper
  class Patch
    include ZypperUtils

    # Lists all patches
    #
    # @param Hash with optional key :where (Hash)
    #        that can consist of one or more parameters from
    #        :repository, :name, :version, :category, and :status.
    #        Logical AND is always applied for all the options present
    #
    # @example
    #   all(:where => {:status => 'Installed'})
    def all(options = {})
      additional_options = {:quiet => true}

      if (run(build_command('patches', options.merge(additional_options))))
        apply_filters(convert_patches(last_message), options.fetch(:where, {}))
      end
    end

    private

    # Current libzypp doesn't support XML output for patches
    def convert_patches(patches)
      out = []
      table_index = 0
      patch = {}

      patches.split("\n").each {|line|
        table_index = table_index + 1
        # Skip the first two - table header
        next if table_index < 3

        line.gsub!(/ +\| +/, '|')
        line.gsub!(/^ +/, '')
        line.gsub!(/ +$/, '')
        patch = line.split '|'

        out.push(
          :repository => patch[0],
          :name       => patch[1],
          :version    => patch[2],
          :category   => patch[3],
          :status     => patch[4]
        )
      }

      out
    end

    # Filters patches according to given parameters
    #
    # @param (Array) patches
    # @param (Hash)  filters criteria, possible keys are :repository, :name, :version, :category and :status
    #
    # @example
    #   apply_patch_filters(patches, { :status => 'Needed' })
    #   apply_patch_filters(patches, { :version' => '1887', :repository => 'SLES11-SP1-Update' })
    def apply_filters(patches = [], filters = {})
      filters.each {|filter_key, filter_value|
        patches = patches.select{|patch| patch[filter_key] == filter_value}
      }
      patches
    end

  end
end
