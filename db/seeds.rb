require 'csv'
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
##SETTINGS
puts ">> Create Default settings"
Setting.create(
    name: 'minutes_until_session_timeout',
    value: 15,
    description: 'Number of minutes before the system logs a user out for not being active',
    restrictions: '%{value}>1',
  )

#Set Limit which desides whether DataTable should be local or server based
Setting.create(
    name: 'local_pagination_limit',
    value: 100,
    description: 'Number of records before an index datatable page is automatically converted to Client Side Pagination',
    restrictions: '%{value}>10',
  )

Setting.create(
    name: 'layout-skin',
    value: 0,
    description: 'ID number of css skin for layout',
    restrictions: '%{value}>=0',
  )

###USER MANAGEMENT
puts ">> Create Default Privileges"
puts ">> Create All Access Privilege"
Privilege.find_or_create_by(name: ALL_ACCESS_PRIVILEGE, group: 'super'){|p| p.description = 'Access To all parts of the System'}

#View, Create & Edit Privileges
['users', 'roles', 'companies'].each do |group|
  puts ">> #{group.singularize.titleize} Privileges"
  ['view', 'create', 'edit'].each { |p|
  Privilege.find_or_create_by(name: "#{p}_#{group}", group: group)}
end

#View & Edit Privileges
['privileges'].each do |group|
  puts ">> #{group.singularize.titleize} Privileges"
  ['view', 'edit'].each { |p|
  Privilege.find_or_create_by(name: "#{p}_#{group}", group: group)}
end

#View only Privileges
['locations', 'location_levels', 'privileges'].each do |group|
  puts ">> #{group.singularize.titleize} Privileges"
  Privilege.find_or_create_by(name: "view_#{group}", group: group)
end


puts ">> Create Default Roles"
super_admin = Role.find_or_create_by(name: 'Super Admin') { |r| r.description = 'Able to access all parts of the system' }
super_admin.set_to_all_access

developer = Role.find_or_create_by(name: 'Developer') { |r| r.description = 'Software Developer for the system' }
developer.set_to_all_access

user_admin = Role.find_or_create_by(name: 'User Admin') { |r| r.description = 'Has access to all User, Role and Privilege actions' }
user_admin.add_privileges_by_group('users')
user_admin.add_privileges_by_group('roles')
user_admin.add_privileges_by_group('privileges')

puts ">> Create Default Users"
super_admin = User.create(
  username: "admin",
  password: "12345678",
  email: "railsadmin@pivotaccess.com",
  firstname: "Super",
  lastname: "Admin",
  phone_number: "0787111111",
  status: "active",
  role_id: super_admin.id,
)

##LOCATIONS
puts ">> Create Location Levels"
CSV.foreach("db/location_levels.csv") do |row|
  LocationLevel.find_or_create_by(id: row[0], code: row[1], name: row[2])
end

puts ">> Create Locations..."
loc_index = 0
loc_total = CSV.read("db/locations.csv", headers: true).length
CSV.foreach("db/locations.csv") do |row|
  printf("\r>> Locations: #{loc_index}/#{loc_total} #{loc_index*100/loc_total}%%")
  loc_index+=1
  Location.find_or_create_by!(id: row[0], code: row[1], coordinates: row[2], level: row[3], name: row[4], parent_id: row[5])
end
puts ""

load(Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb"))

puts "End of Seeds"