module Admin
  class LoginController < AdminController
    skip_before_action :authorize, :set_locale

    def login
      begin
        username = params[:username]
        password = params[:password]

        if username.present? && password.present?
          #Find the user matching the email or username
          @user = User.find_by('lower(email) LIKE lower(:username) OR username LIKE :username', username: username)
          
          #INVALID CREDENTIALS
          if @user.nil? || !@user.valid_password?(password)
            logging.info("Login Failed | #{params.slice(:username, :password)} | Invalid Credentials")
            flash[:error_notice] = "Invalid Credentials"
          
          #INACTIVE USER
          elsif @user.status != "active"
            logging.info("Login Failed | #{params.slice(:username, :password)} | User Account Inactive")
            flash[:error_notice] = "Your Account is Deactivated, please contact your administrator."
          
          #INVALID ROLE
          elsif @user.role_id.nil? || @user.role.status.downcase != 'active'
            logging.info("Login Failed | #{params.slice(:username, :password)} | User Role Invalid")
            flash[:error_notice] = "Your Account does not have a valid role assigned, please contact your administrator."

          #Login and save Session Details
          else
            logging.info "LOGIN | #{Time.now} | User: #{@user.username} has logged in"
            session.update(id: @user.id, name: @user.firstname, role: @user.role.name)
            @user.update(
              sign_in_count: @user.sign_in_count+1,
              current_sign_in_at: Time.now,
              last_sign_in_at: @user.current_sign_in_at,
              current_sign_in_ip: request.remote_ip,
              last_sign_in_ip: @user.current_sign_in_ip)
            flash[:success_notice] = 'Successfully logged in'
            
            #If the user was trying to get to a different page, they will be redirected there
            #By default they will go to the admin_root_path
            redirect_path = session[:original_uri]||admin_root_path
            session[:original_uri]=nil

            redirect_to redirect_path and return
          end
        end
      # rescue Exception=>e
      #   logging.info("Login Error | #{params.slice(:username, :password)} | #{e}")
      #   flash[:error_notice] = "Login Error(#{e}), please contact your administrator."
      end
      render(layout: nil)
    end

    def logout
      #Clear all data from the user's session
      reset_session
      flash[:notice] = params[:notice] || "Successfully logged out!"
      redirect_to admin_login_path
    end

    def error_handling(exception)
      @exception = exception
      logging.error controller_path#exception.message
      self.response_body = nil
      render file: "layouts/error.html.erb"
      return
    end
  end
end