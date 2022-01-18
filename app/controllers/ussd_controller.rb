class UssdController < ActionController::API
  before_action :authorize, only: [:mobile_gateway_test, :flares_test]

  def flares
    missing_params = ['input', 'msisdn'].select{|p| params[p].blank?}
    if !missing_params.empty?
      response.headers['action'] = 'end'
      render plain: "Missing Required Parameters#{missing_params}" and return
    end

    input = params['input'].to_s
    mobile_number = params['msisdn']
    new_request = (params['newrequest']!='1')

    text, continue_request = get_response(input, mobile_number, new_request)

    if continue_request
      response.headers['action']='request'
    else
      response.headers['action']='end'
    end

    render plain: text and return
  end

  def mobile_gateway
    missing_params = ['input', 'mobile_number'].select{|p| params[p].blank?}
    if !missing_params.empty?
      response.headers['action'] = 'end'
      render plain: "Missing Required Parameters#{missing_params}" and return
    end
    #Set Headers
    response.headers["User-Agent"] = "mobileGW"
    response.headers["Host"] = "pivot-app1—bsc-rw"
    response.headers['Content-Type'] = 'text/html; charset=ISO-8859-2'

    input = params['input'].to_s
    mobile_number = params['mobile_number']
    new_request = (params['session']!='1')

    text, continue_request = get_response(input, mobile_number, new_request)

    if continue_request
      response.headers['action']='request'
    else
      response.headers['action']='end'
    end

    render plain: text and return
  end

  #Params:
  # input=>what the user sent
  # mobile_number=>the user's mobile number
  # new_request=>true or false of whether this is a new ussd or continuing
  #
  #Response
  # text=>text that will be shown to the user
  # continue_response=>true or false of whether to end the ussd
  def get_response(input, mobile_number, new_request)
    begin
      #set default values
      text = 'Menu Text not found'
      continue_request=true

      #Find or create ussd_session linked to mobile_number
      ussd_session = UssdSession.find_or_create_by(mobile_number: mobile_number)
      
      #find menu connection
      if new_request
        menu_connection = UssdMenuConnection.where(new_request: true).find_by('? ~ input', input)
      else
        menu_connection = UssdMenuConnection.where(from_menu_id: ussd_session.ussd_menu_id).find_by('? ~ input', input)
      end
      return ["Menu Not found", false] if menu_connection.blank?
      
      #find to menu
      to_menu = menu_connection.to_menu
      
      #call function
      if menu_connection.call_function.present?
        function_response = send(menu_connection.call_function, menu_connection, ussd_session, input)
        to_menu = function_response if function_response.class==UssdMenu
      end

      #set locale
      locale = ussd_session.locale||I18n.default_locale

      #update session
      ussd_session.update!(ussd_menu_id: to_menu.id)

      #update session details
      if menu_connection.save_input_as.present?
        ussd_session.update_details(menu_connection.save_input_as=>input)
      end

      #combine menu text with ussd_session details
      #eg. 'Welcome %{name}' % {name: 'Ms User'} => 'Welcome Ms User'
      #symbolize_keys: the hash keys have to be symbols for this to work
      text = to_menu["text_#{locale}"] % ussd_session.details.symbolize_keys

      #set response headers
      continue_request = false if to_menu.end_request

      return [text, continue_request]
    rescue Exception=>e
      return ["Error: #{e.message}", false]
    end
  end

  #Functions
  def check_math(menu_connection, ussd_session, input)
    if (input.to_i!=0) && (input.to_i%3==0)
      return UssdMenu.find_by_name('correct_math')
    else
      return UssdMenu.find_by_name('incorrect_math')
    end
  end
end