class UssdMenu < ApplicationRecord
  #has_many :from_connections
  #has_many :to_connections
  validates :name, presence: true, uniqueness: true

  def connect_to(to_menu_id, input, save_input_as: nil, call_function: nil)
    connect = UssdMenuConnection.find_or_create_by!(to_menu_id: to_menu_id, from_menu_id: id)
    connect.update!(input: input,save_input_as: save_input_as, call_function: call_function)
  end

  
  def connect_from(from_menu_id, input, new_request: false, save_input_as: nil, call_function: nil)
    connect = UssdMenuConnection.find_or_create_by!(from_menu_id: from_menu_id, to_menu_id: id)
    connect.update!(input: input, new_request: new_request, save_input_as: save_input_as, call_function: call_function)
  end
end