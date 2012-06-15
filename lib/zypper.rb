class Zypper
  require 'rubygems'
  require 'fileutils'
  require 'shellwords'
  require 'popen4'
  require 'xmlsimple'

  DEFAULT_ROOT = '/'
  DEFAULT_IMPORT_GPG = true
  DEFAULT_REFRESH_REPO = true
  DEFAULT_AUTO_AGREE_WITH_LICENSES = true
  DEFAULT_CHROOT_METHOD = 'local'

  CHROOT_METHOD_LOCAL  = 'local'
  CHROOT_METHOD_CHROOT = 'chroot'
  KNOWN_CHROOT_METHODS = [CHROOT_METHOD_LOCAL, CHROOT_METHOD_CHROOT]

  XML_COMMANDS_GET = 'xml'

  # Only getters are public
  attr_reader :last_message, :last_error_message, :last_exit_status

  # Constructor
  #
  # Possible parameters
  #   (string)  :root
  #             Defines the changed root environment, default '/'
  #   (boolean) :auto_import_gpg
  #             Automatically trust (and import) new GPG keys, default true
  #   (boolean) :refresh_repo
  #             Adds new repositories with autorefresh flag, default true
  #   (string)  :chroot_method
  #             Defines which zypper is used; 'local' uses the local zypper with
  #             changed root directory specified as --root parameter whereas
  #             'chroot' uses chroot binary and calls zypper directly in the
  #             :root directory. This can be ignored if changed :root is not
  #             defined
  #   (boolean  :auto_agree_with_licenses
  #             automatically accept all licenses, otherwise such packages
  #             cannot be installed
  def initialize(params = {})
    self.root = params[:root]

    @auto_import_gpg = params[:auto_import_gpg].nil? ?
      DEFAULT_IMPORT_GPG : params[:auto_import_gpg]

    @refresh_repo = params[:refresh_repo].nil? ?
      DEFAULT_REFRESH_REPO : params[:refresh_repo]

    @auto_agree_with_licenses = params[:auto_agree_with_licenses].nil? ?
      DEFAULT_AUTO_AGREE_WITH_LICENSES : params[:auto_agree_with_licenses]

    self.chroot_method = params[:chroot_method]
  end

  # Changes the current root directory, the directory must exist
  def root=(new_root = DEFAULT_ROOT)
    if ! File.exists? new_root
      raise "Directory #{new_root} does not exist"
    elsif ! File.directory? new_root
      raise "#{new_root} is not a directory"
    end

    @root = new_root
  end

  # Changes the current chroot method, see constructor for possible values
  def chroot_method=(new_chroot_method = DEFAULT_CHROOT_METHOD)
    unless KNOWN_CHROOT_METHODS.include? new_chroot_method
      raise "Unknown chroot method #{new_chroot_method}, possible are #{KNOWN_CHROOT_METHODS.join(', ')}"
    end

    @chroot_method = new_chroot_method
  end

  # Refreshes repositories
  #   @param (optional) options
  #     :force - to force the refresh
  #     :force_rebuild - forces rebuilding the libzypp database
  def refresh_repositories(options = {})
    run build_command('refresh', options)
  end

  # Refreshes services
  def refresh_services(options = {})
    run build_command('refresh-services', options)
  end

  # Lists all known repositories
  def repositories(options = {})
    out = xml_run build_command('repos', options.merge(:get => XML_COMMANDS_GET))
    out.fetch('repo-list', []).fetch(0, {}).fetch('repo', [])
  end

  # Cleans the libzypp cache
  def clean_caches(options = {})
    run build_command('clean', options)
  end

  # Adds a new repository defined by options
  #  (string) :url URL/URL
  #  (string) :alias
  def add_repository(options = {})
    run build_command('addrepo', options)
  end

  # Removes a repository defined by options
  #  (string) :alias
  def remove_repository(options = {})
    run build_command('removerepo', options)
  end

  # Lists all known services
  def services(options = {})
    out = xml_run build_command('services', options.merge(:get => XML_COMMANDS_GET))
    out.fetch('service-list', []).fetch(0, {}).fetch('service', [])
  end

  # Auto-imports all GPG keys from repositories
  def auto_import_keys
    previous_auto_import_gpg = auto_import_gpg
    ret = refresh_repositories
    self.auto_import_gpg = previous_auto_import_gpg
    ret
  end

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

  private

  # Setters are private
  attr_writer :last_message, :last_error_message, :last_exit_status

  attr_reader :root, :chroot_method

  def check_mandatory_options_set(zypper_command, options, mandatory)
    mandatory.each {|option|
      raise "Missing #{option} parameter in #{zypper_command} command" if options[option].nil?
    }
  end

  def check_mandatory_options(zypper_command, options)
    case zypper_command
      when 'addrepo'
        check_mandatory_options_set(zypper_command, options, [:url, :alias])
        # FIXME: check that :url or :alias do not contain any spaces (or special characters)
      when 'removerepo'
        check_mandatory_options_set(zypper_command, options, [:alias])
        # FIXME: check that :url or :alias do not contain any spaces (or special characters)
      when 'install'
        # FIXME: check that :packages do not contain any spaces (or special characters)
        check_mandatory_options_set(zypper_command, options, [:packages])
      when 'remove'
        # FIXME: check that :packages do not contain any spaces (or special characters)
        check_mandatory_options_set(zypper_command, options, [:packages])
    end
  end

  # Returns the full zypper command including chroot, zypper command, options, etc.
  def build_command(zypper_command, options = {})
    check_mandatory_options(zypper_command, options)

    chrooted + ' zypper ' + global_options(options) + ' ' +
      zypper_command + ' ' + zypper_command_options(zypper_command, options)
  end

  def escape_items(items = [])
    items.collect{|package| Shellwords::escape(package)}.join(' ')
  end

  # Returns string of command options depending on a given zypper command
  # combined with provided options
  def zypper_command_options(zypper_command, options = {})
    ret_options = []

    case zypper_command
      when 'refresh'
        ret_options = [
          options[:force] ? '--force' : '',
          options[:force_build] ? '--force-build' : '',
        ]
      when 'addrepo'
        ret_options = [
          refresh_repo? ? '--refresh':'',
          options[:url],
          options[:alias],
        ]
      when 'removerepo'
        ret_options = [
          options[:alias],
        ]
      when 'install'
        ret_options = [
          auto_agree_with_licenses? ? '--auto-agree-with-licenses' : '',
          escape_items(options[:packages]),
        ]
      when 'remove'
        ret_options = [
          escape_items(options[:packages]),
        ]
    end

    ret_options.join(' ')
  end

  # Returns string with global zypper options
  def global_options(options = {})
    [
      (options[:get] == XML_COMMANDS_GET ? '--xmlout' : ''),
      '--non-interactive',
      (auto_import_gpg? ? '--gpg-auto-import-keys' : ''),
    ].join(' ')
  end

  def chrooted?
    chroot_method == CHROOT_METHOD_CHROOT
  end

  def chrooted
    chrooted? ? 'chroot ' + Shellwords::escape(root) + ' ' : ''
  end

  def changed_root?
    chroot_method == CHROOT_METHOD_LOCAL
  end

  def changed_root
    changed_root? ? ' --root=' + Shellwords::escape(root) + ' ' : ''
  end

  def auto_import_gpg?
    @auto_import_gpg
  end

  def auto_agree_with_licenses?
    @auto_agree_with_licenses
  end

  def refresh_repo?
    @refresh_repo
  end

  def xml_run(command)
    xml = run(command, {:get => XML_COMMANDS_GET})
    out = XmlSimple.xml_in(xml)

    if !out["message"].nil?
      errors = out["message"].select{|hash| hash["type"] == "error"}
      self.last_error = errors.collect{|hash| hash["content"]}.join("\n")
    end

    out
  end

  # Runs a command given as argument and returns the full output
  # Exit status can be acquired using last_exit_status call
  def run(command, params = {})
    # FIXME: it's here just for debugging
    puts "DEBUG: " + command

    cmd_ret = POpen4::popen4(command) do |stdout, stderr, stdin, pid|
      self.last_message       = stdout.read.strip
      self.last_error_message = stderr.read.strip
    end

    last_exit_status = cmd_ret.exitstatus

    if params[:get] == XML_COMMANDS_GET
      last_message
    else
      last_exit_status == 0
    end
  end
end
