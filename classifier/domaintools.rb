require 'open-uri'

class DomainTools
   class Rule
      def initialize(_type, _str)
         @type = _type
         @str  = _str
      end
      
      def type 
         return @type
      end
      
      def tld
         parts = @str.split('.')
         if @type == :exception then
            i = parts.length -1
         else
            i = parts.length
         end
         return join_labels(parts, Range.new(-i, -1))
      end
      
      def match(hostname)
         h = hostname + '.'
         parts = h.split(@str)
         
         if parts[-1] == '.' then
            return true
            print "Matched rule #{str}\n"
         else
            return false
         end         
      end
      
      def length
         return @str.split('.').length
      end
      
      def normalize(hostname)
         rlabels = @str.split('.')
         hlabels = hostname.split('.')
         for i in 1..hlabels.length do
            break if rlabels[-i] != hlabels[-i]
         end

         #If the prevailing rule is a exception rule, modify it by removing the leftmost label.
         if @type == :exception then
            i = i-1
         end
         
         return join_labels(hlabels, Range.new(-i,-1))
      end
      
      def join_labels(labels, range)
         result = ""
         first = true
         labels[range].each do |label| 
            if first then
               first = false
            else
               result << '.'
            end
            result << label
         end
         return result
      end
   end

   def initialize
      @rules = []
      IO.foreach("effective_tld_names.dat") do |line|
         r = parse line
         @rules << r unless r.nil?      
      end
   end
   
   #converts a hostname to a domain string
   def normalize(hostname)
      #http://publicsuffix.org/format/
      #Match domain against all rules and take note of the matching ones.
      matching_normal = []
      matching_ex = []
      for r in @rules
         if r.match(hostname) then
            if r.type == :normal then
               matching_normal << r
            else
               matching_ex << r
            end
         end
      end
      #If no rules match, the prevailing rule is "*".
      if (matching_normal.length + matching_ex.length) == 0 then
         return {:domain => hostname, :tld => nil}
      end
      #If more than one rule matches, the prevailing rule is the one which is the longest exception rule.
      if (matching_ex.length > 0 ) then
         r = longest_rule(matching_ex) 
         return {:domain => r.normalize(hostname), :tld => r.tld}
      end
      
      #If there is no matching exception rule, the prevailing rule is the one with the most labels.
      if (matching_normal.length > 0 ) then
         r = longest_rule(matching_normal) 
         return {:domain => r.normalize(hostname), :tld => r.tld}
      end
   end
   
   def longest_rule(rules)
      longest = rules[0]
      n = longest.length
      for r in rules do 
         l = r.length
         if l > n then
            longest = r
            n = l
         end
      end
      return longest
   end
   
   def parse(line)
      line.lstrip!
      line.rstrip!
      if line =~ /^\/\/(.*)$/ or line == "" then 
         return nil
      else
         r = Regexp.new("^([*]\.)?(([^*])*)$") 
         m = r.match(line)
         if m then
            return Rule.new(:normal, m[2])
         else
            r = Regexp.new("^!(([^*])*)$")
            m.match(line)
            if m then
               return Rule.new(:exception, m[1])
            else
               return nil
            end
         end
      end
   end
   
   def rules
      return @rules
   end
end
