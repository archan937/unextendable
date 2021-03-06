class Object

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
      if respond_to?(:meta_class)
        wrap_unextendable_module mod if mod.unextendable?
        add_extended_module mod
      end
      super(mod)
    end
  end

  def unextend(*modules, &block)
    if respond_to?(:meta_class)
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
  end

private

  def unextend?(mod, &block)
    mod.unextendable? && (!block_given? || !!block.call(mod))
  end

  def wrap_unextendable_module(mod)
    return unless (mod.class == Module) && mod.unextendable?

    mod.my_methods.each do |method_name|
      wrap_unextendable_method method_name
    end

    return if @wrapped_respond_to

    instance_eval <<-CODE
      def respond_to?(symbol, include_private = false)
        meta_class.extended_modules.any?{|x| x.my_methods(include_private).collect(&:to_s).include? symbol.to_s} ||
        begin
          if meta_class.method_procs.has_key? symbol.to_s
            meta_class.method_procs[symbol.to_s].class == Proc
          else
            self.class.my_methods(include_private).collect(&:to_s).include? symbol.to_s
          end
        end
      end
    CODE

    @wrapped_respond_to = true
  end

  def wrap_unextendable_method(method_name)
    return if meta_class.method_procs.key? method_name.to_s

    meta_class.method_procs[method_name.to_s] = respond_to?(method_name, true) ? method(method_name.to_s).to_proc : nil

    instance_eval <<-CODE
      def #{method_name}(*args, &block)
        call_unextendable_method :#{method_name}, *args, &block
      end
    CODE
  end

  def add_extended_module(mod)
    meta_class.extended_modules.delete  mod
    meta_class.extended_modules.unshift mod
  end

  def call_unextendable_method(method_name, *args, &block)
    if method = method_for(method_name)
      method.call(*args, &block)
    else
      raise NoMethodError, "undefined method `#{method_name}' for #{self.inspect}"
    end
  end

  def method_for(method_name)
    mod = meta_class.extended_modules.detect{|x| x.my_methods.collect(&:to_s).include? method_name.to_s}
    mod ? mod.instance_method(method_name).bind(self) : proc_for(method_name)
  end

  def proc_for(method_name)
    meta_class.method_procs.key?(method_name.to_s) ?
      meta_class.method_procs[method_name.to_s] :
      method(method_name.to_s)
  end

end