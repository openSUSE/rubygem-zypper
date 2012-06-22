module ZypperUtils
  require 'rubygems'
  require 'shellwords'
  require 'popen4'
  require 'xmlsimple'

  require 'zypper/config'

  XML_COMMANDS_GET = 'xml'

  # Only getters are public
  attr_reader :last_message, :last_error_message, :last_exit_status, :config

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
    # Config is the given parameter
    if (params.instance_of?(Zypper::Config))
      self.config = params
    # Called directly
    elsif (params.is_a?(Hash))
      self.config = Zypper::Config.new params
    # Unknown call method
    else
      raise "Parameters #{params.inspect} is neither Zypper::Config nor Hash with options"
    end
  end

  private

  # Setters are private
  attr_writer :last_message, :last_error_message, :last_exit_status, :config

  def check_mandatory_options_set(zypper_action, options, mandatory)
    mandatory.each {|option|
      raise "Missing '#{option}' parameter in '#{zypper_action}' action" if options[option].nil?
    }
  end

  def check_mandatory_options(zypper_action, options)
    case zypper_action
      when 'addrepo'
        check_mandatory_options_set(zypper_action, options, [:url, :alias])
        # FIXME: check that :url or :alias do not contain any spaces (or special characters)
      when 'removerepo'
        check_mandatory_options_set(zypper_action, options, [:alias])
        # FIXME: check that :url or :alias do not contain any spaces (or special characters)
      when 'install'
        # FIXME: check that :packages do not contain any spaces (or special characters)
        check_mandatory_options_set(zypper_action, options, [:packages])
      when 'remove'
        # FIXME: check that :packages do not contain any spaces (or special characters)
        check_mandatory_options_set(zypper_action, options, [:packages])
      when 'info'
        # FIXME: check that :package does not contain any spaces (or special characters)
        check_mandatory_options_set(zypper_action, options, [:package])
    end
  end

  def chrooted
    config.chrooted? ? 'chroot ' + Shellwords::escape(config.root) + ' ' : ''
  end

  # Returns the full zypper command including chroot, zypper command, options, etc.
  def build_command(zypper_action, options = {})
    check_mandatory_options(zypper_action, options)

    chrooted + ' zypper ' + global_options(options) + ' ' +
      zypper_command(zypper_action) + ' ' + zypper_command_options(zypper_action, options)
  end

  # Returns a zypper command (shell) defined by an action
  def zypper_command zypper_action
    case zypper_action
      # version is a global option but not a command
      when 'version'
        ''
      else
        zypper_action
    end
  end

  def escape_items(items = [])
    items.collect{|package| Shellwords::escape(package)}.join(' ')
  end

  def escape(item = '')
    Shellwords::escape(item)
  end

  # Returns string of command options depending on a given zypper command
  # combined with provided options
  def zypper_command_options(zypper_action, options = {})
    ret_options = []

    case zypper_action
      when 'refresh'
        ret_options = [
          options[:force] ? '--force' : '',
          options[:force_build] ? '--force-build' : '',
        ]
      when 'addrepo'
        ret_options = [
          config.refresh_repo? ? '--refresh':'',
          options[:url],
          options[:alias],
        ]
      when 'removerepo'
        ret_options = [
          options[:alias],
        ]
      when 'install'
        ret_options = [
          config.auto_agree_with_licenses? ? '--auto-agree-with-licenses' : '',
          escape_items(options[:packages]),
        ]
      when 'remove'
        ret_options = [
          escape_items(options[:packages]),
        ]
      when 'version'
        ret_options = [
          '--version',
        ]
      when 'info'
        ret_options = [
          escape(options[:package])
        ]
    end

    ret_options.join(' ')
  end

  # Returns string with global zypper options
  def global_options(options = {})
    [
      (config.changed_root? ? '--root=' + Shellwords::escape(config.root) : ''),
      (options[:get] == XML_COMMANDS_GET ? '--xmlout' : ''),
      '--non-interactive',
      (config.auto_import_gpg? ? '--gpg-auto-import-keys' : ''),
    ].join(' ')
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
