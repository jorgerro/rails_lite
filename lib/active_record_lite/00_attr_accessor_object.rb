
class AttrAccessorObject

  def self.my_attr_accessor(*names)

    names.map(&:to_s).each do |name|
      define_method("#{name}") do
        instance_variable_get("@#{name}")
      end
    end

    names.map(&:to_s).each do |name|
      define_method("#{name}=") do |new_value|
        self.instance_variable_set("@#{name}", new_value)
      end
    end

  end

end
