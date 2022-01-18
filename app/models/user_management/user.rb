class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
    :recoverable, :trackable, :validatable, :rememberable
    
  #belongs_to :role
  has_many :privileges, through: :role

  #alias_attribute :name, "concat(firstname, ' ', users.lastname)"

  validates :username, :email, :firstname, :lastname, presence: true
  validates :username, :email, uniqueness: true

  # validates_format_of :phone_number, :with=> /\07[823]\d{5}/
  # validates_format_of :email, :with=> /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/

  def name
    "#{self.firstname} #{self.lastname}"
  end

  def name_extended
    "#{self.firstname} #{self.lastname} (#{self.role.name})"
  end

  #Checks if user has this privilege
  def has_privilege?(privilege_name)
    self.privileges.pluck(:name).include? privilege_name
  end

  #eg.
  #privilege_names = [a,b,c,d] - No further explanation needed
  def has_privileges?(*privilege_names)
    self.role.has_privileges?(privilege_names)
  end

	#List of Privilege Names
  def privilege_names
    self.privileges.pluck(:name)
  end

  #Returns true if you have the 'all_access' privilege
  def all_access?
    self.role.all_access?
  end

  def has_access?(*required_privileges)
    self.role.has_access?(required_privileges)
  end
end
