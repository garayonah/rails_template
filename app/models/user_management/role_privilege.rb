class RolePrivilege < ApplicationRecord
  belongs_to :role
  belongs_to :privilege
  validates :role, :privilege, presence: true
end