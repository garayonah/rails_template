class Privilege < ApplicationRecord
	#Get role_privileges with matching privilege_id(includes active and inactive roles)
  has_many :role_privileges
	
	#Get role_privileges with matching privilege_id and status='active'
  has_many :active_role_privileges, -> { where status: 'active' }, class_name: 'RolePrivilege'

	#Get roles using active_role_privileges association
  has_many :roles, through: :active_role_privileges

  validates :name, presence: true, uniqueness: true
  
	#Makes sure all privileges have names in the same format
  def name=(attribute)
    write_attribute(:name, Privilege.format(attribute))
  end

	#Gives Privileges a default name if it's blank
  before_create do
    self.description = name.titleize if description.blank?
  end

	#Format of Privilege names
	#e.g. Privilege.format('View USERS') => 'view_user'
	def self.format(str)
		return str.to_s.parameterize.tableize.singularize
	end
end
