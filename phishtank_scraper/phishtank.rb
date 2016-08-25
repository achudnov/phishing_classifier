#!/usr/bin/ruby
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'active_support'
require 'active_record'
	 
ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => '',
  :username => '',
  :password => '',
  :host     => '')
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
ActiveRecord::Base.colorize_logging = false
  
class MlPhishingPage < ActiveRecord::Base
end


print "Starting to scrape phishtank.com\n"

doc = Hpricot(open("http://phishtank.com/phish_archive.php?page=1"))

more = true

i=1

while more do
    rows = doc.search("//table[@class='data']//tr")
    rows.slice(1, rows.length-1).each do |row|
      detailed_url=row.search("/td[1]/a").first.attributes['href']
      details = Hpricot(open("http://phishtank.com/"+detailed_url+"&frame=details"))
      url = details.search("//div[@id='widecol']/div/div[3]/b/text()").to_s
      
      page =MlPhishingPage.new do |p|
        p.url=url
        validity = ""

        if row.search("/td[4]/strong").length == 0 then 
          validity = row.search("/td[4]/text()")
        else
          validity = row.search("/td[4]/strong/text()")
        end

        if validity.to_s =~ /(.*)VALID(.*)/ then
           p.isvalid = true
        else if validity.to_s =~ /(.*)INVALID(.*)/ then
                p.isvalid = false
             end
        end  
        
        online = ""

        if row.search("/td[5]/strong").length == 0 then 
          online=row.search("/td[5]/text()")
        else 
          online=row.search("/td[5]/strong/text()")
        end
        
        if online.to_s =~ /(.*)ONLINE(.*)/ then
           p.isonline = true
        else if online.to_s =~ /(.*)Offline(.*)/ then
                p.isonline = false
             end
        end
      end
      
      page.save
    end
    
    print "Page #{i} parsed\n"
    
    #get the next page
    if doc.search("//div[@class='padded']//table//td[5]//a").length != 0 then
      doc = Hpricot(open("http://phishtank.com/phish_archive.php"+doc.search("//div[@class='padded']//table//td[5]//a").first.attributes['href']))
    else
      more = false
    end
   
    i=i+1
end


print "Done!\n"
