require 'rubygems'
require 'mocha'
require 'fileutils'

require 'zypper'
require 'zypper/repository'
require 'zypper/service'
require 'zypper/package'
require 'zypper/patch'

module TestHelper
  OUT_SUFFIX  = 'STDOUT'
  ERR_SUFFIX  = 'STDERR'
  EXIT_SUFFIX = 'EXIT'

  DATA_PATH = File.join(File.dirname(__FILE__), 'unit', 'data')

  def unstub
    Mocha::Mockery.instance.stubba.unstub_all
  end

  def get_file_content(file, suffix = 'boolean')
    filename = File.join(DATA_PATH, "#{file}.#{suffix}")

    if File.exist? filename
      File.read(filename)
    elsif suffix == 'EXIT'
      0  # Default exit code
    else
      '' # Default message
    end
  end

  def prepare_data(data_file, return_type)
    out_std  = get_file_content(data_file, OUT_SUFFIX)
    out_err  = get_file_content(data_file, ERR_SUFFIX)
    out_exit = Integer(get_file_content(data_file, EXIT_SUFFIX))

    # FIXME: Hardcoded 'xml' and 0

    # XML returns text
    if (return_type == 'xml')
      Zypper.any_instance.stubs(:run).returns(out_std)
      Zypper::Repository.any_instance.stubs(:run).returns(out_std)
      Zypper::Service.any_instance.stubs(:run).returns(out_std)
      Zypper::Package.any_instance.stubs(:run).returns(out_std)
      Zypper::Patch.any_instance.stubs(:run).returns(out_std)
    # Otherwise returns boolean
    else
      Zypper.any_instance.stubs(:run).returns(out_exit == 0)
      Zypper::Repository.any_instance.stubs(:run).returns(out_exit == 0)
      Zypper::Service.any_instance.stubs(:run).returns(out_exit == 0)
      Zypper::Package.any_instance.stubs(:run).returns(out_exit == 0)
      Zypper::Patch.any_instance.stubs(:run).returns(out_exit == 0)
    end

    {
      :last_message => out_std,
      :last_error_message => out_err,
      :last_exit_status => out_exit
    }.each do |method, ret|
      Zypper.any_instance.stubs(method).returns(ret)
      Zypper::Repository.any_instance.stubs(method).returns(ret)
      Zypper::Service.any_instance.stubs(method).returns(ret)
      Zypper::Package.any_instance.stubs(method).returns(ret)
      Zypper::Patch.any_instance.stubs(method).returns(ret)
    end
  end

end
