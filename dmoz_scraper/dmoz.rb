#!/usr/bin/ruby
require 'rubygems'
require 'hpricot'
require 'open-uri'
require 'active_support'
require 'active_record'

categories = ['Arts']

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => '',
  :username => '',
  :password => '',
  :host     => '')
ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
ActiveRecord::Base.colorize_logging = false
  
class MlBenignPage < ActiveRecord::Base
end

def scrapeurls (worklist, visited)
  
  while (worklist.length > 0) do
       baseurl = worklist.pop
       print "\nOpening #{baseurl}\n"
      
       begin 
          doc = Hpricot(open(baseurl))
       rescue OpenURI::HTTPError
          print "Caught an exception #{$!}\n"
          next
       end

       
       if doc.nil? then
          print "Can't open #{baseurl}\n"
          return
       end
          
       print("Scraping " + baseurl + "\n")
       print "Links:\n"
       
       #get the urls
       
       uls = doc.search("/html/body/ul")
       if uls.length > 0 then
          links_ul = uls[-1]
          links_ul.search("/li").each do |li| 
            url = li.search("/a").first.attributes["href"]
            if (url =~ /http:(.*)/) then
               print("\t"+url+"\n")
           
               page = MlBenignPage.new do |p|
                  p.url=url
               end
              
               page.save
            end
         end
       end


       visited << baseurl
       
       # get the subcategories  
       subcat_tables = doc.search("/html/body/table")
       #print "Subcattables\n"
       #i=1
       #for t in subcat_tables do
       #   print "#{i}.\n"
       #   print t
       #   print "\n======================\n"
       #   i=i+1
       #end
       if subcat_tables.length > 4 then
          print("Recursing into subcategories\n")
          subcat_tables.slice(1, subcat_tables.length-4).each do |t|
             if t.search("/tr[1]/td").first.innerHTML =~ /(.*)This category in other languages(.*)/ then
             else
               t.search("//a").each do |a|
                  href = a.attributes['href']
                  if href[0] == 47  then
                     newurl = "http://dmoz.org#{href}"
                     if !(visited.include? newurl) then
                         worklist << newurl
                     end
                  end
               end
             end
          end
       end
       
       print "Done with this page\n===============\n"
   end
end

print 'Starting to scrape dmoz.org\n'

l = []

for cat in categories
     l<< "http://dmoz.org/#{cat}/"
end

scrapeurls(l, [])

print("Done!\n")
