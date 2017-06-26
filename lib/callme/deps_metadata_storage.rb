# Storage of dep metadatas
class Callme::DepsMetadataStorage
  def initialize(dep_metadatas = {})
    @dep_metadatas = dep_metadatas
  end

  # Finds dep metadata in storage by it's name
  # @param name [Symbol] dep metadata name
  # @return dep metadata
  def by_name(name)
    @dep_metadatas[name]
  end

  # Saves a given +dep_metadata+ to the storage
  # @param dep_metadata [DepMetadata] dep metadata for saving
  def put(dep_metadata)
    @dep_metadatas[dep_metadata.name] = dep_metadata
  end

  def values
    @dep_metadatas.values
  end

  def keys
    @dep_metadatas.keys
  end

  # Creates an independent copy of this instance
  def copy
    self.class.new(@dep_metadatas.dup)
  end
end
