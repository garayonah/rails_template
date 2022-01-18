module Admin
  class UsersController < BaseController

    def index
      @attributes = default_attributes(only: ['username', 'email', 'phone_number', 'created_by_id', 'role_id', 'status'])
      @attributes[:username].update(attribute_style: 'font-weight: bold')
      super
    end

    def new
      @attributes = default_attributes(only: ["username", "email", "firstname", "lastname", "phone_number", "role_id"])
      @attributes.update(password: {title: "Password"})
      super
    end

    def create
      object_params = params.slice(:password)
      super
    end

    def show
      @attributes = default_attributes(only: ['username', 'firstname', 'lastname', 'email', 'phone_number', 'role_id', 'status', 'created_by_id', 'updated_by_id'])
      super
    end

    def edit
      @attributes = default_attributes(only: ["username", "email", "firstname", "lastname", "phone_number", "role_id"])
      super
    end

    def update
      super
    end

    #Resets the user's password to a random string and sends them an email
    def reset_password
      #Find the user
      user = User.find(params['id'])

      #Create new random password
      random_password = SecureRandom.hex(8)
      #change the password
      user.reset_password(random_password, random_password)

      #Email new password to user
      Thread.new do
        email_content = "Your password has been reset. Please use the credentials below to access AGFD. You are requested to change your password upon your first login. <br/><br/>Should you require any additional information, please contact your administrator or send an email to #{SUPPORT_EMAIL_ID}.<br/><br/>Email: #{user.email}<br/>Password: #{random_password}<br/>URL: #{APP_URL}/login"
        email_delivery = Message.send_email(session_user.id, "Password reset notification", user.email, "#{user.firstname} #{user.lastname}", email_content)
      end

      flash[:success_notice] = "Reset Successful, New Password emailed to user"
      #redirect_to(action: 'show', :id: params[:id])
      redirect_to admin_user_path(params[:id])
    end

    #Changes the password of the session_user
    def change_password
      #Find the user
      begin
        #Validate current_password
        if !session_user.valid_password? params['current_password']
          raise Exception.new("Current Password is Incorrect")
        end

        #Makes suer password is valid
        if params['new_password'].length < 8
          raise Exception.new("Password is too short (minimum is 8 characters)")
        end

        #Change the password
        session_user.reset_password(params['new_password'], params['new_password'])
        Thread.new do
          email_content = "You have updated your password. Should you require any additional information, please contact your administrator or send an email to #{SUPPORT_EMAIL_ID}.<br/><br/>Email: #{session_user.email}<br/>Password: #{random_password}<br/>URL: #{APP_URL}/login"
          email_delivery = Message.send_email(session_user.id, "Password reset notification", session_user.email, "#{session_user.firstname} #{session_user.lastname}", email_content)
        end

        #Logout User
        redirect_to admin_logout_path(success_notice: "<span style='color:green;'>Password Changed</span>")
      rescue Exception => e
        flash[:error_notice] = e.message
        redirect_to admin_user_path(session_user.id)
      end
    end

    private

    def create_params
      params.permit(resource_class.column_names<<'password')
    end
  end
end
