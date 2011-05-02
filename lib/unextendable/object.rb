class Object

  def meta_class(&block)
    class << self
      yield if block_given?
      self
    end
  end
  alias :singleton_class :meta_class

  def meta_class?
    meta_class rescue false
  end
  alias :singleton_class? :meta_class?

  meta_class do
    def extended_modules
      @extended_modules ||= []
    end

    def method_procs
      @method_procs ||= {}
    end
  end

  def extend(*modules)
    modules.each do |mod|
      wrap_unextendable_module mod if mod.unextendable?
      add_extended_module mod
      super(mod)
    end
  end

  def unextend(*modules, &block)
    if modules.empty?
      meta_class.extended_modules.delete_if do |mod|
        unextend? mod, &block
      end
    else
      modules.each do |mod|
        meta_class.extended_modules.delete mod if unextend? mod, &block
      end
    end
  end

private

  def unextend?(mod, &block)
    mod.unextendable? && (!block_given? || !!block.call(mod))
  end

  def wrap_unextendable_module(mod)
    return unless (mod.class == Module) && mod.unextendable?

    mod.instance_methods.each do |method_name|
      wrap_unextendable_method method_name
    end
  end

  def wrap_unextendable_method(name)
    return if meta_class.method_procs.key? name

    meta_class.method_procs[name] = method(name).to_proc

    instance_eval <<-CODE
      def #{name}(*args, &block)
        call_unextendable_method :#{name}, *args, &block
      end
    CODE
  end

  def add_extended_module(mod)
    meta_class.extended_modules.delete  mod
    meta_class.extended_modules.unshift mod
  end

  def call_unextendable_method(method_name, *args, &block)
    method_for(method_name).call(*args, &block)
  end

  def method_for(method_name)
    mod = meta_class.extended_modules.detect{|x| x.instance_methods.include? method_name.to_s}
    mod ? mod.instance_method(method_name).bind(self) : proc_for(method_name)
  end

  def proc_for(method_name)
    meta_class.method_procs[method_name.to_s] || method(method_name.to_s)
  end

end