module ZypperUtils
  require 'rubygems'
  require 'shellwords'
  require 'popen4'
  require 'nori'

  require 'zypper/config'

  XML_COMMANDS_GET = 'xml'

  PARAMS_FOR_TYPES = {
    :patch => [
      # ['attribute_key', :type_to_convert_to],
      [:interactive, :boolean],
      [:pkgmanager, :boolean],
      [:restart, :boolean],
    ],
    :repo => [
      [:autorefresh, :boolean],
      [:gpgcheck, :boolean],
      [:enabled, :boolean],
    ],
    :service => [
      [:autorefresh, :boolean],
      [:enabled, :boolean],
      # Treat :repo entry as :repo subitem
      [:repo, :subitem],
    ],
  }

  Nori.parser = :nokogiri
  Nori.advanced_typecasting = false

  ATTRIBUTE_STARTS_WITH = '@'[0]

  tag_to_sym = {}

  Nori.configure do |config|
    config.convert_tags_to { |tag|
      if (tag_to_sym.has_key?(tag))
        tag_to_sym[tag]
      else
        old_tag = tag.dup

        if (tag[0] == ATTRIBUTE_STARTS_WITH)
          # cut the '@' from the beginning of the string
          tag.slice!(0)
        end

        tag_to_sym.store(old_tag, tag.to_sym)
        tag_to_sym[old_tag]
      end
    }
  end

  # Only getters are public
  attr_reader :last_message, :last_error_message, :last_exit_status, :config

  # Constructor
  #
  # @param either instance of Zypper::Config class
  #        or hash of options for new Zypper::Config class
  #
  # See Zypper::Config new() for more info
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
      # No checks:
      #   * 'search' used also just with command-line parameters but no particular
      #              object to search for
      #
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
    ret_options = options.fetch(:cmd_options, [])

    case zypper_action
      when 'refresh'
        ret_options = ret_options | [
          options[:force] ? '--force' : '',
          options[:force_build] ? '--force-build' : '',
        ]
      when 'addrepo'
        ret_options = ret_options | [
          config.refresh_repo? ? '--refresh':'',
          options[:url],
          options[:alias],
        ]
      when 'removerepo'
        ret_options = ret_options | [
          options[:alias],
        ]
      when 'install'
        ret_options = ret_options | [
          config.auto_agree_with_licenses? ? '--auto-agree-with-licenses' : '',
          escape_items(options[:packages]),
        ]
      when 'remove'
        ret_options = ret_options | [
          escape_items(options[:packages]),
        ]
      when 'version'
        ret_options = ret_options | [
          '--version',
        ]
      when 'info'
        ret_options = ret_options | [
          escape(options[:package]),
        ]
      when 'search'
        ret_options = ret_options | [
          options[:status] == Zypper::Package::Status::INSTALLED ? '--installed-only' : '',
          options[:status] == Zypper::Package::Status::AVAILABLE ? '--uninstalled-only' : '',

          options[:name] ? '--match-exact ' + escape(options[:name]) : '',
        ]
      when 'list-updates'
        ret_options = ret_options | [
          !options[:type].nil? ? "--type #{escape(options[:type])}" : '',
          '--all',
        ]
    end

    ret_options.join(' ')
  end

  # Returns string with global zypper options
  def global_options(options = {})
    [
      (options[:quiet] ? '--quiet' : ''),
      (config.changed_root? ? '--root=' + Shellwords::escape(config.root) : ''),
      (options[:get] == XML_COMMANDS_GET ? '--xmlout' : ''),
      '--non-interactive',
      (config.auto_import_gpg? ? '--gpg-auto-import-keys' : ''),
    ].join(' ')
  end

  def xml_run(command)
    xml = run(command, {:get => XML_COMMANDS_GET})
    Nori.parse xml
  end

  # Runs a command given as argument and returns the full output
  # Exit status can be acquired using last_exit_status call
  def run(command, params = {})
    cmd_ret = POpen4::popen4(command) do |stdout, stderr, stdin, pid|
      self.last_message       = stdout.read.strip
      self.last_error_message = stderr.read.strip
    end

    self.last_exit_status = cmd_ret.exitstatus

    if params[:get] == XML_COMMANDS_GET
      last_message
    else
      last_exit_status == 0
    end
  end

  # Whatever it gets, returns an Array
  # Sometimes even with the only Array item if not got an Array
  def return_array ret
    if ret.kind_of? Array
      ret
    else
      [ret]
    end
  end

  def convert_output(parsed_stream, type)
    out = []

    params = PARAMS_FOR_TYPES.fetch(type, [])

    for item in return_array(parsed_stream)
      one_item = item

      params.each do |param|
        one_item[param[0]] = convert_entry(item[param[0]], param[0], param[1])
      end

      out << one_item
    end

    out
  end

  def convert_entry(entry, key, to_type = nil)
    return entry unless to_type

    case to_type
      when :boolean
        Boolean(entry)
      when :subitem
        convert_output(entry, key)
      else
        entry
    end
  end

  def boolean_nocache(string)
    return false unless string
    return true if string == true || string =~ (/(true|t|yes|y|1)$/i)
    return false if string == false || string.nil? || string =~ (/(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: '#{string}'")
  end

  @@boolean_cache = {}

  def Boolean(string)
    return @@boolean_cache[string] if @@boolean_cache.has_key?(string)

    @@boolean_cache[string] = boolean_nocache(string)
    @@boolean_cache[string]
  end
end
