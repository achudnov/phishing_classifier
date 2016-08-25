require 'pages'
require 'tlds'
require 'urlex'
require 'domaintools'
require 'rubygems' if "#{RUBY_VERSION}" < "1.9.0"
require 'net/dns/resolver'
require 'tempfile'

def fix_tlds 
     dt = DomainTools.new
     for page in Page.find(:all, :conditions => "tld_id is null") do
          r = FeatureExtractors::URLExtractor.parse(page.url)
          next if r.nil?
          hostname = r[:hostname]
          next if hostname.nil?
          if FeatureExtractors::URLExtractor.is_ip?(hostname) then
             page.tld_id = 1
          else
             tld = dt.normalize(hostname)[:tld]
             if tld.nil? then
               page.tld_id = 1
             else
               t = Tld.find_by_tld(tld)
               if t.nil? then
                  t=Tld.new
                  t.tld = tld
                  t.save
               end
               page.tld_id = t.id
             end
          end
          page.save
     end
end

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => '',
  :username => '',
  :password => '',
  :host     => '')

fix_tlds
