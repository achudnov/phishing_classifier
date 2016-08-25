require 'active_record'

class Registrant < ActiveRecord::Base
   belongs_to :page, :autosave => true
end
