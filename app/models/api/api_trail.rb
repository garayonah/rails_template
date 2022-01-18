class ApiTrail < ApplicationRecord
  serialize :request_headers, Hash
  serialize :response_headers, Hash
  serialize :request, Hash
  serialize :response, Hash
end