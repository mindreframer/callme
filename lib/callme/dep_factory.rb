# Instantiates deps according to their scopes
class Callme::DepFactory
  attr_reader :const_loader

  # Constructor
  # @param deps_metadata_storage [DepsMetadataStorage] storage of dep metadatas
  def initialize(const_loader, deps_metadata_storage)
    @const_loader           = const_loader
    @deps_metadata_storage  = deps_metadata_storage
    @singleton_scope        = Callme::Scopes::SingletonScope.new(self)
    @prototype_scope        = Callme::Scopes::PrototypeScope.new(self)
    @request_scope          = Callme::Scopes::RequestScope.new(self)
  end

  # Get dep from the container by it's +name+.
  # According to the dep scope it will be newly created or returned already
  # instantiated dep
  # @param [Symbol] dep name
  # @return dep instance
  # @raise MissingDepError if dep with the specified name is not found
  def get_dep(name)
    dep_metadata = @deps_metadata_storage.by_name(name)
    unless dep_metadata
      raise Callme::Errors::MissingDepError, "Dep with name :#{name} is not defined"
    end
    get_dep_with_metadata(dep_metadata)
  end

  # Get dep by the specified +dep metadata+
  # @param [DepMetadata] dep metadata
  # @return dep instance
  def get_dep_with_metadata(dep_metadata)
    get_scope_by_metadata(dep_metadata).get_dep(dep_metadata)
  end

  # Create new dep instance according
  # to the specified +dep_metadata+
  # @param [DepMetadata] dep metadata
  # @return dep instance
  # @raise MissingDepError if some of dep dependencies are not found
  def create_dep_and_save(dep_metadata, deps_storage)
    if dep_metadata.dep_class.is_a?(Class)
      dep_class = dep_metadata.dep_class
    else
      dep_class = const_loader.load_const(dep_metadata.dep_class)
      dep_metadata.fetch_attrs!(dep_class)
    end
    dep = dep_metadata.instance ? dep_class.new : dep_class

    if dep_metadata.has_contract?
      contract_validator.validate(dep_class, dep_metadata.contract, const_loader)
    end

    if dep_metadata.has_factory_method?
      set_dep_dependencies(dep, dep_metadata)
      dep = dep.send(dep_metadata.factory_method)
      deps_storage[dep_metadata.name] = dep
    else
      # put to container first to prevent circular dependencies
      deps_storage[dep_metadata.name] = dep
      set_dep_dependencies(dep, dep_metadata)
    end

    dep
  end

  # Delete dep from the container by it's +name+.
  # @param [Symbol] dep name
  # @raise MissingDepError if dep with the specified name is not found
  def delete_dep(name)
    dep_metadata = @deps_metadata_storage.by_name(name)
    unless dep_metadata
      raise Callme::Errors::MissingDepError, "Dep with name :#{name} is not defined"
    end
    get_scope_by_metadata(dep_metadata).delete_dep(dep_metadata)
  end

  private

  def set_dep_dependencies(dep, dep_metadata)
    dep_metadata.attrs.each do |attr|
      dep_metadata = @deps_metadata_storage.by_name(attr.ref)
      unless dep_metadata
        raise Callme::Errors::MissingDepError, "Dep with name :#{attr.ref} is not defined, check #{dep.class}"
      end
      case dep_metadata.scope
      when :singleton
        dep.send("#{attr.name}=", get_dep(attr.ref))
      when :prototype
        dep.instance_variable_set(:@_callme_dep_factory, self)
        dep.define_singleton_method(attr.name) do
          @_callme_dep_factory.get_dep(attr.ref)
        end
      when :request
        dep.instance_variable_set(:@_callme_dep_factory, self)
        dep.define_singleton_method(attr.name) do
          @_callme_dep_factory.get_dep(attr.ref)
        end
      end
    end
  end

  def get_scope_by_metadata(dep_metadata)
    case dep_metadata.scope
    when :singleton
      @singleton_scope
    when :prototype
      @prototype_scope
    when :request
      @request_scope
    else
      raise Callme::Errors::UnsupportedScopeError, "Dep with name :#{dep_metadata.name} has unsupported scope :#{dep_metadata.scope}"
    end
  end

  def contract_validator
    Callme::ContractValidator.new
  end
end
