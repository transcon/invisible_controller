module InvisibleController
  class Base < ::ApplicationController
    RESTFUL_ACTIONS = [:index,:create,:new,:edit,:show,:update,:destroy]
    before_filter :load_resource, only: RESTFUL_ACTIONS
    authorize_resource if respond_to?('authorize_resource')

    def self.belongs_to(parent_klass,args={})
      @as ||= HashWithIndifferentAccess.new
      @as[parent_klass] = args[:as]
    end

    def self.has_scope(name,options={})
      raise NameError, "#{name} is an invalid scope name" if [:controller,:action,:format].include?(name.to_sym)
      @scopes ||= []
      @scopes << name.to_s
    end
    RESTFUL_ACTIONS.each do |method|
      define_method("#{method}?") do
        params[:action].to_sym == method
      end
      define_method(method) do
        respond
      end
    end
    def update
      resource.update(processed_params) ? respond : respond_with_errors
    end
    def create
      resource.save(processed_params) ? respond : respond_with_errors
    end
    def destroy
      if resource.destroy
        render response: 204, nothing: true
      else
        render json: resource_with_errors, status: 501
      end
    end

    private
    def resource_with_errors() resource.as_json.merge(errors: resource.errors.full_messages) end
    def respond_with_errors
      respond_to do |format|
        format.html {render nothing: true, status: 422}
        format.json {render json: resource_with_errors, status: 422}
        format.xml  {render xml:  resource_with_errors, status: 422}
      end
    end
    def respond
      respond_to do |format|
        format.html {render layout: !request.headers['angular'], template: template}
        format.json {
          render json: {}, status: 204  if params[:suppress]
          render json: resource     unless params[:suppress]
          }
        format.xml  {render xml:  resource}
        format.pdf  {render pdf:  resource, layout: false}
        (mimes_for_respond_to.keys - [:html, :xml, :json, :pdf]).each do |mime|
          format.send(mime) {render mime => resource}
        end
      end
    end
    def load_resource()
      instance_variable_set("@#{resource_name}", resource)
      instance_variable_set("@#{parent_name}", parent_resource) if nested?
    end
    def controller_name() params[:controller].to_s end
    def resource_name()   index? ? controller_name : controller_name.singularize end
    def nested_name()     (self.class.instance_variable_get('@as') || {})[parent_name] end
    def resource()        @resource ||= define_resource end
    def template()        "#{controller_name}/#{params[:action]}" end

      #belongs_to Functionality
    def nested?()                   parent_name.split('.')[0].singularize != resource_name.singularize end
    def parent_name()               request.path.split('/')[1].singularize end
    def has_one?
      return false unless parent_resource
      parent_resource.class.reflect_on_association(resource_name.singularize).present?
    end

    def parent_resource()           @parent_resource ||= parent_id.present? ? parent_name.classify.constantize.find(parent_id) : nil end
    def parent_id()                 params["#{parent_name}_id"] end
    def active_class()
      if nested?
        return has_one? ? parent_resource : parent_resource.send(nested_name || resource_name.pluralize)
      else
        return klass
      end
    end
    def scoped()                    ((params.keys || []) & (self.class.instance_variable_get("@scopes") || []))[0] end
    def current_scope()             scoped || :all end
    def scope_args()                params[current_scope] end
    def index_with_args?()          index? && scope_args.present? end

    def define_resource()
      return nil                                      unless !!(klass < ActiveRecord::Base)
      return active_class.send(current_scope,scope_args)  if index_with_args?
      return active_class.send(current_scope)             if index?
      return active_class.new(processed_params)           if new? || create?
      define_singleton_resource
    end
    def define_singleton_resource()
      has_one? ? active_class.send(resource_name) : active_class.find(params[:id])
    end
    def klass()            resource_name.classify.constantize rescue Class end
    def permitted_params()
      params[resource_name.to_sym] ||= params[:base]
      params.permit( resource_name.to_sym => (@resource || klass).whitelisted )
    end
    def processed_params() permitted_params[resource_name] end
  end
end
