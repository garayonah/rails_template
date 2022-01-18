#class ApiApplicationController < ActionController::API
class ApiApplicationController < ActionController::Base
  skip_before_action :verify_authenticity_token
  #Any Exceptions are redirected using the error_handling method
  rescue_from Exception, with: :error_handling
  rescue_from ActionController::RoutingError, with: :not_found

  def error_handling(exception)
    backtrace = exception.backtrace.select{|b| b.include?Rails.root.to_s or b==exception.backtrace.first}
    logging.error "#{Time.now} | #{exception.message} | #{backtrace.join(' | ')}"
    render json: {"result_code" => "500", "message" => exception.message}, status: 500
    return
  end

  def not_found
    render :json => {result_code: '404', message: 'API Not Found'}
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
    
  def check_resource_name
    if controller_name=='base'
      model_tables = Dir.glob("app/models/*/*.rb").map{ |s| File.basename(s).remove('.rb')}
      not_found if !model_tables.include? params[:resource_name].to_s.singularize
    end
  end

  def logging(logname=Rails.env)
    Logger.new( Rails.root.join("log", logname + ".log" ), 5 , 100 * 1024 * 1024 )
  end
end