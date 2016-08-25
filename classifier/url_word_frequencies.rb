require 'active_record'

class UrlWordFrequency < ActiveRecord::Base
   belongs_to :page, :autosave => true
   belongs_to :word, :autosave => true
end
