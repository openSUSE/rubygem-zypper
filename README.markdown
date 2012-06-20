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

#### Zypper Version ####

```ruby
zypper.version

# Returns
{:major=>1, :minor=>3, :revision=>7}
```

### Repositories ###
### Packages ###
