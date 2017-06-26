require "spec_helper"

describe "contract validation" do
    class ContactBook
      include Callme::Inject
      inject :contacts_repository
      inject :validator, ref: :contact_validator
    end
    class ContactBookService
      include Callme::Inject
      inject :contacts_repository
      inject :validator, ref: :contact_validator
    end

    class DummyService
      def execute
        put "JUST DO IT!"
      end
    end
    class ContactsRepository
    end
    class ContactValidator
      def validate(item)
      end
    end

    class ContractRepoContract
      def get(id); end
    end
    class ValidatorContract
      def validate(item, opts); end
    end

    class ServiceContract
      def execute; end
    end

    let(:container){
      Callme::Container.new do |c|
        c.dep(:contacts_repository,  class: ContactsRepository, contract: ContractRepoContract)
        c.dep(:contact_validator,    class: ContactValidator, contract: ValidatorContract)
        c.dep(:contact_book,         class: ContactBook)
        c.dep(:contact_book_service, class: "ContactBookService")
        c.dep(:dummy_service,        class: "DummyService", contract: ServiceContract)
        c.dep(:dummy_service2,       class: "DummyService", contract: "ServiceContract")
      end
    }

    it "works when contract matches" do
      container[:dummy_service]
    end

    it "works when contract is declared as string and matches" do
      container[:dummy_service2]
    end

    it "raises when trying to access a dependency with unfullfilled contract: method not present" do
      error_message = {:dep=>ContactsRepository, :contract=>ContractRepoContract, :missing=>[:get]}.inspect
      error_class   = Callme::Errors::DependencyContractMissingMethodsException
      e = expect{
        container[:contacts_repository]
      }.to raise_error(error_class, error_message)
    end

    it "raises when trying to access a dependency with unfullfilled contract: params wrong not present" do
      error_message = "The method signature of method: 'validate' does not match the contract parameters: 'req, item, req, opts'"
      error_class   = Callme::Errors::DependencyContractInvalidParametersException
      e = expect{
        container[:contact_validator]
      }.to raise_error(error_class, error_message)
    end
end