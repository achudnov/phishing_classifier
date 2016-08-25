require 'urlex' 
require 'domaintools'
require 'rubygems' if "#{RUBY_VERSION}" < "1.9.0"
require 'whois'
require 'net/dns/resolver'

module FeatureExtractors

class WHOISExtractor
   def initialize
      @dt = DomainTools.new
   end


   # extract WHOIS features from a domain in the uri
   # except for the AS number
   def extract(uri)
      parsed = URLExtractor.parse(uri)
      return nil if parsed.nil?
      hostname = parsed[:hostname]
      return nil if hostname.nil?
      
      domaintld = to_domain(hostname)
      domain = domaintld[:domain]
      
      ttl = 0
      begin
         Resolver(hostname).answer.each do |rr|
            if rr.type == 'A' then
               ttl = rr.ttl
            end
         end
          
         c = Whois::Client.new(:timeout => 60)
         a = c.query(domain).properties
         return {
            :created => (a[:created_on]), #DateTime: creation date
            :updated => (a[:updated_on]), #DateTime: update date
            :expires => (a[:expires_on]), #DateTime: expiration date
            :tld => (domaintld[:tld]), #String: top-level domain
            :registrant => (a[:registrant].to_s), #String: registrant's name
            :registrar => (a[:registrar].to_s), #String: registrar's name
            :ttl => ttl #UInt: DNS A record time-to-live
         }         
      rescue => e
         return nil
      rescue Timeout::Error => e
         return nil
      end         
      
  end
  
  def to_domain(hostname)
    if URLExtractor.is_ip?(hostname) then
      return hostname
    else
      return @dt.normalize(hostname)
    end
  end
end
end
