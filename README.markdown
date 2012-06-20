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
zypper.add_repository(:url => 'http://example.org/path/to/a/new/repo', :alias => 'New_Repo_at_Example_Org')
```
