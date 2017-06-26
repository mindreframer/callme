require 'request_store'

# Request scope instantiates new dep instance
# on each new HTTP request
class Callme::Scopes::RequestScope

  # Constructon
  # @param dep_factory dep factory
  def initialize(dep_factory)
    @dep_factory = dep_factory
  end

  # Returns a dep from the +RequestStore+
  # RequestStore is a wrapper for Thread.current
  # which clears it on each new HTTP request
  #
  # @param dep_metadata [DepMetadata] dep metadata
  # @returns dep instance
  def get_dep(dep_metadata)
    store[dep_metadata.name] || @dep_factory.create_dep_and_save(dep_metadata, store)
  end

  # Delete dep from scope
  # @param dep_metadata [DepMetadata] dep metadata
  def delete_dep(dep_metadata)
    store.delete(dep_metadata.name)
  end

  private

  def store
    RequestStore.store[:_callme_deps] ||= {}
  end
end
