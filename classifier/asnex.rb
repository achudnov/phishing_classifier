require 'pages'
require 'country_codes'
require 'urlex'
require 'domaintools'
require 'rubygems' if "#{RUBY_VERSION}" < "1.9.0"
require 'net/dns/resolver'
require 'fileutils'

def resolve_asn 
   dt = DomainTools.new
   dns = Net::DNS::Resolver.new(:nameservers => "8.8.8.8")
   ips = []
   ids = []
   pages = Page.find(:all, :conditions => "as_number IS NULL")
   while pages.length > 0 do
        print "Processing #{pages.length} pages\n"
        # for each page
        for page in pages
           #get the host name
           parsed = FeatureExtractors::URLExtractor.parse(page.url)
           if parsed.nil? then
              print "Can't parse the URL for #{page.id}: #{page.url}\n"
              next
           end
           
           hostname = parsed[:hostname]
        
           address = nil
           # get ip address
           begin
                if FeatureExtractors::URLExtractor.is_ip?(hostname) then
                    address = hostname
                else
                     hostname = dt.normalize(hostname)[:domain]
                     print "Attempting to resolve ip for #{hostname}\n"
                     dns.query(hostname).answer.each do |rr|
                        if rr.type == 'A' then
                           address = rr.address.to_s
                           break
                        end
                     end
                end
           rescue
           end
           
           if address.nil? then
              print "Can't resolve ip address for #{page.id}: #{page.url}\n"
              next
           end
           
           ips << address
           ids << page.id
        end
        
        asns = request_asns(ids, ips)
        for asn in asns do
          page = Page.find_by_id(asn[:id])
          page.as_number = asn[:asn]
          cc=CountryCode.find_by_code(asn[:cc])
          if cc.nil? then
             cc = CountryCode.new
             cc.code = asn[:cc]
             cc.save
          end
          page.country_code = cc
          page.save
        end
        pages = Page.find(:all, :conditions => "as_number IS NULL")
   end
   print "Done\n"
end

def request_asns(ids, ips)
   rq = "begin\nverbose\nheader\n"
   for ip in ips do
      rq << ip << "\n"
   end
   rq << "end\n"
   
   FileUtils.rm_f("query.tmp")
   FileUtils.rm_f("answer.tmp")
   File.open("query.tmp", "w") do |f|
     f.write rq
   end
   
   print "netcat whois.cymru.com 43 < query.tmp > answer.tmp\n"   
   system "netcat whois.cymru.com 43 < query.tmp > answer.tmp"
   print "executed request\n"
   
   asns = []
   File.open("answer.tmp", "r") do |anf|
        anf.readline
        ip_asns = []
        anf.each do |line|
            parsed = parse line
            ip_asns << parsed unless parsed.nil?
        end

        for i in ip_asns do
            index =  ips.index i[:ip]
            ips.delete_at index
            id = ids[index]
            ids.delete_at index
            asns << {:id => id, :asn => i[:asn], :cc => i[:cc]}
        end
   end
   return asns
end

def parse(line)
   r = Regexp.new('^(\d*)(\s*)[|](\s*)(\d*[.]\d*[.]\d*[.]\d*)(\s*)[|]([^|]*)[|](\s*)(\w*)(\s*)[|](.*)$')
   m = r.match(line)
   if m.nil? then
      return nil
   else
      return {:ip => m[4], :asn => m[1], :cc => m[8]}
   end
end

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => '',
  :username => '',
  :password => '',
  :host     => '')

resolve_asn
