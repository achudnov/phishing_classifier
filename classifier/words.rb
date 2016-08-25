require 'active_record'

class Word < ActiveRecord::Base
   has_one :url_word_frequency
   has_one :page_word_frequency
end
