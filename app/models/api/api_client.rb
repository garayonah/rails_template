class ApiClient < ApplicationRecord
  validates :access_id, :uniqueness => true
  validates :secret_key, :uniqueness => true

  before_save :create_access_id_and_secret_key

  def create_access_id_and_secret_key
    begin
      self.access_id = SecureRandom.hex(4)
    end while self.class.exists?(access_id: access_id)

    begin
      self.secret_key = ApiAuth.generate_secret_key
    end while self.class.exists?(secret_key: secret_key)
  end

  def validate_request_authenticity(signed_request)
    ApiAuth.authentic?(signed_request, self.secret_key)
  end
end
