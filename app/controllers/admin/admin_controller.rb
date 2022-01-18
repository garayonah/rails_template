module Admin
  #Admin Controller
  class AdminController < ApplicationController
    layout "application"

    #helper_methods are able to be accessed in both the controller and the views
    helper_method :session_user, :session_privileges
    helper_method :resource_class, :resource_name, :resource_object, :query_params

    #authorize users are signed in before accessing any page
    before_action :authorize, :check_resource_name, :set_locale

    #If there is an exception, the user will be shown the error page
    #The error message will be added to the logs and displayed on the page
    #error view => app/views/admin/layouts/error.html.erb
    def error_handling(exception)
      @exception = exception
      logging.error exception.message
      self.response_body = nil
      render file: "admin/layouts/error.html.erb"
      return
    end
  
    #If the user tries to access an unknown page, they will be redirected to the not_found page
    #not_found page => app/views/admin/layouts/not_found.html.erb
    def not_found
      render file: "admin/layouts/not_found.html.erb"
      return
    end
  
    #root page => app/views/admin/layouts/root.html.erb
    def root
      render file: "admin/layouts/root.html.erb"
    end

    private

    #User Object of the person who is signed in
    def session_user
      User.find_by_id(session[:id])
    end

    #If the user does not have the "required_privileges" they are redirected to the homepage
    def privilege_access(*required_privileges)
      result = session_user.has_access?(required_privileges)
      if !result
        flash[:error_notice] = "You do not have the privileges required to access to that page"
        redirect_to admin_root_path and return
      end
    end

    #Returns a list of the session_user's privileges
    #e.g => ["view_user", "create_user", "edit_user"]
    def session_privileges
      session_user.privileges.pluck(:name)
    end

    #Make sure the user is logged in before trying to access the site
    #If they are not logged in, they are redirected to login page
    def authorize
      #Check if a user is logged in
      if session_user.blank?
        flash[:error_notice] = "Please Login First"
        session[:original_uri] = request.url
        logging.error "Unauthorized-Redirected to Login (Session User not found)"
        #Redirect to login page
        redirect_to admin_login_path and return
      end
    end

    #Set the locale to use for the I18n translations
    def set_locale
      begin
        I18n.locale = params[:locale] || session[:locale] || I18n.default_locale
        session[:locale] = I18n.locale
      rescue I18n::InvalidLocale
        session[:locale] = I18n.default_locale
        render file: "layouts/404", layout: false
        return
      end
    end

    def logging(logname="#{Rails.env}_admin")
      super(logname)
    end
  end
end