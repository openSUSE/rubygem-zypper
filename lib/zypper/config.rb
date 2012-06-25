require 'rubygems'
require 'fileutils'

class Zypper
  class Config

    DEFAULT_ROOT = '/'
    DEFAULT_IMPORT_GPG = true
    DEFAULT_REFRESH_REPO = true
    DEFAULT_AUTO_AGREE_WITH_LICENSES = true
    DEFAULT_CHROOT_METHOD = 'local'

    CHROOT_METHOD_LOCAL  = 'local'
    CHROOT_METHOD_CHROOT = 'chroot'
    KNOWN_CHROOT_METHODS = [CHROOT_METHOD_LOCAL, CHROOT_METHOD_CHROOT]

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
      self.root = (params[:root] || DEFAULT_ROOT)
      self.chroot_method = (params[:chroot_method] || DEFAULT_CHROOT_METHOD)

      @auto_import_gpg = (params[:auto_import_gpg] || DEFAULT_IMPORT_GPG)
      @refresh_repo = (params[:refresh_repo] || DEFAULT_REFRESH_REPO)
      @auto_agree_with_licenses = (params[:auto_agree_with_licenses] || DEFAULT_AUTO_AGREE_WITH_LICENSES)
    end

    attr_accessor :auto_import_gpg

    attr_reader :root, :chroot_method

    # Changes the current root directory, the directory must exist
    def root=(new_root)
      if ! File.exists? new_root
        raise "Directory #{new_root} does not exist"
      elsif ! File.directory? new_root
        raise "#{new_root} is not a directory"
      end

      @root = new_root
    end

    # Changes the current chroot method, see constructor for possible values
    def chroot_method=(new_chroot_method)
      unless KNOWN_CHROOT_METHODS.include? new_chroot_method
        raise "Unknown chroot method #{new_chroot_method}, possible are #{KNOWN_CHROOT_METHODS.join(', ')}"
      end

      @chroot_method = new_chroot_method
    end

    # Using chroot command
    def chrooted?
      chroot_method == CHROOT_METHOD_CHROOT
    end

    # Using zypper --root of the root is actually different
    def changed_root?
      root != DEFAULT_ROOT && chroot_method == CHROOT_METHOD_LOCAL
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

  end
end
