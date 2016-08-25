require 'country_codes'
require 'registrars'
require 'registrants'
require 'tlds'
require 'page_word_frequencies'
require 'url_word_frequencies'
require 'rubygems'
require 'active_record'

class Page < ActiveRecord::Base
   has_one :registrar
   has_one :registrant
   belongs_to :tld
   belongs_to :country_code
   
   has_many :page_word_frequencies
   has_many :url_word_frequencies

   def to_feature_vector
      fv = []
      return fv
   end
end


