SOURCE = $(wildcard *.s)
OUTPUT = $(patsubst %.s,%.prg,$(SOURCE))

all: export_dir $(OUTPUT)

export_dir:
	mkdir export

%.prg: %.s
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean: 
	$(RM) -rf export
