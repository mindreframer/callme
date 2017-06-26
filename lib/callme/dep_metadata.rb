# Stores dep specific data: dep class, name, contract,
# scope and dep dependencies
class Callme::DepMetadata
  attr_reader :name, :dep_class, :scope, :instance, :factory_method, :attrs, :contract

  # Constructor
  # @param name [Symbol] dep name
  # @params options [Hash] includes dep class and scope
  # @params &block [Proc] dep dependencies, has the following structure:
  #   do |c|
  #     attr :some_dependency, ref: :dependency_name
  #     arg  :another_dependency, ref: :another_dependency_name
  #   end
  # here attr means setter injection, arg means constructon injects
  # +some_dependency+ is an attr_accessor defined in the dep class,
  # +ref+ specifies what dependency from container to use to set the attribute
  def initialize(name, options, &block)
    Callme::ArgsValidator.has_key!(options, :class)

    @name           = name
    @dep_class      = options[:class]
    @contract       = options[:contract]
    @scope          = options[:scope] || :singleton
    @instance       = options[:instance].nil? ? true : options[:instance]
    @factory_method = options[:factory_method]
    @attrs          = []

    fetch_attrs!(@dep_class)

    if block
      Dsl.new(@attrs).instance_exec(&block)
    end
  end

  def fetch_attrs!(klass)
    if klass.respond_to?(:_callme_injectable_attrs)
      klass._callme_injectable_attrs.each do |attr, options|
        options[:ref] ||= attr
        @attrs << Callme::DepMetadata::Attribute.new(attr, options)
      end
    end
  end

  def has_factory_method?
    !!@factory_method
  end

  def has_contract?
    !!@contract
  end

  class Attribute
    attr_reader :name, :ref

    def initialize(name, options)
      Callme::ArgsValidator.has_key!(options, :ref)
      @name = name
      @ref  = options[:ref]
    end
  end

  class Dsl
    def initialize(attrs)
      @attrs = attrs
    end

    def attr(name, options)
      @attrs << Callme::DepMetadata::Attribute.new(name, options)
    end

    def arg(name, options)
      @args << Callme::DepMetadata::Attribute.new(name, options)
    end
  end
end
