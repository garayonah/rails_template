class ApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  #Any Exceptions are redirected using the error_handling method
  helper_method :resource_name, :resource_class, :resource_object
  rescue_from Exception, with: :error_handling
  rescue_from ActionController::RoutingError, with: :not_found
  before_action :check_resource_name

  #If there is an exception, the user will be shown the error page
  #The error message will be added to the logs and displayed on the page
  #error view => app/views/layouts/error.html.erb
  def error_handling(exception)
    @exception = exception
    puts exception.message
    logging.error controller_path#exception.message
    self.response_body = nil
    render file: "layouts/error.html.erb", layout: false
    return
  end

  def root
    render file: "layouts/root.html.erb", layout: false
  end

  #If the user tries to access an unknown page, they will be redirected to the not_found page
  #not_found page => app/views/layouts/not_found.html.erb
  def not_found
    render file: "layouts/not_found.html.erb", layout: false
    return
  end
  
  def find_resource
    not_found if params[:resource_name].present? && !model_exists?(params[:resource_name])
  end

  # The singular name for the resource class based on the controller
  # @return [String]
  #e.g. UserController => "user"
  def resource_name
    @resource_name ||= (params[:resource_name]||self.controller_name).singularize
  end

  # The resource class based on the controller
  # @return [Class]
  #e.g. UserController => User
  def resource_class
    @resource_class ||= resource_name.classify.constantize
  end

  # Returns the resource from the created instance variable
  # @return [Object]
  #e.g. UserController => User.find(params[:id])
  def resource_object
    resource_class.find(params[:id])
  end

  #Convert object to CSV File
  def resource_to_csv(resource, headers = nil, options = {})
    require 'csv'
    case
    when headers.kind_of?(Array)
      attributes = headers.map { |h| [h, h] }.to_h
    when headers.kind_of?(Hash)
      attributes = headers
    else
      attributes = resource.column_names.map { |h| [h, h] }.to_h
    end

    export = CSV.generate(:headers => true) do |csv|
      csv << attributes.keys.map { |a| a.to_s.titleize }
      resource.pluck(*attributes.values).each do |row|
        csv << row
      end
    end
  end
    
  def check_resource_name
    if controller_name=='base'
      model_tables = Dir.glob("app/models/**/*.rb").map{ |s| File.basename(s).remove('.rb')}
      not_found if !model_tables.include? params[:resource_name].to_s.singularize
    end
  end

  #Will Change default layout folder depending on module
  #e.g. Module Admin => app/views/admin/layouts
  def _normalize_layout(value)
    if value.is_a?(String) && value !~ /\blayouts/ && self.class.parent_name
      "#{self.class.parent_name.tableize.singularize}/layouts/#{value}"
    else
      value
    end
  end

  def logging(logname=Rails.env)
    Logger.new( Rails.root.join("log", logname + ".log" ), 5 , 100 * 1024 * 1024 )
  end
end