.PHONY: sim grade-parta grade-partb grade-partc clean

sim:
	(cd sim; make)

grade-parta:
	./grader/grade-archlaba.pl

grade-partb:
	./grader/grade-archlabb.pl

grade-partc:
	./grader/grade-archlabc.pl

clean:
	rm -f *~ *.o



