class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  class_attribute :index_columns, :show_columns, :new_columns, :edit_columns

  def self.inherited(subclass)
    super
    ##Class Variable defined in the models will define which columns are available for:
    #Index View
    subclass.index_columns = subclass.column_names - ['id', 'updated_by_id', 'created_by_id', 'updated_at']

    #Show View
    subclass.show_columns = subclass.column_names - ['id']

    #New View
    subclass.new_columns = subclass.column_names - ['id', 'status', 'created_at', 'updated_at', 'created_by_id', 'updated_by_id']

    #Edit View
    subclass.edit_columns = subclass.column_names - ['id', 'status', 'created_at', 'updated_at', 'created_by_id', 'updated_by_id']

    subclass.column_names.each do |c|
      alias_attribute c.underscore, c if c.underscore!=c
      alias_attribute c.camelize(:lower), c if c.camelize(:lower)!=c
    end

    subclass.table_columns.each do |c|
      subclass.belongs_to (c.delete_suffix('_id').to_sym)
    end

    # #Get User object using created_by_id
    subclass.belongs_to :created_by, class_name: 'User', optional: true if !defined?created_by
    # #Get User object using updated_by_id
    subclass.belongs_to :updated_by, class_name: 'User', optional: true if !defined?updated_by
    #Get Parent object using parent_id
    subclass.belongs_to :parent, class_name: subclass.to_s, optional: true  if subclass.column_names.include? 'parent_id'


    #Get list of belongs to attributes
    subclass.belongs_to_names.each do |attribute|
      # define_method :"#{attribute}_name" do
      #   self.send(attribute).name if self.send(attribute)
      # end
      delegate :name, :name=, to: attribute, prefix: true
      #alias_attribute "#{attribute}_name", attribute.name
    end
  end

  def self.editable
    self.edit_columns.present?
  end

  def self.showable
    self.show_columns.present?
  end

  #Get list of columns ending in _id that match model names
  def self.table_columns
    model_files = Dir.glob("app/models/*/*.rb").map{ |s| File.basename(s)}
    id_columns = self.column_names.select{|c|(c.ends_with?'_id') && (model_files.include?c.sub('_id', '.rb'))}
  end

  #Get Class linked to _id column
  def self.association_class(association_name)
    #'created_by' => User
    association = self.reflect_on_association(association_name)
    association.klass rescue nil
  end

  #Get List of all belongs_to associations
  def self.belongs_to_names
    self.reflect_on_all_associations(:belongs_to).map(&:name)
  end

  #Update Status to 'inactive'
  def deactivate
    self.update!(status: 'inactive')
  end

  #Update Status to 'active'
  def reactivate
    self.update!(status: 'active')
  end

  #Get name of Locaton and parent location e.g. "Umujyi wa Kigali: Nyarugenge"
  def location_name_extended
    self.location.name_extended
  end

  #Convert object to CSV File
  def self.to_csv(columns = nil, includes: nil)
    require 'csv'
    case
    when columns.kind_of?(Array)
      headers = columns.map{ |c| c.to_s.titleize }
      attributes = columns
    when columns.kind_of?(Hash)
      headers = columns.keys
      attributes = columns.values
    else
      headers = column_names.map(&:titleize)
      attributes = column_names
    end
    objects = objects.includes(includes)

    CSV.generate(headers: true) do |csv|
      csv << headers
      if attributes.any?{|attr| !column_names.include? attr.to_s}
        objects.find_each do |object|
          csv << attributes.map{ |attr| (object.send(attr) rescue object[attr]) }
        end
      else
        pluck(*attributes).each do |row|
          csv << row
        end
      end
    end
  end
end
