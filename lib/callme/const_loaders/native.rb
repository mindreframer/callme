module Callme::ConstLoaders
  module Native
    def self.load_const(const_name)
      return const_name if const_name.is_a?(Class)
      const_name.split('::').inject(Object) do |mod, const_part|
        mod.const_get(const_part)
      end
    end
  end
end
