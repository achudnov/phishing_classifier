require 'active_record'

class Registrar < ActiveRecord::Base
   belongs_to :page, :autosave => true
end
