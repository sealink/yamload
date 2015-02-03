# Yamload

[![Gem Version](https://badge.fury.io/rb/yamload.png)](http://badge.fury.io/rb/yamload)
[![Build Status](https://travis-ci.org/sealink/yamload.png?branch=master)](https://travis-ci.org/sealink/yamload)
[![Coverage Status](https://coveralls.io/repos/sealink/yamload/badge.png)](https://coveralls.io/r/sealink/yamload)
[![Dependency Status](https://gemnasium.com/sealink/yamload.png)](https://gemnasium.com/sealink/yamload)
[![Code Climate](https://codeclimate.com/github/sealink/yamload.png)](https://codeclimate.com/github/sealink/yamload)

* YAML files loading
* Recursive conversion to immutable objects
* Schema validation
* Default values

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
loader.loaded_hash('attribute')
# => true
loader.obj.attribute
# => true
```

Define a schema for the configuration
```ruby
# Load config/test.yml
loader = Yamload::Loader.new(:test)
loader.define_schema do |schema|
  schema.string 'test'
end
loader.valid?
# => true
loader.validate!
# => nil
loader.error
# => nil
```

Define defaults
```ruby
loader.defaults = { 'test' => true , 'coverage' => { 'minimum' => 0.95 } }
```

## Contributing

1. Fork it ( https://github.com/sealink/yamload/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
