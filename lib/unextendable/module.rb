class Module

  def my_methods(include_private = true)
    public_instance_methods.tap do |methods|
      return methods + private_instance_methods + protected_instance_methods if include_private
    end
  end

  def unextendable
    @unextendable = true
  end

  def unextendable?
    !!@unextendable
  end

end