module Callme::ConstLoaders
  module ActiveSupport
    def self.load_const(const_name)
      return const_name if const_name.is_a?(Class)
      ::ActiveSupport::Inflector.constantize(const_name)
    end
  end
end
