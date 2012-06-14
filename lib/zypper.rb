class Zypper
  require 'rubygems'
  require 'fileutils'
  require 'shellwords'
  require 'popen4'
  require 'xmlsimple'

  DEFAULT_ROOT = '/'
  DEFAULT_IMPORT_GPG = true
  DEFAULT_REFRESH_REPO = true
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
    run build_command('refresh', options)
  end

  # Refreshes services
  def refresh_services(options = {})
    run build_command('refresh-services', options)
  end

  # Lists all known repositories
  def repositories(options = {})
    out = xml_run build_command('repos', options.merge(:get => XML_COMMANDS_GET))
    # FIXME: try
    out['repo-list'][0]['repo'] || []
  end

  def clean_caches(options = {})
    run build_command('clean', options)
  end

  def add_repository(options = {})
    run build_command('addrepo', options)
  end

  def remove_repository(options = {})
    run build_command('removerepo', options)
  end

  private

  # Setters are private
  attr_writer :last_message, :last_error_message, :last_exit_status

  def check_mandatory_options_set(zypper_command, options, mandatory)
    mandatory.each {|option|
      raise "Missing #{option} parameter in #{zypper_command} command" if options[option].nil?
    }
  end

  def check_mandatory_options(zypper_command, options)
    case zypper_command
      when 'addrepo'
        check_mandatory_options_set(zypper_command, options, [:url, :alias])
        # FIXME: check that :url or :alias do not contain any space (or special character)
      when 'removerepo'
        check_mandatory_options_set(zypper_command, options, [:alias])
        # FIXME: check that :url or :alias do not contain any space (or special character)
    end
  end

  # Returns the full zypper command including chroot, zypper command, options, etc.
  def build_command(zypper_command, options = {})
    check_mandatory_options(zypper_command, options)
    chrooted + ' zypper ' + global_options(options) + ' ' + zypper_command + ' ' + zypper_command_options(zypper_command, options)
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
