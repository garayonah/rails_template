class UssdSessionDetail < ApplicationRecord
  validates :ussd_session, presence: true
end