# Zypper Library #

This library provides Ruby access to libzypp using the
`zypper` command.

## License ##

Distributed under the MIT license, see LICENSE file.

## Features ###

* Running zypper in chroot
* Running your system zypper over a different root directory
* Installing and removing packages
* Adding and removing repositories
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
zypper.add_repository(:url => 'http://example.org/new/repo', :alias => 'Repo_at_Example_Org')
```

## Public Methods ##

### Global ###

#### Constructor ###

```ruby
zypper = Zypper.new(parameters)
```

All parameters are optional, using their default value if not set.

Possible parameters in hash:
* :root => '/changed-root' - defaults to '/'
* :chroot_method => 'local' or 'chroot'
* :refresh_repo => true or false - default for all newly added repositories
* :auto_agree_with_licenses => true or false - default for installing packages

#### Zypper Output ####

* last_message - STDOUT of the last zypper call
* last_error_message - STDERR of the last zypper call
* last_exit_status - exit code (integer) of the last zypper call

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

#### Listing repositories ####

```ruby
repositories

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
add_repository(:url => 'http://repository/URI', :alias => 'repository_alias')

# returns
true or false
```

#### Removing a Repository ####

```ruby
remove_repository(:alias => 'repository_alias')

# returns
true or false
```

#### Refreshing Repositories ####

```ruby
refresh_repositories(parameters)

# returns
true or false
```

Possible optional parameters:
* :force - forces a complete refresh
* :force_build - forces rebuild of the database

### Services ###

#### Listing Services ####

```ruby
services
```

#### Refreshing Services ####

```ruby
refresh_services

# returns
true or false
```

### Packages ###

#### Installing Packages ####

```ruby
install(:packages => ['package', 'package', ...])

# returns
true or false
```

`package` string can consist of NAME[.ARCH][OP<VERSION>], where OP is one
of <, <=, =, >=, >, for example:

```ruby
install :packages => ['less.x86_64=424b-10.22']
```

#### Removing Packages ####

```ruby
remove(:packages => ['package', 'package', ...])

# returns
true or false
```

`package` string can consist of NAME[.ARCH][OP<VERSION>], where OP is one
of <, <=, =, >=, >, for example:

```ruby
remove :packages => ['less.x86_64=424b-10.22']
```

#### Package Info ####

```ruby
info(:package => 'package')

# Returns, e.g.
{
  :status=>"not installed", :version=>"424b-10.22",
  :summary=>"Text File Browser and Pager Similar to more", :arch=>"x86_64",
  :repository=>"SLES11-SP1-x68_64", :size=>"266.0 KiB",
  :vendor=>"SUSE LINUX Products GmbH, Nuernberg, Germany",
  :name=>"less", :installed=>"No", :level=>"Level 3"
}
```

### Patches ###

#### Listing Patches ####

```ruby
patches(parameters)

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
* :status => 'Status'
* :category => 'Category'
* :name => 'Exact-Name'
* :version => 'Exact-Version'
* :catalog => 'Repo-of-Origin'
