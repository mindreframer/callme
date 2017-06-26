module Callme

  # Callme::Container is the central data store for registering objects
  # used for dependency injection. Users register classes by
  # providing a name and a class to create the object(we call them deps). Deps
  # may be retrieved by asking for them by name (via the [] operator)
  class Container
    DEFAULT_CONST_LOADER = Callme::ConstLoaders::Native

    # Constructor
    # @param resources [Array] array of procs with container's deps definitions
    # @param &block [Proc] optional proc with container's deps definitions
    def initialize(const_loader = DEFAULT_CONST_LOADER, &block)
      @const_loader          = const_loader
      @deps_metadata_storage = Callme::DepsMetadataStorage.new
      @dep_factory           = Callme::DepFactory.new(const_loader, @deps_metadata_storage)

      block.call(self) if block_given?
    end

    # Evaluates the given array of blocks on the container instance
    # what adds new dep definitions to the container
    # @param resources [Array] array of procs with container's deps definitions
    def self.new_with_deps(resources, const_loader = DEFAULT_CONST_LOADER)
      Callme::ArgsValidator.is_array!(resources, :resources)

      self.new(const_loader).tap do |container|
        resources.each do |resource|
          resource.call(container)
        end
      end
    end

    def self.with_parent(parent_container, &block)
      const_loader          = parent_container.instance_variable_get("@const_loader")
      deps_metadata_storage = parent_container.instance_variable_get("@deps_metadata_storage").copy
      container             = self.new(const_loader)
      container.instance_eval do
        @deps_metadata_storage = deps_metadata_storage
        @dep_factory           = Callme::DepFactory.new(const_loader, deps_metadata_storage)
      end
      block.call(container) if block_given?
      container
    end

    # Registers new dep in container
    # @param dep_name [Symbol] dep name
    # @param options [Hash] includes dep class and dep scope
    # @param &block [Proc] the block  which describes dep dependencies,
    #                      see more in the DepMetadata
    def dep(dep_name, options, &block)
      Callme::ArgsValidator.is_symbol!(dep_name, :dep_name)
      Callme::ArgsValidator.is_hash!(options, :options)

      dep = Callme::DepMetadata.new(dep_name, options, &block)
      @deps_metadata_storage.put(dep)
    end

    # Registers new dep in container and replace existing instance if it's instantiated
    # @param dep_name [Symbol] dep name
    # @param options [Hash] includes dep class and dep scope
    # @param &block [Proc] the block  which describes dep dependencies,
    #                      see more in the DepMetadata
    def replace_dep(dep_name, options, &block)
      if @dep_factory.get_dep(dep_name)
        @dep_factory.delete_dep(dep_name)
      end
      dep(dep_name, options, &block)
    end

    def reset!
      @dep_factory = Callme::DepFactory.new(@const_loader, @deps_metadata_storage)
    end

    # Returns dep instance from the container
    # by the specified dep name
    # @param name [Symbol] dep name
    # @return dep instance
    def [](name)
      Callme::ArgsValidator.is_symbol!(name, :dep_name)
      return @dep_factory.get_dep(name)
    end

    def keys
      @deps_metadata_storage.keys
    end

    def inspect
      %Q{<Callme::Container #{@deps_metadata_storage.values.map(&:name)}}
    end

    # Load defined in dep classes
    # this is needed for production usage
    # for eager loading
    def eager_load_dep_classes
      @deps_metadata_storage.values.each do |dep_metadata|
        @const_loader.load_const(dep_metadata.dep_class)
        @const_loader.load_const(dep_metadata.contract) if dep_metadata.contract
      end
    end
  end
end
