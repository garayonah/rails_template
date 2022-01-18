module Api
  class ApiController < ApiApplicationController
    layout false
    before_action :webservice_authentication
    after_action :write_api_trails

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

    private

    def api_client
      ApiClient.find_by_access_id(ApiAuth.access_id(request))
    end
    
    ########################################################################################################
    # ApiAuth is a Ruby gem designed to be used both in your client and server HTTP-based applications.
    # It implements the same authentication methods (HMAC-SHA1) used by Amazon Web Services.
    # The gem will sign your requests on the client side and authenticate that signature on the server side.
    # If your server resources are implemented as a Rails ActiveResource, it will integrate with that.
    # It will even generate the secret keys necessary for your clients to sign their requests.
    #
    # Since it operates entirely using HTTP headers,
    # the server component does not have to be written in the same language as the clients.
    #
    # The signed request expires after 15 minutes in order to avoid replay attacks.
    #
    #	It is used to simultaneously verify both the data integrity and the authentication of a message.
    #
    # = Example header data (APIAuth access_id:signature)
    #		Authorization = APIAuth 1ba9784c:VEaqFbd+nMl2+n6yaKuokjXT7EQ=
    #########################################################################################################
    def webservice_authentication
      logging.info "INCOMING REQUEST = #{request}"
      request.headers['Date']||=request.headers['timestamp']
      auth_headers = ApiAuth::Headers.new(request)
      
      logging.info "TIME NOW = #{Time.now.utc - 900}"
      is_old = Time.httpdate(auth_headers.timestamp).utc < (Time.now.utc - 900) rescue true
      logging.info "IS OLD = #{is_old}"
  
      logging.info "CANONICAL STRING = #{auth_headers.canonical_string}"
  
      logging.info "ApiAuth ACCESS_ID = #{ApiAuth.access_id(request)}"
      
      #ApiClient.find_by_access_id(ApiAuth.access_id(request))
      if api_client.nil?
        render json: {"result_code" => "403", "message" => "Access Denied! This API Client is not found!"}, status: 403
        return
      elsif api_client.user.status=='inactive'
        render json: {"result_code" => "403", "message" => "Access Denied! API Client User is inactive!"}, status: 403
        return
      else
        logging.info "Client Secret KEY = #{api_client.secret_key}"
  
        valid = ApiAuth.authentic?(request, api_client.secret_key)
        logging.info "IS VALID = #{valid}"
  
        if !valid
          render json: {"result_code" => "403", "message" => "Access Denied! API Key not verified!"}, status: 403
          return
        end
      end
    end

    def write_api_trails
      begin
        response_body = JSON.parse(response.body)
        headers = request.headers.to_h.slice(
          "PATH_INFO", "HTTP_ACCEPT", "HTTP_REFERER",
          "HTTP_ACCEPT_ENCODING", "HTTP_ACCEPT_LANGUAGE", "HTTP_VERSION",
        )
        
        api_trail = ApiTrail.create!(
          api_client_id: (api_client.id rescue nil),
          controller: self.controller_name,
          action: self.action_name,

          remote_address: request.env['REMOTE_ADDR'],
          user_agent: request.env['HTTP_USER_AGENT'],
          
          request_headers: headers,
          request: params.to_unsafe_hash,
          response: response_body,

          message: response_body['message'],
          result_code: response_body['result_code'],
          )

        logging.info "API Trail(#{api_trail.id}) Created"
        
      rescue Exception => error
        logging.error "API Trail Error: #{error.message}"
      end
    end
    
    def logging(logname="#{Rails.env}_api")
      super(logname)
    end
    
  end
end