# Yamload

[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)
[![Gem Version](https://badge.fury.io/rb/yamload.svg)](http://badge.fury.io/rb/yamload)
[![Build Status](https://github.com/sealink/yamload/workflows/Build%20and%20Test/badge.svg?branch=master)](https://github.com/sealink/yamload/actions)
[![Coverage Status](https://coveralls.io/repos/sealink/yamload/badge.svg)](https://coveralls.io/r/sealink/yamload)

- YAML files loading
- Recursive conversion to immutable objects
- Default values

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yamload'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yamload

## Usage

Set up the YAML files directory

```ruby
Yamload.dir = File.join(File.dirname(File.expand_path(__FILE__)),'config')
```

e.g. config/test.yml

```yaml
---
test: true
```

Load YAML files from the directory and access keys

```ruby
# Load config/test.yml
loader = Yamload::Loader.new(:test)
loader.content('attribute')
# => true
loader.obj.attribute
# => true
```

Define defaults

```ruby
loader.defaults = { 'test' => true , 'coverage' => { 'minimum' => 0.95 } }
```

## Release

To publish a new version of this gem the following steps must be taken.

* Update the version in the following files
  ```
    CHANGELOG.md
    lib/yamload/version.rb
  ````
* Create a tag using the format v0.1.0
* Follow build progress in GitHub actions


## Contributing

1. Fork it ( https://github.com/sealink/yamload/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
