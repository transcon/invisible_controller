module ActiveRecordExtension
  extend ActiveSupport::Concern
  module ClassMethods
    def whitelisted()
      return self::WHITELISTED                                       if self.constants.include?(:WHITELISTED)
      return column_names_with_nested_attributes - self::BLACKLISTED if self.constants.include?(:BLACKLISTED)
      column_names_with_nested_attributes
    end
    private
    def column_names_with_nested_attributes
      deliverable = column_names.dup
      nested_attributes_options.keys.each do |key|
        deliverable << {"#{key}_attributes" => key.classify.constantize.whitelisted}
      end
      deliverable
    end
  end
  def whitelisted() self.class.whitelisted end
end
ActiveRecord::Base.send(:include, ActiveRecordExtension)
