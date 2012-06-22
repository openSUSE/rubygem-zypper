require 'zypper/utils'

require 'zypper/repository'
require 'zypper/service'
require 'zypper/package'
require 'zypper/patch'

class Zypper
  include ZypperUtils

  attr_reader :repository, :service, :package, :patch

  def initialize(params = {})
    super(params)

    self.repository = Zypper::Repository.new config
    self.service    = Zypper::Service.new    config
    self.package    = Zypper::Package.new    config
    self.patch      = Zypper::Patch.new      config
  end

  # Returns the current zypper version
  def version(options = {})
    if (run(build_command('version', options = {})))
      version_number(last_message, options)
    end
  end

  # Cleans the libzypp cache
  def clean_caches(options = {})
    run build_command('clean', options)
  end

  # Auto-imports all GPG keys from repositories
  def auto_import_keys(options = {})
    previous_auto_import_gpg = config.auto_import_gpg
    ret = refresh_repositories
    config.auto_import_gpg = previous_auto_import_gpg
    ret
  end

  private

  attr_writer :repository, :service, :package, :patch

  def version_number(version_string, options)
    version = version_string.gsub(/[^0-9\.]/, '').split('.')
    {:major => version[0].to_i, :minor => version[1].to_i, :revision => version[2].to_i}
  end
end
