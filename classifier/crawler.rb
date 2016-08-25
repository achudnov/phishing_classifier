require 'whoisex'
require 'urlex'
require 'htmlex'
require 'pages'
require 'words'

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => '',
  :username => '',
  :password => '',
  :host     => '')
#ActiveRecord::Base.logger = Logger.new(File.open('database.log', 'w'))
#ActiveRecord::Base.colorize_logging = false

class MlBenignPage < ActiveRecord::Base
end

class BenignPage < ActiveRecord::Base
end

class MlPhishingPage < ActiveRecord::Base
end

class PhishingPage < ActiveRecord::Base
end


def crawl
  whois = FeatureExtractors::WHOISExtractor.new
  begin
    url_str = nil
    BenignPage.transaction do
      url = BenignPage.first(:conditions => "processed !=1")
      if !url.nil? then 
        url_str = url.url
        url.processed = true
        url.save
      end        
    end
    
    if url_str.nil? then
      PhishingPage.transaction do
        url = PhishingPage.first(:conditions => "processed != 1")
        if !url.nil? then
          url.processed = true
          url.save
          url_str = url.url
        end
      end
    end
   
   if url_str.nil? then
     return
   end   
  
   Page.new do |p| 
      p.phishing = false
      p.url = url_str
      
      #extract features from the url
      features = FeatureExtractors::URLExtractor.extract(p.url)
      if features.nil? then
        print "Error while extracting url features from #{p.url}\n"
        p.url_error = true
      else 
      
        p.ip_address_for_hostname = features[:iphost]
        p.num_host_components = features[:nhostcomp]
        p.url_length = features[:uri_length]
        p.hostname_length = features[:hostname_length]
        p.redirects = features[:redirects]
        features[:words].each do |pair|
          wf = p.url_word_frequencies.new
          wf.page = p
          word = Word.find_by_word(pair[:key])
          if word.nil? then
            wf.word = Word.new
            wf.word.word = pair[:key]
            wf.word.save
          else
            wf.word = word
          end
          wf.frequency = pair[:value]
          wf.save
        end
      end
      #extract features from the page
      features = FeatureExtractors::HTMLExtractor.extract(p.url)
      if features.nil? then
        print "Error while extracting html features from #{p.url}\n"
        p.html_error = true
      else
      
        features[:words].each do |pair|
          wf = p.page_word_frequencies.new
          wf.page = p
          word = Word.find_by_word(pair[:key])
          if word.nil? then
            wf.word = Word.new
            wf.word.word = pair[:key]
          else
            wf.word = word
          end
          wf.frequency = pair[:value]
          wf.save
        end

        p.has_password = features[:has_password]
        p.has_iframes  = features[:has_iframes]
        p.outbound_links = features[:outbound]
      end
      
      #extract features from WHOIS information
      features = whois.extract(p.url)
      if features.nil? then
        print "Error while extracting whois features from #{p.url}\n" 
        p.whois_error = true
      else
      
        p.registered_on=features[:created] unless features[:created].nil?
        p.updated_on   =features[:updated] unless features[:updated].nil?
        p.expires_on   =features[:expires] unless features[:expires].nil?
        tld = Tld.find_by_tld(features[:tld])
        if tld.nil? then
          t = Tld.new
          t.tld = features[:tld]
          t.save
          p.tld_id = t.id
        else
          p.tld_id = tld.id
        end
        if features[:registrant] then
           registrant = Registrant.find_by_name(features[:registrant])
           if registrant.nil? then
               p.registrant = Registrant.new
               p.registrant.name = features[:registrant]
           else
               p.registrant = registrant
           end
        end
        if features[:registrar] then
           registrar = Registrar.find_by_name(features[:registrar])
           if registrar.nil? then
               p.registrar = Registrar.new
               p.registrar.name = features[:registrar]
           else
               p.registrar = registrar
           end
        end

        p.ttl             = features[:ttl]
      end
      print "Processed #{p.url}\n"
      p.save
    end
  end until url_str.nil?
end

crawl
