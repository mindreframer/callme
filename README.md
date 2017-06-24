# IocRb [![Build Status](https://travis-ci.org/AlbertGazizov/ioc_rb.png)](https://travis-ci.org/AlbertGazizov/ioc_rb) [![Code Climate](https://codeclimate.com/github/AlbertGazizov/ioc_rb.png)](https://codeclimate.com/github/AlbertGazizov/ioc_rb)



IocRb is an Inversion of Control container for Ruby.
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

IocRb eliminates the manual injection step and injects dependencies by itself.
To use it you need to instantiate IocRb::Container and pass dependency definitions(we call them beans) to it:
```ruby
container = IocRb::Container.new do |c|
  c.bean(:appender, class: Appender)
  c.bean(:logger, class: Logger) do
    attr :appender, ref: :appender
  end
end
```
Now you can get the Logger instance from container with already set dependencies and use it:
```ruby
logger = container[:logger]
logger.info('some message')
```

To simplify injection IocRb allows you specify dependencies inside of your class:
```ruby
class Logger
  inject :appender

  def info(message)
    # do some work with appender
  end
end

class Appender
end
```
With `inject` keyword you won't need to specify class dependencies in bean definition:
```ruby
container = IocRb::Container.new do |c|
  c.bean(:appender, class: Appender)
  c.bean(:logger, class: Logger)
end
```



## Inheriting from other containers
Quite often you will want to selectively override some parts of the system, use `IocRb::Container.with_parent` to
create a new container with all the beans copied from the parent container.

```ruby
class ContactBook
  inject :contacts_repository
  inject :validator, ref: :contact_validator
end
class ContactBookService
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

parent = IocRb::Container.new do |c|
  c.bean(:contacts_repository,  class: ContactsRepository)
  c.bean(:contact_validator,    class: ContactValidator)
  c.bean(:contact_book,         class: ContactBook)
  c.bean(:contact_book_service, class: "ContactBookService")
end
puts parent[:contact_book_service].inspect
#=> #<ContactBookService:0x007fe9e18c3bb0 @contacts_repository=#<ContactsRepository:0x007fe9e18c3b38>, @validator=#<ContactValidator:0x007fe9e18c3a98>>

testcontainer = IocRb::Container.with_parent(parent) do |c|
  c.bean(:contact_validator,    class: TestContactValidator)
end
puts testcontainer[:contact_book_service].inspect
#=> #<ContactBookService:0x007fe9e18c30c0 @contacts_repository=#<ContactsRepository:0x007fe9e18c2fd0>, @validator=#<TestContactValidator:0x007fe9e18c2f08>>

third = IocRb::Container.with_parent(parent) do |c|
  c.bean(:contact_validator,    class: AnotherTestContactValidator)
end

puts third[:contact_book_service].inspect
#=> #<ContactBookService:0x007fe9e18c2328 @contacts_repository=#<ContactsRepository:0x007fe9e18c2238>, @validator=#<AnotherTestContactValidator:0x007fe9e18c21c0>>
```


## Installation

Add this line to your application's Gemfile:

    gem 'ioc_rb'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ioc_rb

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

# TODO
1. Constructor based injection
2. Scope registration, refactor BeanFactory. IocRb:Container.register_scope(SomeScope)
3. Write documentation with more examples

## Author
Albert Gazizov, [@deeper4k](https://twitter.com/deeper4k)
