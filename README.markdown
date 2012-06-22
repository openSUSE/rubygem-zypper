# Zypper Library #

This library provides Ruby access to libzypp using the
`zypper` command.

## License ##

Distributed under the MIT license, see LICENSE file.

## Features ###

* Easy-to-use API
* Running zypper in chroot or running your system zypper over a different root directory
* Handling packages, repositories and patches
* Easy to extend

## Usage ##

Require the library

```ruby
require "zypper"
```

Initialize new access to the library methods

```ruby
zypper = Zypper.new()
```

Add a new repository

```ruby
zypper.repository.add(:url => 'http://example.org/new/repo', :alias => 'Repo_at_Example_Org')
```

## Public Methods ##

### Global ###

#### Constructor ###

```ruby
zypper = Zypper.new(parameters)
# or
config = Zypper::Config.new(parameters)
zypper = Zypper.new(config)
```

All parameters are optional, using their default value if not set.

Possible parameters in hash:
* :root => '/changed-root' - defaults to '/'
* :chroot_method => 'local' (calls local zypper with changed root) or 'chroot' (calls zypper in chroot)
* :refresh_repo => true or false - default for all newly added repositories
* :auto_agree_with_licenses => true or false - default for installing packages, applying patches...

Example:
```ruby
zypper = Zypper.new(:chroot => '/some-chroot-dir', :chroot_method => 'chroot')
```

#### Zypper Output ####

These methods work after calling all API functions:

* last_message - unparsed STDOUT of the last zypper call
* last_error_message - unparsed STDERR of the last zypper call
* last_exit_status - exit code (integer) of the last zypper call

Example:
```ruby
zypper.last_message
```

#### Zypper Version ####

```ruby
version

# returns
{:major=>1, :minor=>3, :revision=>7}
```

#### Caches Cleanup ####

```ruby
clean_caches

# returns
true or false
```

#### Importing All used GPG Keys ####

```ruby
auto_import_keys

# returns
true or false
```

### Repositories ###

You can access the repositories class either with
```ruby
zypper = Zypper.new
zypper.repository
# or
zypper.repositories
```
or
```ruby
Zypper::Repository.new
```

#### Listing repositories ####

```ruby
zypper.repositories.all

# returns
[
  { "enabled"=>"1", "autorefresh"=>"1", "name"=>"SLES11-SP1-x68_64", "url"=>["http://repo/URI"],
    "type"=>"rpm-md", "alias"=>"repository_alias", "gpgcheck"=>"1" },
  { ... },
  ...
]
```

#### Adding a Repository ####

```ruby
zypper.repository.add(:url => 'http://repository/URI', :alias => 'repository_alias')

# returns
true or false
```

Example:
```ruby
Zypper.new.repository.add(:url => 'http://repository/URI', :alias => 'repository_alias')
# or
Zypper::Repository.new.add(:url => 'http://repository/URI', :alias => 'repository_alias')
```

#### Removing a Repository ####

```ruby
zypper.repository.remove(:alias => 'repository_alias')

# returns
true or false
```

#### Refreshing Repositories ####

```ruby
zypper.repository.refresh(parameters)

# returns
true or false
```

Possible optional parameters:
* :force - forces a complete refresh
* :force_build - forces rebuild of the database

### Services ###

You can access the services class either with
```ruby
zypper = Zypper.new
zypper.service
# or
zypper.services
```
or
```ruby
Zypper::Service.new
```

#### Listing Services ####

```ruby
zypper.services.all
```

Example:
```ruby
Zypper.new.services.all
# or
Zypper::Services.new.all
```

#### Refreshing Services ####

```ruby
zypper.services.refresh

# returns
true or false
```

### Packages ###

#### Installing Packages ####

You can access the packages class either with
```ruby
zypper = Zypper.new
zypper.package
# or
zypper.packages
```
or
```ruby
Zypper::Package.new
```

```ruby
zypper.packages.install(:packages => ['package', 'package', ...])

# returns
true or false
```

`package` string can consist of NAME[.ARCH][OP<VERSION>], where OP is one
of <, <=, =, >=, >, for example:

```ruby
zypper.package.install :packages => ['less.x86_64=424b-10.22']
```

#### Removing Packages ####

```ruby
zypper.packages.remove(:packages => ['package', 'package', ...])

# returns
true or false
```

`package` string can consist of NAME[.ARCH][OP<VERSION>], where OP is one
of <, <=, =, >=, >, for example:

```ruby
zypper.package.remove :packages => ['less.x86_64=424b-10.22']
```

#### Installed Packages ####

```ruby
zypper.packages.installed

# returns
[
  {
    :type=>"package", :status=>"i", :summary=>"Package, Patch, Pattern, and Product Management",
    :name=>"libzypp"
  },
  { ... },
  ...
]
```

#### Package Info ####

```ruby
zypper.package.info(:package => 'package')

# Returns, e.g.
{
  :status=>"not installed", :version=>"424b-10.22",
  :summary=>"Text File Browser and Pager Similar to more", :arch=>"x86_64",
  :repository=>"SLES11-SP1-x68_64", :size=>"266.0 KiB",
  :vendor=>"SUSE LINUX Products GmbH, Nuernberg, Germany",
  :name=>"less", :installed=>"No", :level=>"Level 3"
}
```

#### Package Installed? ####

```ruby
zypper.package.installed?(:package => 'package')

# returns
true or false
```

### Patches ###

You can access the patches class either with
```ruby
zypper = Zypper.new
zypper.patch
# or
zypper.patches
```
or
```ruby
Zypper::patch.new
```

#### Listing Patches ####

```ruby
zypper.patches.all(parameters)

# returns
[
  { :status=>'Needed', :category=>'Recommended', :name=>'patch-name',
    :version=>'patch-version', :catalog=>"repository-name"
  },
  { ... },
  ...
]
```
All parameters are optional and can be combined, using their default value if not set.

Possible parameters in hash:

FIXME: document possible statuses and categories

* :where
    * :status => 'Status'
    * :category => 'Category'
    * :name => 'Exact-Name'
    * :version => 'Exact-Version'
    * :catalog => 'Repo-of-Origin'

Example:
zypper.patches.all(:where => {:status => 'Installed', :category => 'recommended'})
