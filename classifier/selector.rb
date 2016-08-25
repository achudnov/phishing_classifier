c=0.03125
for i in 1..20
   print "time ./train -s 2 -c #{c} -e 0.01 -v 5 unopt1200t200r-training.dat"
   system "time ./train -s 2 -c #{c} -e 0.01 -v 5 unopt1200t200r-training.dat"
   c=c*2
end
