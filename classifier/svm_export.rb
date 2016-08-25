require 'pages'
require 'words'
require 'page_word_frequencies'
require 'url_word_frequencies'
require 'fileutils'

EXPORT_WORDS = true
FILE_PREFIX = "unopt1200t200r"
NTRAINING = 600
NTESTING = 100

class SvmExport
def initialize
     @n = 0
     @s = 0
end
def print_word_frequencies(wfs, words)
  nwords = words.length
  i = 1
  j = 0
  if wfs.nil? then
    word_freqs = []
  else
    if wfs.length == 0 then
      word_freqs = []
    else
      if wfs[0].instance_of? UrlWordFrequency then
        word_freqs = UrlWordFrequency.find(:all, 
                                             :conditions => "page_id = #{wfs[0].page_id}",
                                             :order => "word_id ASC" )
        
      else                                     
        word_freqs = PageWordFrequency.find(:all, 
                                              :conditions => "page_id = #{wfs[0].page_id}",
                                              :order => "word_id ASC" )
      end                                       
    end
  end
  while i<= nwords do
     @s << @n.to_s << ":"
     if !word_freqs[j].nil? then
        if i == word_freqs[j].word_id then
           @s << word_freqs[j].frequency.to_s << " "
           j = j+1
        else
           @s << "0 "
        end
     else
        @s << "0 "
     end
     @n = @n+1
     i = i+1
  end
end

def print_single_feature(feature)
  @s << @n.to_s << ":"
  if feature.nil? then 
    @s << "0 "
  else
    f = feature
    f = 1 if f == true
    f = 0 if f == false
   
    @s << f.to_s << " "
  end
  @n = @n+1
end

def inverse(i)
  return 1.0/Float(i)
end

def date_to_int(date)
  if date.nil? then
    return 0
  else
    return (
      date.yday +
      (date.year-1985)*(366) # the first commercial domain name was registered in 1985
    )  
  end  
end

def normalize(n, min, max)
     return (Float(n)/(Float(max)-Float(min)))
end

def print_page_features(p, np)
  # libsvm line format:
  # <label> <index>:<value> ... <index:value>
  #label
  if p.phishing == true then
    @s << "1 "
  else
    @s << "0 "
  end
  
  @n=1
  # ip address of host name
  print_single_feature(p.ip_address_for_hostname)
  # number of host components
  print_single_feature(normalize(p.num_host_components,np[:nhc_min],np[:nhc_max]))
  # url length
  print_single_feature(normalize(p.url_length,np[:urllen_min],np[:urllen_max]))
  # host name length
  print_single_feature(normalize(p.hostname_length,np[:hnlen_min],np[:hnlen_max]))
  # does it redirect?
  print_single_feature(p.redirects)
  
  if EXPORT_WORDS then
       # url word frequencies
       print_word_frequencies(p.url_word_frequencies)
       # page word frequencies
       print_word_frequencies(p.page_word_frequencies)
  end
  
  # does it have a password  
  print_single_feature(p.has_password)
  # does it have iframes
  print_single_feature(p.has_iframes)
  # percentage of links that are outbound
  print_single_feature(p.outbound_links)
  print_single_feature(normalize(date_to_int(p.registered_on),
                                 date_to_int(np[:registered_min]),
                                 date_to_int(np[:registered_max])))
  print_single_feature(normalize(date_to_int(p.updated_on),
                                 date_to_int(np[:updated_min]),
                                 date_to_int(np[:updated_max])))
  print_single_feature(normalize(date_to_int(p.expires_on),
                                 date_to_int(np[:registered_min]),
                                 date_to_int(np[:regsitered_max])))
  
  if !p.tld.nil? then 
    print_single_feature(normalize(p.tld_id,np[:tld_min],np[:tld_max]))
  else
    print_single_feature(0)
  end
#  if !p.registrant.nil? then
#    print_single_feature(p.registrant_id)
#  else
#    print_single_feature(0)
#  end
#  if !p.registrar.nil? then
#    print_single_feature(p.registrar_id)
#  else
#    print_single_feature(0)
#  end
  if !p.ttl.nil? then
     print_single_feature(normalize(p.ttl,np[:ttl_min],np[:ttl_max]))
  else
     print_single_feature(0)
  end
  if !p.as_number.nil? then
       print_single_feature(normalize(p.as_number,np[:asn_min],np[:asn_max]))
  else
       print_single_feature(0)
  end
  if !p.country_code_id.nil? then
      print_single_feature(normalize(p.country_code_id,np[:cc_min],np[:cc_max]))
  else
      print_single_feature(0)
  end  

  #newline
  @s << "\n"
end

def print_features(pages,np)
    @s = ""
    
    for p in pages do
        print_page_features(p,np)
    end
    
    return @s
end

end


