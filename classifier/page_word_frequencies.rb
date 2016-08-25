require 'active_record'

class PageWordFrequency < ActiveRecord::Base
   belongs_to :page, :autosave => true
   belongs_to :word, :autosave => true
end
