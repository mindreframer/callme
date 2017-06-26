# Prototype scope instantiates new dep instance
# on each +get_dep+ call
class Callme::Scopes::PrototypeScope

  # Constructon
  # @param dep_factory dep factory
  def initialize(dep_factory)
    @dep_factory = dep_factory
  end

  # Get new dep instance
  # @param dep_metadata [BeanMetadata] dep metadata
  # @returns dep instance
  def get_dep(dep_metadata)
    @dep_factory.create_dep_and_save(dep_metadata, {})
  end

  # Delete dep from scope,
  # because Prototype scope doesn't store dep
  # then do nothing here
  #
  # @param dep_metadata [BeanMetadata] dep metadata
  def delete_dep(dep_metadata)
  end
end
