require 'rubygems'
require 'active_record'

class CountryCode < ActiveRecord::Base
   has_many :pages
end