def normalization_params(pages)
    # compute ranges for normalization
    i = 0
    while pages[i].registered_on.nil? do i=i+1 end
    registered_max = pages[i].registered_on
    registered_min = pages[i].registered_on 
    i=0
    while pages[i].updated_on.nil? do i=i+1 end
    updated_max = pages[i].updated_on
    updated_min = pages[i].updated_on
    i=0
    while pages[i].expires_on.nil? do i=i+1 end    
    expires_max = pages[0].expires_on
    expires_min = pages[0].expires_on
    i=0
    while pages[i].ttl.nil? do i=i+1 end
    ttl_max     = pages[i].ttl
    ttl_min     = pages[i].ttl
    asn_max     = pages[0].as_number
    asn_min     = pages[0].as_number
    nhc_max     = pages[0].num_host_components
    nhc_min     = pages[0].num_host_components
    urllen_max  = pages[0].url_length
    urllen_min  = pages[0].url_length
    hnlen_max   = pages[0].hostname_length
    hnlen_min   = pages[0].hostname_length
    cc_max      = pages[0].country_code_id
    cc_min      = pages[0].country_code_id
    i=0
    while pages[i].tld_id.nil? do i=i+1 end
    tld_max     = pages[i].tld_id
    tld_min     = pages[i].tld_id
    
    for p in pages do
        if !p.registered_on.nil? then
            registered_max = p.registered_on if registered_max < p.registered_on
            registered_min = p.registered_on if registered_min > p.registered_on
        end
        if !p.updated_on.nil? then
            updated_max = p.updated_on if updated_max < p.updated_on
            updated_min = p.updated_on if updated_min > p.updated_on
        end
        if !p.ttl.nil? then
            ttl_max = p.ttl if ttl_max < p.ttl
            ttl_min = p.ttl if ttl_min > p.ttl
        end
        if !p.as_number.nil? then
            asn_max = p.as_number if asn_max < p.as_number
            asn_min = p.as_number if asn_min > p.as_number
        end
        if !p.num_host_components.nil? then
            nhc_max = p.num_host_components if nhc_max < p.num_host_components
            nhc_min = p.num_host_components if nhc_min > p.num_host_components
        end
        if !p.url_length.nil? then
            urllen_max = p.url_length if urllen_max < p.url_length
            urllen_min = p.url_length if urllen_min > p.url_length
        end        
        if !p.hostname_length.nil? then
            hnlen_max = p.hostname_length if hnlen_max < p.hostname_length
            hnlen_min = p.hostname_length if hnlen_min > p.hostname_length
        end    
        if !p.country_code_id.nil? then
            cc_max = p.country_code_id if cc_max < p.country_code_id
            cc_min = p.country_code_id if cc_min > p.country_code_id
        end
        if !p.tld_id.nil? then
            tld_max = p.tld_id if tld_max < p.tld_id
            tld_min = p.tld_id if tld_min > p.tld_id
        end    
    end
    
    np = {
      :registered_max => registered_max,
      :registered_min => registered_min,
      :updated_max => updated_max,
      :updated_min => updated_min,
      :expires_max => expires_max,
      :expires_min => expires_min,
      :ttl_max     => ttl_max,
      :ttl_min     => ttl_min,
      :asn_max     => asn_max,
      :asn_min     => asn_min,
      :nhc_max     => nhc_max,
      :nhc_min     => nhc_min,
      :urllen_max  => urllen_max,
      :urllen_min  => urllen_min,
      :hnlen_max   => hnlen_max,
      :hnlen_min   => hnlen_min,
      :cc_max      => cc_max,
      :cc_min      => cc_min,
      :tld_max     => tld_max,
      :tld_min     => tld_min
    }
    return np
end

ActiveRecord::Base.establish_connection(
  :adapter  => 'mysql',
  :database => '',
  :username => '',
  :password => '',
  :host     => '')

exp = SvmExport.new

phish = Page.find(:all, 
                  :conditions => '((html_error or whois_error or url_error) != true) and (as_number is not null) and (tld_id is not null) and (phishing=1)',
                  :order => "rand()",
                  :limit => (NTRAINING+NTESTING))
                  
benign = Page.find(:all, 
                   :conditions => '((html_error or whois_error or url_error) != true) and (as_number is not null) and (tld_id is not null) and (phishing=0)',
                   :order => "rand()",
                   :limit => (NTRAINING+NTESTING))
                   
np = normalization_params(benign+phish)
                   
training = phish[Range.new(0,NTRAINING-1)] + benign[Range.new(0,NTRAINING-1)]

testing = phish[Range.new(NTRAINING,NTRAINING+NTESTING-1)] + benign[Range.new(NTRAINING,NTRAINING+NTESTING-1)]


FileUtils.rm_f(FILE_PREFIX+"-training.dat")
File.open(FILE_PREFIX + "-training.dat", "w") do |f|
     f.write(exp.print_features(training,np))
end

FileUtils.rm_f(FILE_PREFIX+"-testing.dat")
File.open(FILE_PREFIX + "-testing.dat", "w") do |f|
     f.write(exp.print_features(testing,np))
end
