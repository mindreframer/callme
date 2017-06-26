# Singleton scope returns the same dep instance
# on each call
class Callme::Scopes::SingletonScope

  # Constructon
  # @param dep_factory dep factory
  def initialize(dep_factory)
    @deps = {}
    @dep_factory = dep_factory
  end

  # Returns the same dep instance
  # on each call
  # @param dep_metadata [DepMetadata] dep metadata
  # @returns dep instance
  def get_dep(dep_metadata)
    if dep = @deps[dep_metadata.name]
      dep
    else
      @dep_factory.create_dep_and_save(dep_metadata, @deps)
    end
  end

  # Delete dep from scope
  # @param dep_metadata [DepMetadata] dep metadata
  def delete_dep(dep_metadata)
    @deps.delete(dep_metadata.name)
  end
end
