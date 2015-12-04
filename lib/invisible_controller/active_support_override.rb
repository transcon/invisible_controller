module ActiveSupport
  module Dependencies
    #TODO: I really don't like intercepting this way, really disappointed with
    # the lack of available hooks here
    # This code should be checked against RAILS code probably after every release

    # RAILS code copied (RAILS Comments removed)
    def load_missing_constant(from_mod, const_name)
      log_call from_mod, const_name

      unless qualified_const_defined?(from_mod.name) && Inflector.constantize(from_mod.name).equal?(from_mod)
        raise ArgumentError, "A copy of #{from_mod} has been removed from the module tree but is still active!"
      end

      qualified_name = qualified_name_for from_mod, const_name
      path_suffix = qualified_name.underscore

      file_path = search_for_file(path_suffix)
      if file_path
        expanded = File.expand_path(file_path)
        expanded.sub!(/\.rb\z/, '')

        if loading.include?(expanded)
          raise "Circular dependency detected while autoloading constant #{qualified_name}"
        else
          require_or_load(expanded, qualified_name)
          raise LoadError, "Unable to autoload constant #{qualified_name}, expected #{file_path} to define it" unless from_mod.const_defined?(const_name, false)
          return from_mod.const_get(const_name)
        end
      elsif mod = autoload_module!(from_mod, const_name, qualified_name, path_suffix)
        return mod
      elsif (parent = from_mod.parent) && parent != from_mod &&
            ! from_mod.parents.any? { |p| p.const_defined?(const_name, false) }
        begin
          return parent.const_missing(const_name)
        rescue NameError => e
          raise unless e.missing_name? qualified_name_for(parent, const_name)
        end
      end
      activated_name = before_raise_uninitialized_constant(qualified_name)
      return  activated_name if activated_name.present?
      # Continue Rails code
      name_error = NameError.new("uninitialized constant #{qualified_name}", const_name)
      name_error.set_backtrace(caller.reject {|l| l.starts_with? __FILE__ })
      raise name_error
    end
    def before_raise_uninitialized_constant(qualified_name)
      if !!(qualified_name =~ /Controller$/)
        return Object.const_set(qualified_name, InvisibleController::Base)
      end
      return false
    end
  end
end
