# Extend object with the dep injection mechanism
# Example of usage:
# class Bar
# end
#
# class Foo
#   include Callme::Inject
#   inject :bar
#   or:
#   inject :some_bar, ref: bar
# end
#
# ioc_container[:foo].bar == ioc_container[:bar]
module Callme
  module Inject
    def self.included(base)
      base.instance_eval do
        def inject(dependency_name, options = {})
          unless dependency_name.is_a?(Symbol)
            raise ArgumentError, "dependency name should be a symbol"
          end
          unless options.is_a?(Hash)
            raise ArgumentError, "second argument for inject method should be a Hash"
          end
          unless respond_to?(:_callme_injectable_attrs)
            class_attribute :_callme_injectable_attrs
            self._callme_injectable_attrs = { dependency_name => options.dup }
          else
            self._callme_injectable_attrs =
              self._callme_injectable_attrs.merge(dependency_name => options.dup)
          end
          attr_accessor dependency_name
        end
      end
    end
  end
end
