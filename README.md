# Callme [![Build Status](https://travis-ci.org/mindreframer/callme.svg)](https://travis-ci.org/mindreframer/callme) [![Code Climate](https://codeclimate.com/github/mindreframer/callme.svg)](https://codeclimate.com/github/mindreframer/callme)



Callme is an Inversion of Control container for Ruby.
It takes advantage of the dynamic nature of Ruby to provide a rich and flexible approach to injecting dependencies.
It's inspired by SpringIoc and tries to give you the same features.

## Usage
Lets say you have a Logger which has the Appender dependency

```ruby
class Logger
  attr_accessor :appender

  def info(message)
    # do some work with appender
  end
end

class Appender
end
```
To use Logger you need to inject the instance of Appender class, for example
using setter injection:
```ruby
logger = Logger.new
logger.appender = Appender.new
logger.info('some message')
```

Callme eliminates the manual injection step and injects dependencies by itself.
To use it you need to instantiate Callme::Container and pass dependency definitions(we call them deps) to it:
```ruby
container = Callme::Container.new do |c|
  c.dep(:appender, class: Appender)
  c.dep(:logger, class: Logger) do
    attr :appender, ref: :appender
  end
end
```
Now you can get the Logger instance from container with already set dependencies and use it:
```ruby
logger = container[:logger]
logger.info('some message')
```

To simplify injection Callme allows you specify dependencies inside of your class:
```ruby
class Logger
  include Callme::Inject
  inject :appender

  def info(message)
    # do some work with appender
  end
end

class Appender
end
```
With `inject` keyword you won't need to specify class dependencies in dep definition:
```ruby
container = Callme::Container.new do |c|
  c.dep(:appender, class: Appender)
  c.dep(:logger, class: Logger)
end
```



## Inheriting from other containers
Quite often you will want to selectively override some parts of the system, use `Callme::Container.with_parent` to
create a new container with all the deps copied from the parent container.

```ruby
class ContactBook
  include Callme::Inject
  inject :contacts_repository
  inject :validator, ref: :contact_validator
end
class ContactBookService
  include Callme::Inject
  inject :contacts_repository
  inject :validator, ref: :contact_validator
end
class ContactsRepository
end
class ContactValidator
end
class TestContactValidator
end

class AnotherTestContactValidator
end

parent = Callme::Container.new do |c|
  c.dep(:contacts_repository,  class: ContactsRepository)
  c.dep(:contact_validator,    class: ContactValidator)
  c.dep(:contact_book,         class: ContactBook)
  c.dep(:contact_book_service, class: "ContactBookService")
end
puts parent[:contact_book_service].validator.class
#=> ContactValidator

testcontainer = Callme::Container.with_parent(parent) do |c|
  c.dep(:contact_validator,    class: TestContactValidator)
end
puts testcontainer[:contact_book_service].validator.class
#=> TestContactValidator

third = Callme::Container.with_parent(parent) do |c|
  c.dep(:contact_validator,    class: AnotherTestContactValidator)
end

puts third[:contact_book_service].validator.class
#=> AnotherTestContactValidator
```


## Installation

Add this line to your application's Gemfile:

    gem 'callme'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install callme

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## Author
Roman Heinrich, [@mindreframer](https://twitter.com/mindreframer)
Albert Gazizov, [@deeper4k](https://twitter.com/deeper4k)
