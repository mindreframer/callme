module Callme::Errors
  # Thrown when a service cannot be located by name.
  class MissingBeanError < StandardError; end

  # Thrown when a duplicate service is registered.
  class DuplicateBeanError < StandardError; end

  # Thrown when an unsupported dep scope is specified.
  class UnsupportedScopeError < StandardError; end
end
