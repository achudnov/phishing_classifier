module TextTools
public
   def TextTools.words(string)
      if string.nil? then
         return []
      else
         return string.split(/\W/)
      end
   end
   
   def TextTools.word_freq(words)
      dict = Dictionary.new
      n = 0
      words.each do |w|
         if w!="" then
            n=n+1
            dict_increment(dict, w)
         end
      end
      compute_frequencies(dict, n)
      return dict
   end
   
   def TextTools.dict_increment(dictionary, word)
      count = dictionary.lookup(word)
      if count.nil? then
         dictionary.add(word, 1.0)
      else
         dictionary.add(word,count+1)
      end
   end
   
   def TextTools.compute_frequencies(dictionary, n)
      dictionary.each do |pair| 
         pair[:value] = pair[:value]/n
      end
   end

class Dictionary
   def initialize
      @dictionary = []
   end

   def lookup(key)
      @dictionary.each do |pair| 
         return pair[:value] if pair[:key]==key
      end
      return nil
   end

   def add(key, value)
      @dictionary.each do |pair| 
         if pair[:key]==key then
            pair[:value] = value
            return
         end
      end      
      @dictionary << {:key=>key, :value=>value}
      return
   end
   
   def remove(key)
      value = lookup(key)
      if value then 
         @dictionary.delete({:key=>key, :value=>value})
      end
   end
   
   def each(&code)
      @dictionary.each do |pair|
         code.call(pair)      
      end
   end
end

end
