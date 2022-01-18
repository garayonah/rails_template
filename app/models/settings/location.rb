class Location < ApplicationRecord  
  alias_attribute :level, :location_level_id
  validates :code, uniqueness: true, on: :create
  @@index_columns = ['code', 'coordinates']
  @@editable = false
  
  def name_extended
    "#{self.parent.name}: #{self.name}" rescue nil
  end

  def self.provinces
    self.where(level: '12b')
  end

  def self.districts
    self.where(level: '12c')
  end

  #enter the number of levels to up(1)
  #or the level it should stop at(12b)
  def name_tree(levels=1, reverse: false)
    current = self
    result = [current.name]
    until levels.to_i<=0 || levels==current.level || current.parent.blank?
      current = current.parent
      result.prepend(current.name)
      levels -=1 if levels.kind_of?Integer
    end
    result.reverse! if reverse
    return result.join(', ')
  end
end
