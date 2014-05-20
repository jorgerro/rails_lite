# deprecated for Rails 4

require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject

  def self.attributes
    if self == MassObject
      raise "must not call #attributes on MassObject directly"
    else
      @attributes = []
    end
  end

  def initialize(params = {})
    params.each do |key, value|
      key_sym = "#{key}=".to_sym
      self.send(key_sym, value)
    end
  end



end


