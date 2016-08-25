require 'texttools'
require 'rubygems'
require 'httpclient'


module FeatureExtractors

module URLExtractor
   # extracts features from String a uri
   # returns an associative array of features
   # or throws an exception
   def URLExtractor.extract(uri)
      parsed_uri = parse uri
      return nil if parsed_uri.nil?
      
      hostname = parsed_uri[:hostname]
      path = parsed_uri[:path]
          
      
      
      return {
         :iphost => (is_ip? hostname), #bool: ip for hostname?
         :nhostcomp => (num_host_components hostname), #uint: number of host components
         :words => (TextTools.word_freq(TextTools.words(hostname)+TextTools.words(path))), #Dictionary: frequencies of words
         :uri_length => uri.length, #uint: length of the uri
         :hostname_length => hostname.length, #length of the hostname
         :redirects => (redirects? uri) #bool: does the server redirect?
      } 
   end
   
   def URLExtractor.parse(uri)
      r = Regexp.new("http:\/\/(([a-z0-9.]|\-)*)(\/(.*))?")
     	m = r.match(uri)
     	if (m != nil) then
  	   	return {:hostname=>m[1],:path=>m[4]}
  	   else 
  	   	return nil   
  	   end
   end
   
   def URLExtractor.is_ip?(hostname)
      if hostname =~ /((\d*)\.){3}(\d*)/ then return true
      else return false end
   end
   
   def URLExtractor.num_host_components(hostname)
      return hostname.split('.').length
   end
   
   
   
   def URLExtractor.redirects?(url)
      begin
           http = HTTPClient.new
           code = http.get(url).status_code
           if [301,302,307].include?(code) then
              return true
           else
              return false
           end
      rescue
          return false
      end
   end
   
   # see GareraProvos07
   #def url_type(url)
   #   if is_ip?(url) then
   #      return 1
   #   else if
   #end
end
end
