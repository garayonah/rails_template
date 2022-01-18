# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

#Disable activerecord logs(this is just my preference)
ActiveRecord::Base.logger = nil

#DATE & TIME FORMATS
Date::DATE_FORMATS[:default] = '%Y-%m-%d'
Time::DATE_FORMATS[:default]= '%Y-%m-%d %H:%M:%S'
DateTime::DATE_FORMATS[:default]= '%Y-%m-%d %H:%M:%S'

#CONSTANTS
APP_NAME = 'Rails Template Application'
ALL_ACCESS_PRIVILEGE = 'all_access'