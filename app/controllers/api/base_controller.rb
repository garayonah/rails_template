module Api
  #ApiBase Controller has some actions that can be used by many different controllers
  #It has code for actions: index, show, new, create, edit, update, deactivate, reactivate
  class BaseController < ApiController
    before_action :check_resource_name
    def index
      resource_list||= resource_class.all
      resource_list = resource_class.where(query_params)#.order(created_at: :desc)
      resource_list = result.last(params[:last]) if params[:last]
      resource_list = result.first(params[:first]) if params[:first]
      render json: {result_code: "200", message: "Successful", resource_name.pluralize => resource_list}, status: 200
    end

    def show
      render json: {result_code: "200", message: "Successful", resource_name => resource_object}, status: 200
    end

    def create
      create_params||= resource_params
      if resource_class.column_names.include? 'created_by_id'
        create_params.update(created_by_id: api_client.user_id)
      end
      new_object = resource_class.new(create_params)

      if new_object.save
        render json: {"result_code" => "200", "message" => "Created #{resource_name.to_s.sub("_", " ")}", "#{resource_name}" => new_object}, status: 200
        return
      else
        render json: {"result_code" => "422", "message" => "Validation error #{new_object.errors.messages.to_s}"}, status: :unprocessable_entity
        logging.error "Validation error: #{new_object.errors.messages.to_s}"
        return
      end
    end

    def update
      update_params||= resource_params
      if resource_class.column_names.include? 'updated_by_id'
        update_params.update(updated_by_id: api_client.user_id)
      end

      if resource_object.update(update_params)
        render json: {"result_code" => "200", "message" => "Update successful", resource_name => resource_object}, status: 200
      else
        render json: {"result_code" => "422", "message" => "Validation error #{resource_object.errors.messages.to_s}"}, status: :unprocessable_entity
        logging.error "Validation error: #{resource_object.errors.messages.to_s}"
      end
    end

    def deactivate
      if resource_object.update(status: 'inactive')
        render json: {"result_code" => "200", "message" => "Successfully Deactivated", resource_name => resource_object}, status: 200
      else
        render json: {"result_code" => "422", "message" => "Validation error #{resource_object.errors.messages.to_s}"}, status: :unprocessable_entity
        logging.error "Validation error: #{resource_object.errors.messages.to_s}"
      end
    end

    def reactivate
      if resource_object.update(status: 'active')
        render json: {"result_code" => "200", "message" => "Successfully Reactivated", resource_name => resource_object}, status: 200
      else
        render json: {"result_code" => "422", "message" => "Validation error #{resource_object.errors.messages.to_s}"}, status: :unprocessable_entity
        logging.error "Validation error: #{resource_object.errors.messages.to_s}"
      end
    end

    private
    def query_params
      attributes = resource_class.column_names.map(&:to_sym)
      params.permit(attributes)
    end

    def resource_params
      attributes = resource_class.column_names.map(&:to_sym) - [:id, :created_at, :created_by, :updated_at, :updated_by]
      #params.require(resource_name.to_sym).permit(attributes)
      params.permit(attributes)
    end
  end
end