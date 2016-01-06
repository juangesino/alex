# Alex

[![Gem Version](https://badge.fury.io/rb/alex.svg)](https://badge.fury.io/rb/alex)
[![Code Climate](https://codeclimate.com/github/juangesino/alex/badges/gpa.svg)](https://codeclimate.com/github/juangesino/alex)
[![Dependency Status](https://gemnasium.com/juangesino/alex.svg)](https://gemnasium.com/juangesino/alex)
[![security](https://hakiri.io/github/juangesino/alex/master.svg)](https://hakiri.io/github/juangesino/alex/master)

Alex is a Ruby on Rails template generator. Alex asks the user some questions to generate the templates and then applies the template to the new app.

## Installation
First, make sure you have Ruby installed.

**On a Mac**, open `/Applications/Utilities/Terminal.app` and type:

    ruby -v

If the output looks something like this, you're in good shape:

    ruby 1.9.3p484 (2013-11-22 revision 43786) [x86_64-darwin13.0.0]

If the output looks more like this, you need to [install Ruby][ruby]:
[ruby]: https://www.ruby-lang.org/en/downloads/

    ruby: command not found

**On Linux**, for Debian-based systems, open a terminal and type:

    sudo apt-get install ruby-dev

or for Red Hat-based distros like Fedora and CentOS, type:

    sudo yum install ruby-devel

(if necessary, adapt for your package manager)

**On Windows**, you can install Ruby with [RubyInstaller][].
[rubyinstaller]: http://rubyinstaller.org/downloads/

Once you've verified that Ruby is installed:

    gem install alex

## Usage

To start the wizard just run:

    alex new APPNAME


Then you need to run the alex initialization. Navigate to the new app:

    cd APPNAME/

And run:


    alex init



## Contributing

1. Fork it ( https://github.com/juangesino/alex/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
