class Zypper
  require 'rubygems'
  require 'fileutils'
  require 'shellwords'
  require 'popen4'

  DEFAULT_ROOT = '/'
  DEFAULT_IMPORT_GPG = true
  DEFAULT_REFRESH_REPO = true
  DEFAULT_CHROOT_METHOD = 'local'

  CHROOT_METHOD_LOCAL  = 'local'
  CHROOT_METHOD_CHROOT = 'chroot'
  KNOWN_CHROOT_METHODS = [CHROOT_METHOD_LOCAL, CHROOT_METHOD_CHROOT]

  NORET_COMMANDS_GET = 'boolean'

  # Only getters are public
  attr_reader :last_message, :last_error_message, :last_exit_status

  # Constructor
  #
  # Possible parameters
  #   (string)  :root - Defines the changed root environment, default '/'
  #   (boolean) :auto_import_gpg - Automatically trust (and import) new GPG keys, default true
  #   (boolean) :refresh_repo - Adds new repositories with autorefresh flag, default true
  #   (string)  :chroot_method - Defines which zypper is used; 'local' uses the local zypper
  #                              with changed root directory specified as --root parameter
  #                              whereas 'chroot' uses chroot binary and calls zypper directly
  #                              in the :root directory. This can be ignored if changed :root
  #                              is not defined
  def initialize(params = {})
    @root = params[:root].nil? ?
      DEFAULT_ROOT : params[:root]

    if ! File.exists? @root
      raise "Directory #{@root} does not exist"
    elsif ! File.directory? @root
      raise "#{@root} is not a directory"
    end

    @auto_import_gpg = params[:auto_import_gpg].nil? ?
      DEFAULT_IMPORT_GPG : params[:auto_import_gpg]

    @refresh_repo = params[:refresh_repo].nil? ?
      DEFAULT_REFRESH_REPO : params[:refresh_repo]

    @chroot_method = params[:chroot_method].nil? ?
      DEFAULT_CHROOT_METHOD : params[:chroot_method]

    unless KNOWN_CHROOT_METHODS.include? @chroot_method
      raise "Unknown chroot method #{@chroot_method}, possible are #{KNOWN_CHROOT_METHODS.join(', ')}"
    end
  end

  # Refreshes repositories
  #   @param (optional) options
  #     :force - to force the refresh
  #     :force_rebuild - forces rebuilding the libzypp database
  def refresh_repositories(options = {})
    run build_command('refresh', options), :get => NORET_COMMANDS_GET
  end

  # Refreshes services
  def refresh_services(options = {})
    run build_command('refresh-services', options), :get => NORET_COMMANDS_GET
  end

  private

  # Setters are private
  attr_writer :last_message, :last_error_message, :last_exit_status

  # Returns the full zypper command including chroot, zypper command, options, etc.
  def build_command(zypper_command, options = {})
    chrooted + ' zypper ' + global_options + ' ' + zypper_command + ' ' + zypper_command_options(zypper_command, options)
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
    end

    ret_options.join(' ')
  end

  # Returns string with global zypper options
  def global_options
    [
      '--non-interactive',
      (auto_import_gpg? ? '--gpg-auto-import-keys' : '')
    ].join(' ')
  end

  def chrooted?
    @chroot_method == CHROOT_METHOD_CHROOT
  end

  def chrooted
    chrooted? ? 'chroot ' + Shellwords::escape(@root) + ' ' : ''
  end

  def changed_root?
    @chroot_method == CHROOT_METHOD_LOCAL
  end

  def changed_root
    changed_root? ? ' --root=' + Shellwords::escape(@root) + ' ' : ''
  end

  def auto_import_gpg?
    @auto_import_gpg
  end

  # Runs a command given as argument and returns the full output
  # Exit status can be acquired using last_exit_status call
  def run command, params = {}
    # FIXME: it's here just for debugging
    puts "DEBUG: " + command

    cmd_ret = POpen4::popen4(command) do |stdout, stderr, stdin, pid|
      self.last_message       = stdout.read.strip
      self.last_error_message = stderr.read.strip
    end
    last_exit_status = cmd_ret.exitstatus

    if params[:get] == 'boolean'
      last_exit_status == 0
    else
      last_message
    end
  end
end
