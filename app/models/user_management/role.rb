class Role < ApplicationRecord
  has_many :role_privileges
  has_many :active_role_privileges, -> { where status: 'active' }, class_name: 'RolePrivilege'
  has_many :privileges, through: :active_role_privileges
  validates :name, presence: true, uniqueness: true

	#List of Privilege Names
  def privilege_names
    self.privileges.pluck(:name)
  end

  #Checks if role has this privilege
  def has_privilege?(privilege_name)
    self.privileges_names.include? privilege_name
  end

  #privilege_names = [a,b,c,d] - No further explanation needed
  def has_privileges?(*required_privileges)
    #Returns true if any of the privilege_names are included in role_privileges
    required_privileges.flatten.any? { |p| privilege_names.include? p }
  end

  def has_access?(*required_privileges)
    privilege_names = self.privileges.pluck(:name)
    unformated_list = [required_privileges, ALL_ACCESS_PRIVILEGE].flatten
    formated_list = unformated_list.map{|p|Privilege.format(p)}
    return !(privilege_names & formated_list).empty?
  end

  #Returns true if you have the all_access privilege
  def all_access?
    self.privileges.pluck(:name).include? ALL_ACCESS_PRIVILEGE
  end

  #Add privileges using ids or names
  #ex Role.find(1).add_privileges(1, 'view_users')
  def add_privileges(*privileges)
    begin
      privileges.flatten!
      ids = privileges.map(&:to_i)
      names = privileges.map(&:to_s)
      found_privileges = Privilege.where('id IN (:ids) OR name IN (:names)', ids: ids, names: names)
      found_privileges.each do |privilege|
        update_role_privilege = RolePrivilege.find_or_create_by(role_id: self.id, privilege_id: privilege.id)
        update_role_privilege.update(status: 'active')
      end
    rescue Exception => e
      puts e.message
    end
    self.reload
  end

  #Add all privileges that share a group
  #ex Role.find(1).add_privileges_by_group('users')
  def add_privileges_by_group(group)
    group_privilege_ids = Privilege.where(group: group).ids
    self.add_privileges(group_privilege_ids)
  end

  #Remove privileges using ids or names
  #ex Role.find(1).remove_privileges(1, 'view_users')
  def remove_privileges(*privileges)
    begin
      ids = privileges.map(&:to_i)
      names = privileges.map(&:to_s)
      found_privileges = Privilege.where('id IN (:ids) OR name IN (:names)', ids: ids, names: names)
      update_role_privileges = self.role_privileges.where(privilege_id: found_privileges.ids)
      update_role_privileges.update_all(status: 'inactive')
    rescue Exception => e
      puts e.message
    end
    self.reload
  end

  #Remove all privileges that share a group
  #ex Role.find(1).remove_privileges_by_group('users')
  def remove_privileges_by_group(group)
    group_privilege_ids = Privilege.where(group: group).ids
    self.remove_privileges(group_privilege_ids)
  end

  #Remove all privileges from the role
  #ex Role.find(1).remove_all_privileges
  def remove_all_privileges
    self.role_privileges.update_all(status: 'inactive')
  end

  def set_privileges(*privileges)
    self.remove_all_privileges
    self.add_privileges(privileges)
  end

  #Reset Privileges to only 'all_access'
  #ex Role.find(1).set_to_all_access
  def set_to_all_access
    self.remove_all_privileges
    self.add_privileges(ALL_ACCESS_PRIVILEGE)
  end
end
