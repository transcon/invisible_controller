module InvisibleController
  class Base < ::ApplicationController
    authorize_resource if respond_to?('authorize_resource')
    RESTFUL_ACTIONS = [:index,:create,:new,:edit,:show,:update,:destroy]
    before_filter :load_resource, only: RESTFUL_ACTIONS

    def self.belongs_to(parent_klass,args={})
      @nested       = true
      @shallow      = !!args[:shallow]
      @nested_name  = args[:as]
      @parent_name  = parent_klass.to_s
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
    def destroy
      resource.destroy
      render response: 204, nothing: true
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
      end
    end
    def load_resource()   instance_variable_set("@#{resource_name}", resource) end
    def controller_name() params[:controller].to_s end
    def resource_name()   index? ? controller_name : controller_name.singularize end
    def resource()        @resource ||= define_resource end
    def template()        "#{controller_name}/#{params[:action]}" end

      #belongs_to Functionality
    def nested?()                   self.class.instance_variable_get('@nested') end
    def shallow?()                  self.class.instance_variable_get('@shallow') end
    def parent_name()               self.class.instance_variable_get('@parent_name') end
    def nested_name()               self.class.instance_variable_get('@nested_name') end

    def parent_resource()           parent_name.classify.constantize.find(parent_id) end
    def parent_id()                 params["#{parent_name}_id"] end
    def nested_and_indifferent?()   nested? && (!shallow? || index? || new? || create?) end
    def active_class()              nested_and_indifferent? ? parent_resource.send(nested_name || resource_name.pluralize) : klass end

    def define_resource()
      return nil                                   unless !!(klass < ActiveRecord::Base)
      return active_class.all                      if index?
      return active_class.new(processed_params)    if new?
      return active_class.create(processed_params) if create?
      active_class.find(params[:id])
    end
    def klass()            resource_name.classify.constantize rescue Class end
    def permitted_params() params.permit( resource_name.to_sym => klass.whitelisted ) end
    def processed_params() permitted_params[resource_name] end
  end
end
