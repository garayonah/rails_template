class Setting < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :value, presence: true
  validate :check_value_restrictions
 
  def check_value_restrictions
    if !valid_value(value)
      errors.add(:value, "does not match restrictions")
    end
  end

  before_create do
    self.description = name.titleize if description.blank?
  end

  def valid_value(val)
    if self.restrictions.present?
      valid = eval(self.restrictions % {value: val}) rescue false
      return valid
    else
      return true
    end
  end

  def self.named(setting_name)
    self.find_by_name(setting_name) rescue nil
  end

  def self.getValue(setting_name)
    self.find_by_name(setting_name).value rescue nil
  end
end
