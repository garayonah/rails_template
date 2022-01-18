class UssdMenuConnection < ApplicationRecord
  belongs_to :from_menu, class_name: 'UssdMenu', optional: true
  belongs_to :to_menu, class_name: 'UssdMenu', optional: true
end