class Reflection
  require 'singleton'

  def self.class_exists(class_name)
    klass = Module.const_get(class_name)
    return klass.is_a?(Class)
      #return klass.is_a?(Class) || klass.is_a?(Module)
  rescue NameError
    return false
  end

end
