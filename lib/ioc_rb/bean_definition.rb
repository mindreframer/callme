class IocRb::BeanDefinition
  attr_reader :name, :bean_class, :attrs

  def initialize(name, options, &block)
    ArgsValidator.has_key!(options, :class)

    @name       = name
    @bean_class = options[:class]
    @attrs      = []

    if @bean_class.respond_to?(:injectable_attrs)
      @bean_class.injectable_attrs.each do |attr, options|
        options[:ref] ||= attr
        @attrs << Attribute.new(attr, options)
      end
    end

    if block
      Dsl.new(@attrs).instance_exec(&block)
    end
  end

  class Attribute
    attr_reader :name, :ref

    def initialize(name, options)
      ArgsValidator.has_key!(options, :ref)
      @name = name
      @ref  = options[:ref]
    end
  end

  class Dsl
    def initialize(attrs)
      @attrs = attrs
    end

    def attr(name, options)
      @attrs << Attribute.new(name, options)
    end
  end
end