class UssdSession < ApplicationRecord
  has_many :ussd_session_details
  validates :mobile_number, presence: true

  #Returns the associated ussd_session_details as a hash
  #eg. UssdSession.last.details => {age: '21', address: 'Kigali'}
  def details
    session_details = ussd_session_details.pluck(:name, :value).to_h.with_indifferent_access
    return session_details
  end

  #Returns the value of a specific associated ussd_session_detail
  #eg. UssdSession.last.detail('address') => 'Kigali'
  def detail(detail_name)
    session_detail = ussd_session_details.find_by_name(detail_name)
    return session_detail.value rescue nil
  end

  #Create/Updates associated ussd_session_details
  #eg. UssdSession.last.update_details(age: '21', address: 'Kigali') => {age: '21', address: 'Kigali'}
  def update_details(new_details={})
    new_details.each do |name, value|
      UssdSessionDetail.find_or_create_by(ussd_session_id: id, name: name).update(value: value)
    end
  end
end