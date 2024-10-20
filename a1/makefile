SOURCE = $(wildcard *.s)
OUTPUT = $(patsubst %.s,%.prg,$(SOURCE))

all: $(OUTPUT)

%.prg: %.s
	dasm $< -o_$@ -l$(<:.s=.lst)

clean: 
	$(RM) *.prg *.lst
