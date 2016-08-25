require 'hpricot'
require 'open-uri'
require 'texttools'
require 'urlex'

module FeatureExtractors

module HTMLExtractor
   # extract features from an html document specified by a String uri
   def HTMLExtractor.extract(uri)
      begin
           doc = Hpricot(open(uri))
           text = purify doc.to_plain_text
   
           return {
              :words => TextTools.word_freq(TextTools.words(text)), #Dictionary: word frequencies
              :has_password => (has_password doc), #bool: does the page have a password field
              :has_iframes => (has_iframes doc), #bool: does the page have iframes
              :outbound => percent_outbound_links(doc, uri)  #float: percent of outbound references
           }
      rescue
          return nil
      rescue Timeout::Error => e
         return nil
      end       
   end
   
   def HTMLExtractor.purify(string)
      result = []
      words2(string).each do |w| 
         if w =~ /\[[^\]]*\]/ then
            next
         else
            result << w
         end
      end
      return unwords2(result)
   end 
   
   def HTMLExtractor.words2(string)
      string.split(/\s/)
   end
   
   def HTMLExtractor.unwords2(words)
      result = ""
      words.each do |w| 
         result << (w+" ")
      end
      return result
   end
   
   #returns the number of password input fields in the document
   def HTMLExtractor.has_password(doc)
      (doc/"//input[@type='password']").length > 0
   end
   
   def HTMLExtractor.has_iframes(doc)
      (doc/"//iframe").length > 0
   end
   
   def HTMLExtractor.percent_outbound_links(doc, local_url)
      urls = []
      (doc/"//img").each do |img|
         urls << img.attributes['src']
      end
      
      (doc/"//iframe").each do |iframe|
         urls << iframe.attributes['src']      
      end
      
      (doc/"//a").each do |a|
         urls << a.attributes['href']
      end
      
      inbound = 0.0
      
      t = FeatureExtractors::URLExtractor.parse(local_url)
      if t.nil? then
         local_hostname = ""
      else 
         local_hostname = t[:hostname]
      end
      urls.each do |url|
         
         par = FeatureExtractors::URLExtractor.parse(url)
         local = false
         if !(par.nil?)
            local = (par[:hostname]==local_hostname)
         end
         
         if (url =~ /^#(.*)$/) or (url =~ /^\/(.*)$/) or local then
            inbound = inbound + 1.0
         end
      end
      if urls.length == 0 then return 0.0
      else
           return (1-(inbound/Float(urls.length)))
      end
   end

end

end
