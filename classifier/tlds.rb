require 'active_record'

class Tld < ActiveRecord::Base
   has_many :pages
end
