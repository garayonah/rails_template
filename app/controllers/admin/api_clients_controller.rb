#API Clients has the authentication for users to access API functions
module Admin
  class ApiClientsController < BaseController
    def index
      super
      @attributes[:access_id].update(title: 'Access ID', method: 'access_id')
    end

    def show
      super
      @attributes[:access_id].update(title: 'Access ID', method: 'access_id')
    end

    def new
      @attributes = default_attributes(only: [:name, :user_id])
      super
    end

    def create
      super
    end

    def edit
      @attributes = default_attributes(only: [:name, :user_id])
      super
    end

    def update
      super
    end

    #This is a webpage to test api functions using the session_user's linked api_client
    def test
      @client = ApiClient.find_by_user_id(session_user.id)
      if @client.blank?
        flash[:error_notice] = 'You must be registered to an API Client to use the api_test page'
        redirect_to admin_root_path
      end
    end
  end
end