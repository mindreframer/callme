# Singleton scope returns the same dep instance
# on each call
class Callme::Scopes::SingletonScope

  # Constructon
  # @param dep_factory dep factory
  def initialize(dep_factory)
    @dep_factory = dep_factory
  end

  # Returns the same dep instance
  # on each call
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
    @deps ||= {}
  end
end
