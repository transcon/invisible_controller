module ActiveRecordExtension
  extend ActiveSupport::Concern
  module ClassMethods
    def whitelisted()
      return self::WHITELISTED                if self.constants.include?(:WHITELISTED)
      return column_names - self::BLACKLISTED if self.constants.include?(:BLACKLISTED)
      column_names
    end
  end
end
ActiveRecord::Base.send(:include, ActiveRecordExtension)
