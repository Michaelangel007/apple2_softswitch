all: test.lc

test.lc: test.lc.s
	merlin32 $<

