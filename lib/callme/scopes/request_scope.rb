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
    RequestStore.store[:_callme_deps] ||= {}
    if dep = RequestStore.store[:_callme_deps][dep_metadata.name]
      dep
    else
     @dep_factory.create_dep_and_save(dep_metadata, RequestStore.store[:_callme_deps])
    end
  end

  # Delete dep from scope
  # @param dep_metadata [DepMetadata] dep metadata
  def delete_dep(dep_metadata)
    RequestStore.store[:_callme_deps].delete(dep_metadata.name)
  end
end
