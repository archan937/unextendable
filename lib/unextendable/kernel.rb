module Kernel

  def meta_class(&block)
    class << self
      yield if block_given?
      self
    end
  end
  alias :singleton_class :meta_class

end