module A
  def name
    "A"
  end
end

module U
  unextendable
  def name
    "U"
  end
end

class C
  attr_accessor :title
  def salutation
    [title, name].reject{|x| x.nil? || x.empty?}.join " "
  end
  def name
    "C"
  end
end

@c = C.new
@c.title = "Mr."