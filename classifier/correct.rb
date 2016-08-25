IO.foreach("sample_dataset100") do |l|
 if l[0] == ("true"[0]) then
    print("1"+l[Range.new(4,l.length-1)].sub(/304437:(.*)/, ""))
 else
    print("0"+l[Range.new(5,l.length-1)].sub(/304437:(.*)/, ""))
 end
end

