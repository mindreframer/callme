module Callme
  # inspired by https://github.com/Sage/sinject/blob/master/lib/sinject/container.rb#L127
  class ContractValidator
    def validate(dependency_class, contract_class, const_loader)
      contract_class = const_loader.load_const(contract_class) if contract_class.is_a?(String)
      #get the methods defined for the contract
      contract_methods = (contract_class.instance_methods - Object.instance_methods)
      #get the methods defined for the dependency
      dependency_methods = (dependency_class.instance_methods - Object.instance_methods)
      #calculate any methods specified in the contract that are not specified in the dependency
      missing_methods = contract_methods - dependency_methods

      if !missing_methods.empty?
        raise Callme::Errors::DependencyContractMissingMethodsException.new({
            dep: dependency_class,
            contract: contract_class,
            missing: missing_methods
        })
      end

      validate_methods(dependency_class, contract_class, contract_methods)
    end

    private

    def validate_methods(dependency_class, contract_class, contract_methods)
      contract_methods.each do |method|
        #contract method parameters
        cmp = contract_class.instance_method(method).parameters
        #dependency method parameters
        dmp = dependency_class.instance_method(method).parameters

        if cmp != dmp
          raise Callme::Errors::DependencyContractInvalidParametersException.new(method, cmp)
        end
      end
    end
  end
end
