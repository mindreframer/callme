require 'callme/errors'
require 'callme/args_validator'
require 'callme/bean_metadata'
require 'callme/beans_metadata_storage'
require 'callme/bean_factory'
require 'callme/const_loaders/native'

module Callme

  # Callme::Container is the central data store for registering objects
  # used for dependency injection. Users register classes by
  # providing a name and a class to create the object(we call them beans). Beans
  # may be retrieved by asking for them by name (via the [] operator)
  class Container
    DEFAULT_CONST_LOADER = Callme::ConstLoaders::Native

    # Constructor
    # @param resources [Array] array of procs with container's beans definitions
    # @param &block [Proc] optional proc with container's beans definitions
    def initialize(const_loader = DEFAULT_CONST_LOADER, &block)
      @const_loader           = const_loader
      @beans_metadata_storage = Callme::BeansMetadataStorage.new
      @bean_factory           = Callme::BeanFactory.new(const_loader, @beans_metadata_storage)

      block.call(self) if block_given?
    end

    # Evaluates the given array of blocks on the container instance
    # what adds new bean definitions to the container
    # @param resources [Array] array of procs with container's beans definitions
    def self.new_with_beans(resources, const_loader = DEFAULT_CONST_LOADER)
      Callme::ArgsValidator.is_array!(resources, :resources)

      self.new(const_loader).tap do |container|
        resources.each do |resource|
          resource.call(container)
        end
      end
    end

    def self.with_parent(parent_container, &block)
      const_loader           = parent_container.instance_variable_get("@const_loader")
      beans_metadata_storage = parent_container.instance_variable_get("@beans_metadata_storage").copy
      container              = self.new(const_loader)
      container.instance_eval do
        @beans_metadata_storage = beans_metadata_storage
        @bean_factory           = Callme::BeanFactory.new(const_loader, beans_metadata_storage)
      end
      block.call(container) if block_given?
      container
    end

    # Registers new bean in container
    # @param bean_name [Symbol] bean name
    # @param options [Hash] includes bean class and bean scope
    # @param &block [Proc] the block  which describes bean dependencies,
    #                      see more in the BeanMetadata
    def bean(bean_name, options, &block)
      Callme::ArgsValidator.is_symbol!(bean_name, :bean_name)
      Callme::ArgsValidator.is_hash!(options, :options)

      bean = Callme::BeanMetadata.new(bean_name, options, &block)
      @beans_metadata_storage.put(bean)
    end

    # Registers new bean in container and replace existing instance if it's instantiated
    # @param bean_name [Symbol] bean name
    # @param options [Hash] includes bean class and bean scope
    # @param &block [Proc] the block  which describes bean dependencies,
    #                      see more in the BeanMetadata
    def replace_bean(bean_name, options, &block)
      if @bean_factory.get_bean(bean_name)
        @bean_factory.delete_bean(bean_name)
      end
      bean(bean_name, options, &block)
    end

    def reset!
      @bean_factory = Callme::BeanFactory.new(@const_loader, @beans_metadata_storage)
    end

    # Returns bean instance from the container
    # by the specified bean name
    # @param name [Symbol] bean name
    # @return bean instance
    def [](name)
      Callme::ArgsValidator.is_symbol!(name, :bean_name)
      return @bean_factory.get_bean(name)
    end

    def keys
      @beans_metadata_storage.keys
    end

    # Load defined in bean classes
    # this is needed for production usage
    # for eager loading
    def eager_load_bean_classes
      @beans_metadata_storage.bean_classes.each do |bean_class|
        if !bean_class.is_a?(Class)
          @const_loader.load_const(bean_class)
        end
      end
    end

  end
end
