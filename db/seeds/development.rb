Setting.named('minutes_until_session_timeout').update(value: 90)

developer_user = User.create(
  username: "developer",
  password: "12345678",
  email: "developer@pivotaccess.com",
  firstname: "Dev",
  lastname: "Eloper",
  phone_number: "0787222222",
  status: "active",
  role_id: Role.find_by(name: 'Developer').id,
)
user_admin = User.create(
  username: "useradmin",
  password: "12345678",
  email: "useradmin@pivotaccess.com",
  firstname: "People",
  lastname: "Person",
  phone_number: "0787333333",
  status: "active",
  role_id: Role.find_by(name: 'User Admin').id.id,
)

#Create an ApiClient for the admin for testing
ApiClient.create(
  name: 'super_admin',
  user_id: User.find_by(username: "admin").id
)

puts ">> Create Ussd Menu Example..."
main_menu = UssdMenu.create(name: 'main', text_en: "Welcome to USSD\n1.Enter Details\n2.Solve Math Function\n3.Say Goodbye", text_fr: "", text_rw: "")
main_menu.connect_from(nil, '.*', new_request: true)

name_menu = UssdMenu.create(name: 'enter_name', text_en: "Enter Your Name", text_fr: "", text_rw: "")
name_menu.connect_from(main_menu.id, '1')

age_menu = UssdMenu.create(name: 'enter_age', text_en: "Enter Your Age", text_fr: "", text_rw: "")
age_menu.connect_from(name_menu.id, '.*', save_input_as: 'name')

address_menu = UssdMenu.create(name: 'enter_address', text_en: "Enter Your Address")
address_menu.connect_from(age_menu.id, '.*', save_input_as: 'age')

details_menu = UssdMenu.create(name: 'details', text_en: "%{name} is %{age}yrs old and lives in %{address}", end_request: true)
details_menu.connect_from(address_menu.id, '.*', save_input_as: 'address')

enter_math_menu = UssdMenu.create(name: 'enter_math', text_en: "Enter a multiple of 3")
enter_math_menu.connect_from(main_menu.id, '2')

correct_math = UssdMenu.create(name: 'correct_math', text_en: "Thats correct math", end_request: true)
incorrect_math = UssdMenu.create(name: 'incorrect_math', text_en: "Thats incorrect math", end_request: true)
enter_math_menu.connect_to(nil, '.*', call_function: 'check_math')

goodbye_menu = UssdMenu.create(name: 'goodbye', text_en: "Okay Bye!", end_request: true)
goodbye_menu.connect_from(main_menu.id, '3')


puts ">> Create Product Examples..."
Product.create(name: 'Normal Product', description: "A normal product. It doesn't do anything special", price: '100', tags: ['product'])
Product.create(name: 'Special Product', description: "A special product. It has a special feature attached", price: '150', tags: ['product', 'special'])
Product.create(name: 'Luxury Product', description: "A luxurious product. Its the same as normal, but its more expensive", price: '1000', tags: ['product', 'luxury'])