class ApiClientPrivilege < ApplicationRecord
  validates :api_client, :privilege, presence: true
end