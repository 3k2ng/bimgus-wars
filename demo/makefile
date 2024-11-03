ALL = title_screen.prg

all: clean export_dir $(ALL)

export_dir:
	mkdir export

title_screen.prg: ./title_screen_zx02.s
	dasm $< -oexport/_$@ -lexport/$(<:.s=.lst)

clean:
	rm -rf ./export