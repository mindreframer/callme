module Callme::Errors
  # Thrown when a service cannot be located by name.
  class MissingDepError < StandardError; end

  # Thrown when a duplicate service is registered.
  class DuplicateDepError < StandardError; end

  # Thrown when an unsupported dep scope is specified.
  class UnsupportedScopeError < StandardError; end

  class DependencyContractMissingMethodsException < StandardError; end

  class DependencyContractInvalidParametersException < StandardError
    def initialize(method, parameters)
      @method = method
      @parameters = parameters
    end

    def to_s
      parameter_names = @parameters.join(', ')
      "The method signature of method: '#{@method}' does not match the contract parameters: '#{parameter_names}'"
    end
  end
end
