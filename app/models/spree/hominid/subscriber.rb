class Spree::Hominid::Subscriber
  def initialize(attributes = {})
    attributes.each do |name, value|
      self.class.send(:define_method, "#{name}_changed?") do
        false
      end
      self.class.send(:define_method, name) do
        value
      end
    end
    Spree::Hominid::Config.preferred_merge_vars.values.reject { |k| k == :email }.each do |var|
      unless self.class.instance_methods.include? var
        self.class.send(:define_method, var) do
          ""
        end
        self.class.send(:define_method, "#{var}_changed?") do
          false
        end
      end
    end
  end

  def changes
    { 'subscribed' => [false, true] }
  end

  def subscribed_changed?
    true
  end

  def subscribed
    true
  end

end
